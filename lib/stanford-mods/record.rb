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

      attr_writer :druid
      attr_writer :logger

      def druid
        @druid || 'Unknown item'
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end # Record class
  end # Mods module
end # Stanford module
