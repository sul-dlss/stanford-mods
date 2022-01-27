# frozen_string_literal: true

# Parsing MODS /originInfo for Publication/Imprint data:
#  * pub year for date slider facet
#  * pub year for sorting
#  * pub year for single display value
#  * imprint info for display
#  *
# These methods may be used by searchworks.rb file or by downstream apps
module Stanford
  module Mods
    module OriginInfo
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

      # @return [Array<Stanford::Mods::Imprint>] array of imprint objects
      def imprints
        origin_info.map { |el| Stanford::Mods::Imprint.new(el) }
      end

      # @return [String] single String containing imprint information for display
      def imprint_display_str
        imprints.map(&:display_str).reject(&:empty?).join('; ')
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

      def self.included(base)
        base.class_eval do
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

          private

          # get earliest parseable year from the passed date elements
          # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub date
          # @param [Symbol] method_sym method name in DateParsing, as a symbol
          # @return [Array<String,Integer>] two values: earliest date and the original element string
          #   - first is earliest date either as lexically sortable String value or the Integer, depending on method_sym
          #   - second is the original String value of the chosen element
          def self.earliest_year(date_el_array, method_sym)
            poss_results = {}
            date_el_array.each { |el|
              result = DateParsing.send(method_sym, el.content)
              poss_results[result] = el.content if result
            }
            earliest = poss_results.keys.sort.first if poss_results.present?
            return earliest, poss_results[earliest] if earliest
          end
        end
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

      # ----   old date parsing methods used downstream of gem;  will be deprecated/replaced with new date parsing methods

      def place
        term_values([:origin_info, :place, :placeTerm])
      end
    end # class Record
  end
end
