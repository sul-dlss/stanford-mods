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
        @mods_ng_xml.plain_name.each { |n|
          n.role.each { |r|              
            if r.authority.include?('marcrelator') && 
                  (r.value.include?('Creator') || r.value.include?('Author'))
              if n.displayForm.size > 0
                return n.displayForm.text
              elsif n.type_at == 'personal' && n.family_name.size > 0
                return n.given_name.size > 0 ? n.family_name.text + ', ' + n.given_name.text : n.family_name.text
              else
                return n.namePart.text
              end
            end          
          }
        }
      end # main_author
            
    end # Record class
  end # Mods module
end # Stanford module
