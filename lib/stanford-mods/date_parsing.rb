# Parsing date strings
# These methods may be used by searchworks.rb file or by downstream apps
module Stanford
  module Mods
    class DateParsing

      # @param [String] date_str String containing four digit year (we hope)
      # @return [String, nil] 4 digit year (e.g. 1865, 0950) if date_str has yyyy, nil otherwise
      def self.sortable_year_from_date_str(date_str)
        matches = date_str.match(/\d{4}/) if date_str
        return matches.to_s if matches
      end

      # get year if we have a x/x/yy or x-x-yy pattern
      #   note that these are the only 2 digit year patterns found in our actual date strings in MODS records
      # @param [String] date_str String containing x/x/yy or x-x-yy date pattern
      # @return [String, nil] 4 digit year (e.g. 1865, 0950) if date_str matches pattern, nil otherwise
      def self.sortable_year_from_yy(date_str)
        slash_matches = date_str.match(/\d{1,2}\/\d{1,2}\/\d{2}/) if date_str
        if slash_matches
          date_obj = Date.strptime(date_str, '%m/%d/%y')
        else
          hyphen_matches = date_str.match(/\d{1,2}-\d{1,2}-\d{2}/) if date_str
          date_obj = Date.strptime(date_str, '%m-%d-%y') if hyphen_matches
        end
        if date_obj && date_obj > Date.today
          date_obj = Date.new(date_obj.year - 100, date_obj.month, date_obj.mday)
        end
        date_obj.year.to_s if date_obj
      rescue ArgumentError
        nil # explicitly want nil if date won't parse
      end

      # get first year of decade if we have:  yyyu, yyy-, yyy? or yyyx pattern
      #   note that these are the only non-year decade patterns found in our actual date strings in MODS records
      # @param [String] date_str String containing yyyu, yyy-, yyy? or yyyx decade pattern
      # @return [String, nil] 4 digit year (e.g. 1860, 1950) if date_str matches pattern, nil otherwise
      def self.sortable_year_from_decade(date_str)
        decade_matches = date_str.match(/\d{3}[u\-?x]/) if date_str
        if decade_matches
          changed_to_zero = decade_matches.to_s.tr('u\-?x', '0')
          return sortable_year_from_date_str(changed_to_zero)
        end
        nil
      end

      # NOTE:  while Date.parse() works for many dates, the *sortable_year_from_date_str
      #   actually works for nearly all those cases and a lot more besides.  Trial and error
      #   with an extensive set of test data culled from actual date strings in our MODS records
      #   has made this method bogus.
      # @param [String] date_str String containing date (we hope)
      # @return [String, nil] sortable 4 digit year (e.g. 1865, 0950) if date_str is parseable via ruby Date, nil otherwise
      def self.year_via_ruby_parsing(date_str)
        return unless date_str.match(/\d\d/) # need at least 2 digits
        # need more in string than only 2 digits
        return if date_str.match(/^\d\d$/) || date_str.match(/^\D*\d\d\D*$/)
        return if date_str.match(/\d\s*B.C./) # skip B.C. dates
        date_obj = Date.parse(date_str)
        date_obj.year.to_s
      rescue ArgumentError
        nil # explicitly want nil if date won't parse
      end

    end
  end
end