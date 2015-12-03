# encoding: UTF-8
require 'spec_helper'

describe "Date methods (searchworks.rb)" do

  before(:all) do
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  context "pub_dates" do
    it "should choose the first date" do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>1904</dateCreated>
      <dateCreated>1904</dateCreated>
      <dateIssued>1906</dateIssued>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_dates).to eq(['1906','1904','1904'])
    end
  end

  context "pub_date" do
    before :each do
      @smods_rec = Stanford::Mods::Record.new
    end

    it "should choose the first date" do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>1904</dateCreated>
      </originInfo></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('1904')
    end
    it "should parse a date" do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>Aug. 3rd, 1886</dateCreated>
      </originInfo></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('1886')
    end
    it "should remove question marks and brackets" do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>Aug. 3rd, [18]86?</dateCreated>
      </originInfo></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('1886')
    end
    it 'should handle an s after the decade' do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>early 1890s</dateCreated>
      </originInfo></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('1890')
    end
    it 'should choose a date ending with CE if there are multiple dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>7192 AM (li-Adam) / 1684 CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('1684')
    end
    it 'should handle hyphenated range dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>1282 AH / 1865-6 CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('1865')
    end
    it 'should work with multiple 4 digit dates' do
      m = "<mods #{@ns_decl}><originInfo><dateCreated>Text dated June 4, 1594; miniatures added by 1596</dateCreated></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('1594')
    end
    it 'should work on 3 digit BC dates' do
      m = "<mods #{@ns_decl}><originInfo><dateCreated>300 B.C.</dateCreated></originInfo>"
      @smods_rec.from_str(m)
       expect(@smods_rec.pub_year).to eq('-700')
       expect(@smods_rec.pub_date).to eq('-700')
       expect(@smods_rec.pub_date_sort).to eq('-700')
       expect(@smods_rec.pub_date_facet).to eq('300 B.C.')
    end
    it 'should handle century based dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>13th century AH / 19th CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date_facet).to eq('19th century')
      expect(@smods_rec.pub_date_sort).to eq('1800')
      expect(@smods_rec.pub_date).to eq('18--')
    end
    it 'should handle multiple CE dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>6 Dhu al-Hijjah 923 AH / 1517 CE -- 7 Rabi I 924 AH / 1518 CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('1517')
      expect(@smods_rec.pub_date_sort).to eq('1517')
      expect(@smods_rec.pub_date_facet).to eq('1517')
    end
    it 'should handle this case from walters' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>Late 14th or early 15th century CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('14--')
      expect(@smods_rec.pub_date_sort).to eq('1400')
      expect(@smods_rec.pub_date_facet).to eq('15th century')
    end
    it 'should work on 3 digit dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>966 CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('966')
      expect(@smods_rec.pub_date_sort).to eq('0966')
      expect(@smods_rec.pub_date_facet).to eq('966')
    end
    it 'should work on 3 digit dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>3rd century AH / 9th CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date).to eq('8--')
      expect(@smods_rec.pub_date_sort).to eq('0800')
      expect(@smods_rec.pub_date_facet).to eq('9th century')
    end
    it 'should use the dateIssued without marc encoding for pub_date_display and the one with marc encoding for indexing, sorting and faceting' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>[186-?]</dateIssued><dateIssued encoding=\"marc\">1860</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date_display).to eq('[186-?]')
      expect(@smods_rec.pub_date).to eq('1860')
      expect(@smods_rec.pub_date_sort).to eq('1860')
      expect(@smods_rec.pub_date_facet).to eq('1860')
    end
    it 'should use the dateIssued without marc encoding for pub_date_display and the one with marc encoding for indexing, sorting and faceting' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>1860?]</dateIssued><dateIssued encoding=\"marc\">186?</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec.from_str(m)
      expect(@smods_rec.pub_date_display).to eq('1860?]')
      expect(@smods_rec.pub_date).to eq('1860')
      expect(@smods_rec.pub_date_sort).to eq('1860')
      expect(@smods_rec.pub_date_facet).to eq('1860')
    end
  end # pub_date

  context "dates with u notation (198u, 19uu)" do
    context "single digit u notation (198u)" do
      before(:all) do
        m = "<mods #{@ns_decl}>
        <originInfo>
          <dateIssued encoding=\"marc\" point=\"start\" keyDate=\"yes\">198u</dateIssued>
          <dateIssued encoding=\"marc\" point=\"end\">9999</dateIssued>
        </originInfo></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
      end
      it 'pub_date: 198u = 1980' do
        expect(@smods_rec.pub_date).to eq('1980')
      end
      it "pub_date_sort: 198u = 1980" do
        expect(@smods_rec.pub_date_sort).to eq('1980')
      end
      it "pub_date_facet: 198u = 1980" do
        expect(@smods_rec.pub_date_facet).to eq('1980')
      end
    end
    context "double digit u notation (19uu)" do
      before(:all) do
        m = "<mods #{@ns_decl}>
        <originInfo>
          <dateIssued encoding=\"marc\" point=\"start\" keyDate=\"yes\">19uu</dateIssued>
          <dateIssued encoding=\"marc\" point=\"end\">9999</dateIssued>
        </originInfo></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
      end
      it 'pub_date: 19uu = 19--' do
        expect(@smods_rec.pub_date).to eq('19--')
      end
      it "pub_date_sort: 19uu = 1900" do
        expect(@smods_rec.pub_date_sort).to eq('1900')
      end
      it "pub_date_facet: 19uu = 20th century" do
        expect(@smods_rec.pub_date_facet).to eq('20th century')
      end
    end
  end # u notation


  context 'pub_date_sort' do
    before :all do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>Aug. 3rd, 1886</dateCreated>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
    end
    it 'should work on normal dates' do
      allow(@smods_rec).to receive(:pub_date).and_return('1945')
      expect(@smods_rec.pub_date_sort).to eq('1945')
    end
    it 'should work on 3 digit dates' do
      allow(@smods_rec).to receive(:pub_date).and_return('945')
      expect(@smods_rec.pub_date_sort).to eq('0945')
    end
    it 'should work on century dates' do
      allow(@smods_rec).to receive(:pub_date).and_return('16--')
      expect(@smods_rec.pub_date_sort).to eq('1600')
    end
    it 'should work on 3 digit century dates' do
      allow(@smods_rec).to receive(:pub_date).and_return('9--')
      expect(@smods_rec.pub_date_sort).to eq('0900')
    end
  end

end
