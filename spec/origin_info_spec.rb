describe "computations from /originInfo field" do
  let(:smods_rec) { Stanford::Mods::Record.new }

  # used for single examples
  let(:mods_origin_info_start_str) { "<mods xmlns=\"#{Mods::MODS_NS}\"><originInfo>" }
  let(:mods_origin_info_end_str) { '</originInfo></mods>' }

  # used for hashes/arrays of examples
  let(:mods_origin_info) do
    <<-EOF
    #{mods_origin_info_start_str}
        #{example}
     #{mods_origin_info_end_str}
    EOF
  end

  RSpec.shared_examples "single pub date value" do |method_sym, exp_val_position|
    it 'prefers dateIssued to dateCreated' do
      mods_str = mods_origin_info_start_str +
          '<dateIssued>2005</dateIssued>' +
        '</originInfo>' +
        '<originInfo>
          <dateCreated>1999</dateCreated>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym)).to eq method_sym.to_s =~ /int/ ? 2005 : '2005'
    end
    it 'respects ignore_approximate param' do
      mods_str = mods_origin_info_start_str +
        '<dateCreated point="start" qualifier="approximate">1000</dateCreated>' +
        '<dateCreated point="end">1599</dateCreated>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym, ignore_approximate: true)).to eq method_sym.to_s =~ /int/ ? 1599 : '1599'
      expect(smods_rec.send(method_sym, ignore_approximate: false)).to eq method_sym.to_s =~ /int/ ? 1000 : '1000'
    end
    it 'nil if ignore_approximate and all dates are approximate' do
      mods_str = mods_origin_info_start_str +
        '<dateCreated point="start" qualifier="approximate">1000</dateCreated>' +
        '<dateCreated point="end" qualifier="questionable">1599</dateCreated>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym, ignore_approximate: true)).to eq nil
      expect(smods_rec.send(method_sym, ignore_approximate: false)).to eq method_sym.to_s =~ /int/ ? 1000 : '1000'
    end
    it 'respects ignore_approximate even for keyDate' do
      mods_str = mods_origin_info_start_str +
        '<dateCreated point="start" qualifier="approximate" keyDate="yes">1000</dateCreated>' +
        '<dateCreated point="end">1599</dateCreated>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym, ignore_approximate: true)).to eq method_sym.to_s =~ /int/ ? 1599 : '1599'
      expect(smods_rec.send(method_sym, ignore_approximate: false)).to eq method_sym.to_s =~ /int/ ? 1000 : '1000'
    end
    it 'uses dateCaptured if no dateIssued or dateCreated' do
      # for web archive seed files
      mods_str = mods_origin_info_start_str +
        '<dateCaptured encoding="w3cdtf" point="start" keyDate="yes">20151215121212</dateCaptured>' +
        '<dateCaptured encoding="w3cdtf" point="end">20151218111111</dateCaptured>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym)).to eq method_sym.to_s =~ /int/ ? 2015 : '2015'
    end
    context 'spotlight actual data' do
      require 'fixtures/spotlight_pub_date_data'
      SPOTLIGHT_PUB_DATE_DATA.each_pair.each do |coll_name, coll_data|
        # papyri - the only Spotlight data with BC dates
        next if coll_name == 'papyri' && method_sym == :pub_year_int

        coll_data.each_pair do |mods_str, exp_vals|
          expected = exp_vals[exp_val_position]
          it "#{expected} for rec in #{coll_name}" do
            smods_rec.from_str(mods_str)
            expect(smods_rec.send(method_sym)).to eq((method_sym.to_s =~ /int/ ? expected.to_i : expected)) if expected
          end
        end
      end
    end
  end

  context '#pub_year_display_str' do
    it_behaves_like "single pub date value", :pub_year_display_str, 1
  end

  context '#pub_year_sort_str' do
    it_behaves_like "single pub date value", :pub_year_sort_str, 0
  end

  context '#pub_year_int' do
    it_behaves_like "single pub date value", :pub_year_int, 0
    # papyri - the only Spotlight data with BC dates
    it '-200 for 200 B.C.' do
      # hd778hw9236
      mods_str = mods_origin_info_start_str +
        '<dateCreated keyDate="yes" point="start" qualifier="approximate">200 B.C.</dateCreated>' +
        '<dateCreated keyDate="yes" point="end" qualifier="approximate">180 B.C.</dateCreated>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.pub_year_int).to eq(-199)
    end
    it '-211 for 211 B.C.' do
      # ww728rz0477
      mods_str = mods_origin_info_start_str +
        '<dateCreated keyDate="yes" point="start" qualifier="approximate">211 B.C.</dateCreated>' +
        '<dateCreated keyDate="yes" point="end" qualifier="approximate">150 B.C.</dateCreated>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.pub_year_int).to eq(-210)
    end
  end

  context '*best_or_earliest_year' do
    it 'selects earliest (valid) parseable date from multiple options' do
      mods_str = mods_origin_info_start_str +
        '<dateIssued point="start" qualifier="questionable">1758</dateIssued>' +
        '<dateIssued point="end" qualifier="questionable">uuuu</dateIssued>' +
        '<dateIssued>1753]</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(Stanford::Mods::OriginInfo.best_or_earliest_year(smods_rec.origin_info.dateIssued).xml.text).to eq '1753]'
    end
    it 'ignores encoding' do
      # encoding matters for choosing display, not for parsing year
      mods_str = mods_origin_info_start_str +
        '<dateIssued>1100</dateIssued>' +
        '<dateIssued encoding="marc">1200</dateIssued>' +
        '<dateIssued encoding="w3cdtf">1300</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(Stanford::Mods::OriginInfo.best_or_earliest_year(smods_rec.origin_info.dateIssued).xml.text).to eq '1100'
      mods_str = mods_origin_info_start_str +
        '<dateIssued>1200</dateIssued>' +
        '<dateIssued encoding="marc">1300</dateIssued>' +
        '<dateIssued encoding="w3cdtf">1100</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(Stanford::Mods::OriginInfo.best_or_earliest_year(smods_rec.origin_info.dateIssued).xml.text).to eq '1100'
      mods_str = mods_origin_info_start_str +
        '<dateIssued>1300</dateIssued>' +
        '<dateIssued encoding="marc">1100</dateIssued>' +
        '<dateIssued encoding="w3cdtf">1200</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(Stanford::Mods::OriginInfo.best_or_earliest_year(smods_rec.origin_info.dateIssued).xml.text).to eq '1100'
    end
  end

  RSpec.shared_examples "pub date best single value" do |method_sym|
    it 'uses keyDate value if specified' do
      mods_str = mods_origin_info_start_str +
        '<dateIssued>1666</dateIssued>' +
        '<dateIssued keyDate="yes">2014</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym, smods_rec.origin_info.dateIssued)).to eq method_sym.to_s =~ /int/ ? 2014 : '2014'
    end
    it 'ignores invalid keyDate value' do
      mods_str = mods_origin_info_start_str +
        '<dateIssued keyDate="6th">1500</dateIssued>' +
        '<dateIssued>1499</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym, smods_rec.origin_info.dateIssued)).to eq method_sym.to_s =~ /int/ ? 1499 : '1499'
    end
    it 'calls earliest_year if multiple keyDates present' do
      mods_str = mods_origin_info_start_str +
        '<dateCreated keyDate="yes">2003</dateCreated>' +
        '<dateCreated keyDate="yes">2001</dateCreated>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
        expect(Stanford::Mods::OriginInfo).to receive(:best_or_earliest_year).with(smods_rec.origin_info.dateCreated)
      expect(smods_rec.send(method_sym, smods_rec.origin_info.dateCreated))
    end
    it 'calls earliest_year if no keyDate' do
      mods_str = mods_origin_info_start_str +
        '<dateIssued>1753]</dateIssued>' +
        '<dateIssued point="start" qualifier="questionable">1758</dateIssued>' +
        '<dateIssued point="end" qualifier="questionable">uuuu</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      if method_sym.to_s =~ /int/
        expect(Stanford::Mods::OriginInfo).to receive(:best_or_earliest_year).with(smods_rec.origin_info.dateIssued)
      else
        expect(Stanford::Mods::OriginInfo).to receive(:best_or_earliest_year).with(smods_rec.origin_info.dateIssued)
      end
      smods_rec.send(method_sym, smods_rec.origin_info.dateIssued)
    end
    it 'ignores encoding' do
      # encoding matters for choosing display, not for parsing year
      mods_str = mods_origin_info_start_str +
        '<dateIssued keyDate="yes">1100</dateIssued>' +
        '<dateIssued encoding="marc">1200</dateIssued>' +
        '<dateIssued encoding="w3cdtf">1300</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym, smods_rec.origin_info.dateIssued)).to eq method_sym.to_s =~ /int/ ? 1100 : '1100'
      mods_str = mods_origin_info_start_str +
        '<dateIssued>1200</dateIssued>' +
        '<dateIssued encoding="marc">1300</dateIssued>' +
        '<dateIssued encoding="w3cdtf" keyDate="yes">1100</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym, smods_rec.origin_info.dateIssued)).to eq method_sym.to_s =~ /int/ ? 1100 : '1100'
      mods_str = mods_origin_info_start_str +
        '<dateIssued>1300</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1100</dateIssued>' +
        '<dateIssued encoding="w3cdtf">1200</dateIssued>' +
        mods_origin_info_end_str
      smods_rec.from_str(mods_str)
      expect(smods_rec.send(method_sym, smods_rec.origin_info.dateIssued)).to eq method_sym.to_s =~ /int/ ? 1100 : '1100'
    end
  end

  context '*is_approximate' do
    it 'removes elements when date_is_approximate? returns true' do
      mods_str = "#{mods_origin_info_start_str}
        <dateIssued>1900</dateIssued>
        <dateIssued qualifier='inferred'>1910</dateIssued>
        <dateIssued qualifier='questionable'>1930</dateIssued>
        #{mods_origin_info_end_str}"
      smods_rec.from_str(mods_str)
      elements = smods_rec.origin_info.dateIssued
      expect(elements.size).to eq 3
      result = elements.reject { |n| smods_rec.is_approximate(n) }
      expect(result).to be_instance_of(Array)
      expect(result.size).to eq 2
    end
  end
end
