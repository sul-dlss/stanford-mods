# frozen_string_literal: true

# NON-SearchWorks specific wranglings of MODS <name> metadata as a mixin to the Stanford::Mods::Record object
module Stanford
  module Mods
    module Name
      # the first encountered <mods><name> element with marcrelator flavor role of 'Creator' or 'Author'.
      # if no marcrelator 'Creator' or 'Author', the first name without a role.
      # if no name without a role, then nil
      # @return [String] value for author_1xx_search field
      def sw_main_author
        result = mods_ng_xml.plain_name.find { |n| n.role.any? { |r| r.authority.include?('marcrelator') && r.value.any? { |v| v.match(/creator/i) || v.match?(/author/i) } } }
        result ||= mods_ng_xml.plain_name.find { |n| n.role.empty? }

        result&.display_value_w_date
      end

      # all names, in display form, except the main_author
      #  names will be the display_value_w_date form
      #  see Mods::Record.name  in nom_terminology for details on the display_value algorithm
      # @return [Array<String>] values for author_7xx_search field
      def sw_addl_authors
        mods_ng_xml.plain_name.map(&:display_value_w_date) - [sw_main_author]
      end

      # @return [Array<String>] values for author_person_facet, author_person_display
      def sw_person_authors
        mods_ng_xml.personal_names_w_dates
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
        "#{sw_main_author || "\u{10FFFF} " }#{sort_title}".gsub(/[[:punct:]]*/, '').strip
      end
    end # class Record
  end # Module Mods
end # Module Stanford
