# This file is for reference as I implement the searchworks.rb mixin file
#  it is a bunch of methods from the old dor-sw-ingest code 
module Stanford
  module Mods

    def empty?
      mods_xml.xpath('//text()').empty?
    end

    # Determine what language(s) this record declares
    # Use iso-639 to translate codes into English words 
    # @return Array
    def language
      languages = []
      language_codes.each do |code|
        begin
          csv_codes = code.to_s.split(/[,|\ ]/)
          csv_codes = csv_codes.delete_if {|x| x.strip.length==0 } 
          csv_codes.each do |c|
            languages << ISO_639.find(c.to_s.strip).english_name
          end
        rescue => e
          SearchWorksOaiHarvester.logger.error "Couldn't find english name for #{code.to_s}"
          # SearchWorksOaiHarvester.logger.error e
          languages << code.to_s
        end
      end

      language_words.each do |word|
        if word.to_s.strip.length > 0
          languages << word.to_s.strip
        end
      end
      return nil if languages.uniq.empty?
      return languages.uniq
    end

    # Interpret the various permutations of dateCreated
    # @param [Nokogiri::XML::Element] node
    def date_created
      if create_start_date.length > 0 && create_end_date.length > 0
        return "#{start_date} - #{end_date}"
      else
        return node.xpath('//dateCreated/text()').to_s
      end
    end

    def date_created_or_issued
      begin
        return date_created unless date_created.nil? or date_created.length == 0
        return date_issued unless date_issued.nil? or date_issued.length == 0
        nil
      rescue
        nil
      end
    end

    # A single value for publication year (this will need refinement over time)
    # @return String
    def pub_year(year = date_created_or_issued)
      year[/[0-9]{4}/]
    end




    # TODO: Ask Jessie what the valid values are here
    # @return String
    def display_type
      return "image" if is_an_image?
      return "image" if is_a_map?
      return "collection" if is_a_collection?
      nil
    end

    # Check to see if this item is a map
    # @return Boolean
    def is_a_map?
      return true if mods_xml.xpath('//typeOfResource/text()').to_s.match(/^[Cc]artographic/)
      return true if mods_xml.xpath('//genre[@authority="marcgt"]/text()').to_s.match(/^[Mm]ap/)
      return true if mods_xml.xpath('//physicalDescription/form/text()').to_s.match(/[Mm]ap/)
      return true if mods_xml.xpath('//physicalDescription/internetMediaType/text()').to_s.match(/[Mm]ap/)
      false
    end

    # Check to see if this item is an Image
    # @return Boolean
    def is_an_image?
      return true if mods_xml.xpath('//typeOfResource/text()').to_s.match(/still image/)
      false
    end

    # Objects can belong to a collection by reference (handled in solr_mapper.rb), 
    # or they can declare themselves part of a collection in MODS
    # e.g., Revs does it like this:
    # <mods:relatedItem type="host">
    #   <mods:titleInfo>
    #     <mods:title>The Collier Collection of the Revs Institute for Automotive Research</mods:title>
    #   </mods:titleInfo>
    #   <mods:typeOfResource collection="yes"/>
    # </mods:relatedItem>
    def declared_collections
      c = []
      collection_nodes = mods_xml.xpath("//relatedItem/typeOfResource[@collection='yes']")
      collection_nodes.each do |node|
        c << node.xpath('../titleInfo/title/text()').to_s
      end
      c
    end

    # Check to see if this item is a collection
    # @return Boolean
    def is_a_collection?
      return true if mods_xml.xpath("/mods/typeOfResource/@collection").to_s == 'yes'
      false
    end

    def physical_description_form
      form = mods_xml.xpath('//physicalDescription/form/text()').to_s
      media_type = mods_xml.xpath('//physicalDescription/internetMediaType/text()').to_s
      if form != media_type && form
        form
      elsif media_type
        media_type
      else
        nil
      end
    end



    # Accept a nokogiri representation of a mods titleInfo element
    # Return a formatted string of the title it describes
    # @param node Nokogiri::XML::Element 
    # @return String
    def extract_title_from_title_info(node)
      "#{node.xpath('nonSort/text()')} #{node.xpath('title/text()')}".strip
    end

    # Accept a nokogiri representation of a mods titleInfo element
    # Return a formatted string of the title it describes
    # @param node Nokogiri::XML::Element 
    # @return String
    def extract_full_title_from_title_info(node)
      title = "#{node.xpath('nonSort/text()')} #{node.xpath('title/text()')}".strip
      unless node.xpath('subTitle/text()').empty?
        title = "#{title}: #{node.xpath('subTitle/text()')}"
      end
      return title
    end

    

  end
end
