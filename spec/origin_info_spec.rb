describe "computations from /originInfo field" do

  let(:smods_rec) { Stanford::Mods::Record.new }

  let(:mods_origin_info_start_str) { "<mods xmlns=\"#{Mods::MODS_NS}\"><originInfo>" }
  let(:mods_origin_info_end_str) { '</originInfo></mods>' }

  let(:mods_origin_info) do
    <<-EOF
      <mods xmlns="#{Mods::MODS_NS}">
        <originInfo>
          #{example}
        </originInfo>
      </mods>
    EOF
  end

  context '#date_issued_nodeset' do
    # example string as key, expected num of Elements as value
    {
      '<dateIssued>[1717]</dateIssued><dateIssued encoding="marc">1717</dateIssued>' => 2,
      '' => 0
    }.each do |example, expected|
      describe "for example: #{example}" do
        let(:example) { example }
        it 'returns Nokogiri NodeSet of Elements matching /originInfo/dateIssued' do
          smods_rec.from_str(mods_origin_info)
          result = smods_rec.date_issued_nodeset
          expect(result).to be_instance_of(Nokogiri::XML::NodeSet)
          expect(result.size).to eq expected
          expect(result).to all(be_an(Nokogiri::XML::Element))
        end
      end
    end
  end

  context '#date_created_nodeset' do
    # example string as key, expected num of Elements as value
    {
      '<dateCreated encoding="edtf" keydate="yes" point="start">-0012</dateCreated>
         <dateCreated encoding="edtf" point="end">-0044</dateCreated>' => 2,
      '' => 0
    }.each do |example, expected|
      describe "for example: #{example}" do
        let(:example) { example }
        it 'returns Nokogiri NodeSet of Elements matching /originInfo/dateCreated' do
          smods_rec.from_str(mods_origin_info)
          result = smods_rec.date_created_nodeset
          expect(result).to be_instance_of(Nokogiri::XML::NodeSet)
          expect(result.size).to eq expected
          expect(result).to all(be_an(Nokogiri::XML::Element))
        end
      end
    end
  end

  context '#keyDate' do
    it 'returns nil if passed nodeset is empty' do
      mods_str = "#{mods_origin_info_start_str}#{mods_origin_info_end_str}"
      smods_rec.from_str(mods_str)
      expect(smods_rec.keyDate(smods_rec.date_issued_nodeset)).to be_nil
    end
    it 'returns nil if passed nodeset has no element with keyDate attribute' do
      mods_str = "#{mods_origin_info_start_str}<dateIssued>[1738]</dateIssued>#{mods_origin_info_end_str}"
      smods_rec.from_str(mods_str)
      expect(smods_rec.keyDate(smods_rec.date_issued_nodeset)).to be_nil
    end
    it 'returns nil if passed nodeset has multiple elements with keyDate attribute' do
      mods_str = "#{mods_origin_info_start_str}
        <dateIssued>[1968?-</dateIssued>
        <dateIssued encoding='marc' point='start' keyDate='yes'>1968</dateIssued>
        <dateIssued encoding='marc' point='end' keyDate='yes'>9999</dateIssued>
        #{mods_origin_info_end_str}"
      smods_rec.from_str(mods_str)
      expect(smods_rec.keyDate(smods_rec.date_issued_nodeset)).to be_nil
    end
    it 'returns single Nokogiri::XML::Element if nodeset has single element with keyDate attribute' do
      mods_str = "#{mods_origin_info_start_str}<dateIssued encoding='w3cdtf' keyDate='yes'>2011</dateIssued>#{mods_origin_info_end_str}"
      smods_rec.from_str(mods_str)
      expect(smods_rec.keyDate(smods_rec.date_issued_nodeset)).to be_instance_of(Nokogiri::XML::Element)
    end
  end

  context '#get_u_year' do
    it "turns ending u to 0" do
      expect(smods_rec.send(:get_u_year, ["201u"])).to eql "2010"
      expect(smods_rec.send(:get_u_year, ["198u"])).to eql "1980"
      expect(smods_rec.send(:get_u_year, ["185u"])).to eql "1850"
    end
    it "turns ending uu to --" do
      expect(smods_rec.send(:get_u_year, ["19uu"])).to eql "19--"
      expect(smods_rec.send(:get_u_year, ["17uu"])).to eql "17--"
    end
    it 'ignores 9999' do
      expect(smods_rec.send(:get_u_year, ["9999"])).to be_nil
    end
  end
end