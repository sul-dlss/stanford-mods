# encoding: UTF-8
require 'logger'
require 'mods'

# SearchWorks specific wranglings of MODS  *subject* metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods
    class Record < ::Mods::Record
      # Values are the contents of:
      #   subject/geographic
      #   subject/hierarchicalGeographic
      #   subject/geographicCode  (only include the translated value if it isn't already present from other mods geo fields)
      # @param [String] sep - the separator string for joining hierarchicalGeographic sub elements
      # @return [Array<String>] values for geographic_search Solr field for this document or [] if none
      def sw_geographic_search(sep = ' ')
        result = term_values([:subject, :geographic]) || []

        # hierarchicalGeographic has sub elements
        mods_ng_xml.subject.hierarchicalGeographic.each { |hg_node|
          hg_vals = hg_node.element_children.map(&:text).reject(&:empty?)
          result << hg_vals.join(sep) unless hg_vals.empty?
        }

        trans_code_vals = mods_ng_xml.subject.geographicCode.translated_value || []
        trans_code_vals.each { |val|
          result << val unless result.include?(val)
        }
        result
      end

      # Values are the contents of:
      #   subject/name/namePart
      #  "Values from namePart subelements should be concatenated in the order they appear (e.g. "Shakespeare, William, 1564-1616")"
      # @param [String] sep - the separator string for joining namePart sub elements
      # @return [Array<String>] values for names inside subject elements or [] if none
      def sw_subject_names(sep = ', ')
        mods_ng_xml.subject.name_el
                   .select { |n_el| n_el.namePart }
                   .map { |name_el_w_np| name_el_w_np.namePart.map(&:text).reject(&:empty?) }
                   .reject(&:empty?)
                   .map { |parts| parts.join(sep).strip }
      end

      # Values are the contents of:
      #   subject/titleInfo/(subelements)
      # @param [String] sep - the separator string for joining titleInfo sub elements
      # @return [Array<String>] values for titles inside subject elements or [] if none
      def sw_subject_titles(sep = ' ')
        result = []
        mods_ng_xml.subject.titleInfo.each { |ti_el|
          parts = ti_el.element_children.map(&:text).reject(&:empty?)
          result << parts.join(sep).strip unless parts.empty?
        }
        result
      end

      # Values are the contents of:
      #   mods/subject/topic
      # @return [Array<String>] values for the topic_search Solr field for this document or nil if none
      def topic_search
        @topic_search ||= begin
          vals = []
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
        vals.map! { |val| val.sub(/[\\,;]$/, '').strip }
        vals.empty? ? nil : vals
      end

      # geographic_search values with trailing comma, semicolon, and backslash (and any preceding spaces) removed
      # @return [Array<String>] values for the geographic_facet Solr field for this document or nil if none
      def geographic_facet
        geographic_search.map { |val| val.sub(/[\\,;]$/, '').strip } if geographic_search
      end

      # subject/temporal values with trailing comma, semicolon, and backslash (and any preceding spaces) removed
      # @return [Array<String>] values for the era_facet Solr field for this document or nil if none
      def era_facet
        subject_temporal.map { |val| val.sub(/[\\,;]$/, '').strip } if subject_temporal
      end

      # Values are the contents of:
      #   subject/geographic
      #   subject/hierarchicalGeographic
      #   subject/geographicCode  (only include the translated value if it isn't already present from other mods geo fields)
      # @return [Array<String>] values for the geographic_search Solr field for this document or nil if none
      def geographic_search
        @geographic_search ||= begin
          result = sw_geographic_search

          # TODO:  this should go into stanford-mods ... but then we have to set that gem up with a Logger
          # print a message for any unrecognized encodings
          xvals = subject.geographicCode.translated_value
          codes = term_values([:subject, :geographicCode])
          if codes && codes.size > xvals.size
            subject.geographicCode.each { |n|
              next unless n.authority != 'marcgac' && n.authority != 'marccountry'
              sw_logger.info("#{druid} has subject geographicCode element with untranslated encoding (#{n.authority}): #{n.to_xml}")
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
          gvals = term_values([:subject, :genre])
          vals.concat(gvals) if gvals

          # print a message for any temporal encodings
          subject.temporal.each { |n|
            sw_logger.info("#{druid} has subject temporal element with untranslated encoding: #{n.to_xml}") unless n.encoding.empty?
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

      protected #----------------------------------------------------------

      # convenience method for subject/name/namePart values (to avoid parsing the mods for the same thing multiple times)
      def subject_names
        @subject_names ||= sw_subject_names
      end

      # convenience method for subject/occupation values (to avoid parsing the mods for the same thing multiple times)
      def subject_occupations
        @subject_occupations ||= term_values([:subject, :occupation])
      end

      # convenience method for subject/temporal values (to avoid parsing the mods for the same thing multiple times)
      def subject_temporal
        @subject_temporal ||= term_values([:subject, :temporal])
      end

      # convenience method for subject/titleInfo values (to avoid parsing the mods for the same thing multiple times)
      def subject_titles
        @subject_titles ||= sw_subject_titles
      end

      # convenience method for subject/topic values (to avoid parsing the mods for the same thing multiple times)
      def subject_topics
        @subject_topics ||= term_values([:subject, :topic])
      end
    end
  end
end
