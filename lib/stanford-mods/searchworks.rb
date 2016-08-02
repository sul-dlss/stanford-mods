# encoding: UTF-8
require 'stanford-mods/searchworks_languages'
require 'stanford-mods/searchworks_subjects'
require 'logger'
require 'mods'

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
            if ct.authority =~ /^iso639/
              begin
                vals = ct.text.split(/[,|\ ]/).reject { |x| x.strip.empty? }
                vals.each do |v|
                  iso639_val = ISO_639.find(v.strip).english_name
                  if SEARCHWORKS_LANGUAGES.has_value?(iso639_val)
                    result << iso639_val
                  else
                    result << SEARCHWORKS_LANGUAGES[v.strip]
                  end
                end
              rescue
                # TODO:  this should be written to a logger
                p "Couldn't find english name for #{ct.text}"
              end
            else
              vals = ct.text.split(/[,|\ ]/).reject { |x| x.strip.empty? }
              vals.each do |v|
                result << SEARCHWORKS_LANGUAGES[v.strip]
              end
            end
          }
          # add languageTerm text values
          n.text_term.each { |tt|
            val = tt.text.strip
            result << val if !val.empty? && SEARCHWORKS_LANGUAGES.has_value?(val)
          }

          # add language values that aren't in languageTerm subelement
          if n.languageTerm.empty?
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
        @mods_ng_xml.plain_name.select { |n| n.type_at != 'personal' }.map { |n| n.display_value_w_date }
      end

      # @return [Array<String>] values for author_corp_display
      def sw_corporate_authors
        @mods_ng_xml.plain_name.select { |n| n.type_at == 'corporate' }.map { |n| n.display_value_w_date }
      end

      # @return [Array<String>] values for author_meeting_display
      def sw_meeting_authors
        @mods_ng_xml.plain_name.select { |n| n.type_at == 'conference' }.map { |n| n.display_value_w_date }
      end

      # Returns a sortable version of the main_author:
      #  main_author + sorting title
      # which is the mods approximation of the value created for a marc record
      # @return [String] value for author_sort field
      def sw_sort_author
        #  substitute java Character.MAX_CODE_POINT for nil main_author so missing main authors sort last
        val = '' + (main_author_w_date ? main_author_w_date : "\u{10FFFF} ") + (sort_title ? sort_title : '')
        val.gsub(/[[:punct:]]*/, '').strip
      end

      def main_author_w_date_test
        result = nil
        first_wo_role = nil
        plain_name.each { |n|
          first_wo_role ||= n if n.role.empty?
          n.role.each { |r|
            if r.authority.include?('marcrelator') &&
              (r.value.include?('Creator') || r.value.include?('Author'))
              result ||= n.display_value_w_date
            end
          }
        }
        result = first_wo_role.display_value_w_date if !result && first_wo_role
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
        return nil unless outer_node
        nonSort = outer_node.nonSort.text.strip.empty? ? nil : outer_node.nonSort.text.strip
        title   = outer_node.title.text.strip.empty?   ? nil : outer_node.title.text.strip
        preSubTitle = nonSort ? [nonSort, title].compact.join(" ") : title
        preSubTitle.sub!(/:$/, '') if preSubTitle # remove trailing colon

        subTitle = outer_node.subTitle.text.strip
        preParts = subTitle.empty? ? preSubTitle : preSubTitle + " : " + subTitle
        preParts.sub!(/\.$/, '') if preParts # remove trailing period

        partName   = outer_node.partName.text.strip   unless outer_node.partName.text.strip.empty?
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
        result += "." unless result =~ /[[:punct:]]$/
        result.strip!
        result = nil if result.empty?
        result
      end

      # like sw_full_title without trailing \,/;:.
      # spec from solrmarc-sw   sw_index.properties
      #    title_display = custom, removeTrailingPunct(245abdefghijklmnopqrstuvwxyz, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
      # @return [String] value for title_display (like title_full_display without trailing punctuation)
      def sw_title_display
        result = sw_full_title
        return nil unless result
        result.sub(/[\.,;:\/\\]+$/, '').strip
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

        val = '' + (sw_full_title ? sw_full_title : '')
        val.sub!(Regexp.new("^" + Regexp.escape(nonSort)), '') if nonSort
        val.gsub!(/[[:punct:]]*/, '').strip
        val.squeeze(" ").strip
      end

      # remove trailing commas
      # @deprecated in favor of sw_title_display
      def sw_full_title_without_commas
        result = sw_full_title
        result.sub!(/,$/, '') if result
        result
      end

      # ---- end TITLE ----

      # ---- SUBJECT ----
      # see searchworks_subjects.rb
      # ---- end SUBJECT ----

      # ---- PUBLICATION (place, year) ----
      # see origin_info.rb  (as all this information comes from top level originInfo element)
      # ---- end PUBLICATION (place, year) ----

      def sw_logger
        @logger ||= Logger.new(STDOUT)
      end

      # select one or more format values from the controlled vocabulary here:
      #   http://searchworks-solr-lb.stanford.edu:8983/solr/select?facet.field=format&rows=0&facet.sort=index
      # @return <Array[String]> value in the SearchWorks controlled vocabulary
      # @deprecated - kept for backwards compatibility but not part of SW UI redesign work Summer 2014
      # @deprecated:  this is no longer used in SW, Revs or Spotlight Jan 2016
      def format
        types = term_values(:typeOfResource)
        return [] unless types
        genres = term_values(:genre)
        issuance = term_values([:origin_info, :issuance])
        val = []
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
              val << 'Book' if issuance && issuance.include?('monographic')
              book_genres = ['book chapter', 'Book chapter', 'Book Chapter',
                'issue brief', 'Issue brief', 'Issue Brief',
                'librettos', 'Librettos',
                'project report', 'Project report', 'Project Report',
                'technical report', 'Technical report', 'Technical Report',
                'working paper', 'Working paper', 'Working Paper']
              val << 'Book' if genres && !(genres & book_genres).empty?
              conf_pub = ['conference publication', 'Conference publication', 'Conference Publication']
              val << 'Conference Proceedings' if genres && !(genres & conf_pub).empty?
              val << 'Journal/Periodical' if issuance && issuance.include?('continuing')
              article = ['article', 'Article']
              val << 'Journal/Periodical' if genres && !(genres & article).empty?
              stu_proj_rpt = ['student project report', 'Student project report', 'Student Project report', 'Student Project Report']
              val << 'Other' if genres && !(genres & stu_proj_rpt).empty?
              thesis = ['thesis', 'Thesis']
              val << 'Thesis' if genres && !(genres & thesis).empty?
            when 'three dimensional object'
              val << 'Other'
          end
        end
        val.uniq
      end

      # select one or more format values from the controlled vocabulary per JVine Summer 2014
      #   http://searchworks-solr-lb.stanford.edu:8983/solr/select?facet.field=format_main_ssim&rows=0&facet.sort=index
      # https://github.com/sul-dlss/stanford-mods/issues/66 - For geodata, the
      # resource type should be only Map and not include Software, multimedia.
      # @return <Array[String]> value in the SearchWorks controlled vocabulary
      def format_main
        types = term_values(:typeOfResource)
        return [] unless types
        article_genres = ['article', 'Article',
          'book chapter', 'Book chapter', 'Book Chapter',
          'issue brief', 'Issue brief', 'Issue Brief',
          'project report', 'Project report', 'Project Report',
          'student project report', 'Student project report', 'Student Project report', 'Student Project Report',
          'technical report', 'Technical report', 'Technical Report',
          'working paper', 'Working paper', 'Working Paper'
        ]
        book_genres = ['conference publication', 'Conference publication', 'Conference Publication',
          'instruction', 'Instruction',
          'librettos', 'Librettos',
          'thesis', 'Thesis'
        ]
        val = []
        genres = term_values(:genre)
        issuance = term_values([:origin_info, :issuance])
        types.each do |type|
          case type
            when 'cartographic'
              val << 'Map'
              val.delete 'Software/Multimedia'
            when 'mixed material'
              val << 'Archive/Manuscript'
            when 'moving image'
              val << 'Video'
            when 'notated music'
              val << 'Music score'
            when 'software, multimedia'
              if genres && (genres.include?('dataset') || genres.include?('Dataset'))
                val << 'Dataset'
              elsif !val.include?('Map')
                val << 'Software/Multimedia'
              end
            when 'sound recording-musical'
              val << 'Music recording'
            when 'sound recording-nonmusical', 'sound recording'
              val << 'Sound recording'
            when 'still image'
              val << 'Image'
            when 'text'
              val << 'Book' if genres && !(genres & article_genres).empty?
              val << 'Book' if issuance && issuance.include?('monographic')
              val << 'Book' if genres && !(genres & book_genres).empty?
              val << 'Journal/Periodical' if issuance && issuance.include?('continuing')
              val << 'Archived website' if genres && genres.include?('archived website')
            when 'three dimensional object'
              val << 'Object'
          end
        end
        val.uniq
      end

      # https://github.com/sul-dlss/stanford-mods/issues/66
      # Limit genre values to Government document, Conference proceedings,
      # Technical report and Thesis/Dissertation
      # @return <Array[String]> values for the genre facet in SearchWorks
      def sw_genre
        genres = term_values(:genre)
        return [] unless genres
        types = term_values(:typeOfResource)
        val = []
        val << 'Thesis/Dissertation' if genres.include?('thesis') || genres.include?('Thesis')
        conf_pub = ['conference publication', 'Conference publication', 'Conference Publication']
        unless (genres & conf_pub).empty?
          val << 'Conference proceedings' if types && types.include?('text')
        end
        gov_pub = ['government publication', 'Government publication', 'Government Publication']
        unless (genres & gov_pub).empty?
          val << 'Government document' if types && types.include?('text')
        end
        tech_rpt = ['technical report', 'Technical report', 'Technical Report']
        unless (genres & tech_rpt).empty?
          val << 'Technical report' if types && types.include?('text')
        end
        val.uniq
      end

      # @return [String] value with the numeric catkey in it, or nil if none exists
      def catkey
        catkey = term_values([:record_info, :recordIdentifier])
        return nil unless catkey && !catkey.empty?
        catkey.first.tr('a', '') # ensure catkey is numeric only
      end

      attr_writer :druid

      def druid
        @druid || 'Unknown item'
      end
    end # class Record
  end # Module Mods
end # Module Stanford
