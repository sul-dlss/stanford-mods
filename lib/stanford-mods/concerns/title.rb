module Stanford
  module Mods
    module Title
      # @return [String] value for title_245a_search field
      def sw_short_title
        short_titles&.compact&.reject(&:empty?)&.first
      end

      # Searchworks requires that the MODS has a '//titleInfo/title'
      # @return [String] value for title_245_search, title_full_display
      def sw_full_title(title_info = first_title_info_node, sortable: false)
        return unless title_info&.children&.any?

        title = title_info.title&.text&.strip
        return if title.nil? || title.empty?

        title = ''
        previous_element = nil

        title_info.children.select { |value| title_parts.include? value.name }.each do |value|
          next if value.name == 'nonSort' && sortable

          str = value.text.strip
          next if str.empty?

          delimiter = if title.empty? || title.end_with?(' ')
                        nil
                      elsif previous_element&.name == 'nonSort' && title.end_with?('-', '\'')
                        nil
                      elsif title.end_with?('.', ',', ':', ';')
                        ' '
                      elsif value.name == 'subTitle'
                        ' : '
                      elsif value.name == 'partName' && previous_element.name == 'partNumber'
                        ', '
                      elsif value.name == 'partNumber' || value.name == 'partName'
                        '. '
                      else
                        ' '
                      end

          title += delimiter if delimiter
          title += str

          previous_element = value
        end

        title += "." unless title =~ /\s*[[:punct:]]$/

        title.strip
      end

      def title_parts
        %w[nonSort title subTitle partName partNumber]
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

      private

      # @return [Nokogiri::XML::Node] the first titleInfo node if present, else nil
      def first_title_info_node
        non_blank_nodes = mods_ng_xml.title_info.reject { |node| node.text.strip.empty? }
        non_blank_nodes.find { |node| node.type_at != 'alternative' } || non_blank_nodes.first
      end
    end
  end
end
