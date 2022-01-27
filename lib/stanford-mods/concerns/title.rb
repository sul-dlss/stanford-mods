module Stanford
  module Mods
    module Title

      # @return [String] value for title_245a_search field
      def sw_short_title
        short_titles ? short_titles.compact.reject(&:empty?).first : nil
      end

      # @return [Nokogiri::XML::Node] the first titleInfo node if present, else nil
      # @private
      def first_title_info_node
        non_blank_nodes = mods_ng_xml.title_info.reject { |node| node.text.strip.empty? }
        non_blank_nodes.find { |node| node.type_at != 'alternative' } || non_blank_nodes.first
      end

      # @return [String] the nonSort text portion of the titleInfo node as a string (if non-empty, else nil)
      # @private
      def nonSort_title
        return unless first_title_info_node && first_title_info_node.nonSort

        first_title_info_node.nonSort.text.strip.empty? ? nil : first_title_info_node.nonSort.text.strip
      end

      # @return [String] the text of the titleInfo node as a string (if non-empty, else nil)
      # @private
      def title
        return unless first_title_info_node && first_title_info_node.title

        first_title_info_node.title.text.strip.empty?   ? nil : first_title_info_node.title.text.strip
      end

      # Searchworks requires that the MODS has a '//titleInfo/title'
      # @return [String] value for title_245_search, title_full_display
      def sw_full_title(sortable: false)
        return nil if !first_title_info_node || !title

        preSubTitle = if !sortable && nonSort_title
          [nonSort_title, title].compact.join(" ")
        else
          title
        end

        preSubTitle.sub!(/:$/, '')

        subTitle = first_title_info_node.subTitle.text.strip
        preParts = subTitle.empty? ? preSubTitle : preSubTitle + " : " + subTitle
        preParts.sub!(/\.$/, '') if preParts # remove trailing period

        partName   = first_title_info_node.partName.text.strip   unless first_title_info_node.partName.text.strip.empty?
        partNumber = first_title_info_node.partNumber.text.strip unless first_title_info_node.partNumber.text.strip.empty?
        partNumber.sub!(/,$/, '') if partNumber # remove trailing comma
        if partNumber && partName
          parts = partNumber + ", " + partName
        elsif partNumber
          parts = partNumber
        elsif partName
          parts = partName
        end
        parts.sub!(/\.$/, '') if parts

        result = parts ? preParts + ". " + parts : preParts
        return nil unless result

        result += "." unless result =~ /[[:punct:]]$/
        result.strip!
        result = nil if result.empty?
        result
      end

      # like sw_full_title without trailing \,/;:.
      # spec from solrmarc-sw   sw_index.properties
      #    title_display = custom, removeTrailingPunct(245abdefghijklmnopqrstuvwxyz, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
      # @return [String] value for title_display (like title_full_display without trailing punctuation)
      def sw_title_display
        sw_full_title&.sub(/[\.,;:\/\\]+$/, '')&.strip
      end

      # this includes all titles except
      # @return [Array<String>] values for title_variant_search
      def sw_addl_titles
        (full_titles - first_title_info_node.full_title).reject(&:blank?)
      end

      # Returns a sortable version of the main title
      # @return [String] value for title_sort field
      def sw_sort_title
        val = sw_full_title(sortable: true) || ''
        val.gsub(/[[:punct:]]*/, '').squeeze(" ").strip
      end
    end
  end
end