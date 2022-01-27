# frozen_string_literal: true

# NON-SearchWorks specific wranglings of MODS <name> metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods
    module Name
      # the first encountered <mods><name> element with marcrelator flavor role of 'Creator' or 'Author'.
      # if no marcrelator 'Creator' or 'Author', the first name without a role.
      # if no name without a role, then nil
      # @return [String] a name in the display_value_w_date form
      # see Mods::Record.name  in nom_terminology for details on the display_value algorithm
      def main_author_w_date
        result = mods_ng_xml.plain_name.find { |n| n.role.any? { |r| r.authority.include?('marcrelator') && r.value.any? { |v| v.match(/creator/i) || v.match?(/author/i) } } }
        result ||= mods_ng_xml.plain_name.find { |n| n.role.empty? }

        result&.display_value_w_date
      end # main_author

      # all names, in display form, except the main_author
      #  names will be the display_value_w_date form
      #  see Mods::Record.name  in nom_terminology for details on the display_value algorithm
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
