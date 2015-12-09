require 'logger'
require 'mods'

# Parsing MODS /originInfo for Publication/Imprint data:
#  * pub date for date slider facet
#  * pub date for sort
#  * imprint info for display
#  *
# These methods may be used by searchworks.rb file or by downstream apps
module Stanford
  module Mods
    class Record < ::Mods::Record


# -- likely to be private or protected

      # return all /originInfo/dateCreated elements in MODS records
      # @return [Nokogiri::XML::NodeSet<Nokogiri::XML::Element>]
      def date_created_nodeset
        @mods_ng_xml.origin_info.dateCreated   # returns nokogiri element/node objects
      end

      # return all /originInfo/dateIssued elements in MODS records
      # @return [Nokogiri::XML::NodeSet<Nokogiri::XML::Element>]
      def date_issued_nodeset
        @mods_ng_xml.origin_info.dateIssued   # returns nokogiri element/node objects
      end

      # given a set of date elements, return the single element with attribute keyDate="yes"
      #  or return nil if no elements have attribute keyDate="yes", or if multiple elements have keyDate="yes"
      # @param [Nokogiri::XML::NodeSet<Nokogiri::XML::Element>] nodeset set of date elements
      # @return [Nokogiri::XML::Element, nil] single date element with attribute keyDate="yes", or nil
      def self.keyDate(nodeset)
        keyDates = nodeset.select { |node| node["keyDate"] == 'yes' }
        return keyDates.first if keyDates.size == 1
      end

      # @param [Nokogiri::XML::NodeSet<Nokogiri::XML::Element>] nodeset set of date elements
      # @return [Nokogiri::XML::NodeSet<Nokogiri::XML::Element>] the set of date elements minus any that
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


# ----   old date parsing methods;  will be deprecated/replaced with new date parsing methods

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

    protected

      def is_number?(object)
        true if Integer(object) rescue false
      end

      def is_date?(object)
        true if Date.parse(object) rescue false
      end

      # TODO:  need tests for these methods

      # get a 4 digit year like 1865 from array of dates
      # @param [Array<String>] dates an array of potential year strings
      def get_plain_four_digit_year dates
        dates.each do |f_date|
          matches = f_date.scan(/\d{4}/)
          if matches.length == 1
            @pub_year = matches.first
            return matches.first
          else
            # when there are multiple matches, check for ones with CE after them
            matches.each do |match|
              #look for things like '1865-6 CE'
              pos = f_date.index(Regexp.new(match+'...CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match+' CE') or pos > 0
                @pub_year=match
                return match
              end
            end
            return matches.first
          end
        end
        return nil
      end

      # get a 3 digit year like 965 from the date array
      # @param [Array<String>] dates an array of potential year strings
      def get_three_digit_year dates
        dates.each do |f_date|
          matches = f_date.scan(/\d{3}/)
          return matches.first if matches.length > 0
        end
        nil
      end

      #get the 3 digit BC year, return it as a negative, so -700 for 300 BC. Other methods will translate it to proper display, this is good for sorting.
      # @param [Array<String>] dates an array of potential year strings
      def get_bc_year dates
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
      def get_single_digit_century dates
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
      def get_double_digit_century dates
        dates.each do |f_date|
          matches=f_date.scan(/\d{2}th/)
          next if matches.length == 0
          if matches.length == 1
            @pub_year=((matches.first[0,2].to_i)-1).to_s+'--'
            return @pub_year
          else
            # when there are multiple matches, check for ones with CE after them
            matches.each do |match|
              pos = f_date.index(Regexp.new(match+'...CE'))
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

      # If a year has a "u" in it, replace instances of u with 0
      # @param [String] dates
      # @return String
      def get_u_year dates
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