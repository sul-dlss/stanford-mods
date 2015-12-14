module Stanford
  module Mods
    # Parsing date strings
    # TODO:  this should become its own gem and/or become eclipsed by/merged with timetwister gem
    #   When this is "gemified":
    #     - we may want an integer or date sort field as well as lexical
    #     - we may want to either make this a module (a collection of methods another class can use)
    #       or have an initialize method so we don't have to keep passing the date_str argument
    class DateParsing

      # looks for 4 consecutive digits in String and returns first occurence if found
      # @param [String] date_str String containing four digit year (we hope)
      # @return [String, nil] 4 digit year (e.g. 1865, 0950) if date_str has yyyy, nil otherwise
      def self.sortable_year_for_yyyy(date_str)
        matches = date_str.match(/\d{4}/) if date_str
        return matches.to_s if matches
      end

      # returns 4 digit year as String if we have a x/x/yy or x-x-yy pattern
      #   note that these are the only 2 digit year patterns found in our actual date strings in MODS records
      #   we use 20 as century digits unless it is greater than current year:
      #   1/1/15  ->  2015
      #   1/1/25  ->  1925
      # @param [String] date_str String containing x/x/yy or x-x-yy date pattern
      # @return [String, nil] 4 digit year (e.g. 1865, 0950) if date_str matches pattern, nil otherwise
      def self.sortable_year_for_yy(date_str)
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

      # get first year of decade (as String) if we have:  yyyu, yyy-, yyy? or yyyx pattern
      #   note that these are the only decade patterns found in our actual date strings in MODS records
      # @param [String] date_str String containing yyyu, yyy-, yyy? or yyyx decade pattern
      # @return [String, nil] 4 digit year (e.g. 1860, 1950) if date_str matches pattern, nil otherwise
      def self.sortable_year_for_decade(date_str)
        decade_matches = date_str.match(/\d{3}[u\-?x]/) if date_str
        if decade_matches
          changed_to_zero = decade_matches.to_s.tr('u\-?x', '0')
          return sortable_year_for_yyyy(changed_to_zero)
        end
      end

      CENTURY_WORD_REGEXP = Regexp.new('(\d{1,2}).*century')
      CENTURY_4CHAR_REGEXP = Regexp.new('(\d{1,2})[u\-]{2}')

      # get first year of century (as String) if we have:  yyuu, yy--, yy--? or xxth century pattern
      #   note that these are the only century patterns found in our actual date strings in MODS records
      # @param [String] date_str String containing yyuu, yy--, yy--? or xxth century pattern
      # @return [String, nil] yy00 if date_str matches pattern, nil otherwise; also nil if B.C. in pattern
      def self.sortable_year_for_century(date_str)
        return unless date_str
        return if date_str.match(/B\.C\./)
        century_matches = date_str.match(CENTURY_4CHAR_REGEXP)
        if century_matches
          return $1 + '00' if $1.length == 2
          return '0' + $1 + '00' if $1.length == 1
        end
        century_str_matches = date_str.match(CENTURY_WORD_REGEXP)
        if century_str_matches
          yy = ($1.to_i - 1).to_s
          return yy + '00' if yy.length == 2
          return '0' + yy + '00' if yy.length == 1
        end
      end

      # get single facet value for century (17th century) if we have:  yyuu, yy--, yy--? or xxth century pattern
      #   note that these are the only century patterns found in our actual date strings in MODS records
      # @param [String] date_str String containing yyuu, yy--, yy--? or xxth century pattern
      # @return [String, nil] yy(th) Century if date_str matches pattern, nil otherwise; also nil if B.C. in pattern
      def self.facet_string_for_century(date_str)
        return unless date_str
        return if date_str.match(/B\.C\./)
        century_str_matches = date_str.match(CENTURY_WORD_REGEXP)
        return century_str_matches.to_s if century_str_matches

        century_matches = date_str.match(CENTURY_4CHAR_REGEXP)
        if century_matches
          require 'active_support/core_ext/integer/inflections'
          return "#{($1.to_i + 1).ordinalize} century"
        end
      end

      BC_REGEX = Regexp.new('(\d{1,4}).*' + Regexp.escape('B.C.'))

      # get String sortable value for B.C. if we have  B.C. pattern
      #  note that these values must *lexically* sort to create a chronological sort.
      #  We know our data does not contain B.C. dates older than 999, so we can make them
      #  lexically sort by subtracting 1000.  So we get:
      #    -700 for 300 B.C., -750 for 250 B.C., -800 for 200 B.C., -801 for 199 B.C.
      # @param [String] date_str String containing B.C.
      # @return [String, nil] String sortable -ddd if B.C. in pattern; nil otherwise
      def self.sortable_year_for_bc(date_str)
        bc_matches = date_str.match(BC_REGEX) if date_str
        return ($1.to_i - 1000).to_s if bc_matches
      end

      # get single facet value for B.C. if we have  B.C. pattern
      # @param [String] date_str String containing B.C.
      # @return [String, nil] ddd B.C.  if ddd B.C. in pattern; nil otherwise
      def self.facet_string_for_bc(date_str)
        bc_matches = date_str.match(BC_REGEX) if date_str
        return bc_matches.to_s if bc_matches
      end

      EARLY_NUMERIC = Regexp.new('^\-?\d{1,3}$')

      # get String sortable value from date String containing yyy, yy, y, -y, -yy, -yyy
      #  note that these values must *lexically* sort to create a chronological sort.
      #  We know our data does not contain negative dates older than -999, so we can make them
      #  lexically sort by subtracting 1000.  So we get:
      #    -983 for -17, -999 for -1, 0000 for 0, 0001 for 1, 0017 for 17
      # @param [String] date_str String containing yyy, yy, y, -y, -yy, -yyy
      # @return [String, nil] String sortable -ddd if date_str matches pattern; nil otherwise
      def self.sortable_year_for_early_numeric(date_str)
        return unless date_str.match(EARLY_NUMERIC)
        if date_str.match(/^\-/)
          # negative number becomes x - 1000 for sorting; -005 for -995
          num = date_str[1..-1].to_i - 1000
          return '-' + num.to_s[1..-1].rjust(3, '0')
        else
          return date_str.rjust(4, '0')
        end
      end

      # get single facet value for date String containing yyy, yy, y, -y, -yy, -yyy
      #   negative number strings will be changed to B.C. strings
      #   positive number strings will be left padded with zeros for clarity in the facet
      # @param [String] date_str String containing yyy, yy, y, -y, -yy, -yyy
      def self.facet_string_for_early_numeric(date_str)
        return unless date_str.match(EARLY_NUMERIC)
        # negative number becomes B.C.
        return date_str[1..-1] + " B.C." if date_str.match(/^\-/)
        date_str.rjust(4, '0')
      end

      # NOTE:  while Date.parse() works for many dates, the *sortable_year_for_yyyy
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