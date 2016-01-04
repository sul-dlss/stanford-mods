require 'logger'
require 'mods'

# Parsing MODS /originInfo for Publication/Imprint data:
#  * pub year for date slider facet
#  * pub year for sorting
#  * pub year for single facet value
#  * imprint info for display
#  *
# These methods may be used by searchworks.rb file or by downstream apps
module Stanford
  module Mods
    class Record < ::Mods::Record

      # return a single string intended for facet use for pub date
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be ignored; false if approximate dates should be included
      # @return [String] single String containing publication year for facet use
      def pub_date_facet_single_value(ignore_approximate = false)
        # prefer dateIssued
        result = pub_date_best_single_facet_value(date_issued_elements(ignore_approximate))
        result ||= pub_date_best_single_facet_value(date_created_elements(ignore_approximate))
        # dateCaptured for web archive seed records
        result ||= pub_date_best_single_facet_value(@mods_ng_xml.origin_info.dateCaptured.to_a)
        result
      end

      # return a single string intended for lexical sorting for pub date
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be ignored; false if approximate dates should be included
      # @return [String] single String containing publication year for lexical sorting
      #   note that for string sorting  5 B.C. = -5  => -995;  6 B.C. => -994  so 6 B.C. sorts before 5 B.C.
      def pub_date_sortable_string(ignore_approximate = false)
        # prefer dateIssued
        result = pub_date_best_sort_str_value(date_issued_elements(ignore_approximate))
        result ||= pub_date_best_sort_str_value(date_created_elements(ignore_approximate))
        # dateCaptured for web archive seed records
        result ||= pub_date_best_sort_str_value(@mods_ng_xml.origin_info.dateCaptured.to_a)
        result
      end

      # given the passed date elements, look for a single keyDate and use it if there is one;
      #    otherwise pick earliest parseable date
      # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub_date
      # @return [String] single String containing publication year for facet use
      def pub_date_best_single_facet_value(date_el_array)
        return if date_el_array.empty?
        # prefer keyDate
        desired_el = self.class.keyDate(date_el_array)
        result = DateParsing.facet_string_from_date_str(desired_el.content) if desired_el
        return result if result
        # settle for earliest parseable date
        poss_results = {}
        date_el_array.each { |el|
          result = DateParsing.sortable_year_string_from_date_str(el.content)
          poss_results[result] = el.content if result
        }
        earliest = poss_results.keys.sort.first if poss_results.present?
        return DateParsing.facet_string_from_date_str(poss_results[earliest]) if earliest
      end

      # given the passed date elements, look for a single keyDate and use it if there is one;
      #    otherwise pick earliest parseable date
      # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub_date
      # @return [String] single String containing publication year for lexical sorting
      def pub_date_best_sort_str_value(date_el_array)
        return if date_el_array.empty?
        # prefer keyDate
        desired_el = self.class.keyDate(date_el_array)
        result = DateParsing.sortable_year_string_from_date_str(desired_el.content) if desired_el
        return result if result
        # settle for earliest parseable date
        poss_results = {}
        date_el_array.each { |el|
          result = DateParsing.sortable_year_string_from_date_str(el.content)
          poss_results[result] = el.content if result
        }
        return poss_results.keys.sort.first if poss_results.present?
      end

      protected :pub_date_best_single_facet_value, :pub_date_best_sort_str_value

      # return /originInfo/dateCreated elements in MODS records
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be excluded; false approximate dates should be included
      # @return [Array<Nokogiri::XML::Element>]
      def date_created_elements(ignore_approximate=false)
        date_created_nodeset = @mods_ng_xml.origin_info.dateCreated
        return self.class.remove_approximate(date_created_nodeset) if ignore_approximate
        date_created_nodeset.to_a
      end

      # return /originInfo/dateIssued elements in MODS records
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be excluded; false approximate dates should be included
      # @return [Array<Nokogiri::XML::Element>]
      def date_issued_elements(ignore_approximate=false)
        date_issued_nodeset = @mods_ng_xml.origin_info.dateIssued
        return self.class.remove_approximate(date_issued_nodeset) if ignore_approximate
        date_issued_nodeset.to_a
      end

      # given a set of date elements, return the single element with attribute keyDate="yes"
      #  or return nil if no elements have attribute keyDate="yes", or if multiple elements have keyDate="yes"
      # @param [Array<Nokogiri::XML::Element>] Array of date elements
      # @return [Nokogiri::XML::Element, nil] single date element with attribute keyDate="yes", or nil
      def self.keyDate(elements)
        keyDates = elements.select { |node| node["keyDate"] == 'yes' }
        return keyDates.first if keyDates.size == 1
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


