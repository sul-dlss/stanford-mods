# encoding: UTF-8
require 'stanford-mods/searchworks_languages'
require 'logger'
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
              end
            else
              vals = ct.text.split(/[,|\ ]/).reject {|x| x.strip.length == 0 } 
              vals.each do |v|
                result << SEARCHWORKS_LANGUAGES[v.strip]
              end
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
        val = @mods_ng_xml.plain_name.select {|n| n.type_at == 'corporate'}.map { |n| n.display_value_w_date }
        val
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
        val = '' + (main_author_w_date ? main_author_w_date : "\u{10FFFF} ") + ( sort_title ? sort_title : '')
        val.gsub(/[[:punct:]]*/, '').strip
      end
      
      def main_author_w_date_test
        result = nil
        first_wo_role = nil
        self.plain_name.each { |n|
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
      end

      # ---- end AUTHOR ----
      
      # ---- TITLE ----

      # @return [String] value for title_245a_search field
      def sw_short_title
        short_titles ? short_titles.first : nil
      end
      
      # @return [String] value for title_245_search, title_full_display
      def sw_full_title
        outer_nodes = @mods_ng_xml.title_info
        outer_node = outer_nodes ? outer_nodes.first : nil
        if outer_node
          nonSort = outer_node.nonSort.text.strip.empty? ? nil : outer_node.nonSort.text.strip
          title = outer_node.title.text.strip.empty? ? nil: outer_node.title.text.strip
          preSubTitle = nonSort ? [nonSort, title].compact.join(" ") : title
          preSubTitle.sub!(/:$/, '') if preSubTitle # remove trailing colon

          subTitle = outer_node.subTitle.text.strip
          preParts = subTitle.empty? ? preSubTitle : preSubTitle + " : " + subTitle
          preParts.sub!(/\.$/, '') if preParts # remove trailing period
          
          partName = outer_node.partName.text.strip unless outer_node.partName.text.strip.empty?
          partNumber = outer_node.partNumber.text.strip unless outer_node.partNumber.text.strip.empty?
          partNumber.sub!(/,$/, '') if partNumber # remove trailing comma
          if partNumber && partName
            parts = partNumber + ", " + partName
          elsif partNumber
            parts = partNumber
          elsif partName
            parts = partName
          end
          parts.sub!(/\.$/, '') if parts

          result = parts ? preParts + ". " + parts : preParts
          result += "." if !result.match(/[[:punct:]]$/)
          result.strip!
          result = nil if result.empty?
          result
        else
          nil
        end
      end

      # like sw_full_title without trailing \,/;:.
      # spec from solrmarc-sw   sw_index.properties
      #    title_display = custom, removeTrailingPunct(245abdefghijklmnopqrstuvwxyz, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
      # @return [String] value for title_display (like title_full_display without trailing punctuation)
      def sw_title_display
        result = sw_full_title ? sw_full_title : nil
        if result
          result.sub!(/[\.,;:\/\\]+$/, '')
          result.strip!
        end
        result
      end
      
      # this includes all titles except 
      # @return [Array<String>] values for title_variant_search
      def sw_addl_titles
        full_titles.select { |s| s !~ Regexp.new(Regexp.escape(sw_short_title)) }
      end
      
      # Returns a sortable version of the main title
      # @return [String] value for title_sort field
      def sw_sort_title
        # get nonSort piece
        outer_nodes = @mods_ng_xml.title_info
        outer_node = outer_nodes ? outer_nodes.first : nil
        if outer_node
          nonSort = outer_node.nonSort.text.strip.empty? ? nil : outer_node.nonSort.text.strip
        end
        
        val = '' + ( sw_full_title ? sw_full_title : '')
        val.sub!(Regexp.new("^" + nonSort), '') if nonSort
        val.gsub!(/[[:punct:]]*/, '').strip
        val.squeeze(" ").strip
      end
      
      #remove trailing commas
      # @deprecated in favor of sw_title_display
      def sw_full_title_without_commas
        result = self.sw_full_title
        result.sub!(/,$/, '') if result
        result
      end
    
      # ---- end TITLE ----

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
            
      # Values are the contents of:
      #   mods/genre
      #   mods/subject/topic
      # @return [Array<String>] values for the topic_search Solr field for this document or nil if none
      def topic_search
        @topic_search ||= begin
          vals = self.term_values(:genre) || []
          vals.concat(subject_topics) if subject_topics
          vals.empty? ? nil : vals
        end
      end

      # Values are the contents of:
      #   subject/topic
      #   subject/name
      #   subject/title
      #   subject/occupation
      #  with trailing comma, semicolon, and backslash (and any preceding spaces) removed
      # @return [Array<String>] values for the topic_facet Solr field for this document or nil if none 
      def topic_facet
        vals = subject_topics ? Array.new(subject_topics) : []
        vals.concat(subject_names) if subject_names
        vals.concat(subject_titles) if subject_titles
        vals.concat(subject_occupations) if subject_occupations
        vals.map! { |val| 
          v = val.sub(/[\\,;]$/, '')
          v.strip
        }
        vals.empty? ? nil : vals
      end

      # geographic_search values with trailing comma, semicolon, and backslash (and any preceding spaces) removed
      # @return [Array<String>] values for the geographic_facet Solr field for this document or nil if none 
      def geographic_facet
        geographic_search.map { |val| val.sub(/[\\,;]$/, '').strip } unless !geographic_search
      end

      # subject/temporal values with trailing comma, semicolon, and backslash (and any preceding spaces) removed
      # @return [Array<String>] values for the era_facet Solr field for this document or nil if none 
      def era_facet
        subject_temporal.map { |val| val.sub(/[\\,;]$/, '').strip } unless !subject_temporal
      end

      # Values are the contents of:
      #   subject/geographic
      #   subject/hierarchicalGeographic
      #   subject/geographicCode  (only include the translated value if it isn't already present from other mods geo fields)
      # @return [Array<String>] values for the geographic_search Solr field for this document or nil if none
      def geographic_search
        @geographic_search ||= begin
          result = self.sw_geographic_search

          # TODO:  this should go into stanford-mods ... but then we have to set that gem up with a Logger
          # print a message for any unrecognized encodings
          xvals = self.subject.geographicCode.translated_value
          codes = self.term_values([:subject, :geographicCode]) 
          if codes && codes.size > xvals.size
            self.subject.geographicCode.each { |n|
              if n.authority != 'marcgac' && n.authority != 'marccountry'
                sw_logger.info("#{druid} has subject geographicCode element with untranslated encoding (#{n.authority}): #{n.to_xml}")
              end
            }
          end

          # FIXME:  stanford-mods should be returning [], not nil ... 
          return nil if !result || result.empty?
          result
        end
      end

      # Values are the contents of:
      #   subject/name
      #   subject/occupation  - no subelements
      #   subject/titleInfo
      # @return [Array<String>] values for the subject_other_search Solr field for this document or nil if none
      def subject_other_search
        @subject_other_search ||= begin
          vals = subject_occupations ? Array.new(subject_occupations) : []
          vals.concat(subject_names) if subject_names
          vals.concat(subject_titles) if subject_titles
          vals.empty? ? nil : vals
        end
      end

      # Values are the contents of:
      #   subject/temporal
      #   subject/genre
      # @return [Array<String>] values for the subject_other_subvy_search Solr field for this document or nil if none
      def subject_other_subvy_search
        @subject_other_subvy_search ||= begin
          vals = subject_temporal ? Array.new(subject_temporal) : []
          gvals = self.term_values([:subject, :genre])
          vals.concat(gvals) if gvals

          # print a message for any temporal encodings
          self.subject.temporal.each { |n| 
            sw_logger.info("#{druid} has subject temporal element with untranslated encoding: #{n.to_xml}") if !n.encoding.empty?
          }

          vals.empty? ? nil : vals
        end
      end
      
      # Values are the contents of:
      #  all subject subelements except subject/cartographic plus  genre top level element
      # @return [Array<String>] values for the subject_all_search Solr field for this document or nil if none
      def subject_all_search
        vals = topic_search ? Array.new(topic_search) : []
        vals.concat(geographic_search) if geographic_search
        vals.concat(subject_other_search) if subject_other_search
        vals.concat(subject_other_subvy_search) if subject_other_subvy_search
        vals.empty? ? nil : vals
      end

      # ---- end SUBJECT ----

      # ---- PUBLICATION (place, year) ----
      def place
        vals = self.term_values([:origin_info,:place,:placeTerm])
        vals
      end

      # For the date display only, the first place to look is in the dates without encoding=marc array.
      # If no such dates, select the first date in the dates_marc_encoding array.  Otherwise return nil
      # @return [String] value for the pub_date_display Solr field for this document or nil if none
      def pub_date_display
          return dates_no_marc_encoding.first unless dates_no_marc_encoding.empty?
          return dates_marc_encoding.first unless dates_marc_encoding.empty?
          return nil
      end

      # For the date indexing, sorting and faceting, the first place to look is in the dates with encoding=marc array.
      # If that doesn't exist, look in the dates without encoding=marc array.  Otherwise return nil
      # @return [Array<String>] values for the date Solr field for this document or nil if none
      def pub_dates
        return dates_marc_encoding unless dates_marc_encoding.empty?
        return dates_no_marc_encoding unless dates_no_marc_encoding.empty?
        return nil
      end
      
      def is_number?(object)
        true if Integer(object) rescue false
      end
      def is_date?(object)
        true if Date.parse(object) rescue false
      end
  
      # Get the publish year from mods
      # @return [String] 4 character year or nil if no valid date was found
      def pub_year
        #use the cached year if there is one
        if @pub_year
          if @pub_year == ''
            return nil
          end
          return @pub_year
        end
        dates = pub_dates
        if dates
          year = []
          pruned_dates = []
          dates.each do |f_date|
            #remove ? and [] 
            pruned_dates << f_date.gsub('?','').gsub('[','').gsub(']','')
          end
          #try to find a date starting with the most normal date formats and progressing to more wonky ones
          @pub_year = get_plain_four_digit_year pruned_dates
          return @pub_year if @pub_year
          # Check for years in u notation, e.g., 198u
          @pub_year = get_u_year pruned_dates
          return @pub_year if @pub_year
          @pub_year = get_double_digit_century pruned_dates
          return @pub_year if @pub_year
          @pub_year = get_bc_year pruned_dates
          return @pub_year if @pub_year
          @pub_year = get_three_digit_year pruned_dates
          return @pub_year if @pub_year
          @pub_year = get_single_digit_century pruned_dates
          return @pub_year if @pub_year
        end
        @pub_year=''
        return nil
      end
      
      #creates a date suitable for sorting. Guarnteed to be 4 digits or nil
      def pub_date_sort
        pd=nil
        if pub_date
          pd=pub_date
          if pd.length == 3
            pd='0'+pd
          end
          pd=pd.gsub('--','00')
        end
        raise "pub_date_sort was about to return a non 4 digit value #{pd}!" if pd and pd.length !=4 
        pd
      end
      
      #The year the object was published, , filtered based on max_pub_date and min_pub_date from the config file
      #@return [String] 4 character year or nil
      def pub_date
        val=pub_year
        if val
          return val
        end
        nil
      end
      
      #Values for the pub date facet. This is less strict than the 4 year date requirements for pub_date
      #@return <Array[String]> with values for the pub date facet
      def pub_date_facet
        if pub_date
          if pub_date.start_with?('-')
            return (pub_date.to_i + 1000).to_s + ' B.C.'
          end
          if pub_date.include? '--'
            cent=pub_date[0,2].to_i
            cent+=1
            cent=cent.to_s+'th century'
            return cent
          else
            return pub_date
          end
        else
          nil
        end
      end
      
      # ---- end PUBLICATION (place, year) ----

      def sw_logger
        @logger ||= Logger.new(STDOUT)
      end
      
      # select one or more format values from the controlled vocabulary here:
      #   http://searchworks-solr-lb.stanford.edu:8983/solr/select?facet.field=format&rows=0&facet.sort=index
      # @return <Array[String]> value in the SearchWorks controlled vocabulary
      # @deprecated - kept for backwards compatibility but not part of SW UI redesign work Summer 2014
      def format
        val = []
        types = self.term_values(:typeOfResource)
        if types
          genres = self.term_values(:genre)
          issuance = self.term_values([:origin_info,:issuance])
          types.each do |type|
            case type
              when 'cartographic'
                val << 'Map/Globe'
              when 'mixed material'
                val << 'Manuscript/Archive'
              when 'moving image'
                val << 'Video'
              when 'notated music'
                val << 'Music - Score'
              when 'software, multimedia'
                val << 'Computer File'
              when 'sound recording-musical'
                val << 'Music - Recording'
              when 'sound recording-nonmusical', 'sound recording'
                val << 'Sound Recording'
              when 'still image'
                val << 'Image'
              when 'text'
                val << 'Book' if issuance and issuance.include? 'monographic'
                book_genres = ['book chapter', 'Book chapter', 'Book Chapter',
                  'issue brief', 'Issue brief', 'Issue Brief', 
                  'librettos', 'Librettos', 
                  'project report', 'Project report', 'Project Report',
                  'technical report', 'Technical report', 'Technical Report',
                  'working paper', 'Working paper', 'Working Paper']
                val << 'Book' if genres and !(genres & book_genres).empty?
                conf_pub = ['conference publication', 'Conference publication', 'Conference Publication']
                val << 'Conference Proceedings' if genres and !(genres & conf_pub).empty?
                val << 'Journal/Periodical' if issuance and issuance.include? 'continuing'
                article = ['article', 'Article']
                val << 'Journal/Periodical' if genres and !(genres & article).empty?
                stu_proj_rpt = ['student project report', 'Student project report', 'Student Project report', 'Student Project Report']
                val << 'Other' if genres and !(genres & stu_proj_rpt).empty?
                thesis = ['thesis', 'Thesis']
                val << 'Thesis' if genres and !(genres & thesis).empty?
              when 'three dimensional object'
                val << 'Other'
            end
          end
        end
        val.uniq
      end

      # select one or more format values from the controlled vocabulary per JVine Summer 2014
      #   http://searchworks-solr-lb.stanford.edu:8983/solr/select?facet.field=format_main_ssim&rows=0&facet.sort=index
      # @return <Array[String]> value in the SearchWorks controlled vocabulary
      def format_main
        val = []
        types = self.term_values(:typeOfResource)
        if types
          genres = self.term_values(:genre)
          issuance = self.term_values([:origin_info,:issuance])
          types.each do |type|
            case type
              when 'cartographic'
                val << 'Map'
              when 'mixed material'
                val << 'Archive/Manuscript'
              when 'moving image'
                val << 'Video'
              when 'notated music'
                val << 'Music score'
              when 'software, multimedia'
                if genres and (genres.include?('dataset') || genres.include?('Dataset'))
                  val << 'Dataset'
                else
                  val << 'Software/Multimedia'
                end
              when 'sound recording-musical'
                val << 'Music recording'
              when 'sound recording-nonmusical', 'sound recording'
                val << 'Sound recording'
              when 'still image'
                val << 'Image'
              when 'text'
                article_genres = ['article', 'Article',
                  'book chapter', 'Book chapter', 'Book Chapter',
                  'issue brief', 'Issue brief', 'Issue Brief',
                  'project report', 'Project report', 'Project Report',
                  'student project report', 'Student project report', 'Student Project report', 'Student Project Report',
                  'technical report', 'Technical report', 'Technical Report',
                  'working paper', 'Working paper', 'Working Paper'
                  ]
                val << 'Book' if genres and !(genres & article_genres).empty?
                val << 'Book' if issuance and issuance.include? 'monographic'
                book_genres = ['conference publication', 'Conference publication', 'Conference Publication',
                  'instruction', 'Instruction',
                  'librettos', 'Librettos',
                  'thesis', 'Thesis'
                  ]
                val << 'Book' if genres and !(genres & book_genres).empty?
                val << 'Journal/Periodical' if issuance and issuance.include? 'continuing'
              when 'three dimensional object'
                val << 'Object'
            end
          end
        end
        val.uniq
      end

      # return values for the genre facet in SearchWorks
      # @return <Array[String]>
      def sw_genre
        val = []
        genres = self.term_values(:genre)
        if genres
          val << genres.map(&:capitalize)
          val.flatten! if !val.empty?
          if genres.include?('thesis') || genres.include?('Thesis')
            val << 'Thesis/Dissertation'
            val.delete 'Thesis'
          end
          conf_pub = ['conference publication', 'Conference publication', 'Conference Publication']
          if !(genres & conf_pub).empty?
            types = self.term_values(:typeOfResource)
            if types && types.include?('text')
              val << 'Conference proceedings'
              val.delete 'Conference publication'
            end
          end
        end
        val.uniq
      end

      # @return [String] value with the numeric catkey in it, or nil if none exists
      def catkey
        catkey=self.term_values([:record_info,:recordIdentifier])
        if catkey and catkey.length>0
          return catkey.first.gsub('a','') #need to ensure catkey is numeric only
        end
        nil
      end
      def druid= new_druid
        @druid=new_druid
      end
      def druid
        @druid ? @druid : 'Unknown item'
      end

# protected ----------------------------------------------------------

      # convenience method for subject/name/namePart values (to avoid parsing the mods for the same thing multiple times)
      def subject_names
        @subject_names ||= self.sw_subject_names
      end

      # convenience method for subject/occupation values (to avoid parsing the mods for the same thing multiple times)
      def subject_occupations
        @subject_occupations ||= self.term_values([:subject, :occupation])
      end

      # convenience method for subject/temporal values (to avoid parsing the mods for the same thing multiple times)
      def subject_temporal
        @subject_temporal ||= self.term_values([:subject, :temporal])
      end

      # convenience method for subject/titleInfo values (to avoid parsing the mods for the same thing multiple times)
      def subject_titles
        @subject_titles ||= self.sw_subject_titles
      end

      # convenience method for subject/topic values (to avoid parsing the mods for the same thing multiple times)
      def subject_topics
        @subject_topics ||= self.term_values([:subject, :topic])
      end
  
      #get a 4 digit year like 1865 from the date array
      def get_plain_four_digit_year dates
        dates.each do |f_date|
          matches=f_date.scan(/\d{4}/)
          if matches.length == 1
            @pub_year=matches.first 
            return matches.first
          else
            #if there are multiples, check for ones with CE after them
            matches.each do |match|
              #look for things like '1865-6 CE'
              pos = f_date.index(Regexp.new(match+'...CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match+' CE') or pos > 0
                @pub_year=match
                return match  
              end 
            end
            return matches.first
          end
        end
        return nil
      end
      
      # If a year has a "u" in it, replace instances of u with 0
      # @param [String] dates
      # @return String
      def get_u_year dates
        dates.each do |f_date|
          # Single digit u notation
          matches = f_date.scan(/\d{3}u/)
          if matches.length == 1
            return matches.first.gsub('u','0')
          end
          # Double digit u notation
          matches = f_date.scan(/\d{2}u{2}/)
          if matches.length == 1
            return matches.first.gsub('u','-')
          end
        end
        return nil
      end
  
      #get a double digit century like '12th century' from the date array
      def get_double_digit_century dates
        dates.each do |f_date|
          matches=f_date.scan(/\d{2}th/)
          if matches.length == 1
            @pub_year=((matches.first[0,2].to_i)-1).to_s+'--'
            return @pub_year
          end
          #if there are multiples, check for ones with CE after them
          if matches.length > 0
            matches.each do |match|
              pos = f_date.index(Regexp.new(match+'...CE'))
              pos = pos ? pos.to_i : f_date.index(Regexp.new(match+' century CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match+' CE') or pos > 0
                @pub_year=((match[0,2].to_i) - 1).to_s+'--'
                return @pub_year
              end 
            end
          end
        end
        return nil
      end
  
      #get a 3 digit year like 965 from the date array
      def get_three_digit_year dates
        dates.each do |f_date|
          matches=f_date.scan(/\d{3}/)
          if matches.length > 0
            return matches.first
          end
        end
        return nil
      end
      #get the 3 digit BC year, return it as a negative, so -700 for 300 BC. Other methods will translate it to proper display, this is good for sorting.
      def get_bc_year dates
        dates.each do |f_date|
          matches=f_date.scan(/\d{3} B.C./)
          if matches.length > 0   
            bc_year=matches.first[0..2]
            return (bc_year.to_i-1000).to_s
          end
        end
        return nil
      end
  
      #get a single digit century like '9th century' from the date array
      def get_single_digit_century dates
        dates.each do |f_date|
          matches=f_date.scan(/\d{1}th/)
          if matches.length == 1
            @pub_year=((matches.first[0,2].to_i)-1).to_s+'--'
            return @pub_year
          end
          #if there are multiples, check for ones with CE after them
          if matches.length > 0
            matches.each do |match|
              pos = f_date.index(Regexp.new(match+'...CE'))
              pos = pos ? pos.to_i : f_date.index(Regexp.new(match+' century CE'))
              pos = pos ? pos.to_i : 0
              if f_date.include?(match+' CE') or pos > 0
                @pub_year=((match[0,1].to_i) - 1).to_s+'--'
                return @pub_year
              end 
            end
          end
        end 
        return nil
      end

      # @return [Array<String>] dates from dateIssued and dateCreated tags from origin_info with encoding="marc"
      def dates_marc_encoding
        @dates_marc_encoding ||= begin
          parse_dates_from_originInfo
          @dates_marc_encoding
        end
      end

      # @return [Array<String>] dates from dateIssued and dateCreated tags from origin_info with encoding not "marc"
      def dates_no_marc_encoding
        @dates_no_marc_encoding ||= begin
          parse_dates_from_originInfo
          @dates_no_marc_encoding
        end
      end

      # Populate @dates_marc_encoding and @dates_no_marc_encoding from dateIssued and dateCreated tags from origin_info 
      # with and without encoding=marc
      def parse_dates_from_originInfo
        @dates_marc_encoding = []
        @dates_no_marc_encoding = []
        self.origin_info.dateIssued.each { |di|
          if di.encoding == "marc"
            @dates_marc_encoding << di.text
          else
            @dates_no_marc_encoding << di.text
          end
        }
        self.origin_info.dateCreated.each { |dc|
          if dc.encoding == "marc"
            @dates_marc_encoding << dc.text
          else
            @dates_no_marc_encoding << dc.text
          end
        }
      end
    end # class Record
  end # Module Mods
end # Module Stanford
