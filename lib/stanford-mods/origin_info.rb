require 'mods'

# Parsing MODS /originInfo for Publication/Imprint data:
#  * pub year for date slider facet
#  * pub year for sorting
#  * pub year for single display value
#  * imprint info for display
#  *
# These methods may be used by searchworks.rb file or by downstream apps
module Stanford
  module Mods
    class Record < ::Mods::Record
      # return pub year as an Integer
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute) should be ignored; false if approximate dates should be included
      # @return [Integer] publication year as an Integer
      # @note for sorting:  5 B.C. => -5;  666 B.C. => -666
      def pub_year_int(ignore_approximate = false)
        single_pub_year(ignore_approximate, :year_int)
      end

      # return a single string intended for lexical sorting for pub date
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute) should be ignored; false if approximate dates should be included
      # @return [String] single String containing publication year for lexical sorting
      # @note for string sorting  5 B.C. = -5  => -995;  6 B.C. => -994, so 6 B.C. sorts before 5 B.C.
      # @deprecated use pub_year_int
      def pub_year_sort_str(ignore_approximate = false)
        single_pub_year(ignore_approximate, :year_sort_str)
      end

      # return a single string intended for display of pub year
      # 0 < year < 1000:  add A.D. suffix
      # year < 0:  add B.C. suffix.  ('-5'  =>  '5 B.C.', '700 B.C.'  => '700 B.C.')
      # 195u =>  195x
      # 19uu => 19xx
      #   '-5'  =>  '5 B.C.'
      #   '700 B.C.'  => '700 B.C.'
      #   '7th century' => '7th century'
      # date ranges?
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be ignored; false if approximate dates should be included
      def pub_year_display_str(ignore_approximate = false)
        single_pub_year(ignore_approximate, :year_display_str)

        # TODO: want range displayed when start and end points
        # TODO: also want best year in year_isi fields
        # get_main_title_date
        # https://github.com/sul-dlss/SearchWorks/blob/7d4d870a9d450fed8b081c38dc3dbd590f0b706e/app/helpers/results_document_helper.rb#L8-L46

        # "publication_year_isi"   => "Publication date",  <--  do it already
        # "beginning_year_isi"     => "Beginning date",
        # "earliest_year_isi"      => "Earliest date",
        # "earliest_poss_year_isi" => "Earliest possible date",
        # "ending_year_isi"        => "Ending date",
        # "latest_year_isi"        => "Latest date",
        # "latest_poss_year_isi"   => "Latest possible date",
        # "production_year_isi"    => "Production date",
        # "original_year_isi"      => "Original date",
        # "copyright_year_isi"     => "Copyright date"} %>

        # "creation_year_isi"      => "Creation date",  <--  do it already
        # {}"release_year_isi"       => "Release date",
        # {}"reprint_year_isi"       => "Reprint/reissue date",
        # {}"other_year_isi"         => "Date",
      end

      # @return [String] single String containing imprint information for display
      def imprint_display_str
        imp = Stanford::Mods::Imprint.new(origin_info)
        imp.display_str
      end

      # given the passed date elements, look for a single keyDate and use it if there is one;
      #    otherwise pick earliest parseable date
      # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub date
      # @return [String] single String containing publication year for display
      def year_display_str(date_el_array)
        result = date_parsing_result(date_el_array, :date_str_for_display)
        return result if result
        _ignore, orig_str_to_parse = self.class.earliest_year_str(date_el_array)
        DateParsing.date_str_for_display(orig_str_to_parse) if orig_str_to_parse
      end

      # given the passed date elements, look for a single keyDate and use it if there is one;
      #    otherwise pick earliest parseable date
      # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub date
      # @return [Integer] publication year as an Integer
      def year_int(date_el_array)
        result = date_parsing_result(date_el_array, :year_int_from_date_str)
        return result if result
        year_int, _ignore = self.class.earliest_year_int(date_el_array)
        year_int if year_int
      end

      # given the passed date elements, look for a single keyDate and use it if there is one;
      #    otherwise pick earliest parseable date
      # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub date
      # @return [String] single String containing publication year for lexical sorting
      def year_sort_str(date_el_array)
        result = date_parsing_result(date_el_array, :sortable_year_string_from_date_str)
        return result if result
        sortable_str, _ignore = self.class.earliest_year_str(date_el_array)
        sortable_str if sortable_str
      end

      # return /originInfo/dateCreated elements in MODS records
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be excluded; false approximate dates should be included
      # @return [Array<Nokogiri::XML::Element>]
      def date_created_elements(ignore_approximate = false)
        date_created_nodeset = mods_ng_xml.origin_info.dateCreated
        return self.class.remove_approximate(date_created_nodeset) if ignore_approximate
        date_created_nodeset.to_a
      end

      # return /originInfo/dateIssued elements in MODS records
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be excluded; false approximate dates should be included
      # @return [Array<Nokogiri::XML::Element>]
      def date_issued_elements(ignore_approximate = false)
        date_issued_nodeset = mods_ng_xml.origin_info.dateIssued
        return self.class.remove_approximate(date_issued_nodeset) if ignore_approximate
        date_issued_nodeset.to_a
      end

      # given a set of date elements, return the single element with attribute keyDate="yes"
      #  or return nil if no elements have attribute keyDate="yes", or if multiple elements have keyDate="yes"
      # @param [Array<Nokogiri::XML::Element>] Array of date elements
      # @return [Nokogiri::XML::Element, nil] single date element with attribute keyDate="yes", or nil
      def self.keyDate(elements)
        keyDates = elements.select { |node| node["keyDate"] == 'yes' }
        keyDates.first if keyDates.size == 1
      end

      # remove Elements from NodeSet if they have a qualifier attribute of 'approximate' or 'questionable'
      # @param [Nokogiri::XML::NodeSet<Nokogiri::XML::Element>] nodeset set of date elements
      # @return [Array<Nokogiri::XML::Element>] the set of date elements minus any that
      #   had a qualifier attribute of 'approximate' or 'questionable'
      def self.remove_approximate(nodeset)
        nodeset.select { |node| node unless date_is_approximate?(node) }
      end

      # NOTE: legal values for MODS date elements with attribute qualifier are
      #   'approximate', 'inferred' or 'questionable'
      # @param [Nokogiri::XML::Element] date_element MODS date element
      # @return [Boolean] true if date_element has a qualifier attribute of "approximate" or "questionable",
      #   false if no qualifier attribute, or if attribute is 'inferred' or some other value
      def self.date_is_approximate?(date_element)
        qualifier = date_element["qualifier"] if date_element.respond_to?('[]')
        qualifier == 'approximate' || qualifier == 'questionable'
      end

      # get earliest parseable year (as an Integer) from the passed date elements
      # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub date
      # @return two String values:
      #   the first is the Integer value of the earliest year;
      #   the second is the original String value of the chosen element
      def self.earliest_year_int(date_el_array)
        earliest_year(date_el_array, :year_int_from_date_str)
      end

      # get earliest parseable year (as a String) from the passed date elements
      # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub date
      # @return two String values:
      #   the first is the lexically sortable String value of the earliest year;
      #   the second is the original String value of the chosen element
      def self.earliest_year_str(date_el_array)
        earliest_year(date_el_array, :sortable_year_string_from_date_str)
      end

      # return a single value intended for pub date flavor indicated by method_sym
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be ignored; false if approximate dates should be included
      # @param [Symbol] method_sym method name in DateParsing, as a symbol
      # @return [String, Integer] publication year as String or Integer
      def single_pub_year(ignore_approximate, method_sym)
        result = send(method_sym, date_issued_elements(ignore_approximate))
        result ||= send(method_sym, date_created_elements(ignore_approximate))
        # dateCaptured for web archive seed records
        result || send(method_sym, mods_ng_xml.origin_info.dateCaptured.to_a)
      end

      # given the passed date elements, look for a single keyDate and use it if there is one;
      #    otherwise pick earliest parseable date
      # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub date
      # @param [Symbol] method_sym method name in DateParsing, as a symbol
      # @return [Integer, String] year as a String or Integer, depending on method_sym
      def date_parsing_result(date_el_array, method_sym)
        return if date_el_array.empty?
        # prefer keyDate
        key_date_el = self.class.keyDate(date_el_array)
        DateParsing.send(method_sym, key_date_el.content) if key_date_el
      end
      # temporarily use this technique to mark methods private until we get rid of old date parsing methods below
      private :single_pub_year, :date_parsing_result

      class << self
        private

        # get earliest parseable year from the passed date elements
        # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub date
        # @param [Symbol] method_sym method name in DateParsing, as a symbol
        # @return [Array<String,Integer>] two values: earliest date and the original element string
        #   - first is earliest date either as lexically sortable String value or the Integer, depending on method_sym
        #   - second is the original String value of the chosen element
        def earliest_year(date_el_array, method_sym)
          poss_results = {}
          date_el_array.each { |el|
            result = DateParsing.send(method_sym, el.content)
            poss_results[result] = el.content if result
          }
          earliest = poss_results.keys.sort.first if poss_results.present?
          return earliest, poss_results[earliest] if earliest
        end
      end

