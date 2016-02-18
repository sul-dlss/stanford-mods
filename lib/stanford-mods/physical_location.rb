require 'logger'
require 'mods'

# Parsing MODS //location/physicalLocation for series, box, and folder for Special Collections
# This is not used by Searchworks, otherwise it would have been in the searchworks.rb file
module Stanford
  module Mods
    class Record < ::Mods::Record
      # return box number (note: single valued and might be something like 35A)
      #   data in location/physicalLocation or in relatedItem/location/physicalLocation
      #   so use _location to get the data from either one of them
      # TODO:  should it be hierarchical series/box/folder?
      def box
        #   _location.physicalLocation should find top level and relatedItem
        box_num = @mods_ng_xml._location.physicalLocation.map do |node|
          val = node.text
          # note that this will also find Flatbox or Flat-box
          match_data = val.match(/Box ?:? ?([^,|(Folder)]+)/i)
          match_data[1].strip if match_data.present?
        end.compact

        # There should only be one box
        box_num.first
      end

      # returns folder number (note: single valued)
      #   data in location/physicalLocation or in relatedItem/location/physicalLocation
      #   so use _location to get the data from either one of them
      # TODO:  should it be hierarchical series/box/folder?
      def folder
        #   _location.physicalLocation should find top level and relatedItem
        folder_num = @mods_ng_xml._location.physicalLocation.map do |node|
          val = node.text

          match_data = if val =~ /\|/
                         # we assume the data is pipe-delimited, and may contain commas within values
                         val.match(/Folder ?:? ?([^|]+)/)
                       else
                         # the data should be comma-delimited, and may not contain commas within values
                         val.match(/Folder ?:? ?([^,]+)/)
                       end

          match_data[1].strip if match_data.present?
        end.compact

        # There should be one folder
        folder_num.first
      end

      # return entire contents of physicalLocation as a string (note: single valued)
      #   but only if it has series, accession, box or folder data
      #   data in location/physicalLocation or in relatedItem/location/physicalLocation
      #   so use _location to get the data from either one of them
      # TODO:  should it be hierarchical series/box/folder?
      # NOTE: there is a "physicalLocation" and a "location" method defined in the mods gem, so we cannot use these names to avoid conflicts
      def physical_location_str
        #   _location.physicalLocation should find top level and relatedItem
        loc = @mods_ng_xml._location.physicalLocation.map do |node|
          node.text if node.text.match(/.*(Series)|(Accession)|(Folder)|(Box).*/i)
        end.compact

        # There should only be one location
        loc.first
      end

      # return series/accession 'number' (note: single valued)
      #   data in location/physicalLocation or in relatedItem/location/physicalLocation
      #   so use _location to get the data from either one of them
      # TODO: should it be hierarchical series/box/folder?
      def series
        #   _location.physicalLocation should find top level and relatedItem
        series_num = @mods_ng_xml._location.physicalLocation.map do |node|
          val = node.text
          # feigenbaum uses 'Accession'
          match_data = val.match(/(?:(?:Series)|(?:Accession)):? ([^,|]+)/i)
          match_data[1].strip if match_data.present?
        end.compact

        # There should be only one series
        series_num.first
      end
    end # class Record
  end # Module Mods
end # Module Stanford
