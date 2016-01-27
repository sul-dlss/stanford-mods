# encoding: UTF-8
require 'logger'
require 'mods'

module Stanford
  module Mods
    # NON-SearchWorks specific wranglings of MODS cartographics metadata
    class Record < ::Mods::Record
      def coordinates
        Array(@mods_ng_xml.subject.cartographics.coordinates).map(&:text)
      end

      def coordinates_as_envelope
        coordinates.map do |n|
          c = Stanford::Mods::Coordinate.new(n)

          c.as_envelope if c.valid?
        end.compact
      end

      def coordinates_as_bbox
        coordinates.map do |n|
          c = Stanford::Mods::Coordinate.new(n)

          c.as_bbox if c.valid?
        end.compact
      end

      alias point_bbox coordinates_as_bbox
    end # class Record
  end # Module Mods
end # Module Stanford
