# encoding: UTF-8
require 'mods'

module Stanford
  module Mods
    # NON-SearchWorks specific wranglings of MODS cartographics metadata
    class Record < ::Mods::Record
      GMLNS = 'http://www.opengis.net/gml/3.2/'.freeze

      # @return [Array{String}] subject cartographic coordinates values
      def coordinates
        Array(mods_ng_xml.subject.cartographics.coordinates).map(&:text)
      end

      # @return [Array{String}] values suitable for solr SRPT fields, like "ENVELOPE(-16.0, 28.0, 13.0, -15.0)"
      # @note example xml leaf nodes
      #  <gml:lowerCorner>-122.191292 37.4063388</gml:lowerCorner>
      #  <gml:upperCorner>-122.149475 37.4435369</gml:upperCorner>
      def geo_extensions_as_envelope
        mods_ng_xml.extension
                   .xpath(
                     '//rdf:RDF/rdf:Description/gml:boundedBy/gml:Envelope',
                     'gml' => GMLNS,
                     'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
                   ).map do |v|
                     uppers = v.xpath('gml:upperCorner', 'gml' => GMLNS).text.split
                     lowers = v.xpath('gml:lowerCorner', 'gml' => GMLNS).text.split
                     "ENVELOPE(#{lowers[0]}, #{uppers[0]}, #{uppers[1]}, #{lowers[1]})"
                   end
      rescue RuntimeError => e
        logger.warn "failure parsing <extension> element: #{e.message}"
        []
      end

      # @return [Array{Stanford::Mods::Coordinate}] valid coordinates as objects
      def coordinates_objects
        coordinates.map { |n| Stanford::Mods::Coordinate.new(n) }.select(&:valid?)
      end

      # @return [Array{String}] values suitable for solr SRPT fields, like "ENVELOPE(-16.0, 28.0, 13.0, -15.0)"
      def coordinates_as_envelope
        coordinates_objects.map(&:as_envelope).compact
      end

      # @return [Array{String}] with 4-part space-delimted strings, like "-16.0 -15.0 28.0 13.0"
      def coordinates_as_bbox
        coordinates_objects.map(&:as_bbox).compact
      end

      alias point_bbox coordinates_as_bbox
    end
  end
end
