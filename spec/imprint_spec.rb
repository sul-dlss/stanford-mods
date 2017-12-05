def stanford_mods_imprint(smods_rec)
  Stanford::Mods::Imprint.new(smods_rec.origin_info)
end

# unit / functional tests for imprint class
describe Stanford::Mods::Imprint do
  let(:smods_rec) { Stanford::Mods::Record.new }
  let(:mods_origin_info_start_str) { "<mods xmlns=\"#{Mods::MODS_NS}\"><originInfo>" }
  let(:mods_origin_info_end_str) { '</originInfo></mods>' }

  describe 'date processing' do
    describe '#publication_date_for_slider' do
      {
        '' => [],
        '<dateIssued>1957</dateIssued>' => [1957],
        '<dateIssued>195u</dateIssued>' => (1950..1959).to_a,
        '<dateCreated keyDate="yes">1964</dateCreated><dateIssued>195u</dateIssued>' => [1964],
        '<dateIssued>1964</dateIssued><dateCreated>195u</dateCreated>' => [1964],
        '<dateIssued point="start">195u</dateIssued><dateIssued point="end">1964</dateIssued>' => (1950..1964).to_a,
        '<dateIssued>1964</dateIssued><dateIssued>195u</dateIssued>' => [1964] + (1950..1959).to_a
      }.each do |example, expected|
        it 'works' do
          smods_rec.from_str("#{mods_origin_info_start_str}
            #{example}
          #{mods_origin_info_end_str}")
          imprint = stanford_mods_imprint(smods_rec)
          expect(imprint.publication_date_for_slider).to eq expected
        end
      end
    end
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
        imprint_strs = stanford_mods_imprint(smods_rec).imprint_statements
        expect(imprint_strs).to eq(['Spain'])
      end
      it 'handles invalid dates by returning the original value' do
        smods_rec.from_str(mods_origin_info_start_str +
          '<dateCreated encoding="w3cdtf">1920-09-00</dateCreated>' +
          mods_origin_info_end_str)
        imprint_strs = stanford_mods_imprint(smods_rec).imprint_statements
        expect(imprint_strs.first).to match('1920-09-00')
      end
    end

    context '#process_decade_century_dates' do
      it 'calls process_decade_date for each element in passed nodeset that matches decade str' do
        smods_rec.from_str("#{mods_origin_info_start_str}
          <dateIssued>before 195x after</dateIssued>
          <dateIssued>1950s not a match</dateIssued>
          <dateIssued>before 17-- after</dateIssued>
          <dateIssued>not a match</dateIssued>
          <dateIssued>another 165x match</dateIssued>
        #{mods_origin_info_end_str}")
        imp = stanford_mods_imprint(smods_rec)
        dt_elements = smods_rec.origin_info.dateIssued
        expect(imp).to receive(:date_is_decade?).and_return(true, false, false, false, true)
        expect(imp).to receive(:process_decade_date).twice
        expect(imp).to receive(:date_is_century?).and_return(false, true, false)
        expect(imp).to receive(:process_century_date)
        imp.send(:process_decade_century_dates, dt_elements)
      end
    end

    context 'date_is_decade?' do
      ['156u',
        '167-?]',
        '[171-?]',
        '[189-]',
        'ca.170-?]',
        '200-?]',
        '186?',
        '195x',
        'before 195x after'
      ].each do |example|
        it 'true when decade string to change' do
          smods_rec.from_str("#{mods_origin_info_start_str}
            <dateIssued>#{example}</dateIssued>
          #{mods_origin_info_end_str}")
          imp = stanford_mods_imprint(smods_rec)
          element = smods_rec.origin_info.dateIssued.first
          expect(imp.send(:date_is_decade?, element)).to be_truthy
        end
      end
      ['1950s',
        "1950's",
        'before 1950s after'
      ].each do |example|
        it 'false when no decade string to change' do
          smods_rec.from_str("#{mods_origin_info_start_str}
            <dateIssued>#{example}</dateIssued>
          #{mods_origin_info_end_str}")
          imp = stanford_mods_imprint(smods_rec)
          element = smods_rec.origin_info.dateIssued.first
          expect(imp.send(:date_is_decade?, element)).to be_falsey
        end
      end
    end

    context '#process_decade_date' do
      {
        '1950s' => '1950s',
        "1950's" => "1950's",
        '156u' => '1560s',
        '167-?]' => '1670s?]',
        '[171-?]' => '[1710s?]',
        '[189-]' => '[1890s]',
        'ca.170-?]' => 'ca.1700s?]',
        '200-?]' => '2000s?]',
        '186?' => '1860s',
        '195x' => '1950s',
        'early 1890s' => 'early 1890s',
        'before 195x after' => 'before 1950s after'
      }.each do |example, expected|
        it "#{expected} for #{example}" do
          smods_rec.from_str("#{mods_origin_info_start_str}
            <dateIssued>#{example}</dateIssued>
          #{mods_origin_info_end_str}")
          imp = stanford_mods_imprint(smods_rec)
          updated_element = imp.send(:process_decade_date, smods_rec.origin_info.dateIssued.first)
          expect(updated_element.text).to eq expected
        end
      end
      it 'leaves text alone when date str but no decade' do
        smods_rec.from_str("#{mods_origin_info_start_str}
          <dateIssued>I think July 15, 1965 was a great day</dateIssued>
        #{mods_origin_info_end_str}")
        imp = stanford_mods_imprint(smods_rec)
        updated_element = imp.send(:process_decade_date, smods_rec.origin_info.dateIssued.first)
        expect(updated_element.text).to eq 'I think July 15, 1965 was a great day'
      end
      it 'leaves text alone when no date str' do
        smods_rec.from_str("#{mods_origin_info_start_str}
          <dateIssued>ain't no date heah</dateIssued>
        #{mods_origin_info_end_str}")
        imp = stanford_mods_imprint(smods_rec)
        updated_element = imp.send(:process_decade_date, smods_rec.origin_info.dateIssued.first)
        expect(updated_element.text).to eq "ain't no date heah"
      end
    end

    context 'date_is_century?' do
      ['17uu',
        '17--?',
        'before [16--] after'
      ].each do |example|
        it 'true when century string to change' do
          smods_rec.from_str("#{mods_origin_info_start_str}
            <dateIssued>#{example}</dateIssued>
          #{mods_origin_info_end_str}")
          imp = stanford_mods_imprint(smods_rec)
          element = smods_rec.origin_info.dateIssued.first
          expect(imp.send(:date_is_century?, element)).to be_truthy
        end
      end
      ['18th century CE',
        "before 5th century after"
      ].each do |example|
        it 'false when no century string to change' do
          smods_rec.from_str("#{mods_origin_info_start_str}
            <dateIssued>#{example}</dateIssued>
          #{mods_origin_info_end_str}")
          imp = stanford_mods_imprint(smods_rec)
          element = smods_rec.origin_info.dateIssued.first
          expect(imp.send(:date_is_century?, element)).to be_falsey
        end
      end
    end

    context '#process_century_date' do
      {
        '18th century CE' => '18th century CE',
        '17uu' => '18th century',
        '17--?]' => '18th century?]',
        '17--]' => '18th century]',
        '[17--]' => '[18th century]',
        '[17--?]' => '[18th century?]',
        'before 16uu after' => 'before 17th century after'
      }.each do |example, expected|
        it "#{expected} for #{example}" do
          smods_rec.from_str("#{mods_origin_info_start_str}
            <dateIssued>#{example}</dateIssued>
          #{mods_origin_info_end_str}")
          imp = stanford_mods_imprint(smods_rec)
          updated_element = imp.send(:process_century_date, smods_rec.origin_info.dateIssued.first)
          expect(updated_element.text).to eq expected
        end
      end
      it 'leaves text alone when date str but no century' do
        smods_rec.from_str("#{mods_origin_info_start_str}
          <dateIssued>I think July 15, 1965 was a great day</dateIssued>
        #{mods_origin_info_end_str}")
        imp = stanford_mods_imprint(smods_rec)
        updated_element = imp.send(:process_century_date, smods_rec.origin_info.dateIssued.first)
        expect(updated_element.text).to eq 'I think July 15, 1965 was a great day'
      end
      it 'leaves text alone when no date str' do
        smods_rec.from_str("#{mods_origin_info_start_str}
          <dateIssued>ain't no date heah</dateIssued>
        #{mods_origin_info_end_str}")
        imp = stanford_mods_imprint(smods_rec)
        updated_element = imp.send(:process_century_date, smods_rec.origin_info.dateIssued.first)
        expect(updated_element.text).to eq "ain't no date heah"
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
      imprint_strs = stanford_mods_imprint(smods_rec).imprint_statements
      expect(imprint_strs).to eq ['San Francisco : Chronicle Books, 2015.']
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
      imprint_strs = stanford_mods_imprint(smods_rec).imprint_statements
      expect(imprint_strs).to eq ['[Amsterdam]']
    end
    it "translates encoded place if there isn't a text (or non-typed) value available" do
      smods_rec.from_str(mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">ne</placeTerm>
        </place>' +
        mods_origin_info_end_str)
      imprint_strs = stanford_mods_imprint(smods_rec).imprint_statements
      expect(imprint_strs).to eq ['Netherlands']
    end
    it "ignores 'xx' country code" do
      smods_rec.from_str(mods_origin_info_start_str +
        '<place>
           <placeTerm type="code" authority="marccountry">xx</placeTerm>
         </place>
         <dateIssued>1994</dateIssued>' +
        mods_origin_info_end_str)
      imprint_strs = stanford_mods_imprint(smods_rec).imprint_statements
      expect(imprint_strs).to eq(['1994'])
    end
  end
end
