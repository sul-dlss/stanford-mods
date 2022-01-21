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
        result = nil
        first_wo_role = nil
        mods_ng_xml.plain_name.each { |n|
          first_wo_role ||= n if n.role.empty?
          n.role.each { |r|
            if r.authority.include?('marcrelator') &&
                 r.value.any? { |v| v.match(/creator/i) || v.match?(/author/i) }
              result ||= n.display_value_w_date
            end
          }
        }
        result = first_wo_role.display_value_w_date if !result && first_wo_role
        result
      end # main_author

      # all names, in display form, except the main_author
      #  names will be the display_value_w_date form
      #  see Mods::Record.name  in nom_terminology for details on the display_value algorithm
      def additional_authors_w_dates
        results = []
        mods_ng_xml.plain_name.each { |n|
          results << n.display_value_w_date
        }
        results.delete(main_author_w_date)
        results
      end

      # @return Array of Strings, each containing the computed display value of a personal name
      #   except for the collector role (see mods gem nom_terminology for display value algorithm)
      # FIXME:  this is broken if there are multiple role codes and some of them are not marcrelator
      def non_collector_person_authors
        result = []
        mods_ng_xml.personal_name.map do |n|
          next if n.role.size.zero?

          n.role.each { |r|
            result << n.display_value_w_date unless includes_marc_relator_collector_role?(r)
          }
        end
        result unless result.empty?
      end

      # @return Array of Strings, each containing the computed display value of
      #  a personal name with the role of Collector (see mods gem nom_terminology for display value algorithm)
      def collectors_w_dates
        result = []
        mods_ng_xml.personal_name.each do |n|
          next if n.role.size.zero?

          n.role.each { |r|
            result << n.display_value_w_date if includes_marc_relator_collector_role?(r)
          }
        end
        result unless result.empty?
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
