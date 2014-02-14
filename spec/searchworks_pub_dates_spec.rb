# encoding: UTF-8
require 'spec_helper'

describe "Date methods in Searchworks mixin for Stanford::Mods::Record" do

  before(:all) do
    @smods_rec = Stanford::Mods::Record.new
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
      @smods_rec.pub_dates.should == ['1906','1904','1904']
    end

    it 'should choose a date ending with CE if there are multiple dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>7192 AM (li-Adam) / 1684 CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '1684'
    end  

  end


  context "pub_date" do
    it "should choose the first date" do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>1904</dateCreated>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '1904'
    end
    it "should parse a date" do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>Aug. 3rd, 1886</dateCreated>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '1886'
    end
    it "should remove question marks and brackets" do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>Aug. 3rd, [18]86?</dateCreated>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '1886'
    end
    it 'should handle an s after the decade' do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>early 1890s</dateCreated>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '1890'
    end
    it 'should choose a date ending with CE if there are multiple dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>7192 AM (li-Adam) / 1684 CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '1684'
    end
    it 'should handle hyphenated range dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>1282 AH / 1865-6 CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '1865'
    end
    it 'should work with multiple 4 digit dates' do
      m = "<mods #{@ns_decl}><originInfo><dateCreated>Text dated June 4, 1594; miniatures added by 1596</dateCreated></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
       @smods_rec.pub_date.should == '1594'
    end
    it 'should work on 3 digit BC dates' do
      m = "<mods #{@ns_decl}><originInfo><dateCreated>300 B.C.</dateCreated></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
       @smods_rec.pub_year.should == '-700'
       @smods_rec.pub_date.should == '-700'
       @smods_rec.pub_date_sort.should =='-700'
       @smods_rec.pub_date_facet.should == '300 B.C.'
    end
    it 'should handle century based dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>13th century AH / 19th CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date_facet.should == '19th century'
      @smods_rec.pub_date_sort.should =='1800'
      @smods_rec.pub_date.should == '18--'
    end
    it 'should handle multiple CE dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>6 Dhu al-Hijjah 923 AH / 1517 CE -- 7 Rabi I 924 AH / 1518 CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '1517'
      @smods_rec.pub_date_sort.should =='1517'
      @smods_rec.pub_date_facet.should == '1517'
    end
    it 'should handle this case from walters' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>Late 14th or early 15th century CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '14--'
      @smods_rec.pub_date_sort.should =='1400'
      @smods_rec.pub_date_facet.should == '15th century'
    end
    it 'should work on 3 digit dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>966 CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date.should == '966'
      @smods_rec.pub_date_sort.should =='0966'
      @smods_rec.pub_date_facet.should == '966'
    end
    it 'should work on 3 digit dates' do
      m = "<mods #{@ns_decl}><originInfo><dateIssued>3rd century AH / 9th CE</dateIssued><issuance>monographic</issuance></originInfo>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
  
      @smods_rec.pub_date.should == '8--'
      @smods_rec.pub_date_sort.should =='0800'
      @smods_rec.pub_date_facet.should == '9th century'
    end
  
    context "dates with u notation (e.g., 198u)" do
      context "single digit u notation (e.g., 198u)" do
        before(:each) do
          m = "<mods #{@ns_decl}>
          <originInfo>
            <dateIssued encoding=\"marc\" point=\"start\" keyDate=\"yes\">198u</dateIssued>
            <dateIssued encoding=\"marc\" point=\"end\">9999</dateIssued>
          </originInfo></mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
        end
        it "recognizes single digit u notation" do
          dates = ["198u", "9999"]
          uDate = @smods_rec.get_u_year dates
          uDate.should eql("1980")
        end
        it 'pub_date: 198u = 1980' do
          @smods_rec.pub_date.should == '1980'
        end
        it "pub_date_sort: 198u = 1980" do
          @smods_rec.pub_date_sort.should =='1980'
        end
        it "pub_date_facet: 198u = 1980" do
          @smods_rec.pub_date_facet.should == '1980'
        end
      end
      context "double digit u notation (e.g., 19uu)" do
        before(:each) do
          m = "<mods #{@ns_decl}>
          <originInfo>
            <dateIssued encoding=\"marc\" point=\"start\" keyDate=\"yes\">19uu</dateIssued>
            <dateIssued encoding=\"marc\" point=\"end\">9999</dateIssued>
          </originInfo></mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
        end
        it "recognizes double digit u notation" do
          dates = ["19uu", "9999"]
          uDate = @smods_rec.get_u_year dates
          uDate.should eql("19--")
        end
        it 'pub_date: 19uu = 19--' do
          @smods_rec.pub_date.should == '19--'
        end
        it "pub_date_sort: 19uu = 1900" do
          @smods_rec.pub_date_sort.should =='1900'
        end
        it "pub_date_facet: 19uu = 20th century" do
          @smods_rec.pub_date_facet.should == '20th century'
        end
      end
    end
  
  end #context pub_dates

  context 'pub_date_sort' do
    before :each do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>Aug. 3rd, 1886</dateCreated>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
  
    end
    it 'should work on normal dates' do
      @smods_rec.stub(:pub_date).and_return('1945')
      @smods_rec.pub_date_sort.should == '1945'
    end
    it 'should work on 3 digit dates' do
      @smods_rec.stub(:pub_date).and_return('945')
      @smods_rec.pub_date_sort.should == '0945'
    end
    it 'should work on century dates' do
      @smods_rec.stub(:pub_date).and_return('16--')
      @smods_rec.pub_date_sort.should == '1600'
    end
    it 'should work on 3 digit century dates' do
      @smods_rec.stub(:pub_date).and_return('9--')
      @smods_rec.pub_date_sort.should == '0900'
    end
  end


  context "pub_date_groups" do
    it 'should generate the groups' do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>1904</dateCreated>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
    
      @smods_rec.pub_date_groups(1904).should == ['More than 50 years ago']
    end
    it 'should work for a modern date too' do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>1904</dateCreated>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date_groups(2013).should == ["This year"]
    end
    it 'should work ok given a nil date' do
      m = "<mods #{@ns_decl}><originInfo>
      <dateCreated>1904</dateCreated>
      </originInfo></mods>"
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str(m)
      @smods_rec.pub_date_groups(nil).should == nil
    end
  end#context pub date groups

end