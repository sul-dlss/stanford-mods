# Stanford specific wranglings of MODS metadata as an extension of the Mods::Record object
module Stanford
  module Mods
    class Record < ::Mods::Record
      include Stanford::Mods::Geospatial
      include Stanford::Mods::Name
      include Stanford::Mods::OriginInfo
      include Stanford::Mods::PhysicalLocation
      include Stanford::Mods::SearchworksSubjects
      include Stanford::Mods::Searchworks
      include Stanford::Mods::Title

      attr_writer :druid

      def druid
        @druid || 'Unknown item'
      end
    end # Record class
  end # Mods module
end # Stanford module
