# frozen_string_literal: true

# Parsing MODS /originInfo for Publication/Imprint data:
#  * pub year for date slider facet
#  * pub year for sorting
#  * pub year for single display value
#  * imprint info for display
#  *
# These methods may be used by searchworks.rb file or by downstream apps
module Stanford
  module Mods
    module OriginInfo
      # return pub year as an Integer
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute) should be ignored; false if approximate dates should be included
      # @return [Integer] publication year as an Integer
      # @note for sorting:  5 BCE => -5;  666 BCE => -666
      def pub_year_int(ignore_approximate: false)
        date = earliest_preferred_date(ignore_approximate: ignore_approximate)

        return unless date

        if date.is_a? Stanford::Mods::Imprint::DateRange
          date = date.start || date.stop
        end

        edtf_date = date.date

        if edtf_date.is_a?(EDTF::Interval)
          edtf_date.from.year
        else
          edtf_date.year
        end
      end

      # return a single string intended for lexical sorting for pub date
      # prefer dateIssued (any) before dateCreated (any) before dateCaptured (any)
      #  look for a keyDate and use it if there is one;  otherwise pick earliest date
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute) should be ignored; false if approximate dates should be included
      # @return [String] single String containing publication year for lexical sorting
      # @note for string sorting  5 BCE = -5  => -995;  6 BCE => -994, so 6 BCE sorts before 5 BCE
      # @deprecated use pub_year_int
      def pub_year_sort_str(ignore_approximate: false)
        date = earliest_preferred_date(ignore_approximate: ignore_approximate)

        return unless date

        if date.is_a? Stanford::Mods::Imprint::DateRange
          date = date.start || date.stop
        end

        edtf_date = date.date

        year = if edtf_date.is_a?(EDTF::Interval)
          edtf_date.from.year
        else
          edtf_date.year
        end

        str = if year < 1
          (-1 * year - 1000).to_s
        else
          year.to_s
        end

        case edtf_date.precision
        when :decade
          str[0..2] + "-"
        when :century
          str[0..1] + "--"
        else
          str.rjust(4, "0")
        end
      end

      # return a single string intended for display of pub year (or year range)
      #
      # @param [Array<Symbol>] fields array of field types to use to look for dates.
      # @param [Boolean] ignore_approximate true if approximate dates (per qualifier attribute)
      #   should be ignored; false if approximate dates should be included
      def pub_year_display_str(ignore_approximate: false)
        earliest_preferred_date(ignore_approximate: ignore_approximate)&.decoded_value(allowed_precisions: [:year, :decade, :century], ignore_unparseable: true, display_original_text: false)
      end

      # @return [Array<Stanford::Mods::Imprint>] array of imprint objects
      # @private
      def imprints
        origin_info.map { |el| Stanford::Mods::Imprint.new(el) }
      end

      def place
        term_values([:origin_info, :place, :placeTerm])
      end

      # @return [String] single String containing imprint information for display
      def imprint_display_str
        imprints.map(&:display_str).reject(&:empty?).join('; ')
      end

      private

      # The rules for which date to pick is a little complicated:
      #
      # 1) Examine the date elements of the provided fields.
      # 2) Discard any we can't parse a year out of.
      # 3) (if ignore_approximate is true, used only by exhibits for Feigenbaum), throw out any qualified dates (or ranges if either the start or end is qualified)
      # 4) If that set of date elements has elements with a keyDate, prefer those.
      # 5) If there were encoded dates, prefer those.
      # 6) Choose the earliest date (or starting date of a range).
      #
      # Finally, format the date or range of an encoded date, or just pluck out the year from an unencoded one.
      def earliest_preferred_date(fields: [:dateIssued, :dateCreated, :dateCaptured], ignore_approximate: false)
        local_imprints = imprints

        fields.each do |field_name|
          potential_dates = local_imprints.flat_map do |imprint|
            dates = imprint.dates([field_name])
            dates = dates.select(&:parsed_date?)
            dates = dates.reject(&:qualified?) if ignore_approximate

            dates
          end

          preferred_dates = potential_dates.select(&:key_date?).presence || potential_dates
          best_dates = (preferred_dates.select { |x| x.encoding.present? }.presence || preferred_dates)

          earliest_date = best_dates.min_by do |date|
            if date.is_a? Stanford::Mods::Imprint::DateRange
              date.start.base_value
            else
              date.base_value
            end
          end

          return earliest_date if earliest_date
        end

        nil
      end
    end # class Record
  end
end