# ----   old date parsing methods used downstream of gem;  will be deprecated/replaced with new date parsing methods

      def place
        term_values([:origin_info, :place, :placeTerm])
      end

      # Values for the pub date facet. This is less strict than the 4 year date requirements for pub_date
      # Jan 2016:  used to populate Solr pub_date field for Spotlight and SearchWorks
      #   Spotlight:  pub_date field should be replaced by pub_year_w_approx_isi and pub_year_no_approx_isi
      #   SearchWorks:  pub_date field used for display in search results and show view; for sorting nearby-on-shelf
      #      these could be done with more approp fields/methods (pub_year_int for sorting;  new pub year methods to populate field)
      # TODO: prob should deprecate this in favor of pub_year_display_str;
      #    need head-to-head testing with pub_year_display_str
      # @return [String] value for the pub date facet
      def pub_date_facet
        return nil unless pub_date
        return "#{pub_date.to_i + 1000} B.C." if pub_date.start_with?('-')
        return pub_date unless pub_date.include? '--'
        "#{pub_date[0, 2].to_i + 1}th century"
      end

      # creates a date suitable for sorting. Guarnteed to be 4 digits or nil
      # @deprecated use pub_year_int, or pub_year_sort_str if you must have a string (why?)
      def pub_date_sort
        if pub_date
          pd = pub_date
          pd = '0' + pd if pd.length == 3
          pd = pd.gsub('--', '00')
        end
        fail "pub_date_sort was about to return a non 4 digit value #{pd}!" if pd && pd.length != 4
        pd
      end

      # For the date display only, the first place to look is in the dates without encoding=marc array.
      # If no such dates, select the first date in the dates_marc_encoding array.  Otherwise return nil
      # @return [String] value for the pub_date_display Solr field for this document or nil if none
      # @deprecated DO NOT USE: this is no longer used in SW, Revs or Spotlight Jan 2016
      def pub_date_display
        return dates_no_marc_encoding.first unless dates_no_marc_encoding.empty?
        return dates_marc_encoding.first unless dates_marc_encoding.empty?
        nil
      end

