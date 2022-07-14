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
      # @note for sorting:  5 BCE => -5;  666 BCE => -666
      def pub_year_int(fields = [:dateIssued, :dateCreated, :dateCaptured], ignore_approximate: false)
        fields.each do |date_key|
          values = mods_ng_xml.origin_info.send(date_key)
          values = values.reject(&method(:is_approximate)) if ignore_approximate

          earliest_date = Stanford::Mods::OriginInfo.best_or_earliest_year(values)
          return earliest_date.year_int_from_date_str if earliest_date&.year_int_from_date_str
        end; nil
      end

      # return a single string intended for lexical sorting for pub date
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute) should be ignored; false if approximate dates should be included
      # @return [String] single String containing publication year for lexical sorting
      # @note for string sorting  5 BCE = -5  => -995;  6 BCE => -994, so 6 BCE sorts before 5 BCE
      # @deprecated use pub_year_int
      def pub_year_sort_str(fields = [:dateIssued, :dateCreated, :dateCaptured], ignore_approximate: false)
        fields.each do |date_key|
          values = mods_ng_xml.origin_info.send(date_key)
          values = values.reject(&method(:is_approximate)) if ignore_approximate

          earliest_date = Stanford::Mods::OriginInfo.best_or_earliest_year(values)
          return earliest_date.sortable_year_string_from_date_str if earliest_date&.sortable_year_string_from_date_str
        end; nil
      end

      # return a single string intended for display of pub year
      # 0 < year < 1000:  add CE suffix
      # year < 0:  add BCE suffix.  ('-5'  =>  '5 BCE', '700 BCE'  => '700 BCE')
      # 195u =>  195x
      # 19uu => 19xx
      #   '-5'  =>  '5 BCE'
      #   '700 BCE'  => '700 BCE'
      #   '7th century' => '7th century'
      # date ranges?
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be ignored; false if approximate dates should be included
      def pub_year_display_str(fields = [:dateIssued, :dateCreated, :dateCaptured], ignore_approximate: false)
        fields.each do |date_key|
          values = mods_ng_xml.origin_info.send(date_key)
          values = values.reject(&method(:is_approximate)) if ignore_approximate

          earliest_date = Stanford::Mods::OriginInfo.best_or_earliest_year(values)
          return earliest_date.date_str_for_display if earliest_date&.date_str_for_display
        end; nil
      end

      # @return [Array<Stanford::Mods::Imprint>] array of imprint objects
      # @private
      def imprints
        origin_info.map { |el| Stanford::Mods::Imprint.new(el) }
      end

      def place
        term_values([:origin_info, :place, :placeTerm])
      end

      # @return [String] single String containing imprint information for display
      def imprint_display_str
        imprints.map(&:display_str).reject(&:empty?).join('; ')
      end

      # remove Elements from NodeSet if they have a qualifier attribute of 'approximate' or 'questionable'
      # @param [Nokogiri::XML::Element] node the date element
      # @return [Boolean]
      # @private
      def is_approximate(node)
        qualifier = node["qualifier"] if node.respond_to?('[]')
        qualifier == 'approximate' || qualifier == 'questionable'
      end

      # get earliest parseable year from the passed date elements
      # @param [Array<Nokogiri::XML::Element>] date_el_array the elements from which to select a pub date
      # @return [Stanford::Mods::DateParsing]
      def self.best_or_earliest_year(date_el_array)
        key_dates, other_dates = date_el_array.partition { |node| node['keyDate'] == 'yes' }

        sortable_dates = key_dates.map { |x| DateParsing.new(x) }.select(&:sortable_year_string_from_date_str)
        sortable_dates = other_dates.map { |x| DateParsing.new(x) }.select(&:sortable_year_string_from_date_str) if sortable_dates.empty?
        results = {}

        # this is a little weird; instead of just the earliest sorting date, if there are multiple
        # dates with the same sort key, we want to make sure we get the last occurring one?
        sortable_dates.each do |v|
          results[v.sortable_year_string_from_date_str] = v
        end

        results[results.keys.min]
      end
    end # class Record
  end
end
