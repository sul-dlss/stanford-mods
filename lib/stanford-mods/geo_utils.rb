# encoding: utf-8
module Stanford
  module Mods
    # Abstract geo methods usable to several classes
    module GeoUtils
      # @param [String] val Coordinates value
      # @return [String] cleaned value (strips parens and period), or the original value
      def cleaner_coordinate(val)
        matches = val.match(/^\(?([^)]+)\)?\.?$/)
        matches ? matches[1] : val
      end

      # @param [String] point coordinate point in degrees notation
      # @return [Float] converted value in decimal notation
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
    end
  end
end
