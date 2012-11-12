require "stanford-mods/mappings"
require "stanford-mods/version"
require 'mods'

# Stanford specific wranglings of MODS metadata as an extension of the Mods::Record object
module Stanford
  module Mods

    class Record < ::Mods::Record
      
      # proof of concept method
      def to_be_removed
        puts "in to_be_removed!"
      end
      
    end
  end
end
