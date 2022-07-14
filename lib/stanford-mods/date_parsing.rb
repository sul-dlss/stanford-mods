module Stanford
  module Mods
    class DateParsing
      # true if the year is between -9999 and (current year + 1)
      # @return [Boolean] true if the year is between -9999 and (current year + 1); false otherwise
      def self.year_int_valid?(year)
        return false unless year.is_a? Integer

        (year < Date.today.year + 2)
      end

      attr_reader :xml

      def initialize(xml)
        @xml = xml
      end

      # get display value for year, generally an explicit year or "17th century" or "5 BCE" or "1950s" or '845 CE'
      # @return [String, nil] String value for year if we could parse one, nil otherwise
      def date_str_for_display
        date = xml&.as_object&.date
        date = date.min || date.max if date.is_a?(EDTF::Epoch) || date.is_a?(EDTF::Interval)

        return case xml.as_object.precision
        when :century
          return "#{(date.to_s[0..1].to_i + 1).ordinalize} century"
        when :decade
          return "#{date.year}s"
        when :unknown
          xml.text
        else
          if !self.class.year_int_valid? date.year
            xml.text
          elsif date.year < 1
            "#{date.year.abs + 1} BCE"
          elsif date.year < 1000
            "#{date.year} CE"
          else
            date.year.to_s
          end
        end
      end

      # get Integer year if we can parse date_str to get a year.
      # @return [Integer, nil] Integer year if we could parse one, nil otherwise
      def year_int_from_date_str
        xml&.as_object&.as_range&.first&.year
      end

      # get String sortable value year if we can parse date_str to get a year.
      #   SearchWorks currently uses a string field for pub date sorting; thus so does Spotlight.
      #   The values returned must *lexically* sort in chronological order, so the BCE dates are tricky
      # @return [String, nil] String sortable year if we could parse one, nil otherwise
      #  note that these values must *lexically* sort to create a chronological sort.
      def sortable_year_string_from_date_str
        return unless xml&.as_object&.date

        date = xml.as_object.date

        if date.is_a?(EDTF::Interval) && date.from.year < 1
          (-1 * date.from.year - 1000).to_s
        elsif date.is_a?(Date) && date.year < 1
          (-1 * date.year - 1000).to_s
        else
          date.to_s[0..3]&.gsub('X', '-')
        end
      end
    end
  end
end
