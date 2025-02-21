describe "computations from /originInfo field" do
  let(:record) { Stanford::Mods::Record.new.from_str(modsxml) }

  context '#pub_year_display_str' do
    context 'when it has a dateIssued date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the year from the dateIssued field' do
        expect(record.pub_year_display_str).to eq '1900'
      end
    end

    context 'when it has a dateCreated date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>1800</dateCreated>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the year from the dateCreated field' do
        expect(record.pub_year_display_str).to eq '1800'
      end
    end

    context 'when it has a dateCaptured date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCaptured>1700</dateCaptured>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the year from the dateCaptured field' do
        expect(record.pub_year_display_str).to eq '1700'
      end
    end

    context 'when it has multiple types of date fields' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1900</dateIssued>
              <dateCreated>1800</dateCreated>
              <dateCaptured>1700</dateCaptured>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the year from the dateIssued field' do
        expect(record.pub_year_display_str).to eq '1900'
      end
    end

    context 'when it has a key date of the same type' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued keyDate="yes">1900</dateIssued>
              <dateIssued>1800</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the year from the keyDate field' do
        expect(record.pub_year_display_str).to eq '1900'
      end
    end

    context 'when it has a key date of a different type' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated keyDate="yes">1900</dateCreated>
              <dateIssued>1800</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the year from the preferred field type regardless of the keyDate' do
        expect(record.pub_year_display_str).to eq '1800'
      end

      context 'with field filters' do
        it 'returns the year from the requested field' do
          expect(record.pub_year_display_str([:dateCreated])).to eq '1900'
        end
      end
    end

    context 'when it has multiple dates' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1900</dateIssued>
              <dateIssued>1800</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest year' do
        expect(record.pub_year_display_str).to eq '1800'
      end
    end

    context 'when it has multiple originInfo elements' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1900</dateIssued>
            </originInfo>
            <originInfo>
              <dateIssued>1800</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest year across all the dates' do
        expect(record.pub_year_display_str).to eq '1800'
      end
    end

    context 'when it has a date range' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued point="start">1800</dateIssued>
              <dateIssued point="end">1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the date range' do
        expect(record.pub_year_display_str).to eq '1800 - 1900'
      end
    end

    context 'when it has an open-ended date range' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued point="start">uuuu</dateIssued>
              <dateIssued point="end">1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the date range' do
        expect(record.pub_year_display_str).to eq ' - 1900'
      end
    end

    context 'when it has an encoded date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1800</dateIssued>
              <dateIssued encoding="marc">1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the encoded date' do
        expect(record.pub_year_display_str).to eq '1900'
      end
    end

    context 'when it has a date range and an earlier single date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1799</dateIssued>
              <dateIssued point="start">1800</dateIssued>
              <dateIssued point="end">1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest date' do
        expect(record.pub_year_display_str).to eq '1799'
      end
    end

    context 'when it has a date range and a later single date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1850</dateIssued>
              <dateIssued point="start">1800</dateIssued>
              <dateIssued point="end">1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the date range' do
        expect(record.pub_year_display_str).to eq '1800 - 1900'
      end
    end

    context 'with BCE dates' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued encoding="edtf">-0249</dateIssued>
              <dateIssued encoding="edtf">-0149</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest date' do
        expect(record.pub_year_display_str).to eq '250 BCE'
      end
    end

    context 'with a BCE date range' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued encoding="edtf" point="start">-0249</dateIssued>
              <dateIssued encoding="edtf" point="end">-0149</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the date range' do
        expect(record.pub_year_display_str).to eq '250 BCE - 150 BCE'
      end
    end

    context 'with a qualified date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued qualifier="approximate">249</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the date without any qualifiers' do
        expect(record.pub_year_display_str).to eq '249 CE'
      end

      context 'with ignore_approximate: true' do
        it 'returns nothing' do
          expect(record.pub_year_display_str(ignore_approximate: true)).to eq nil
        end
      end
    end

    context 'with non-year data in the field' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>12th May 1800</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns only the year part of the date' do
        expect(record.pub_year_display_str).to eq '1800'
      end
    end

    context 'with a placeholder dates' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued qualifier="approximate">9999</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'ignores the date' do
        expect(record.pub_year_display_str).to eq nil
      end
    end

    context 'with a date not handled by EDTF' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued encoding="marc">1uuu</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'ignores the date' do
        expect(record.pub_year_display_str).to eq nil
      end
    end
  end

  context '#pub_year_sort_str' do
    context 'when it has a dateIssued date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the year from the field' do
        expect(record.pub_year_sort_str).to eq '1900'
      end
    end

    context 'when it has a date range' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued point="start">1800</dateIssued>
              <dateIssued point="end">1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns just the earliest date in the range' do
        expect(record.pub_year_sort_str).to eq '1800'
      end
    end

    context 'with BCE dates' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued encoding="edtf">-0249</dateIssued>
              <dateIssued encoding="edtf">-0149</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest date with the funky lexical sort encoding' do
        expect(record.pub_year_sort_str).to eq '-6750'
      end
    end

    context 'with a BCE date range' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued encoding="edtf" point="start">-0249</dateIssued>
              <dateIssued encoding="edtf" point="end">-0149</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest date of the range with the funky lexical sort encoding' do
        expect(record.pub_year_sort_str).to eq '-6750'
      end
    end

    context 'with a really old BCE date (e.g. ky899rv1161)' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued encoding="edtf">Y-12345</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest date of the range with the funky lexical sort encoding' do
        expect(record.pub_year_sort_str).to eq '-487654'
      end
    end

    context 'with a qualified date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued qualifier="approximate">249</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the date without any qualifiers' do
        expect(record.pub_year_sort_str).to eq '0249'
      end

      context 'with ignore_approximate: true' do
        it 'returns nothing' do
          expect(record.pub_year_sort_str(ignore_approximate: true)).to eq nil
        end
      end
    end

    context 'with a placeholder dates' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued qualifier="approximate">9999</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'ignores the date' do
        expect(record.pub_year_sort_str).to eq nil
      end
    end

    context 'with a date not handled by EDTF' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued encoding="marc">1uuu</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'ignores the date' do
        expect(record.pub_year_sort_str).to eq nil
      end
    end

    context 'when it has an open-ended date range' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued point="start">uuuu</dateIssued>
              <dateIssued point="end">1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the known part of the date range' do
        expect(record.pub_year_sort_str).to eq '1900'
      end
    end
  end

  context '#pub_year_int' do
    context 'when it has a dateIssued date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the year from the dateIssued field' do
        expect(record.pub_year_int).to eq 1900
      end
    end

    context 'when it has multiple dates' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>1900</dateIssued>
              <dateIssued>1800</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest year' do
        expect(record.pub_year_int).to eq 1800
      end
    end

    context 'when it has a date range' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued point="start">1800</dateIssued>
              <dateIssued point="end">1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest year from the date range' do
        expect(record.pub_year_int).to eq 1800
      end
    end

    context 'when it has an open-ended date range' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued point="start">uuuu</dateIssued>
              <dateIssued point="end">1900</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the known part of the date range' do
        expect(record.pub_year_int).to eq 1900
      end
    end

    context 'with BCE dates' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued encoding="edtf">-0249</dateIssued>
              <dateIssued encoding="edtf">-0149</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the earliest date' do
        expect(record.pub_year_int).to eq(-249)
      end
    end

    context 'with a BCE date range' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued encoding="edtf" point="start">-0249</dateIssued>
              <dateIssued encoding="edtf" point="end">-0149</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the year of the earliest date in the range' do
        expect(record.pub_year_int).to eq(-249)
      end
    end

    context 'with a qualified date' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued qualifier="approximate">249</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'returns the date without any qualifiers' do
        expect(record.pub_year_int).to eq 249
      end

      context 'with ignore_approximate: true' do
        it 'returns nothing' do
          expect(record.pub_year_int(ignore_approximate: true)).to eq nil
        end
      end
    end

    context 'with a placeholder dates' do
      let(:modsxml) do
        <<-EOF
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued qualifier="approximate">9999</dateIssued>
            </originInfo>
          </mods>
        EOF
      end

      it 'ignores the date' do
        expect(record.pub_year_int).to eq nil
      end
    end
  end
end
