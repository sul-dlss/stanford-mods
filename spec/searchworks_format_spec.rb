# encoding: UTF-8
require 'spec_helper'

describe "Format field from Searchworks mixin for Stanford::Mods::Record" do

  before(:all) do
    @smods_rec = Stanford::Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  context "Book:" do
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
  end # 'Book'
  
  context "Computer File: typeOfResource 'software, multimedia'" do
    it "no genre (e.g. Dataset)" do
      m = "<mods #{@ns_decl}><typeOfResource>software, multimedia</typeOfResource></mods>"
      @smods_rec.from_str(m)
      @smods_rec.format.should == ['Computer File']
    end
    it "genre 'game'", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><genre>game</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
      @smods_rec.from_str(m)
      @smods_rec.format.should == ['Computer File']
    end
  end

  it "Conference Proceedings: typeOfResource 'text', genre 'conference publication'", :jira => 'GRYPHONDOR-207' do
    m = "<mods #{@ns_decl}><genre>conference publication</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Conference Proceedings']
  end
  
  it "Journal/Periodical: typeOfResource 'text', genre 'article'" do
    m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>article</genre></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Journal/Periodical']
  end

  it "Image: typeOfResource 'still image'" do
    m = "<mods #{@ns_decl}><typeOfResource>still image</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Image']
  end
  
  it "Music - Recording: typeOfResource 'sound recording-musical'", :jira => 'GRYPHONDOR-207' do
    m = "<mods #{@ns_decl}><typeOfResource>sound recording-musical</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Music - Recording']
  end

  it "Music - Score: typeOfResource 'notated music'" do
    m = "<mods #{@ns_decl}><typeOfResource>notated music</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Music - Score']
  end

  it "Other: typeOfResource 'text', genre 'student project report'", :email => 'from Vitus, August 16, 2013' do
    m = "<mods #{@ns_decl}><genre>student project report</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Other']
  end
  
  it "Sound Recording: typeOfResource 'sound recording-nonmusical', genre 'sound", :jira => 'GRYPHONDOR-207' do
    m = "<mods #{@ns_decl}><genre>sound</genre><typeOfResource>sound recording-nonmusical</typeOfResource></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == ['Sound Recording']
  end

  context "Video: typeOfResource 'moving image'" do
    it "no genre" do
      m = "<mods #{@ns_decl}><typeOfResource>moving image</typeOfResource></mods>"
      @smods_rec.from_str(m)
      @smods_rec.format.should == ['Video']
    end
    it "genre 'motion picture'", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><genre>motion picture</genre><typeOfResource>moving image</typeOfResource></mods>"
      @smods_rec.from_str(m)
      @smods_rec.format.should == ['Video']
    end
  end

  it "empty Array if no typeOfResource field" do
    m = "<mods #{@ns_decl}><originInfo>
    <dateCreated>1904</dateCreated>
    </originInfo></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == []
  end

  it "empty Array if weird typeOfResource value" do
    m = "<mods #{@ns_decl}><originInfo>
    <typeOfResource>foo</typeOfResource>
    </originInfo></mods>"
    @smods_rec.from_str(m)
    @smods_rec.format.should == []
  end
end