# ----   old date parsing methods used downstream of gem;  will be deprecated/replaced with new date parsing methods

      def place
        vals = self.term_values([:origin_info, :place, :placeTerm])
        vals
      end

      # For the date display only, the first place to look is in the dates without encoding=marc array.
      # If no such dates, select the first date in the dates_marc_encoding array.  Otherwise return nil
      # @return [String] value for the pub_date_display Solr field for this document or nil if none
      def pub_date_display
        return dates_no_marc_encoding.first unless dates_no_marc_encoding.empty?
        return dates_marc_encoding.first unless dates_marc_encoding.empty?
        nil
      end

      # For the date indexing, sorting and faceting, the first place to look is in the dates with encoding=marc array.
      # If that doesn't exist, look in the dates without encoding=marc array.  Otherwise return nil
      # @return [Array<String>] values for the date Solr field for this document or nil if none
      def pub_dates
        return dates_marc_encoding unless dates_marc_encoding.empty?
        return dates_no_marc_encoding unless dates_no_marc_encoding.empty?
        nil
      end

      # Get the publish year from mods
      # @return [String] 4 character year or nil if no valid date was found
      def pub_year
        # use the cached year if there is one
        if @pub_year
          return nil if @pub_year == ''
          return @pub_year
        end

        dates = pub_dates
        if dates
          pruned_dates = []
          dates.each do |f_date|
            # remove ? and []
            if f_date.length == 4 && f_date.end_with?('?')
              pruned_dates << f_date.tr('?', '0')
            else
              pruned_dates << f_date.delete('?[]')
            end
          end
          # try to find a date starting with the most normal date formats and progressing to more wonky ones
          @pub_year = get_plain_four_digit_year pruned_dates
          return @pub_year if @pub_year
          # Check for years in u notation, e.g., 198u
          @pub_year = get_u_year pruned_dates
          return @pub_year if @pub_year
          @pub_year = get_double_digit_century pruned_dates
          return @pub_year if @pub_year
          @pub_year = get_bc_year pruned_dates
          return @pub_year if @pub_year
          @pub_year = get_three_digit_year pruned_dates
          return @pub_year if @pub_year
          @pub_year = get_single_digit_century pruned_dates
          return @pub_year if @pub_year
        end
        @pub_year = ''
        nil
      end

      # creates a date suitable for sorting. Guarnteed to be 4 digits or nil
      def pub_date_sort
        if pub_date
          pd = pub_date
          pd = '0' + pd if pd.length == 3
          pd = pd.gsub('--', '00')
        end
        fail "pub_date_sort was about to return a non 4 digit value #{pd}!" if pd && pd.length != 4
        pd
      end

      # The year the object was published, filtered based on max_pub_date and min_pub_date from the config file
      # @return [String] 4 character year or nil
      def pub_date
        pub_year || nil
      end

      # Values for the pub date facet. This is less strict than the 4 year date requirements for pub_date
      # @return <Array[String]> with values for the pub date facet
      def pub_date_facet
        if pub_date
          if pub_date.start_with?('-')
            return (pub_date.to_i + 1000).to_s + ' B.C.'
          end
          if pub_date.include? '--'
            cent = pub_date[0, 2].to_i
            cent += 1
            cent = cent.to_s + 'th century'
            return cent
          else
            return pub_date
          end
        end
        nil
      end

# ----   old date parsing methods will be deprecated/replaced with new date parsing methods

    protected

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
        self.origin_info.dateIssued.each { |di|
          if di.encoding == "marc"
            @dates_marc_encoding << di.text
          else
            @dates_no_marc_encoding << di.text
          end
        }
        self.origin_info.dateCreated.each { |dc|
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

      # TODO:  need tests for these methods

      # get a 4 digit year like 1865 from array of dates
      # @param [Array<String>] dates an array of potential year strings
      def get_plain_four_digit_year(dates)
        dates.each do |f_date|
          matches = f_date.scan(/\d{4}/)
          if matches.length == 1
            @pub_year = matches.first
            return matches.first
          else
            # when there are multiple matches, check for ones with CE after them
            matches.each do |match|
              # look for things like '1865-6 CE'
              pos = f_date.index(Regexp.new(match + '...CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match+' CE') or pos > 0
                @pub_year = match
                return match
              end
            end
            return matches.first
          end
        end
        nil
      end

      # get a 3 digit year like 965 from the date array
      # @param [Array<String>] dates an array of potential year strings
      def get_three_digit_year(dates)
        dates.each do |f_date|
          matches = f_date.scan(/\d{3}/)
          return matches.first if matches.length > 0
        end
        nil
      end

      # get the 3 digit BC year, return it as a negative, so -700 for 300 BC.
      #  Other methods will translate it to proper display, this is good for sorting.
      # @param [Array<String>] dates an array of potential year strings
      def get_bc_year(dates)
        dates.each do |f_date|
          matches = f_date.scan(/\d{3} B.C./)
          if matches.length > 0
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
          next if matches.length == 0
          if matches.length == 1
            @pub_year = ((matches.first[0, 2].to_i) - 1).to_s + '--'
            return @pub_year
          else
            # when there are multiple matches, check for ones with CE after them
            matches.each do |match|
              pos = f_date.index(Regexp.new(match + '...CE'))
              pos = pos ? pos.to_i : f_date.index(Regexp.new(match + ' century CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match + ' CE') || pos > 0
                @pub_year = ((match[0, 1].to_i) - 1).to_s + '--'
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
          next if matches.length == 0
          if matches.length == 1
            @pub_year=((matches.first[0, 2].to_i) - 1).to_s + '--'
            return @pub_year
          else
            # when there are multiple matches, check for ones with CE after them
            matches.each do |match|
              pos = f_date.index(Regexp.new(match + '...CE'))
              pos = pos ? pos.to_i : f_date.index(Regexp.new(match + ' century CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match+' CE') or pos > 0
                @pub_year = ((match[0, 2].to_i) - 1).to_s + '--'
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