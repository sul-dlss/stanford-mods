# Parsing date strings
# TODO:  this should become its own gem
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
      #   we use 20 as century digits unless it is greater than current year:
      #   1/1/15  ->  2015
      #   1/1/25  ->  1925
      # @param [String] date_str String containing x/x/yy or x-x-yy date pattern
      # @return [String, nil] 4 digit year (e.g. 1865, 0950) if date_str matches pattern, nil otherwise
      def self.sortable_year_from_yy(date_str)
        return unless date_str
        slash_matches = date_str.match(/\d{1,2}\/\d{1,2}\/\d{2}/)
        if slash_matches
          date_obj = Date.strptime(date_str, '%m/%d/%y')
        else
          hyphen_matches = date_str.match(/\d{1,2}-\d{1,2}-\d{2}/)
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
      #   note that these are the only decade patterns found in our actual date strings in MODS records
      # @param [String] date_str String containing yyyu, yyy-, yyy? or yyyx decade pattern
      # @return [String, nil] 4 digit year (e.g. 1860, 1950) if date_str matches pattern, nil otherwise
      def self.sortable_year_from_decade(date_str)
        decade_matches = date_str.match(/\d{3}[u\-?x]/) if date_str
        if decade_matches
          changed_to_zero = decade_matches.to_s.tr('u\-?x', '0')
          return sortable_year_from_date_str(changed_to_zero)
        end
      end

      # get facet value for century (17th century) if we have:  yyuu, yy--, yy--? or xxth century pattern
      #   note that these are the only century patterns found in our actual date strings in MODS records
      # @param [String] date_str String containing yyuu, yy--, yy--? or xxth century pattern
      # @return [String, nil] yy(th) Century if date_str matches pattern, nil otherwise; also nil if B.C. in pattern
      def self.facet_string_for_century(date_str)
        return unless date_str
        return if date_str.match(/B\.C\./)
        century_str_matches = date_str.match(/\d{1,2}.*century/)
        return century_str_matches.to_s if century_str_matches

        century_matches = date_str.match(/(\d{1,2})[u\-]{2}/)
        if century_matches
          require 'active_support/core_ext/integer/inflections'
          return "#{($1.to_i + 1).ordinalize} century"
        end
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