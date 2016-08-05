require 'mods'

module Stanford
  module Mods
    # Parsing MODS //location/physicalLocation for series, box, and folder for Special Collections.
    # This is not used by Searchworks, otherwise it would have been in the searchworks.rb file.
    # Note: mods_ng_xml_location.physicalLocation should find top level and relatedItem.
    # Each method here expects to find at most ONE matching element.  Subsequent potential matches
    # are ignored.
    class Record < ::Mods::Record
      # data in location/physicalLocation or in relatedItem/location/physicalLocation
      # so use _location to get the data from either one of them
      # @return [String] box number (note: single valued and might be something like 35A)
      # @todo should it be hierarchical series/box/folder?
      def box
        mods_ng_xml._location.physicalLocation.each do |node|
          match_data = node.text.match(/Box ?:? ?([^,|(Folder)]+)/i) # note that this will also find Flatbox or Flat-box
          return match_data[1].strip if match_data.present?
        end
        nil
      end

      # data in location/physicalLocation or in relatedItem/location/physicalLocation
      # so use _location to get the data from either one of them
      # @return [String] folder number (note: single valued)
      # @todo should it be hierarchical series/box/folder?
      def folder
        mods_ng_xml._location.physicalLocation.each do |node|
          val = node.text
          match_data = val =~ /\|/ ?
                       val.match(/Folder ?:? ?([^|]+)/) : # expect pipe-delimited, may contain commas within values
                       val.match(/Folder ?:? ?([^,]+)/)   # expect comma-delimited, may NOT contain commas within values
          return match_data[1].strip if match_data.present?
        end
        nil
      end

      # but only if it has series, accession, box or folder data
      # data in location/physicalLocation or in relatedItem/location/physicalLocation
      # so use _location to get the data from either one of them
      # @return [String] entire contents of physicalLocation as a string (note: single valued)
      # @note there is a "physicalLocation" and a "location" method defined in the mods gem, so we cannot use these names to avoid conflicts
      # @todo should it be hierarchical series/box/folder?
      def physical_location_str
        mods_ng_xml._location.physicalLocation.map(&:text).find do |text|
          text =~ /.*(Series)|(Accession)|(Folder)|(Box).*/i
        end
      end

      # data in location/physicalLocation or in relatedItem/location/physicalLocation
      # so use _location to get the data from either one of them
      # @return [String] series/accession 'number' (note: single valued)
      # @todo should it be hierarchical series/box/folder?
      def series
        mods_ng_xml._location.physicalLocation.each do |node|
          # feigenbaum uses 'Accession'
          match_data = node.text.match(/(?:(?:Series)|(?:Accession)):? ([^,|]+)/i)
          return match_data[1].strip if match_data.present?
        end
        nil
      end
    end # class Record
  end # Module Mods
end # Module Stanford
