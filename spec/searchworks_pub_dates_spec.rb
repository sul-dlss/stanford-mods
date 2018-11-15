# encoding: UTF-8
describe "Date methods (searchworks.rb)" do
  let(:ns_decl) { "xmlns='#{Mods::MODS_NS}'" }
  let(:smods_rec) { Stanford::Mods::Record.new }

  # NOTE: walters dates are now:
  # dateIssued:  1500 CE
  # dateIssued:  15th century CE
  # dateIssued:  Ca. 1580 CE
  # or
  # dateCreated:  4 digit year
  #   and they should go in spec/fixtures searchworks_pub_date_data.rb

  # @deprecated:  need to switch to pub_year_int, or pub_date_sortable_string if you must have a string (why?)
  context '#pub_date_sort (deprecated)' do
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
    it '1980 for 198u' do
      m = "<mods #{ns_decl}>
            <originInfo>
              <dateIssued>198u</dateIssued>
            </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_sort).to eq('1980')
    end
    it '1900 for 19uu' do
      m = "<mods #{ns_decl}>
            <originInfo>
              <dateIssued>19uu</dateIssued>
            </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_sort).to eq('1900')
    end
    it '-700 for 300 B.C.' do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>300 B.C.</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_sort).to eq('-700')
    end
    it '0966 for 966' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>966</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_sort).to eq('0966')
    end
    it '0800 for 9th century' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>9th century</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_sort).to eq('0800')
    end
  end

  context '#pub_date_facet' do
    it '1980 for 198u' do
      m = "<mods #{ns_decl}>
            <originInfo>
              <dateIssued>198u</dateIssued>
            </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_facet).to eq('1980')
    end
    it '20th century for 19uu' do
      m = "<mods #{ns_decl}>
            <originInfo>
              <dateIssued>19uu</dateIssued>
            </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_facet).to eq('20th century')
    end
    it '3000 B.C. for 300 B.C.' do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>300 B.C.</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_facet).to eq('300 B.C.')
    end
    it '966 for 966' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>966</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_facet).to eq('966')
    end
    it '9th century for 9th century' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>9th century</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_facet).to eq('9th century')
    end
  end

  context 'uses dateIssued with marc encoding for sorting and faceting' do
    it '1860' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>1844</dateIssued>
          <dateIssued encoding=\"marc\">1860</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_sort).to eq('1860') # @deprecated:  need to switch to pub_year_int, or pub_date_sortable_string if you must have a string (why?)
      expect(smods_rec.pub_date_facet).to eq('1860')
    end
    it '186?' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>1844</dateIssued>
          <dateIssued encoding=\"marc\">186?</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.pub_date_sort).to eq('1860') # @deprecated:  need to switch to pub_year_int, or pub_date_sortable_string if you must have a string (why?)
      expect(smods_rec.pub_date_facet).to eq('1860')
    end
  end

  context '#pub_year (protected)' do
    it '-700 for 300 B.C.' do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>300 B.C.</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_year)).to eq('-700')
    end
  end

  context "#pub_date (protected)" do
    it "uses dateCreated if no dateIssued" do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>1904</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('1904')
    end
    it "gets year from text date" do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>Aug. 3rd, 1886</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('1886')
    end
    it "ignores question marks and square brackets" do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>Aug. 3rd, [18]86?</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('1886')
    end
    it '1890 for 1890s' do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>early 1890s</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('1890')
    end
    it 'takes first occurring 4 digit date in string' do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>Text dated June 4, 1594; miniatures added by 1596</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('1594')
    end
    it '1980 for 198u' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued >198u</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('1980')
    end
    it '19-- for 19uu' do
      m = "<mods #{ns_decl}>
      <originInfo>
        <dateIssued>19uu</dateIssued>
      </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('19--')
    end
    it '-700 for 300 B.C.' do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>300 B.C.</dateCreated>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('-700')
    end
    it '966 for 966' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>966</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('966')
    end
    it '8-- for 9th century' do
      m = "<mods #{ns_decl}><originInfo>
          <dateIssued>9th century</dateIssued>
        </originInfo></mods>"
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_date)).to eq('8--')
    end
  end # pub_date

  context "pub_dates (protected)" do
    it "puts dateIssued values before dateCreated values" do
      m = "<mods #{ns_decl}><originInfo>
          <dateCreated>1904</dateCreated>
          <dateCreated>1904</dateCreated>
          <dateIssued>1906</dateIssued>
        </originInfo></mods>"
      smods_rec = Stanford::Mods::Record.new
      smods_rec.from_str(m)
      expect(smods_rec.send(:pub_dates)).to eq(['1906', '1904', '1904'])
    end
  end
end
