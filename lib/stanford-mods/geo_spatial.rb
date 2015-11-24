# encoding: UTF-8
require 'logger'
require 'mods'

# NON-SearchWorks specific wranglings of MODS cartographics metadata
module Stanford
  module Mods

    class Record < ::Mods::Record

      def coordinates
        Array(@mods_ng_xml.subject.cartographics.coordinates).map(&:text)
      end

      def point_bbox
        coordinates.map do |n|
          matches = n.match(/^\(([^)]+)\)\.?$/)
          next unless matches
          coord_to_bbox(matches[1])
        end.compact
      end

      private

      def coord_to_bbox(coord)
        lng, lat = coord.split('/')

        min_x, max_x = lng.split('--').map { |x| coord_to_decimal(x) }
        max_y, min_y = lat.split('--').map { |y| coord_to_decimal(y) }
        "#{min_x} #{min_y} #{max_x} #{max_y}"
      end

      def coord_to_decimal(point)
        regex = /(?<dir>[NESW])\s*(?<deg>\d+)°(?:(?<sec>\d+)ʹ)?/
        match = regex.match(point)
        dec = 0

        dec += match['deg'].to_i
        dec += match['sec'].to_f / 60
        dec = -1 * dec if match['dir'] == 'W' || match['dir'] == 'S'

        dec
      end
    end # class Record
  end # Module Mods
end # Module Stanford
