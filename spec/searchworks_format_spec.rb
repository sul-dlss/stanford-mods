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
        expect(@smods_rec.format).to eq ['Book']
      end
      context "genre" do
        it "'book chapter'", :email => 'mods-squad 2014-05-22, Joanna Dyla' do
          m = "<mods #{@ns_decl}><genre>book chapter</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Book chapter</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Book Chapter</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
        end
        it "'issue brief'", :email => 'mods-squad 2014-05-22, Joanna Dyla' do
          m = "<mods #{@ns_decl}><genre>issue brief</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Issue brief</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Issue Brief</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
        end
        it "'librettos'", :jira => 'INDEX-98' do
          m = "<mods #{@ns_decl}><genre>librettos</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Librettos</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
        end
        it "'libretto' isn't valid", :jira => 'INDEX-98' do
          m = "<mods #{@ns_decl}><genre>libretto</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq []
        end
        it "'project report'", :jira => 'GRYP-170', :github => 'gdor-indexer/#7' do
          m = "<mods #{@ns_decl}><genre>project report</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Project report</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Project Report</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
        end
        it "'report' isn't valid", :jira => 'GRYP-170', :github => 'gdor-indexer/#7' do
          m = "<mods #{@ns_decl}><genre>report</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq []
        end
        it "'technical report'", :jira => 'GRYPHONDOR-207' do
          m = "<mods #{@ns_decl}><genre>technical report</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Technical report</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Technical Report</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
        end
        it "'working paper'", :email => 'mods-squad 2014-05-22, Joanna Dyla' do
          m = "<mods #{@ns_decl}><genre>working paper</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Working paper</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
          m = "<mods #{@ns_decl}><genre>Working Paper</genre><typeOfResource>text</typeOfResource></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format).to eq ['Book']
        end
      end
    end
  end # 'Book'
  
  context "Computer File: typeOfResource 'software, multimedia'" do
    it "no genre (e.g. Dataset)" do
      m = "<mods #{@ns_decl}><typeOfResource>software, multimedia</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Computer File']
    end
    it "genre 'game'", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><genre>game</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Computer File']
      m = "<mods #{@ns_decl}><genre>Game</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Computer File']
    end
  end

  it "Conference Proceedings: typeOfResource 'text', genre 'conference publication'", :jira => 'GRYPHONDOR-207' do
    m = "<mods #{@ns_decl}><genre>conference publication</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Conference Proceedings']
    m = "<mods #{@ns_decl}><genre>Conference publication</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Conference Proceedings']
    m = "<mods #{@ns_decl}><genre>Conference Publication</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Conference Proceedings']
  end
  
  it "Journal/Periodical: typeOfResource 'text', genre 'article'" do
    m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>article</genre></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Journal/Periodical']
    m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>Article</genre></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Journal/Periodical']
  end

  it "Image: typeOfResource 'still image'" do
    m = "<mods #{@ns_decl}><typeOfResource>still image</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Image']
  end
  
  it "Music - Recording: typeOfResource 'sound recording-musical'", :jira => 'GRYPHONDOR-207' do
    m = "<mods #{@ns_decl}><typeOfResource>sound recording-musical</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Music - Recording']
  end

  it "Music - Score: typeOfResource 'notated music'" do
    m = "<mods #{@ns_decl}><typeOfResource>notated music</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Music - Score']
  end

  it "Other: typeOfResource 'text', genre 'student project report'", :email => 'from Vitus, August 16, 2013' do
    m = "<mods #{@ns_decl}><genre>student project report</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Other']
    m = "<mods #{@ns_decl}><genre>Student project report</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Other']
    m = "<mods #{@ns_decl}><genre>Student Project report</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Other']
    m = "<mods #{@ns_decl}><genre>Student Project Report</genre><typeOfResource>text</typeOfResource></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Other']
  end
  
  context "Sound Recording:" do
    it "typeOfResource 'sound recording-nonmusical', genre 'sound", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><genre>sound</genre><typeOfResource>sound recording-nonmusical</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Sound Recording']
      m = "<mods #{@ns_decl}><genre>Sound</genre><typeOfResource>sound recording-nonmusical</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Sound Recording']
    end
    it "typeOfResource 'sound recording', genre 'sound", :jira => 'INDEX-94' do
      m = "<mods #{@ns_decl}><genre>sound</genre><typeOfResource>sound recording</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Sound Recording']
      m = "<mods #{@ns_decl}><genre>Sound</genre><typeOfResource>sound recording</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Sound Recording']
    end
  end

  it "Thesis: typeOfResource 'text', genre 'thesis'" do
    m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>thesis</genre></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Thesis']
    m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>Thesis</genre></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq ['Thesis']
  end

  context "Video: typeOfResource 'moving image'" do
    it "no genre" do
      m = "<mods #{@ns_decl}><typeOfResource>moving image</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Video']
    end
    it "genre 'motion picture'", :jira => 'GRYPHONDOR-207' do
      m = "<mods #{@ns_decl}><genre>motion picture</genre><typeOfResource>moving image</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Video']
      m = "<mods #{@ns_decl}><genre>Motion Picture</genre><typeOfResource>moving image</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Video']
      m = "<mods #{@ns_decl}><genre>Motion Picture</genre><typeOfResource>moving image</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Video']
    end
  end

  context "multiple format values", :jira => 'INDEX-32' do
    it "multiple typeOfResource elements" do
      m = "<mods #{@ns_decl}><typeOfResource>moving image</typeOfResource><typeOfResource>sound recording</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Video', 'Sound Recording']
    end
    it "multiple genre elements, single typeOfResource" do
      m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>librettos</genre><genre>article</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Book', 'Journal/Periodical']
    end
    it "mish mash" do
      m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><typeOfResource>still image</typeOfResource><genre>librettos</genre><genre>article</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Book', 'Journal/Periodical', 'Image']
    end
    it "doesn't give duplicate values" do
      m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>librettos</genre><genre>issue brief</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Book']
    end
  end

  it "empty Array if no typeOfResource field" do
    m = "<mods #{@ns_decl}><originInfo>
    <dateCreated>1904</dateCreated>
    </originInfo></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq []
  end

  it "empty Array if weird typeOfResource value" do
    m = "<mods #{@ns_decl}><originInfo>
    <typeOfResource>foo</typeOfResource>
    </originInfo></mods>"
    @smods_rec.from_str(m)
    expect(@smods_rec.format).to eq []
  end
end