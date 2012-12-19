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
      def main_author
        result = nil
        first_no_role = nil
        @mods_ng_xml.plain_name.each { |n|
          if n.role.size == 0
            first_no_role ||= n
          end
          n.role.each { |r|              
            if r.authority.include?('marcrelator') && 
                  (r.value.include?('Creator') || r.value.include?('Author'))
              if n.displayForm.size > 0
                result ||= n.displayForm.text
              elsif n.type_at == 'personal' && n.family_name.size > 0
                result ||= n.given_name.size > 0 ? n.family_name.text + ', ' + n.given_name.text : n.family_name.text
              else
                result ||= n.namePart.text
              end
            end          
          }
        }
        if !result && first_no_role
          if first_no_role.displayForm.size > 0
            result = first_no_role.displayForm.text
          elsif first_no_role.type_at == 'personal' && first_no_role.family_name.size > 0
            result = first_no_role.given_name.size > 0 ? first_no_role.family_name.text + ', ' + first_no_role.given_name.text : first_no_role.family_name.text
          else
            result = first_no_role.namePart.text
          end
        end
# FIXME:  need method to create display name from name node        
        result
      end # main_author
      
      
            
    end # Record class
  end # Mods module
end # Stanford module
