require 'stanford-mods/searchworks_languages'

# # SearchWorks specific wranglings of MODS metadata as an extension of the Mods::Record object
module Stanford
  module Mods

    class Record < ::Mods::Record
      
      # if it's coming from DOR, then it is available online
      def sw_access_facet
        ['Online']
      end
      
      # include langagues known to SearchWorks; try to error correct when possible (e.g. when ISO-639 disagrees with MARC standard)
      def sw_language_facet
        result = []
        @mods_ng_xml.language.each { |n| 
          # get languageTerm codes and add their translations to the result
          n.code_term.each { |ct| 
            if ct.authority.match(/^iso639/)
              begin
                vals = ct.text.split(/[,|\ ]/).reject {|x| x.strip.length == 0 } 
                vals.each do |v|
                  iso639_val = ISO_639.find(v.strip).english_name
                  if SEARCHWORKS_LANGUAGES.has_value?(iso639_val)
                    result << iso639_val
                  else
                    result << SEARCHWORKS_LANGUAGES[v.strip]
                  end
                end
              rescue => e
                p "Couldn't find english name for #{ct.text}"
                result << SEARCHWORKS_LANGUAGES[v.strip]
              end
            else
              result << SEARCHWORKS_LANGUAGES[v.strip]
            end
          }
          # add languageTerm text values
          n.text_term.each { |tt| 
            val = tt.text.strip
            result << val if val.length > 0 && SEARCHWORKS_LANGUAGES.has_value?(val)
          }

          # add language values that aren't in languageTerm subelement
          if n.languageTerm.size == 0
            result << n.text if SEARCHWORKS_LANGUAGES.has_value?(n.text)
          end
        }
        result.uniq
      end # language_facet
      
    end # class Record
  end # Module Mods
end # Module Stanford
