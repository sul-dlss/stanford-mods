require 'mods/marc_country_codes'

module Stanford
  module Mods
    ##
    # Get the imprint information from originInfo elements (and sub elements) to create display strings
    #
    # This code is adapted from the mods_display gem.  In a perfect world, this
    # code would make use of the date_parsing class instead of reimplementing pieces of it;
    # however, the date_parsing class only does years, and this does finer tuned dates and also
    # reformats them according to the encoding.
    class Imprint
      attr_reader :element

      # @param [Nokogiri::XML::Node] an originInfo node
      def initialize(element)
        @element = element
      end

      def imprint_statements
        display_str
      end

      # @return <String> an imprint statement from a single originInfo element
      def display_str
        edition = edition_vals_str
        place = place_vals_str
        publisher = publisher_vals_str
        dates = date_str

        place_pub = compact_and_join_with_delimiter([place, publisher], ' : ')
        edition_place_pub = compact_and_join_with_delimiter([edition, place_pub], ' - ')
        ed_place_pub_dates = compact_and_join_with_delimiter([edition_place_pub, dates], ', ')

        ed_place_pub_dates
      end

      # @return Array<Integer> an array of publication years for the resource
      def publication_date_for_slider
        date_elements = if element.as_object.first.key_dates.any?
                          element.as_object.first.key_dates.map(&:as_object).map(&:first)
                        else
                          date_field_keys.map do |date_field|
                            next unless element.respond_to?(date_field)

                            date_elements = element.send(date_field)
                            date_elements.map(&:as_object).map(&:first) if date_elements.any?
                          end.compact.first
                        end

        dates = if date_elements.nil? || date_elements.none?
          []
        elsif date_elements.find(&:start?) &&
              date_elements.find(&:start?).as_range &&
              date_elements.find(&:end?) &&
              date_elements.find(&:end?).as_range
          start_date = date_elements.find(&:start?)
          end_date = date_elements.find(&:end?)

          (start_date.as_range.min.year..end_date.as_range.max.year).to_a
        elsif date_elements.find(&:start?) && date_elements.find(&:start?).as_range
          start_date = date_elements.find(&:start?)

          (start_date.as_range.min.year..Time.now.year).to_a
        elsif date_elements.one?
          date_elements.first.to_a.map(&:year)
        else
          date_elements.map { |v| v.to_a.map(&:year) }
        end

        dates.flatten
      end

      private

      def extract_year(el)
        DateParsing.new(el.text).year_int_from_date_str
      end

      def compact_and_join_with_delimiter(values, delimiter)
        compact_values = values.compact.reject { |v| v.strip.empty? }
        return compact_values.join(delimiter) if compact_values.length == 1 ||
                                                 !ends_in_terminating_punctuation?(delimiter)

        compact_values.each_with_index.map do |value, i|
          if (compact_values.length - 1) == i || # last item?
             ends_in_terminating_punctuation?(value)
            value << ' '
          else
            value << delimiter
          end
        end.join.strip
      end

      def ends_in_terminating_punctuation?(value)
        value.strip.end_with?('.', ',', ':', ';')
      end

      def edition_vals_str
        element.edition.reject do |e|
          e.text.strip.empty?
        end.map(&:text).join(' ').strip
      end

      def publisher_vals_str
        return if element.publisher.text.strip.empty?

        publishers = element.publisher.reject do |p|
          p.text.strip.empty?
        end.map(&:text)
        compact_and_join_with_delimiter(publishers, ' : ')
      end

      # PLACE processing methods ------

      def place_vals_str
        return if element.place.text.strip.empty?

        places = place_terms.reject do |p|
          p.text.strip.empty?
        end.map(&:text)
        compact_and_join_with_delimiter(places, ' : ')
      end

      def unencoded_place_terms?(element)
        element.place.placeTerm.any? do |term|
          !term.attributes['type'].respond_to?(:value) ||
            term.attributes['type'].value == 'text'
        end
      end

      def place_terms
        return [] unless element.respond_to?(:place) &&
                         element.place.respond_to?(:placeTerm)

        if unencoded_place_terms?(element)
          element.place.placeTerm.select do |term|
            !term.attributes['type'].respond_to?(:value) ||
              term.attributes['type'].value == 'text'
          end.compact
        else
          element.place.placeTerm.map do |term|
            next unless term.attributes['type'].respond_to?(:value) &&
                        term.attributes['type'].value == 'code' &&
                        term.attributes['authority'].respond_to?(:value) &&
                        term.attributes['authority'].value == 'marccountry' &&
                        !['xx', 'vp'].include?(term.text.strip) &&
                        MARC_COUNTRY.include?(term.text.strip)

            term = term.clone
            term.content = MARC_COUNTRY[term.text.strip]
            term
          end.compact
        end
      end

      # DATE processing methods ------

      def date_str
        date_vals = origin_info_date_vals
        return if date_vals.empty?

        date_vals.map(&:strip).join(' ')
      end

      def origin_info_date_vals
        date_field_keys.map do |date_field|
          next unless element.respond_to?(date_field)

          date_elements = element.send(date_field)
          date_elements_display_vals(date_elements) if date_elements.present?
        end.compact.flatten
      end

      def date_elements_display_vals(ng_date_elements)
        apply_date_qualifier_decoration(
          dedup_dates(
            join_date_ranges(
              process_decade_century_dates(
                process_bc_ad_dates(
                  process_encoded_dates(ignore_bad_dates(ng_date_elements))
                )
              )
            )
          )
        )
      end

      def date_field_keys
        [:dateIssued, :dateCreated, :dateCaptured, :copyrightDate]
      end

      def ignore_bad_dates(ng_date_elements)
        ng_date_elements.select do |ng_date_element|
          val = ng_date_element.text.strip
          val != '9999' && val != '0000-00-00' && val != 'uuuu'
        end
      end

      def process_encoded_dates(ng_date_elements)
        ng_date_elements.map do |ng_date_element|
          if date_is_w3cdtf?(ng_date_element)
            process_w3cdtf_date(ng_date_element)
          elsif date_is_iso8601?(ng_date_element)
            process_iso8601_date(ng_date_element)
          else
            ng_date_element
          end
        end
      end

      # note that there is no year 0:  from https://en.wikipedia.org/wiki/Anno_Domini
      # "AD counting years from the start of this epoch, and BC denoting years before the start of the era.
      # There is no year zero in this scheme, so the year AD 1 immediately follows the year 1 BC."
      # See also https://consul.stanford.edu/display/chimera/MODS+display+rules for etdf
      def process_bc_ad_dates(ng_date_elements)
        ng_date_elements.map do |ng_date_element|
          case
          when date_is_edtf?(ng_date_element) && ng_date_element.text.strip == '0'
            ng_date_element.content = "1 B.C."
          when date_is_bc_edtf?(ng_date_element)
            year = ng_date_element.text.strip.gsub(/^-0*/, '').to_i + 1
            ng_date_element.content = "#{year} B.C."
          when date_is_ad?(ng_date_element)
            ng_date_element.content = "#{ng_date_element.text.strip.gsub(/^0*/, '')} A.D."
          end
          ng_date_element
        end
      end

      def process_decade_century_dates(ng_date_elements)
        ng_date_elements.map do |ng_date_element|
          if date_is_decade?(ng_date_element)
            process_decade_date(ng_date_element)
          elsif date_is_century?(ng_date_element)
            process_century_date(ng_date_element)
          else
            ng_date_element
          end
        end
      end

      def join_date_ranges(ng_date_elements)
        if dates_are_range?(ng_date_elements)
          start_date = ng_date_elements.find { |d| d.attributes['point'] && d.attributes['point'].value == 'start' }
          end_date = ng_date_elements.find { |d| d.attributes['point'] && d.attributes['point'].value == 'end' }
          ng_date_elements.map do |date|
            date = date.clone # clone the date object so we don't append the same one
            if normalize_date(date.text) == normalize_date(start_date.text)
              date.content = [start_date.text, end_date.text].join(' - ')
              date
            elsif normalize_date(date.text) != normalize_date(end_date.text)
              date
            end
          end.compact
        elsif dates_are_open_range?(ng_date_elements)
          start_date = ng_date_elements.find { |d| d.attributes['point'] && d.attributes['point'].value == 'start' }
          ng_date_elements.map do |date|
            date = date.clone # clone the date object so we don't append the same one
            date.content = "#{start_date.text}-" if date.text == start_date.text
            date
          end
        else
          ng_date_elements
        end
      end

      def dedup_dates(ng_date_elements)
        date_text = ng_date_elements.map { |d| normalize_date(d.text) }
        if date_text != date_text.uniq
          if ng_date_elements.find { |d| d.attributes['qualifier'].respond_to?(:value) }
            [ng_date_elements.find { |d| d.attributes['qualifier'].respond_to?(:value) }]
          elsif ng_date_elements.find { |d| !d.attributes['encoding'] }
            [ng_date_elements.find { |d| !d.attributes['encoding'] }]
          else
            [ng_date_elements.first]
          end
        else
          ng_date_elements
        end
      end

      def apply_date_qualifier_decoration(ng_date_elements)
        return_fields = ng_date_elements.map do |date|
          date = date.clone
          if date_is_approximate?(date)
            date.content = "[ca. #{date.text}]"
          elsif date_is_questionable?(date)
            date.content = "[#{date.text}?]"
          elsif date_is_inferred?(date)
            date.content = "[#{date.text}]"
          end
          date
        end
        return_fields.map(&:text)
      end

      def date_is_approximate?(ng_date_element)
        ng_date_element.attributes['qualifier'] &&
          ng_date_element.attributes['qualifier'].respond_to?(:value) &&
          ng_date_element.attributes['qualifier'].value == 'approximate'
      end

      def date_is_questionable?(ng_date_element)
        ng_date_element.attributes['qualifier'] &&
          ng_date_element.attributes['qualifier'].respond_to?(:value) &&
          ng_date_element.attributes['qualifier'].value == 'questionable'
      end

      def date_is_inferred?(ng_date_element)
        ng_date_element.attributes['qualifier'] &&
          ng_date_element.attributes['qualifier'].respond_to?(:value) &&
          ng_date_element.attributes['qualifier'].value == 'inferred'
      end

      def dates_are_open_range?(ng_date_elements)
        ng_date_elements.any? do |element|
          element.attributes['point'] &&
            element.attributes['point'].respond_to?(:value) &&
            element.attributes['point'].value == 'start'
        end && !ng_date_elements.any? do |element|
          element.attributes['point'] &&
            element.attributes['point'].respond_to?(:value) &&
            element.attributes['point'].value == 'end'
        end
      end

      def dates_are_range?(ng_date_elements)
        attributes = ng_date_elements.map do |date|
          if date.attributes['point'].respond_to?(:value)
            date.attributes['point'].value
          end
        end
        attributes.include?('start') &&
          attributes.include?('end')
      end

      def process_w3cdtf_date(ng_date_element)
        ng_date_element = ng_date_element.clone
        ng_date_element.content = begin
          if ng_date_element.text.strip =~ /^\d{4}-\d{2}-\d{2}$/
            Date.parse(ng_date_element.text).strftime(full_date_format)
          elsif ng_date_element.text.strip =~ /^\d{4}-\d{2}$/
            Date.parse("#{ng_date_element.text}-01").strftime(short_date_format)
          else
            ng_date_element.content
          end
                                  rescue
                                    ng_date_element.content
        end
        ng_date_element
      end

      def process_iso8601_date(ng_date_element)
        ng_date_element = ng_date_element.clone
        ng_date_element.content = begin
          if ng_date_element.text.strip =~ /^\d{8,}$/
            Date.parse(ng_date_element.text).strftime(full_date_format)
          else
            ng_date_element.content
          end
                                  rescue
                                    ng_date_element.content
        end
        ng_date_element
      end

      DECADE_4CHAR_REGEXP = Regexp.new('(^|.*\D)(\d{3}[u\-?x])(.*)')

      # strings like 195x, 195u, 195- and 195?  become '1950s' in the ng_date_element content
      def process_decade_date(ng_date_element)
        my_ng_date_element = ng_date_element.clone
        my_ng_date_element.content = begin
          orig_date_str = ng_date_element.text.strip
          # note:  not calling DateParsing.display_str_for_decade directly because non-year text is lost
          decade_matches = orig_date_str.match(DECADE_4CHAR_REGEXP) if orig_date_str
          if decade_matches
            decade_str = decade_matches[2]
            changed_to_zero = decade_str.to_s.tr('u\-?x', '0') if decade_str
            zeroth_year = DateParsing.new(changed_to_zero).sortable_year_for_yyyy if changed_to_zero
            new_decade_str = "#{zeroth_year}s" if zeroth_year
            my_ng_date_element.content = "#{decade_matches[1]}#{new_decade_str}#{decade_matches[3]}"
          else
            my_ng_date_element.content
          end
                                     rescue
                                       my_ng_date_element.content
        end
        my_ng_date_element
      end

      CENTURY_4CHAR_REGEXP = Regexp.new('(^|.*\D)((\d{1,2})[u\-]{2})(.*)')

      # strings like 18uu, 18-- become '19th century' in the ng_date_element content
      def process_century_date(ng_date_element)
        my_ng_date_element = ng_date_element.clone
        my_ng_date_element.content = begin
          orig_date_str = ng_date_element.text.strip
          # note:  not calling DateParsing.display_str_for_century directly because non-year text is lost
          century_matches = orig_date_str.match(CENTURY_4CHAR_REGEXP) if orig_date_str
          if century_matches
            new_century_str = "#{(century_matches[3].to_i + 1).ordinalize} century"
            my_ng_date_element.content = "#{century_matches[1]}#{new_century_str}#{century_matches[4]}"
          else
            my_ng_date_element.content
          end
                                     rescue
                                       my_ng_date_element.content
        end
        my_ng_date_element
      end

      def field_is_encoded?(ng_element, encoding)
        ng_element.attributes['encoding'] &&
          ng_element.attributes['encoding'].respond_to?(:value) &&
          ng_element.attributes['encoding'].value.downcase == encoding
      end

      def date_is_bc_edtf?(ng_date_element)
        ng_date_element.text.strip.start_with?('-') && date_is_edtf?(ng_date_element)
      end

      def date_is_ad?(ng_date_element)
        str = ng_date_element.text.strip.gsub(/^0*/, '')
        str.present? && str.length < 4 && !str.match('A.D.')
      end

      def date_is_edtf?(ng_date_element)
        field_is_encoded?(ng_date_element, 'edtf')
      end

      def date_is_w3cdtf?(ng_date_element)
        field_is_encoded?(ng_date_element, 'w3cdtf')
      end

      def date_is_iso8601?(ng_date_element)
        field_is_encoded?(ng_date_element, 'iso8601')
      end

      # @return true if decade string needs tweaking for display
      def date_is_decade?(ng_date_element)
        ng_date_element.text.strip.match(DECADE_4CHAR_REGEXP)
      end

      # @return true if century string needs tweaking for display
      def date_is_century?(ng_date_element)
        ng_date_element.text.strip.match(CENTURY_4CHAR_REGEXP)
      end

      def full_date_format(full_date_format = '%B %-d, %Y')
        @full_date_format ||= full_date_format
      end

      def short_date_format(short_date_format = '%B %Y')
        @short_date_format ||= short_date_format
      end

      def normalize_date(date_str)
        date_str.strip.gsub(/^\[*ca\.\s*|c|\[|\]|\?/, '')
      end
    end
  end
end
