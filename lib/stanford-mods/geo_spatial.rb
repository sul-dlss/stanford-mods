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

      def point_bbox
        coordinates.map do |n|
          matches = n.match(/^\(?([^)]+)\)?\.?$/)

          if matches
            coord_to_bbox(matches[1])
          else
            coord_to_bbox(n)
          end
        end.compact
      end

      private

      def coord_to_bbox(coord)
        matches = coord.match %r{\A(?<lat>[EW].+-+.+)\s*/\s*(?<lng>[NS].+-+.+)\Z}
        return unless matches

        min_x, max_x = matches['lat'].split(/-+/).map { |x| coord_to_decimal(x) }.minmax
        min_y, max_y = matches['lng'].split(/-+/).map { |y| coord_to_decimal(y) }.minmax

        "#{min_x} #{min_y} #{max_x} #{max_y}" if valid_bbox?(min_x, max_x, min_y, max_y)
      end

      def coord_to_decimal(point)
        regex = /(?<dir>[NESW])\s*(?<deg>\d+)[°⁰º](?:(?<min>\d+)[ʹ'])?(?:(?<sec>\d+)[ʺ"])?/
        match = regex.match(point)

        return Float::INFINITY unless match

        dec = match['deg'].to_i
        dec += match['min'].to_f / 60
        dec += match['sec'].to_f / 60 / 60
        dec = -1 * dec if match['dir'] == 'W' || match['dir'] == 'S'

        dec
      end

      def valid_bbox?(min_x, max_x, min_y, max_y)
        range_x = -180.0..180.0
        range_y = -90.0..90.0

        range_x.include?(min_x) && range_x.include?(max_x) && range_y.include?(min_y) && range_y.include?(max_y)
      end
    end # class Record
  end # Module Mods
end # Module Stanford
