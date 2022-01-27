# frozen_string_literal: true

# SearchWorks specific wranglings of MODS  *subject* metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods
    module SearchworksSubjects
      # Values are the contents of:
      #   subject/geographic
      #   subject/hierarchicalGeographic
      #   subject/geographicCode  (only include the translated value if it isn't already present from other mods geo fields)
      # @param [String] sep - the separator string for joining hierarchicalGeographic sub elements
      # @return [Array<String>] values for geographic_search Solr field for this document or [] if none
      # @private
      def sw_geographic_search(sep = ' ')
        result = term_values([:subject, :geographic]) || []

        # hierarchicalGeographic has sub elements
        hierarchical_vals = mods_ng_xml.subject.hierarchicalGeographic.map do |hg_node|
          hg_vals = hg_node.element_children.map(&:text).reject(&:empty?)
          hg_vals.join(sep) unless hg_vals.empty?
        end

        trans_code_vals = mods_ng_xml.subject.geographicCode.translated_value || []

        (result + hierarchical_vals + trans_code_vals).compact.uniq
      end

      # Values are the contents of:
      #   subject/name/namePart
      #  "Values from namePart subelements should be concatenated in the order they appear (e.g. "Shakespeare, William, 1564-1616")"
      # @param [String] sep - the separator string for joining namePart sub elements
      # @return [Array<String>] values for names inside subject elements or [] if none
      # @private
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
      # @private
      def sw_subject_titles(sep = ' ')
        mods_ng_xml.subject.titleInfo.map do |ti_el|
          parts = ti_el.element_children.map(&:text).reject(&:empty?)
          parts.join(sep).strip unless parts.empty?
        end.compact
      end

      # Values are the contents of:
      #   mods/subject/topic
      # @return [Array<String>] values for the topic_search Solr field for this document or nil if none
      def topic_search
        @topic_search ||= subject_topics
      end

      # Values are the contents of:
      #   subject/topic
      #   subject/name
      #   subject/title
      #   subject/occupation
      #  with trailing comma, semicolon, and backslash (and any preceding spaces) removed
      # @return [Array<String>] values for the topic_facet Solr field for this document or nil if none
      def topic_facet
        strip_punctuation(subject_topics + subject_names + subject_titles + subject_occupations)
      end

      def strip_punctuation(arr)
        arr&.map { |val| val.gsub(/[\\,;]$/, '').strip }
      end

      # geographic_search values with trailing comma, semicolon, and backslash (and any preceding spaces) removed
      # @return [Array<String>] values for the geographic_facet Solr field for this document or nil if none
      def geographic_facet
        strip_punctuation(geographic_search)
      end

      # subject/temporal values with trailing comma, semicolon, and backslash (and any preceding spaces) removed
      # @return [Array<String>] values for the era_facet Solr field for this document or nil if none
      def era_facet
        strip_punctuation(subject_temporal)
      end

      # Values are the contents of:
      #   subject/geographic
      #   subject/hierarchicalGeographic
      #   subject/geographicCode  (only include the translated value if it isn't already present from other mods geo fields)
      # @return [Array<String>] values for the geographic_search Solr field for this document or nil if none
      def geographic_search
        @geographic_search ||= sw_geographic_search
      end

      # Values are the contents of:
      #   subject/name
      #   subject/occupation  - no subelements
      #   subject/titleInfo
      # @return [Array<String>] values for the subject_other_search Solr field for this document or nil if none
      def subject_other_search
        @subject_other_search ||= subject_occupations + subject_names + subject_titles
      end

      # Values are the contents of:
      #   subject/temporal
      #   subject/genre
      # @return [Array<String>] values for the subject_other_subvy_search Solr field for this document or nil if none
      def subject_other_subvy_search
        @subject_other_subvy_search ||= begin
          vals = Array(subject_temporal)
          gvals = term_values([:subject, :genre])

          vals + Array(gvals)
        end
      end

      # Values are the contents of:
      #  all subject subelements except subject/cartographic plus  genre top level element
      # @return [Array<String>] values for the subject_all_search Solr field for this document or nil if none
      def subject_all_search
        topic_search + geographic_search + subject_other_search + subject_other_subvy_search
      end

      protected #----------------------------------------------------------

      # convenience method for subject/name/namePart values (to avoid parsing the mods for the same thing multiple times)
      def subject_names
        @subject_names ||= sw_subject_names
      end

      # convenience method for subject/occupation values (to avoid parsing the mods for the same thing multiple times)
      def subject_occupations
        @subject_occupations ||= term_values([:subject, :occupation]) || []
      end

      # convenience method for subject/temporal values (to avoid parsing the mods for the same thing multiple times)
      def subject_temporal
        @subject_temporal ||= term_values([:subject, :temporal]) || []
      end

      # convenience method for subject/titleInfo values (to avoid parsing the mods for the same thing multiple times)
      def subject_titles
        @subject_titles ||= sw_subject_titles
      end

      # convenience method for subject/topic values (to avoid parsing the mods for the same thing multiple times)
      def subject_topics
        @subject_topics ||= term_values([:subject, :topic]) || []
      end
    end
  end
end
