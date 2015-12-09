# Parsing date strings
# These methods may be used by searchworks.rb file or by downstream apps
module Stanford
  module Mods
    class DateParsing

      # @param [String] date_str String containing date (we hope)
      # @return [String, nil] sortable 4 digit year (e.g. 1865, 0950) if date_str is parseable via ruby Date, nil otherwise
      def self.year_via_ruby_parsing(date_str)
        return unless date_str.match(/\d\d/) # need at least 2 digits
        # need more in string than only 2 digits
        return if date_str.match(/^\d\d$/) || date_str.match(/^\D*\d\d\D*$/)
        return if date_str.match(/\d\s*B.C./) # skip B.C. dates
        date_obj = Date.parse(date_str)
        date_obj.year.to_s
      rescue
        nil # explicitly want nil if date won't parse
      end

      # @param [String] date_str String containing date (we hope)
      # @return [String, nil] 4 digit year (e.g. 1865, 0950) if date_str has one, nil otherwise
      def self.sortable_year_from_date_str(date_str)
        matches = date_str.scan(/\d{4}/) if date_str
        return matches[0] if matches && matches.size == 1
      end

    end
  end
end