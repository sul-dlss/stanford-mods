# Kolb Collection specific wranglings of MODS metadata as an extension of the Mods::Record object
module Stanford
  module Mods

    class KolbRecord < Record
      
      require 'stanford-mods/searchworks'
      
      # NAOMI_MUST_COMMENT_THIS_METHOD
      def publish_date
        
      end
      
    end
  end
end
