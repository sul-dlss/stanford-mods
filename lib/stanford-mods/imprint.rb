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

      private

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
          parse_dates(date_elements) if date_elements.present?
        end.compact.flatten
      end

      def date_field_keys
        [:dateIssued, :dateCreated, :dateCaptured, :copyrightDate]
      end

      class DateValue
        attr_reader :value
        delegate :text, :date, :point, :qualifier, :encoding, to: :value

        def initialize(value)
          @value = value
        end

        # True if the element text isn't blank or the placeholder "9999".
        def valid?
          text.present? && !['9999', '0000-00-00', 'uuuu'].include?(text.strip)
        end

        # Element text reduced to digits and hyphen. Captures date ranges and
        # negative (BCE) dates. Used for comparison/deduping.
        def base_value
          if text =~ /^\[?1\d{3}-\d{2}\??\]?$/
            return text.sub(/(\d{2})(\d{2})-(\d{2})/, '\1\2-\1\3')
          end

          text.gsub(/(?<![\d])(\d{1,3})([xu-]{1,3})/i) { "#{$1}#{'0' * $2.length}"}.scan(/[\d-]/).join
        end

        # Decoded version of the date, if it was encoded. Strips leading zeroes.
        def decoded_value
          return text.strip unless date

          unless encoding.present?
            return text.strip unless text =~ /^-?\d+$/ || text =~ /^[\dXxu?-]{4}$/
          end

          if date.is_a?(EDTF::Interval)
            if value.precision == :century || value.precision == :decade
              return format_date(date, value.precision)
            end

            range = [
              format_date(date.min, date.min.precision),
              format_date(date.max, date.max.precision)
            ].uniq.compact

            return text.strip if range.empty?

            range.join(' - ')
          else
            format_date(date, value.precision) || text.strip
          end
        end

        def format_date(date, precision)
          case precision
          when :day
            date.strftime('%B %e, %Y')
          when :month
            date.strftime('%B %Y')
          when :year
            year = date.year
            if year < 1
              "#{year.abs + 1} BCE"
            # Any dates before the year 1000 are explicitly marked CE
            elsif year > 1 && year < 1000
              "#{year} CE"
            else
              year.to_s
            end
          when :century
            if date.year.negative?
              "#{((date.year / 100).abs + 1).ordinalize} century BCE"
            else
              "#{((date.year / 100) + 1).ordinalize} century"
            end
          when :decade
            "#{date.year}s"
          end
        end

        # Decoded date with "BCE" or "CE" and qualifier markers. See (outdated):
        # https://consul.stanford.edu/display/chimera/MODS+display+rules#MODSdisplayrules-3b.%3CoriginInfo%3E
        def qualified_value
          qualified_format = case qualifier
          when 'approximate'
            '[ca. %s]'
          when 'questionable'
            '[%s?]'
          when 'inferred'
            '[%s]'
          else
            '%s'
          end

          format(qualified_format, decoded_value)
        end
      end

      class DateRange
        def initialize(start: nil, stop: nil)
          @start = start
          @stop = stop
        end

        # Base value as hyphen-joined string. Used for comparison/deduping.
        def base_value
          "#{@start&.base_value}-#{@stop&.base_value}"
        end

        # Base values as array. Used for comparison/deduping of individual dates.
        def base_values
          [@start&.base_value, @stop&.base_value].compact
        end

        # The encoding value for the start of the range, or stop if not present.
        def encoding
          @start&.encoding || @stop&.encoding
        end

        # Decoded dates with "BCE" or "CE" and qualifier markers applied to
        # the entire range, or individually if dates differ.
        def qualified_value
          if @start&.qualifier == @stop&.qualifier
            qualifier = @start&.qualifier || @stop&.qualifier
            date = "#{@start&.decoded_value} - #{@stop&.decoded_value}"
            return "[ca. #{date}]" if qualifier == 'approximate'
            return "[#{date}?]" if qualifier == 'questionable'
            return "[#{date}]" if qualifier == 'inferred'

            date
          else
            "#{@start&.qualified_value} - #{@stop&.qualified_value}"
          end
        end
      end

      def parse_dates(elements)
        # convert to DateValue objects and keep only valid ones
        dates = elements.map(&:as_object).flatten.map { |element| DateValue.new(element) }.select(&:valid?)
        # join any date ranges into DateRange objects
        point, nonpoint = dates.partition(&:point)
        if point.any?
          range = DateRange.new(start: point.find { |date| date.point == 'start' },
                                stop: point.find { |date| date.point == 'end' })
          nonpoint.unshift(range)
        end
        dates = nonpoint

        # ensure dates are unique with respect to their base values
        dates = dates.group_by(&:base_value).map do |_value, group|
          next group.first if group.one?

          # if one of the duplicates wasn't encoded, use that one. see:
          # https://consul.stanford.edu/display/chimera/MODS+display+rules#MODSdisplayrules-3b.%3CoriginInfo%3E
          if group.reject(&:encoding).any?
            group.reject(&:encoding).first

          # otherwise just randomly pick the first in the group
          else
            group.last
          end
        end

        # compare the remaining dates against one part of the other of a range
        date_ranges = dates.select { |date| date.is_a?(DateRange) }

        # remove any range that duplicates an unencoded date that includes that range
        duplicated_ranges = dates.flat_map do |date|
          next if date.is_a?(DateRange) || date.encoding.present?

          date_ranges.select { |r| r.base_values.include?(date.base_value) }
        end

        dates = dates - duplicated_ranges

        # output formatted dates with qualifiers, CE/BCE, etc.
        dates.map(&:qualified_value)
      end
    end
  end
end
