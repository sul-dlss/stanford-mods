# encoding: UTF-8
require 'stanford-mods/searchworks_languages'

# SearchWorks specific wranglings of MODS metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods

    class Record < ::Mods::Record
      
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
                # TODO:  this should be written to a logger
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
      
      
      # ---- AUTHOR ----
      
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
        @mods_ng_xml.plain_name.select {|n| n.type_at != 'personal'}.map { |n| n.display_value_w_date }
      end
      
      # @return [Array<String>] values for author_corp_display
      def sw_corporate_authors
        @mods_ng_xml.plain_name.select {|n| n.type_at == 'corporate'}.map { |n| n.display_value_w_date }
      end
      
      # @return [Array<String>] values for author_meeting_display
      def sw_meeting_authors
        @mods_ng_xml.plain_name.select {|n| n.type_at == 'conference'}.map { |n| n.display_value_w_date }
      end
      
      # Returns a sortable version of the main_author:
    	#  main_author + sorting title
    	# which is the mods approximation of the value created for a marc record
      # @return [String] value for author_sort field
      def sw_sort_author
        #  substitute java Character.MAX_CODE_POINT for nil main_author so missing main authors sort last
        val = '' + (main_author_w_date ? main_author_w_date : "\u{FFFF} ") + ( sort_title ? sort_title : '')
        val.gsub(/[[:punct:]]*/, '').strip
      end
      
      # ---- TITLE ----

      # @return [String] value for title_245a_search field
      def sw_short_title
        short_titles ? short_titles.first : nil
      end
      
      # @return [String] value for title_245_search, title_display, title_full_display
      def sw_full_title
        full_titles ? full_titles.find { |s| s =~ Regexp.new(Regexp.escape(sw_short_title)) } : nil
      end
      
      # this includes all titles except 
      # @return [Array<String>] values for title_variant_search
      def sw_addl_titles
        full_titles.select { |s| s !~ Regexp.new(Regexp.escape(sw_short_title)) }
      end
      
      # Returns a sortable version of the main title
      # @return [String] value for title_sort field
      def sw_sort_title
        val = '' + ( sort_title ? sort_title : '')
        val.gsub(/[[:punct:]]*/, '').strip
      end
      
      # ---- SUBJECT ----
      
      # Values are the contents of:
      #   subject/geographic
      #   subject/hierarchicalGeographic
      #   subject/geographicCode  (only include the translated value if it isn't already present from other mods geo fields)
      # @param [String] sep - the separator string for joining hierarchicalGeographic sub elements
      # @return [Array<String>] values for geographic_search Solr field for this document or [] if none
      def sw_geographic_search(sep = ' ')
        result = term_values([:subject, :geographic]) || []
        
        # hierarchicalGeographic has sub elements
        @mods_ng_xml.subject.hierarchicalGeographic.each { |hg_node|  
          hg_vals = []
          hg_node.element_children.each { |e| 
            hg_vals << e.text unless e.text.empty?
          }
          result << hg_vals.join(sep) unless hg_vals.empty?
        }

        trans_code_vals = @mods_ng_xml.subject.geographicCode.translated_value
        if trans_code_vals
          trans_code_vals.each { |val|  
            result << val if !result.include?(val)
          }
        end

        result    
      end
      
      # Values are the contents of:
      #   subject/name/namePart
      #  "Values from namePart subelements should be concatenated in the order they appear (e.g. "Shakespeare, William, 1564-1616")"
      # @param [String] sep - the separator string for joining namePart sub elements
      # @return [Array<String>] values for names inside subject elements or [] if none
      def sw_subject_names(sep = ', ')
        result = []
        @mods_ng_xml.subject.name_el.select { |n_el| n_el.namePart }.each { |name_el_w_np|  
          parts = name_el_w_np.namePart.map { |npn| npn.text unless npn.text.empty? }.compact
          result << parts.join(sep).strip unless parts.empty?
        }
        result
      end
      
      # Values are the contents of:
      #   subject/titleInfo/(subelements)
      # @param [String] sep - the separator string for joining titleInfo sub elements
      # @return [Array<String>] values for titles inside subject elements or [] if none
      def sw_subject_titles(sep = ' ')
        result = []
        @mods_ng_xml.subject.titleInfo.each { |ti_el|
          parts = ti_el.element_children.map { |el| el.text unless el.text.empty? }.compact
          result << parts.join(sep).strip unless parts.empty?
        }
        result
      end
            
    end # class Record
  end # Module Mods
end # Module Stanford
