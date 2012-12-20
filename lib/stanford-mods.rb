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
        first_wo_role = nil
        @mods_ng_xml.plain_name.each { |n|
          if n.role.size == 0
            first_wo_role ||= n
          end
          n.role.each { |r|
            if r.authority.include?('marcrelator') && 
                  (r.value.include?('Creator') || r.value.include?('Author'))
              result ||= n.display_value
            end          
          }
        }
        if !result && first_wo_role
          result = first_wo_role.display_value
        end
        result
      end # main_author
      
      
            
    end # Record class
  end # Mods module
end # Stanford module
