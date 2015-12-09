require 'logger'
require 'mods'

# Parsing date strings in mods
# These methods may be used by searchworks.rb file or by downstream apps
module Stanford
  module Mods
    class Record < ::Mods::Record
      # @param [String] date_str String containing date (we hope)
      # @return [String, nil] sortable 4 digit year (e.g. 1865, 0950) if date_str is parseable via ruby Date, nil otherwise
      def self.year_via_ruby_parsing(date_str)
        return unless date_str.match(/\d\d/) # need at least 2 digits
        return if date_str.match(/^\D*\d\d\D*$/) # need more in string than only 2 digits
        return if date_str.match(/\d\s*B.C./) # skip B.C. dates
        date_obj = Date.parse(date_str)
        date_obj.year.to_s
      rescue
        nil # explicitly want nil if date won't parse
      end
    end
  end
end