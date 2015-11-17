require 'stanford-mods/version'
require 'mods'
require 'stanford-mods/name'
require 'stanford-mods/searchworks'
require 'stanford-mods/physical_location'

# Stanford specific wranglings of MODS metadata as an extension of the Mods::Record object
module Stanford
  module Mods

    class Record < ::Mods::Record

    end # Record class
  end # Mods module
end # Stanford module
