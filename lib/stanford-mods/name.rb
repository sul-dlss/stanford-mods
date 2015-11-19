# encoding: UTF-8
require 'logger'
require 'mods'

# NON-SearchWorks specific wranglings of MODS <name> metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods

    class Record < ::Mods::Record

      # the first encountered <mods><name> element with marcrelator flavor role of 'Creator' or 'Author'.
      # if no marcrelator 'Creator' or 'Author', the first name without a role.
      # if no name without a role, then nil
      # @return [String] a name in the display_value_w_date form
      # see Mods::Record.name  in nom_terminology for details on the display_value algorithm
      def main_author_w_date
        result = nil
        first_wo_role = nil
        @mods_ng_xml.plain_name.each { |n|
          if n.role.size == 0
            first_wo_role ||= n
          end
          n.role.each { |r|
            if r.authority.include?('marcrelator') &&
                  (r.value.include?('Creator') || r.value.include?('Author'))
              result ||= n.display_value_w_date
            end
          }
        }
        if !result && first_wo_role
          result = first_wo_role.display_value_w_date
        end
        result
      end # main_author

      # all names, in display form, except the main_author
      #  names will be the display_value_w_date form
      #  see Mods::Record.name  in nom_terminology for details on the display_value algorithm
      def additional_authors_w_dates
        results = []
        @mods_ng_xml.plain_name.each { |n|
          results << n.display_value_w_date
        }
        results.delete(main_author_w_date)
        results
      end

      COLLECTOR_ROLE_URI = 'http://id.loc.gov/vocabulary/relators/col'

      # @return Array of Strings, each containing the computed display value of a personal name
      #   except for the collector role (see mods gem nom_terminology for display value algorithm)
      # FIXME:  this is broken if there are multiple role codes and some of them are not marcrelator
      def non_collector_person_authors
        result = []
        @mods_ng_xml.personal_name.map do |n|
          unless n.role.size == 0
            n.role.each { |r|
              unless (r.authority.include?('marcrelator') && r.value.include?('Collector')) ||
                      r.roleTerm.valueURI.first == COLLECTOR_ROLE_URI
                result << n.display_value_w_date
              end
            }
          end
        end
        result unless result.empty?
      end

      # @return Array of Strings, each containing the computed display value of
      #  a personal name with the role of Collector (see mods gem nom_terminology for display value algorithm)
      def collectors_w_dates
        result = []
        @mods_ng_xml.personal_name.each do |n|
          unless n.role.size == 0
            n.role.each { |r|
              if (r.authority.include?('marcrelator') && r.value.include?('Collector')) ||
                  r.roleTerm.valueURI.first == COLLECTOR_ROLE_URI
                result << n.display_value_w_date
              end
            }
          end
        end
        result unless result.empty?
      end

    end # class Record
  end # Module Mods
end # Module Stanford
