# frozen_string_literal: true

# NON-SearchWorks specific wranglings of MODS <name> metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods
    module Name
      # @return [String] value for author_1xx_search field
      def sw_main_author
        main_author_w_date
      end

      # @return [Array<String>] values for author_7xx_search field
      def sw_addl_authors
        additional_authors_w_dates
      end

      # @return [Array<String>] values for author_person_facet, author_person_display
      def sw_person_authors
        personal_names_w_dates
      end

      # return the display_value_w_date for all <mods><name> elements that do not have type='personal'
      # @return [Array<String>] values for author_other_facet
      def sw_impersonal_authors
        mods_ng_xml.plain_name.select { |n| n.type_at != 'personal' }.map(&:display_value_w_date)
      end

      # @return [Array<String>] values for author_corp_display
      def sw_corporate_authors
        mods_ng_xml.corporate_name.map(&:display_value_w_date)
      end

      # @return [Array<String>] values for author_meeting_display
      def sw_meeting_authors
        mods_ng_xml.conference_name.map(&:display_value_w_date)
      end

      # Returns a sortable version of the main_author:
      #  main_author + sorting title
      # which is the mods approximation of the value created for a marc record
      # @return [String] value for author_sort field
      def sw_sort_author
        #  substitute java Character.MAX_CODE_POINT for nil main_author so missing main authors sort last
        val = '' + (main_author_w_date ? main_author_w_date : "\u{10FFFF} ") + (sort_title ? sort_title : '')
        val.gsub(/[[:punct:]]*/, '').strip
      end

      # the first encountered <mods><name> element with marcrelator flavor role of 'Creator' or 'Author'.
      # if no marcrelator 'Creator' or 'Author', the first name without a role.
      # if no name without a role, then nil
      # @return [String] a name in the display_value_w_date form
      # see Mods::Record.name  in nom_terminology for details on the display_value algorithm
      # @private
      def main_author_w_date
        result = mods_ng_xml.plain_name.find { |n| n.role.any? { |r| r.authority.include?('marcrelator') && r.value.any? { |v| v.match(/creator/i) || v.match?(/author/i) } } }
        result ||= mods_ng_xml.plain_name.find { |n| n.role.empty? }

        result&.display_value_w_date
      end # main_author

      # all names, in display form, except the main_author
      #  names will be the display_value_w_date form
      #  see Mods::Record.name  in nom_terminology for details on the display_value algorithm
      # @private
      def additional_authors_w_dates
        mods_ng_xml.plain_name.map(&:display_value_w_date) - [main_author_w_date]
      end

      # @return Array of Strings, each containing the computed display value of a personal name
      #   except for the collector role (see mods gem nom_terminology for display value algorithm)
      def non_collector_person_authors
        mods_ng_xml.personal_name.select { |n| n.role.any? }.reject { |n| n.role.all? { |r| includes_marc_relator_collector_role?(r) } }.map(&:display_value_w_date)
      end

      # @return Array of Strings, each containing the computed display value of
      #  a personal name with the role of Collector (see mods gem nom_terminology for display value algorithm)
      def collectors_w_dates
        mods_ng_xml.personal_name.select { |n| n.role.any? }.select { |n| n.role.any? { |r| includes_marc_relator_collector_role?(r) } }.map(&:display_value_w_date)
      end

      COLLECTOR_ROLE_URI = 'http://id.loc.gov/vocabulary/relators/col'.freeze

      # @param Nokogiri::XML::Node role_node the role node from a parent name node
      # @return true if there is a MARC relator collector role assigned
      def includes_marc_relator_collector_role?(role_node)
        (role_node.authority.include?('marcrelator') && role_node.value.include?('Collector')) ||
        role_node.roleTerm.valueURI.first == COLLECTOR_ROLE_URI
      end
    end # class Record
  end # Module Mods
end # Module Stanford
