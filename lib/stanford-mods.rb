require 'mods'
require 'stanford-mods/date_parsing'
require 'stanford-mods/coordinate'
require 'stanford-mods/geo_spatial'
require 'stanford-mods/name'
require 'stanford-mods/origin_info'
require 'stanford-mods/physical_location'
require 'stanford-mods/searchworks'
require 'stanford-mods/version'

# Stanford specific wranglings of MODS metadata as an extension of the Mods::Record object
module Stanford
  module Mods
    class Record < ::Mods::Record
    end # Record class
  end # Mods module
end # Stanford module
