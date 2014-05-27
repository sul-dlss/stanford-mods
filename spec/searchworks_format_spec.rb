# encoding: UTF-8
require 'spec_helper'

describe "Format field from Searchworks mixin for Stanford::Mods::Record" do

  before(:all) do
    @smods_rec = Stanford::Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  context "SW format Book:" do
    context "typeOfResource text," do
      it 'originInfo/issuance monographic' do
        m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><originInfo><issuance>monographic</issuance></originInfo></mods>"
        @smods_rec.from_str(m)
        @smods_rec.format.should == ['Book']
      end
      context "genre" do
        it "'book chapter'", :email => 'mods-squad 2014-05-22, Joanna Dyla' do
          m = "<mods #{@ns_decl}><genre>book chapter</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          @smods_rec.format.should == ['Book']
        end
        it "'issue brief'", :email => 'mods-squad 2014-05-22, Joanna Dyla' do
          m = "<mods #{@ns_decl}><genre>issue brief</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          @smods_rec.format.should == ['Book']
        end
        it "'libretto'", :email => 'mods-squad 2014-05-22, Laura Wilsey' do
          m = "<mods #{@ns_decl}><genre>libretto</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          @smods_rec.format.should == ['Book']
        end
        it "'report'", :jira => 'GRYP-170', :github => 'gdor-indexer/#7' do
          m = "<mods #{@ns_decl}><genre>report</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          @smods_rec.format.should == ['Book']
        end
        it "'technical report'", :jira => 'GRYPHONDOR-207' do
          m = "<mods #{@ns_decl}><genre>technical report</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          @smods_rec.format.should == ['Book']
        end
        it "'working paper'", :email => 'mods-squad 2014-05-22, Joanna Dyla' do
          m = "<mods #{@ns_decl}><genre>working paper</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          @smods_rec.format.should == ['Book']
        end
      end
    end
  end
  
  it 'should work for datasets' do
    m = "<mods #{@ns_decl}><typeOfResource>software, multimedia</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Computer File']
  end


  it "should work for a hydrus journal article" do
    m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>article</genre></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Journal/Periodical']
  end

  it "should work for image" do
    m = "<mods #{@ns_decl}><typeOfResource>still image</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Image']
  end

  context "Hydrus mappings per GRYPHONDOR-207" do
    it "should give a format of Computer File for <genre>game</genre> and <typeOfResource>software, multimedia</typeOfResource>", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><genre>game</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
      @smods_rec.from_str(m)
      @smods_rec.format.should == ['Computer File']
    end
    it "should give a format of Video for <genre>motion picture</genre> and <typeOfResource>moving image</typeOfResource>", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><genre>motion picture</genre><typeOfResource>moving image</typeOfResource></mods>"
      @smods_rec.from_str(m)
      @smods_rec.format.should == ['Video']
    end
    it "should give a format of Sound Recording for <genre>sound</genre> and <typeOfResource>sound recording-nonmusical</typeOfResource>", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><genre>sound</genre><typeOfResource>sound recording-nonmusical</typeOfResource></mods>"
      @smods_rec.from_str(m)
      @smods_rec.format.should == ['Sound Recording']
    end
    it "should give a format of Music - Recording for <typeOfResource>sound recording-musical</typeOfResource>", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><typeOfResource>sound recording-musical</typeOfResource></mods>"
      @smods_rec.from_str(m)
      @smods_rec.format.should == ['Music - Recording']
    end
    it "should give a format of Conference Proceedings for <genre>conference publication</genre> and <typeOfResource>text</typeOfResource>", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><genre>conference publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      @smods_rec.format.should == ['Conference Proceedings']
    end
  end

  # Student Project Reports: spec via email from Vitus, August 16, 2013
  it "should give a format of Other for <genre>student project report</genre> and <typeOfResource>text</typeOfResource>" do
    m = "<mods #{@ns_decl}><genre>student project report</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Other']
  end
  
  it "should give a format of Music - Score for <typeOfResource>notated music</typeOfResource>" do
    m = "<mods #{@ns_decl}><typeOfResource>notated music</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Music - Score']
  end
  
  it "should return nothing if there is no typeOfResource field" do
    m = "<mods #{@ns_decl}><originInfo>
    <dateCreated>1904</dateCreated>
    </originInfo></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == []
  end

  it "should return nothing if there is a weird typeOfResource field" do
    m = "<mods #{@ns_decl}><originInfo>
    <typeOfResource>foo</typeOfResource>
    </originInfo></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == []
  end
end