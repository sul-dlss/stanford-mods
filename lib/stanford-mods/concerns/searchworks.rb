# frozen_string_literal: true

# SearchWorks specific wranglings of MODS metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods
    module Searchworks
      # include langagues known to SearchWorks; try to error correct when possible (e.g. when ISO-639 disagrees with MARC standard)
      def sw_language_facet
        mods_ng_xml.language.flat_map do |n|
          # get languageTerm codes and add their translations to the result
          result = n.code_term.flat_map do |ct|
            if ct.authority.to_s =~ /^iso639/
              vals = ct.text.split(/[,|\ ]/).reject { |x| x.strip.empty? }
              vals.select { |v| ISO_639.find(v.strip) }.map do |v|
                iso639_val = ISO_639.find(v.strip).english_name

                if SEARCHWORKS_LANGUAGES.has_value?(iso639_val)
                  iso639_val
                else
                  SEARCHWORKS_LANGUAGES[v.strip]
                end
              end
            else
              vals = ct.text.split(/[,|\ ]/).reject { |x| x.strip.empty? }

              vals.map do |v|
                SEARCHWORKS_LANGUAGES[v.strip]
              end
            end
          end

          # add languageTerm text values
          result.concat(n.text_term.map { |tt| tt.text.strip }.select { |val| !val.empty? && SEARCHWORKS_LANGUAGES.has_value?(val) })

          # add language values that aren't in languageTerm subelement
          result << n.text if n.languageTerm.empty? && SEARCHWORKS_LANGUAGES.has_value?(n.text)

          result
        end.uniq
      end

      # select one or more format values from the controlled vocabulary per JVine Summer 2014
      #   http://searchworks-solr-lb.stanford.edu:8983/solr/select?facet.field=format_main_ssim&rows=0&facet.sort=index
      # https://github.com/sul-dlss/stanford-mods/issues/66 - For geodata, the
      # resource type should be only Map and not include Software, multimedia.
      # @return <Array[String]> value in the SearchWorks controlled vocabulary
      def format_main
        types = typeOfResource
        return [] unless types

        val = []
        genres = term_values(:genre) || []
        issuance = term_values([:origin_info, :issuance]) || []
        frequency = term_values([:origin_info, :frequency]) || []

        val << 'Dataset' if genres.include?('dataset') || genres.include?('Dataset')
        val << 'Archive/Manuscript' if types.any? { |t| t.manuscript == 'yes' }

        val.concat(types.flat_map do |type|
          case type.text
            when 'cartographic'
              'Map'
            when 'mixed material'
              'Archive/Manuscript'
            when 'moving image'
              'Video'
            when 'notated music'
              'Music score'
            when 'software, multimedia'
              'Software/Multimedia' unless types.map(&:text).include?('cartographic') || (genres.include?('dataset') || genres.include?('Dataset'))
            when 'sound recording-musical'
              'Music recording'
            when 'sound recording-nonmusical', 'sound recording'
              'Sound recording'
            when 'still image'
              'Image'
            when 'text'
              is_periodical = issuance.include?('continuing') || issuance.include?('serial') || frequency.any? { |x| !x.empty? }
              is_archived_website = genres.any? { |x| x.casecmp('archived website') == 0 }

              if is_periodical || is_archived_website
                [
                  ('Journal/Periodical' if is_periodical),
                  ('Archived website' if is_archived_website)
                ].compact
              else
                'Book'
              end
            when 'three dimensional object'
              'Object'
          end
        end)

        val.compact.uniq
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

      # @return [String] value with the catkey in it, or nil if none exists
      def catkey
        catkey = term_values([:record_info, :recordIdentifier])

        catkey.first&.tr('a', '') # remove prefix from SUL catkeys
      end
    end # class Record
  end # Module Mods
end # Module Stanford
