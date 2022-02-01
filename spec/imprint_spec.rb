def stanford_mods_imprint(smods_rec)
  Stanford::Mods::Imprint.new(smods_rec.origin_info.first)
end

# unit / functional tests for imprint class
describe Stanford::Mods::Imprint do
  let(:smods_rec) { Stanford::Mods::Record.new }
  let(:mods_origin_info_start_str) { "<mods xmlns=\"#{Mods::MODS_NS}\"><originInfo>" }
  let(:mods_origin_info_end_str) { '</originInfo></mods>' }

  describe 'date processing' do
    it 'ignores bad dates' do
      smods_rec.from_str(mods_origin_info_start_str +
        '<place>
            <placeTerm>Spain</placeTerm>
          </place>
          <dateIssued>
            9999
          </dateIssued>
          <dateIssued>
            uuuu
          </dateIssued>
          <dateIssued>
            0000-00-00
          </dateIssued>' +
        mods_origin_info_end_str)
      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element.to_s).to be_empty
    end

    it 'handles invalid dates by returning the original value' do
      smods_rec.from_str(mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf">1920-09-32</dateCreated>' +
        mods_origin_info_end_str)
      imprint_strs = stanford_mods_imprint(smods_rec).display_str
      expect(imprint_strs).to eq '1920-09-32'
    end

    it 'collects all the dates from date elements in the MODS' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued>17uu</dateIssued>
          <dateIssued>ain't no date heah</dateIssued>
          <dateCreated encoding="w3cdtf">1920-09</dateCreated>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to include('18th century', "ain't no date heah", '1920')
    end

    it 'prefers unencoded dates in order to preserve punctuation-as-metadata' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued>1874]</dateIssued>
          <dateIssued encoding="w3cdtf">1874</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '1874]'
    end

    it 'deduplicates dates so we do not show the same information repeatedly' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued>1874</dateIssued>
          <dateIssued encoding="edtf">1874</dateIssued>
          <dateIssued encoding="w3cdtf">1874</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '1874'
    end

    it 'also deduplicates date ranges against a single date' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued>1874]</dateIssued>
          <dateIssued point="start" encoding="edtf">1874</dateIssued>
          <dateIssued point="end" encoding="w3cdtf">1876</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '1874]'
    end

    it 'presents date ranges' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued point="start" encoding="edtf">1874</dateIssued>
          <dateIssued point="end" encoding="w3cdtf">1876</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '1874 - 1876'
    end

    it 'presents centuries' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued encoding="edtf">18XX</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '19th century'
    end

    it 'presents decades' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued encoding="edtf">147X</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '1470s'
    end

    it 'adds A.D. to early years' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued encoding="edtf">988</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '988 A.D.'
    end

    it 'adds B.C. to B.C. years' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued encoding="edtf">-5</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '6 B.C.'
    end

    it 'has special handling for the year 0 (1 B.C.)' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued>0</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '1 B.C.'
    end

    it 'presents years + months' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued encoding="edtf">1948-04</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq 'April 1948'
    end

    it 'presents exact days nicely' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued encoding="edtf">1948-04-02</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq 'April  2, 1948'
    end

    it 'handles the approximate qualifier' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued encoding="edtf" qualifier="approximate">1948-04-02</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '[ca. April  2, 1948]'
    end

    it 'handles the questionable qualifier' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued encoding="edtf" qualifier="questionable">0322</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '[322 A.D.?]'
    end

    it 'handles the inferred qualifier' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued encoding="edtf" qualifier="inferred">190X</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '[1900s]'
    end

    it 'presents date ranges with matching qualifiers by compacting the qualifiers' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued point="start" encoding="edtf" qualifier="approximate">1874</dateIssued>
          <dateIssued point="end" encoding="w3cdtf" qualifier="approximate">1876</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '[ca. 1874 - 1876]'
    end


    it 'presents date ranges with mismatching qualifiers by presenting them individually' do
      smods_rec.from_str <<-XML
        #{mods_origin_info_start_str}
          <dateIssued point="start" encoding="edtf" qualifier="approximate">1874</dateIssued>
          <dateIssued point="end" encoding="w3cdtf" qualifier="questionable">1876</dateIssued>
        #{mods_origin_info_end_str}
      XML

      imp = stanford_mods_imprint(smods_rec)
      updated_element = imp.send(:date_str)
      expect(updated_element).to eq '[ca. 1874] - [1876?]'
    end
  end

  describe 'punctuation' do
    it 'does not duplicate punctuation when end of element value matches the joining punct.' do
      smods_rec.from_str(mods_origin_info_start_str +
        '<place>
            <placeTerm>San Francisco :</placeTerm>
          </place>
          <publisher>Chronicle Books,</publisher>
          <dateIssued>2015.</dateIssued>' +
        mods_origin_info_end_str)
      imprint_strs = stanford_mods_imprint(smods_rec).display_str
      expect(imprint_strs).to eq 'San Francisco : Chronicle Books, 2015.'
    end
  end

  describe 'place processing' do
    it 'uses type text instead of type code when avail' do
      smods_rec.from_str(mods_origin_info_start_str +
        '<place>
           <placeTerm type="code" authority="marccountry">ne</placeTerm>
         </place>
         <place>
           <placeTerm type="text" authority="marccountry">[Amsterdam]</placeTerm>
         </place>' +
        mods_origin_info_end_str)
      imprint_strs = stanford_mods_imprint(smods_rec).display_str
      expect(imprint_strs).to eq '[Amsterdam]'
    end
    it "translates encoded place if there isn't a text (or non-typed) value available" do
      smods_rec.from_str(mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">ne</placeTerm>
        </place>' +
        mods_origin_info_end_str)
      imprint_strs = stanford_mods_imprint(smods_rec).display_str
      expect(imprint_strs).to eq 'Netherlands'
    end
    it "ignores 'xx' country code" do
      smods_rec.from_str(mods_origin_info_start_str +
        '<place>
           <placeTerm type="code" authority="marccountry">xx</placeTerm>
         </place>
         <dateIssued>1994</dateIssued>' +
        mods_origin_info_end_str)
      imprint_strs = stanford_mods_imprint(smods_rec).display_str
      expect(imprint_strs).to eq('1994')
    end
  end
end
