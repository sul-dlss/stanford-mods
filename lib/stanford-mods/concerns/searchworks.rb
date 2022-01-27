# frozen_string_literal: true

# SearchWorks specific wranglings of MODS metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods
    module Searchworks
      # include langagues known to SearchWorks; try to error correct when possible (e.g. when ISO-639 disagrees with MARC standard)
      def sw_language_facet
        result = []
        mods_ng_xml.language.each { |n|
          # get languageTerm codes and add their translations to the result
          n.code_term.each { |ct|
            if ct.authority =~ /^iso639/
              vals = ct.text.split(/[,|\ ]/).reject { |x| x.strip.empty? }
              vals.each do |v|
                next unless ISO_639.find(v.strip)
                iso639_val = ISO_639.find(v.strip).english_name
                if SEARCHWORKS_LANGUAGES.has_value?(iso639_val)
                  result << iso639_val
                else
                  result << SEARCHWORKS_LANGUAGES[v.strip]
                end
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
        mods_ng_xml.plain_name.select { |n| n.type_at != 'personal' }.map(&:display_value_w_date)
      end

      # @return [Array<String>] values for author_corp_display
      def sw_corporate_authors
        mods_ng_xml.corporate_name.map(&:display_value_w_date)
      end

      # @return [Array<String>] values for author_meeting_display
      def sw_meeting_authors
        mods_ng_xml.conference_name.map(&:display_value_w_date)
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

      # ---- end AUTHOR ----

      # select one or more format values from the controlled vocabulary per JVine Summer 2014
      #   http://searchworks-solr-lb.stanford.edu:8983/solr/select?facet.field=format_main_ssim&rows=0&facet.sort=index
      # https://github.com/sul-dlss/stanford-mods/issues/66 - For geodata, the
      # resource type should be only Map and not include Software, multimedia.
      # @return <Array[String]> value in the SearchWorks controlled vocabulary
      def format_main
        types = typeOfResource
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
        genres = term_values(:genre) || []
        issuance = term_values([:origin_info, :issuance]) || []
        frequency = term_values([:origin_info, :frequency]) || []

        val << 'Dataset' if genres.include?('dataset') || genres.include?('Dataset')

        types.each do |type|
          val << 'Archive/Manuscript' if type.manuscript == 'yes'

          case type.text
            when 'cartographic'
              val << 'Map'
            when 'mixed material'
              val << 'Archive/Manuscript'
            when 'moving image'
              val << 'Video'
            when 'notated music'
              val << 'Music score'
            when 'software, multimedia'
              val << 'Software/Multimedia' unless types.map(&:text).include?('cartographic') || (genres.include?('dataset') || genres.include?('Dataset'))
            when 'sound recording-musical'
              val << 'Music recording'
            when 'sound recording-nonmusical', 'sound recording'
              val << 'Sound recording'
            when 'still image'
              val << 'Image'
            when 'text'
              is_explicitly_a_book = type.manuscript != 'yes' && (issuance.include?('monographic') || !(genres & article_genres).empty? || !(genres & book_genres).empty?)
              is_periodical = issuance.include?('continuing') || issuance.include?('serial') || frequency.any? { |x| !x.empty? }
              is_archived_website = genres.any? { |x| x.casecmp('archived website') == 0 }

              val << 'Book' if is_explicitly_a_book
              val << 'Journal/Periodical' if is_periodical
              val << 'Archived website' if is_archived_website
              val << 'Book' unless is_explicitly_a_book || is_periodical || is_archived_website
            when 'three dimensional object'
              val << 'Object'
          end
        end
        val.uniq
      end

      # @return <Array[String]> values for the genre facet in SearchWorks
      def sw_genre
        genres = term_values(:genre)
        return [] unless genres

        val = genres.map(&:to_s)
        thesis_pub = ['thesis', 'Thesis']
        val << 'Thesis/Dissertation' if (genres & thesis_pub).any?

        conf_pub = ['conference publication', 'Conference publication', 'Conference Publication']
        gov_pub  = ['government publication', 'Government publication', 'Government Publication']
        tech_rpt = ['technical report', 'Technical report', 'Technical Report']

        val << 'Conference proceedings' if (genres & conf_pub).any?
        val << 'Government document' if (genres & gov_pub).any?
        val << 'Technical report' if (genres & tech_rpt).any?

        val.uniq
      end

      # @return [String] value with the numeric catkey in it, or nil if none exists
      def catkey
        catkey = term_values([:record_info, :recordIdentifier])

        catkey.first&.tr('a', '') # ensure catkey is numeric only
      end
    end # class Record
  end # Module Mods
end # Module Stanford
