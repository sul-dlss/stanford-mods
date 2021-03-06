module Stanford
  module Mods
    # Parsing date strings
    # TODO:  this should become its own gem and/or become eclipsed by/merged with timetwister gem
    #   When this is "gemified":
    #     - we may want an integer or date sort field as well as lexical
    #     - we could add methods like my_date.bc?
    class DateParsing
      # get display value for year, generally an explicit year or "17th century" or "5 B.C." or "1950s" or '845 A.D.'
      # @return [String, nil] display value for year if we could parse one, nil otherwise
      def self.date_str_for_display(date_str)
        DateParsing.new(date_str).date_str_for_display
      end

      # get year as Integer if we can parse date_str to get a year.
      # @return [Integer, nil] Integer year if we could parse one, nil otherwise
      def self.year_int_from_date_str(date_str)
        DateParsing.new(date_str).year_int_from_date_str
      end

      # get String sortable value year if we can parse date_str to get a year.
      #   SearchWorks currently uses a string field for pub date sorting; thus so does Spotlight.
      #   The values returned must *lexically* sort in chronological order, so the B.C. dates are tricky
      # @return [String, nil] String sortable year if we could parse one, nil otherwise
      #  note that these values must *lexically* sort to create a chronological sort.
      def self.sortable_year_string_from_date_str(date_str)
        DateParsing.new(date_str).sortable_year_string_from_date_str
      end

      # true if the year is between -999 and (current year + 1)
      # @param [String] year_str String containing a date in format: -yyy, -yy, -y, y, yy, yyy, yyyy
      # @return [Boolean] true if the year is between -999 and (current year + 1); false otherwise
      def self.year_str_valid?(year_str)
        return false unless year_str && (year_str.match(/^\d{1,4}$/) || year_str.match(/^-\d{1,3}$/))

        (-1000 < year_str.to_i) && (year_str.to_i < Date.today.year + 2)
      end

      # true if the year is between -9999 and (current year + 1)
      # @return [Boolean] true if the year is between -9999 and (current year + 1); false otherwise
      def self.year_int_valid?(year)
        return false unless year.is_a? Integer

        (-1000 < year.to_i) && (year < Date.today.year + 2)
      end

      attr_reader :orig_date_str

      def initialize(date_str)
        @orig_date_str = date_str
        @orig_date_str.freeze
      end

      BRACKETS_BETWEEN_DIGITS_REXEXP = Regexp.new('\d[' + Regexp.escape('[]') + ']\d')

      # get display value for year, generally an explicit year or "17th century" or "5 B.C." or "1950s" or '845 A.D.'
      # @return [String, nil] String value for year if we could parse one, nil otherwise
      def date_str_for_display
        return if orig_date_str == '0000-00-00' # shpc collection has these useless dates
        # B.C. first in case there are 4 digits, e.g. 1600 B.C.
        return display_str_for_bc if orig_date_str.match(BC_REGEX)
        # decade next in case there are 4 digits, e.g. 1950s
        return display_str_for_decade if orig_date_str.match(DECADE_4CHAR_REGEXP) || orig_date_str.match(DECADE_S_REGEXP)

        result = sortable_year_for_yyyy_or_yy
        unless result
          # try removing brackets between digits in case we have 169[5] or [18]91
          no_brackets = remove_brackets
          return DateParsing.new(no_brackets).date_str_for_display if no_brackets
        end
        # parsing below this line gives string inapprop for year_str_valid?
        unless self.class.year_str_valid?(result)
          result = display_str_for_century
          result ||= display_str_for_early_numeric
        end
        # remove leading 0s from early dates
        result = "#{result.to_i} A.D." if result && result.match(/^0\d+$/)
        result
      end

      # get Integer year if we can parse date_str to get a year.
      # @return [Integer, nil] Integer year if we could parse one, nil otherwise
      def year_int_from_date_str
        return if orig_date_str == '0000-00-00' # shpc collection has these useless dates
        # B.C. first in case there are 4 digits, e.g. 1600 B.C.
        return sortable_year_int_for_bc if orig_date_str.match(BC_REGEX)

        result = sortable_year_for_yyyy_or_yy
        result ||= sortable_year_for_decade # 19xx or 20xx
        result ||= sortable_year_for_century
        result ||= sortable_year_int_for_early_numeric
        unless result
          # try removing brackets between digits in case we have 169[5] or [18]91
          no_brackets = remove_brackets
          return DateParsing.new(no_brackets).year_int_from_date_str if no_brackets
        end
        result.to_i if result && self.class.year_int_valid?(result.to_i)
      end

      # get String sortable value year if we can parse date_str to get a year.
      #   SearchWorks currently uses a string field for pub date sorting; thus so does Spotlight.
      #   The values returned must *lexically* sort in chronological order, so the B.C. dates are tricky
      # @return [String, nil] String sortable year if we could parse one, nil otherwise
      #  note that these values must *lexically* sort to create a chronological sort.
      def sortable_year_string_from_date_str
        return if orig_date_str == '0000-00-00' # shpc collection has these useless dates
        # B.C. first in case there are 4 digits, e.g. 1600 B.C.
        return sortable_year_str_for_bc if orig_date_str.match(BC_REGEX)

        result = sortable_year_for_yyyy_or_yy
        result ||= sortable_year_for_decade # 19xx or 20xx
        result ||= sortable_year_for_century
        result ||= sortable_year_str_for_early_numeric
        unless result
          # try removing brackets between digits in case we have 169[5] or [18]91
          no_brackets = remove_brackets
          return DateParsing.new(no_brackets).sortable_year_string_from_date_str if no_brackets
        end
        result if self.class.year_str_valid?(result)
      end

      # get String sortable value year if we can parse date_str to get a year.
      # @return [String, nil] String sortable year if we could parse one, nil otherwise
      #  note that these values must *lexically* sort to create a chronological sort.
      def sortable_year_for_yyyy_or_yy
        # most date strings have a four digit year
        result = sortable_year_for_yyyy
        result ||= sortable_year_for_yy # 19xx or 20xx
        result
      end

      # removes brackets between digits such as 169[5] or [18]91
      def remove_brackets
        orig_date_str.delete('[]') if orig_date_str.match(BRACKETS_BETWEEN_DIGITS_REXEXP)
      end

      # looks for 4 consecutive digits in orig_date_str and returns first occurrence if found
      # @return [String, nil] 4 digit year (e.g. 1865, 0950) if orig_date_str has yyyy, nil otherwise
      def sortable_year_for_yyyy
        matches = orig_date_str.match(/\d{4}/) if orig_date_str
        matches.to_s if matches
      end

      # returns 4 digit year as String if we have a x/x/yy or x-x-yy pattern
      #   note that these are the only 2 digit year patterns found in our actual date strings in MODS records
      #   we use 20 as century digits unless it is greater than current year:
      #   1/1/15  ->  2015
      #   1/1/25  ->  1925
      # @return [String, nil] 4 digit year (e.g. 1865, 0950) if orig_date_str matches pattern, nil otherwise
      def sortable_year_for_yy
        return unless orig_date_str

        slash_matches = orig_date_str.match(/\d{1,2}\/\d{1,2}\/\d{2}/)
        if slash_matches
          date_obj = Date.strptime(orig_date_str, '%m/%d/%y')
        else
          hyphen_matches = orig_date_str.match(/\d{1,2}-\d{1,2}-\d{2}/)
          date_obj = Date.strptime(orig_date_str, '%m-%d-%y') if hyphen_matches
        end
        if date_obj && date_obj > Date.today
          date_obj = Date.new(date_obj.year - 100, date_obj.month, date_obj.mday)
        end
        date_obj.year.to_s if date_obj
      rescue ArgumentError
        nil # explicitly want nil if date won't parse
      end

      DECADE_4CHAR_REGEXP = Regexp.new('(^|\D)\d{3}[u\-?x]')

      # get first year of decade (as String) if we have:  yyyu, yyy-, yyy? or yyyx pattern
      #   note that these are the only decade patterns found in our actual date strings in MODS records
      # @return [String, nil] 4 digit year (e.g. 1860, 1950) if orig_date_str matches pattern, nil otherwise
      def sortable_year_for_decade
        decade_matches = orig_date_str.match(DECADE_4CHAR_REGEXP) if orig_date_str
        changed_to_zero = decade_matches.to_s.tr('u\-?x', '0') if decade_matches
        DateParsing.new(changed_to_zero).sortable_year_for_yyyy if changed_to_zero
      end

      DECADE_S_REGEXP = Regexp.new('\d{3}0\'?s')

      # get, e.g. 1950s, if we have:  yyyu, yyy-, yyy? or yyyx pattern or  yyy0s or yyy0's
      #   note that these are the only decade patterns found in our actual date strings in MODS records
      # @return [String, nil] 4 digit year with s (e.g. 1860s, 1950s) if orig_date_str matches pattern, nil otherwise
      def display_str_for_decade
        decade_matches = orig_date_str.match(DECADE_4CHAR_REGEXP) if orig_date_str
        if decade_matches
          changed_to_zero = decade_matches.to_s.tr('u\-?x', '0') if decade_matches
          zeroth_year = DateParsing.new(changed_to_zero).sortable_year_for_yyyy if changed_to_zero
          return "#{zeroth_year}s" if zeroth_year
        else
          decade_matches = orig_date_str.match(DECADE_S_REGEXP) if orig_date_str
          return decade_matches.to_s.tr("'", '') if decade_matches
        end
      end

      CENTURY_WORD_REGEXP = Regexp.new('(\d{1,2}).*century')
      CENTURY_4CHAR_REGEXP = Regexp.new('(\d{1,2})[u\-]{2}([^u\-]|$)')

      # get first year of century (as String) if we have:  yyuu, yy--, yy--? or xxth century pattern
      #   note that these are the only century patterns found in our actual date strings in MODS records
      # @return [String, nil] yy00 if orig_date_str matches pattern, nil otherwise; also nil if B.C. in pattern
      def sortable_year_for_century
        return unless orig_date_str
        return if orig_date_str =~ /B\.C\./

        century_matches = orig_date_str.match(CENTURY_4CHAR_REGEXP)
        if century_matches
          return $1 + '00' if $1.length == 2
          return '0' + $1 + '00' if $1.length == 1
        end
        century_str_matches = orig_date_str.match(CENTURY_WORD_REGEXP)
        if century_str_matches
          yy = ($1.to_i - 1).to_s
          return yy + '00' if yy.length == 2
          return '0' + yy + '00' if yy.length == 1
        end
      end

      # get display value for century (17th century) if we have:  yyuu, yy--, yy--? or xxth century pattern
      #   note that these are the only century patterns found in our actual date strings in MODS records
      # @return [String, nil] yy(th) Century if orig_date_str matches pattern, nil otherwise; also nil if B.C. in pattern
      def display_str_for_century
        return unless orig_date_str
        return if orig_date_str =~ /B\.C\./

        century_str_matches = orig_date_str.match(CENTURY_WORD_REGEXP)
        return century_str_matches.to_s if century_str_matches

        century_matches = orig_date_str.match(CENTURY_4CHAR_REGEXP)
        if century_matches
          require 'active_support/core_ext/integer/inflections'
          return "#{($1.to_i + 1).ordinalize} century"
        end
      end

      BC_REGEX = Regexp.new('(\d{1,4}).*' + Regexp.escape('B.C.'))

      # get String sortable value for B.C. if we have B.C. pattern
      #  note that these values must *lexically* sort to create a chronological sort.
      #  We know our data does not contain B.C. dates older than 999, so we can make them
      #  lexically sort by subtracting 1000.  So we get:
      #    -700 for 300 B.C., -750 for 250 B.C., -800 for 200 B.C., -801 for 199 B.C.
      # @return [String, nil] String sortable -ddd if B.C. in pattern; nil otherwise
      def sortable_year_str_for_bc
        bc_matches = orig_date_str.match(BC_REGEX) if orig_date_str
        ($1.to_i - 1000).to_s if bc_matches
      end

      # get Integer sortable value for B.C. if we have B.C. pattern
      # @return [Integer, nil] Integer sortable -ddd if B.C. in pattern; nil otherwise
      def sortable_year_int_for_bc
        bc_matches = orig_date_str.match(BC_REGEX) if orig_date_str
        "-#{$1}".to_i if bc_matches
      end

      # get display value for B.C. if we have  B.C. pattern
      # @return [String, nil] ddd B.C.  if ddd B.C. in pattern; nil otherwise
      def display_str_for_bc
        bc_matches = orig_date_str.match(BC_REGEX) if orig_date_str
        bc_matches.to_s if bc_matches
      end

      EARLY_NUMERIC = Regexp.new('^\-?\d{1,3}$')

      # get String sortable value from date String containing yyy, yy, y, -y, -yy, -yyy
      #  note that these values must *lexically* sort to create a chronological sort.
      #  We know our data does not contain negative dates older than -999, so we can make them
      #  lexically sort by subtracting 1000.  So we get:
      #    -983 for -17, -999 for -1, 0000 for 0, 0001 for 1, 0017 for 17
      # @return [String, nil] String sortable -ddd if orig_date_str matches pattern; nil otherwise
      def sortable_year_str_for_early_numeric
        return unless orig_date_str.match(EARLY_NUMERIC)

        if orig_date_str =~ /^\-/
          # negative number becomes x - 1000 for sorting; -005 for -995
          num = orig_date_str[1..-1].to_i - 1000
          return '-' + num.to_s[1..-1].rjust(3, '0')
        else
          return orig_date_str.rjust(4, '0')
        end
      end

      # get Integer sortable value from date String containing yyy, yy, y, -y, -yy, -yyy, -yyyy
      # @return [Integer, nil] Integer sortable -ddd if orig_date_str matches pattern; nil otherwise
      def sortable_year_int_for_early_numeric
        return orig_date_str.to_i if orig_date_str.match(EARLY_NUMERIC)

        orig_date_str.to_i if orig_date_str =~ /^-\d{4}$/
      end

      # get display value for date String containing yyy, yy, y, -y, -yy, -yyy
      #   negative number strings will be changed to B.C. strings
      # note that there is no year 0:  from https://en.wikipedia.org/wiki/Anno_Domini
      # "AD counting years from the start of this epoch, and BC denoting years before the start of the era.
      # There is no year zero in this scheme, so the year AD 1 immediately follows the year 1 BC."
      # See also https://consul.stanford.edu/display/chimera/MODS+display+rules for etdf
      def display_str_for_early_numeric
        return unless orig_date_str.match(EARLY_NUMERIC)
        # return 1 B.C. when the date is 0 since there is no 0 year
        return '1 B.C.' if orig_date_str == '0'
        # negative number becomes B.C.
        return "#{orig_date_str[1..-1].to_i + 1} B.C." if orig_date_str =~ /^\-/

        # remove leading 0s from early dates
        "#{orig_date_str.to_i} A.D."
      end

      # NOTE:  while Date.parse() works for many dates, the *sortable_year_for_yyyy
      #   actually works for nearly all those cases and a lot more besides.  Trial and error
      #   with an extensive set of test data culled from actual date strings in our MODS records
      #   has made this method bogus.
      # @return [String, nil] sortable 4 digit year (e.g. 1865, 0950) if orig_date_str is parseable via ruby Date, nil otherwise
      def year_via_ruby_parsing
        return unless orig_date_str =~ /\d\d/ # need at least 2 digits
        # need more in string than only 2 digits
        return if orig_date_str.match(/^\d\d$/) || orig_date_str.match(/^\D*\d\d\D*$/)
        return if orig_date_str =~ /\d\s*B.C./ # skip B.C. dates

        date_obj = Date.parse(orig_date_str)
        date_obj.year.to_s
      rescue ArgumentError
        nil # explicitly want nil if date won't parse
      end
    end
  end
end
