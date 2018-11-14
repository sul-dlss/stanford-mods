# encoding: UTF-8
require 'stanford-mods/searchworks_languages'
require 'stanford-mods/searchworks_subjects'
require 'logger'
require 'mods'

# SearchWorks specific wranglings of MODS metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods
    class Record < ::Mods::Record
      attr_writer :druid
      attr_writer :logger

      def druid
        @druid || 'Unknown item'
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
      alias sw_logger logger

      # include langagues known to SearchWorks; try to error correct when possible (e.g. when ISO-639 disagrees with MARC standard)
      def sw_language_facet
        result = []
        mods_ng_xml.language.each { |n|
          # get languageTerm codes and add their translations to the result
          n.code_term.each { |ct|
            if ct.authority =~ /^iso639/
              vals = ct.text.split(/[,|\ ]/).reject { |x| x.strip.empty? }
              vals.each do |v|
                if ISO_639.find(v.strip)
                  iso639_val = ISO_639.find(v.strip).english_name
                  if SEARCHWORKS_LANGUAGES.has_value?(iso639_val)
                    result << iso639_val
                  else
                    result << SEARCHWORKS_LANGUAGES[v.strip]
                  end
                else
                  logger.warn "Couldn't find english name for #{ct.text}"
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
        mods_ng_xml.plain_name.select { |n| n.type_at != 'personal' }.map { |n| n.display_value_w_date }
      end

      # @return [Array<String>] values for author_corp_display
      def sw_corporate_authors
        mods_ng_xml.plain_name.select { |n| n.type_at == 'corporate' }.map { |n| n.display_value_w_date }
      end

      # @return [Array<String>] values for author_meeting_display
      def sw_meeting_authors
        mods_ng_xml.plain_name.select { |n| n.type_at == 'conference' }.map { |n| n.display_value_w_date }
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
        short_titles ? short_titles.compact.reject(&:empty?).first : nil
      end

      # @return [Nokogiri::XML::NodeSet] title_info nodes, rejecting ones that just have blank text values
      def present_title_info_nodes
        mods_ng_xml.title_info.reject {|node| node.text.strip.empty?}
      end

      # @return [Nokogiri::XML::Node] the first titleInfo node if present, else nil
      def first_title_info_node
        present_title_info_nodes ? present_title_info_nodes.first : nil
      end

      # @return [String] the nonSort text portion of the titleInfo node as a string (if non-empty, else nil)
      def nonSort_title
        return unless first_title_info_node && first_title_info_node.nonSort

        first_title_info_node.nonSort.text.strip.empty? ? nil : first_title_info_node.nonSort.text.strip
      end

      # @return [String] the text of the titleInfo node as a string (if non-empty, else nil)
      def title
        return unless first_title_info_node && first_title_info_node.title

        first_title_info_node.title.text.strip.empty?   ? nil : first_title_info_node.title.text.strip
      end

      # Searchworks requires that the MODS has a '//titleInfo/title'
      # @return [String] value for title_245_search, title_full_display
      def sw_full_title
        return nil if !first_title_info_node || !title

        preSubTitle = nonSort_title ? [nonSort_title, title].compact.join(" ") : title
        preSubTitle.sub!(/:$/, '')

        subTitle = first_title_info_node.subTitle.text.strip
        preParts = subTitle.empty? ? preSubTitle : preSubTitle + " : " + subTitle
        preParts.sub!(/\.$/, '') if preParts # remove trailing period

        partName   = first_title_info_node.partName.text.strip   unless first_title_info_node.partName.text.strip.empty?
        partNumber = first_title_info_node.partNumber.text.strip unless first_title_info_node.partNumber.text.strip.empty?
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
        return nil unless result
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
        val = '' + (sw_full_title ? sw_full_title : '')
        val.sub!(Regexp.new("^" + Regexp.escape(nonSort_title)), '') if nonSort_title
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
        return nil unless catkey && !catkey.empty?
        catkey.first.tr('a', '') # ensure catkey is numeric only
      end
    end # class Record
  end # Module Mods
end # Module Stanford
