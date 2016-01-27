# encoding: utf-8
module Stanford
  module Mods
    ##
    # Geospatial coordinate parsing
    class Coordinate
      attr_reader :value

      def initialize(value)
        @value = value
      end

      # Convert the coordinate to a WKT/CQL ENVELOPE representation
      def as_envelope
        return unless valid?

        "ENVELOPE(#{bounds[:min_x]}, #{bounds[:max_x]}, #{bounds[:min_y]}, #{bounds[:max_y]})"
      end

      # Convert the coordinate to a Solr 4.x bbox-format representation
      def as_bbox
        return unless valid?

        "#{bounds[:min_x]} #{bounds[:min_y]} #{bounds[:max_x]} #{bounds[:max_y]}"
      end

      def valid?
        return false if bounds.empty?

        range_x = -180.0..180.0
        range_y = -90.0..90.0

        range_x.include?(bounds[:min_x]) &&
          range_x.include?(bounds[:max_x]) &&
          range_y.include?(bounds[:min_y]) &&
          range_y.include?(bounds[:max_y])
      end

      private

      def bounds
        @bounds ||= begin
          matches = coord.match %r{\A(?<lat>[EW].+-+.+)\s*/\s*(?<lng>[NS].+-+.+)\Z}

          if matches
            min_x, max_x = matches['lat'].split(/-+/).map { |x| coord_to_decimal(x) }.minmax
            min_y, max_y = matches['lng'].split(/-+/).map { |y| coord_to_decimal(y) }.minmax

            { min_x: min_x, min_y: min_y, max_x: max_x, max_y: max_y }
          else
            {}
          end
        end
      end

      def coord
        matches = value.match(/^\(?([^)]+)\)?\.?$/)

        if matches
          matches[1]
        else
          value
        end
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
    end
  end
end