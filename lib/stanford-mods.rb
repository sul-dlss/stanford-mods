require "stanford-mods/mappings"
require "stanford-mods/version"
require 'mods'

# Stanford specific wranglings of MODS metadata as an extension of the Mods::Record object
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
            
    end # Record class
  end # Mods module
end # Stanford module
