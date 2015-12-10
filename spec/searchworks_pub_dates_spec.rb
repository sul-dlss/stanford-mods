# encoding: UTF-8
require 'spec_helper'

describe "Date methods (searchworks.rb)" do

  let(:ns_decl) { "xmlns='#{Mods::MODS_NS}'" }

  context "pub_dates" do
    it "puts dateIssued values before dateCreated values" do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>1904</dateCreated>
          <dateCreated>1904</dateCreated>
          <dateIssued>1906</dateIssued>
        </originInfo></mods>"
      smods_rec = Stanford::Mods::Record.new
      smods_rec.from_str(m)
      expect(smods_rec.pub_dates).to eq(['1906', '1904', '1904'])
    end
  end

  context "pub_date" do
    let(:smods_rec) { Stanford::Mods::Record.new }

    it "uses dateCreated if no dateIssued" do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>1904</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('1904')
    end
    it "parses date" do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>Aug. 3rd, 1886</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('1886')
    end
    it "ignores question marks and square brackets" do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>Aug. 3rd, [18]86?</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('1886')
    end
    it 'handles an s after the decade' do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>early 1890s</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('1890')
    end
    it 'chooses date ending with CE if there are other choices' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>7192 AM (li-Adam) / 1684 CE</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('1684')
    end
    it 'handles 1865-6 (hyphenated range dates)' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>1282 AH / 1865-6 CE</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('1865')
    end
    it 'takes first occurring 4 digit date in string' do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>Text dated June 4, 1594; miniatures added by 1596</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('1594')
    end
    it '3 digit BC dates are "B.C." in pub_date_facet and negative in pub_date_sort, pub_year, and pub_date' do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>300 B.C.</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_year).to eq('-700')
      expect(smods_rec.pub_date).to eq('-700')
      expect(smods_rec.pub_date_sort).to eq('-700')
      expect(smods_rec.pub_date_facet).to eq('300 B.C.')
    end
    it '"19th CE" becomes 1800 for pub_date_sort, 19th centruy for pub_date_facet' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>13th century AH / 19th CE</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_facet).to eq('19th century')
      expect(smods_rec.pub_date_sort).to eq('1800')
      expect(smods_rec.pub_date).to eq('18--')
    end
    it 'takes first of multiple CE dates' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>6 Dhu al-Hijjah 923 AH / 1517 CE -- 7 Rabi I 924 AH / 1518 CE</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('1517')
      expect(smods_rec.pub_date_sort).to eq('1517')
      expect(smods_rec.pub_date_facet).to eq('1517')
    end
    it 'handles "Late 14th or early 15th century CE" from walters' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>Late 14th or early 15th century CE</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('14--')
      expect(smods_rec.pub_date_sort).to eq('1400')
      expect(smods_rec.pub_date_facet).to eq('15th century')
    end
    it 'explicit 3 digit dates have correct pub_date_sort and pub_date_facet' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>966 CE</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('966')
      expect(smods_rec.pub_date_sort).to eq('0966')
      expect(smods_rec.pub_date_facet).to eq('966')
    end
    it 'single digit century dates have correct pub_date_sort and pub_date_facet' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>3rd century AH / 9th CE</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date).to eq('8--')
      expect(smods_rec.pub_date_sort).to eq('0800')
      expect(smods_rec.pub_date_facet).to eq('9th century')
    end
    it 'uses dateIssued without marc encoding for pub_date_display and the one with marc encoding for indexing, sorting and faceting' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>[186-?]</dateIssued><dateIssued encoding=\"marc\">1860</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_display).to eq('[186-?]')
      expect(smods_rec.pub_date).to eq('1860')
      expect(smods_rec.pub_date_sort).to eq('1860')
      expect(smods_rec.pub_date_facet).to eq('1860')
    end
    it 'uses dateIssued without marc encoding for pub_date_display and the one with marc encoding for indexing, sorting and faceting' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>1860?]</dateIssued><dateIssued encoding=\"marc\">186?</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_display).to eq('1860?]')
      expect(smods_rec.pub_date).to eq('1860')
      expect(smods_rec.pub_date_sort).to eq('1860')
      expect(smods_rec.pub_date_facet).to eq('1860')
    end
  end # pub_date

  context "dates with u notation (198u, 19uu)" do
    context "single digit u notation (198u)" do
      let(:smods_rec) do
        m = "<mods #{ns_decl}>
        <originInfo>
          <dateIssued encoding=\"marc\" point=\"start\" keyDate=\"yes\">198u</dateIssued>
          <dateIssued encoding=\"marc\" point=\"end\">9999</dateIssued>
        </originInfo></mods>"
        smr = Stanford::Mods::Record.new
        smr.from_str(m)
        smr
      end
      it 'pub_date: 198u = 1980' do
        expect(smods_rec.pub_date).to eq('1980')
      end
      it "pub_date_sort: 198u = 1980" do
        expect(smods_rec.pub_date_sort).to eq('1980')
      end
      it "pub_date_facet: 198u = 1980" do
        expect(smods_rec.pub_date_facet).to eq('1980')
      end
    end
    context "double digit u notation (19uu)" do
      let(:smods_rec) do
        m = "<mods #{ns_decl}>
        <originInfo>
          <dateIssued encoding=\"marc\" point=\"start\" keyDate=\"yes\">19uu</dateIssued>
          <dateIssued encoding=\"marc\" point=\"end\">9999</dateIssued>
        </originInfo></mods>"
        smr = Stanford::Mods::Record.new
        smr.from_str(m)
        smr
      end
      it 'pub_date: 19uu = 19--' do
        expect(smods_rec.pub_date).to eq('19--')
      end
      it "pub_date_sort: 19uu = 1900" do
        expect(smods_rec.pub_date_sort).to eq('1900')
      end
      it "pub_date_facet: 19uu = 20th century" do
        expect(smods_rec.pub_date_facet).to eq('20th century')
      end
    end
  end # u notation

  context 'pub_date_sort' do
    let(:smods_rec) { Stanford::Mods::Record.new }
    it 'four digits' do
      allow(smods_rec).to receive(:pub_date).and_return('1945')
      expect(smods_rec.pub_date_sort).to eq('1945')
    end
    it '3 digits' do
      allow(smods_rec).to receive(:pub_date).and_return('945')
      expect(smods_rec.pub_date_sort).to eq('0945')
    end
    it '16--' do
      allow(smods_rec).to receive(:pub_date).and_return('16--')
      expect(smods_rec.pub_date_sort).to eq('1600')
    end
    it '9--' do
      allow(smods_rec).to receive(:pub_date).and_return('9--')
      expect(smods_rec.pub_date_sort).to eq('0900')
    end
  end

end
