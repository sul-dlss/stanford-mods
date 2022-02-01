def stanford_mods_imprint(smods_rec)
  Stanford::Mods::Imprint.new(smods_rec.origin_info.first)
end

# unit / functional tests for imprint class
describe Stanford::Mods::Imprint do
  let(:smods_rec) { Stanford::Mods::Record.new }
  let(:mods_origin_info_start_str) { "<mods xmlns=\"#{Mods::MODS_NS}\"><originInfo>" }
  let(:mods_origin_info_end_str) { '</originInfo></mods>' }

  describe 'date processing' do
    describe 'bad dates' do
      it 'ignores bad date values' do
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
        imprint_strs = stanford_mods_imprint(smods_rec).display_str
        expect(imprint_strs).to eq 'Spain'
      end
      it 'handles invalid dates by returning the original value' do
        smods_rec.from_str(mods_origin_info_start_str +
          '<dateCreated encoding="w3cdtf">1920-09-32</dateCreated>' +
          mods_origin_info_end_str)
        imprint_strs = stanford_mods_imprint(smods_rec).display_str
        expect(imprint_strs).to eq '1920-09-32'
      end
    end

    context '#process_decade_date' do
      {
        '1950s' => '1950s',
        "1950's" => "1950's",
        '156u' => '1560s',
        '186?' => '1860s',
        '195x' => '1950s'
      }.each do |example, expected|
        it "#{expected} for #{example}" do
          smods_rec.from_str("#{mods_origin_info_start_str}
            <dateIssued>#{example}</dateIssued>
          #{mods_origin_info_end_str}")
          imp = stanford_mods_imprint(smods_rec)
          updated_element = imp.send(:date_str)
          expect(updated_element).to eq expected
        end
      end
      it 'leaves text alone when date str but no decade' do
        smods_rec.from_str("#{mods_origin_info_start_str}
          <dateIssued>I think July 15, 1965 was a great day</dateIssued>
        #{mods_origin_info_end_str}")
        imp = stanford_mods_imprint(smods_rec)
        updated_element = imp.send(:date_str)
        expect(updated_element).to eq 'I think July 15, 1965 was a great day'
      end
      it 'leaves text alone when no date str' do
        smods_rec.from_str("#{mods_origin_info_start_str}
          <dateIssued>ain't no date heah</dateIssued>
        #{mods_origin_info_end_str}")
        imp = stanford_mods_imprint(smods_rec)
        updated_element = imp.send(:date_str)
        expect(updated_element).to eq "ain't no date heah"
      end
    end

    context '#process_century_date' do
      {
        '18th century CE' => '18th century CE',
        '17uu' => '18th century'
      }.each do |example, expected|
        it "#{expected} for #{example}" do
          smods_rec.from_str("#{mods_origin_info_start_str}
            <dateIssued>#{example}</dateIssued>
          #{mods_origin_info_end_str}")
          imp = stanford_mods_imprint(smods_rec)
          updated_element = imp.send(:date_str)
          expect(updated_element).to eq expected
        end
      end
      it 'leaves text alone when date str but no century' do
        smods_rec.from_str("#{mods_origin_info_start_str}
          <dateIssued>I think July 15, 1965 was a great day</dateIssued>
        #{mods_origin_info_end_str}")
        imp = stanford_mods_imprint(smods_rec)
        updated_element = imp.send(:date_str)
        expect(updated_element).to eq 'I think July 15, 1965 was a great day'
      end
      it 'leaves text alone when no date str' do
        smods_rec.from_str("#{mods_origin_info_start_str}
          <dateIssued>ain't no date heah</dateIssued>
        #{mods_origin_info_end_str}")
        imp = stanford_mods_imprint(smods_rec)
        updated_element = imp.send(:date_str)
        expect(updated_element).to eq "ain't no date heah"
      end
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