# old date parsing protected methods to be deprecated/replaced with new methods (see also DateParsing)

    protected

      # The year the object was published
      # @return [String] 4 character year or nil if no valid date was found
      def pub_year
        # use the cached year if there is one
        if @pub_year
          return nil if @pub_year == ''
          return @pub_year
        end

        dates = pub_dates.map do |f_date|
          # remove ? and []
          if f_date.length == 4 && f_date.end_with?('?')
            f_date.tr('?', '0')
          else
            f_date.delete('?[]')
          end
        end

        if dates
          # try to find a date starting with the most normal date formats and progressing to more wonky ones
          @pub_year = get_plain_four_digit_year(dates) ||
                      get_u_year(dates)                || # Check for years in u notation, e.g., 198u
                      get_double_digit_century(dates)  ||
                      get_bc_year(dates)               ||
                      get_three_digit_year(dates)      ||
                      get_single_digit_century(dates)
          return @pub_year if @pub_year
        end
        @pub_year = ''
        nil
      end
      alias_method :pub_date, :pub_year

      # For the date indexing, sorting and faceting, the first place to look is in the dates with encoding=marc array.
      # If that doesn't exist, look in the dates without encoding=marc array.  Otherwise return nil
      # @return [Array<String>] values for the date Solr field for this document or nil if none
      def pub_dates
        return dates_marc_encoding unless dates_marc_encoding.empty?
        return dates_no_marc_encoding unless dates_no_marc_encoding.empty?
        nil
      end

      # @return [Array<String>] dates from dateIssued and dateCreated tags from origin_info with encoding="marc"
      def dates_marc_encoding
        @dates_marc_encoding ||= begin
          parse_dates_from_originInfo
          @dates_marc_encoding
        end
      end

      # @return [Array<String>] dates from dateIssued and dateCreated tags from origin_info with encoding not "marc"
      def dates_no_marc_encoding
        @dates_no_marc_encoding ||= begin
          parse_dates_from_originInfo
          @dates_no_marc_encoding
        end
      end

      # Populate @dates_marc_encoding and @dates_no_marc_encoding from dateIssued and dateCreated tags from origin_info
      # with and without encoding=marc
      def parse_dates_from_originInfo
        @dates_marc_encoding = []
        @dates_no_marc_encoding = []
        origin_info.dateIssued.each { |di|
          if di.encoding == "marc"
            @dates_marc_encoding << di.text
          else
            @dates_no_marc_encoding << di.text
          end
        }
        origin_info.dateCreated.each { |dc|
          if dc.encoding == "marc"
            @dates_marc_encoding << dc.text
          else
            @dates_no_marc_encoding << dc.text
          end
        }
      end

      def is_number?(object)
        true if Integer(object) rescue false
      end

      def is_date?(object)
        true if Date.parse(object) rescue false
      end

      # get a 4 digit year like 1865 from array of dates
      # @param [Array<String>] dates an array of potential year strings
      def get_plain_four_digit_year(dates)
        dates.each do |f_date|
          matches = f_date.scan(/\d{4}/)
          if matches.length == 1
            @pub_year = matches.first
          else
            # when there are multiple matches, check for ones with CE after them
            matches.each do |match|
              # look for things like '1865-6 CE'
              pos = f_date.index(Regexp.new(match + '...CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match + ' CE') || pos > 0
                @pub_year = match
                return match
              end
            end
          end
          return matches.first
        end
        nil
      end

      # get a 3 digit year like 965 from the date array
      # @param [Array<String>] dates an array of potential year strings
      def get_three_digit_year(dates)
        dates.each do |f_date|
          matches = f_date.scan(/\d{3}/)
          return matches.first unless matches.empty?
        end
        nil
      end

      # get the 3 digit BC year, return it as a negative, so -700 for 300 BC.
      #  Other methods will translate it to proper display, this is good for sorting.
      # @param [Array<String>] dates an array of potential year strings
      def get_bc_year(dates)
        dates.each do |f_date|
          matches = f_date.scan(/\d{3} B.C./)
          unless matches.empty?
            bc_year = matches.first[0..2]
            return (bc_year.to_i - 1000).to_s
          end
        end
        nil
      end

      # get a single digit century like '9th century' from the date array
      # @param [Array<String>] dates an array of potential year strings
      # @return [String] y--  if we identify century digit in string
      def get_single_digit_century(dates)
        dates.each do |f_date|
          matches = f_date.scan(/\d{1}th/)
          next if matches.empty?
          if matches.length == 1
            @pub_year = (matches.first[0, 2].to_i - 1).to_s + '--'
            return @pub_year
          else
            # when there are multiple matches, check for ones with CE after them
            matches.each do |match|
              pos = f_date.index(Regexp.new(match + '...CE'))
              pos = pos ? pos.to_i : f_date.index(Regexp.new(match + ' century CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match + ' CE') || pos > 0
                @pub_year = (match[0, 1].to_i - 1).to_s + '--'
                return @pub_year
              end
            end
          end
        end
        nil
      end

      # get a double digit century like '12th century' from the date array
      # @param [Array<String>] dates an array of potential year strings
      # @return [String] yy--  if we identify century digits in string
      def get_double_digit_century(dates)
        dates.each do |f_date|
          matches = f_date.scan(/\d{2}th/)
          next if matches.empty?
          if matches.length == 1
            @pub_year = (matches.first[0, 2].to_i - 1).to_s + '--'
            return @pub_year
          else
            # when there are multiple matches, check for ones with CE after them
            matches.each do |match|
              pos = f_date.index(Regexp.new(match + '...CE'))
              pos = pos ? pos.to_i : f_date.index(Regexp.new(match + ' century CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match + ' CE') || pos > 0
                @pub_year = (match[0, 2].to_i - 1).to_s + '--'
                return @pub_year
              end
            end
          end
        end
        nil
      end

      # If a year has a "u" in it, replace u with 0 for yyyu (becomes yyy0)
      #   and replace u with '-' for yyuu  (becomes yy--)
      # @param [String] dates looking for matches on yyyu or yyuu in these strings
      # @return [String, nil] String of format yyy0 or yy--, or nil
      def get_u_year(dates)
        dates.each do |f_date|
          # Single digit u notation
          matches = f_date.scan(/\d{3}u/)
          return matches.first.tr('u', '0') if matches.length == 1
          # Double digit u notation
          matches = f_date.scan(/\d{2}u{2}/)
          return matches.first.tr('u', '-') if matches.length == 1
        end
        nil
      end
    end # class Record
  end
end
