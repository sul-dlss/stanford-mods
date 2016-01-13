# encoding: UTF-8
require 'spec_helper'

describe "Format fields (searchworks.rb)" do

  before(:all) do
    @smods_rec = Stanford::Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  # @deprecated:  this is no longer used in SW, Revs or Spotlight Jan 2016
  context "format" do
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

    context "Journal/Periodical: typeOfResource 'text'," do
      it "genre 'article" do
        m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>article</genre></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format).to eq ['Journal/Periodical']
        m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>Article</genre></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format).to eq ['Journal/Periodical']
      end
      it "originInfo/issuance 'continuing'" do
        m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><originInfo><issuance>continuing</issuance></originInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format).to eq ['Journal/Periodical']
      end
    end

    it "Image: typeOfResource 'still image'" do
      m = "<mods #{@ns_decl}><typeOfResource>still image</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Image']
    end

    it "Manuscript/Archive: typeOfResource 'mixed material'" do
      m = "<mods #{@ns_decl}><typeOfResource>mixed material</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Manuscript/Archive']
    end

    it "Map/Globe: typeOfResource 'cartographic'" do
      m = "<mods #{@ns_decl}><typeOfResource>cartographic</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq ['Map/Globe']
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
      m = "<mods #{@ns_decl}>
      <typeOfResource>foo</typeOfResource>
      </mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format).to eq []
    end
  end # format

  context "format_main" do
    it "3D object: typeOfResource 'three dimensional object'" do
      m = "<mods #{@ns_decl}><typeOfResource>three dimensional object</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format_main).to eq ['Object']
    end

    it "Archive/Manuscript: typeOfResource 'mixed material'" do
      m = "<mods #{@ns_decl}><typeOfResource>mixed material</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format_main).to eq ['Archive/Manuscript']
    end

    context "Book, formerly Article: typeOfResource text, genre" do
      it "'article'" do
        m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre authority=\"marcgt\">article</genre></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre authority=\"marcgt\">Article</genre></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
      it "'book chapter'", :email => 'mods-squad 2014-05-22, Joanna Dyla' do
        m = "<mods #{@ns_decl}><genre authority=\"local\">book chapter</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Book chapter</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Book Chapter</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
      it "'issue brief'", :email => 'mods-squad 2014-05-22, Joanna Dyla' do
        m = "<mods #{@ns_decl}><genre authority=\"local\">issue brief</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Issue brief</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Issue Brief</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
      it "'project report'", :jira => 'GRYP-170', :github => 'gdor-indexer/#7' do
        m = "<mods #{@ns_decl}><genre>project report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre>Project report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre>Project Report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
      it "'report' isn't valid", :jira => 'GRYP-170', :github => 'gdor-indexer/#7' do
        m = "<mods #{@ns_decl}><genre>report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq []
      end
      it "'student project report'", :consul => '/NGDE/Format 2014-05-28' do
        m = "<mods #{@ns_decl}><genre authority=\"local\">student project report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Student project report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Student Project report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Student Project Report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
      it "'technical report'", :jira => 'GRYPHONDOR-207' do
        m = "<mods #{@ns_decl}><genre authority=\"marcgt\">technical report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Technical report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Technical Report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
      it "'working paper'", :email => 'mods-squad 2014-05-22, Joanna Dyla' do
        m = "<mods #{@ns_decl}><genre authority=\"local\">working paper</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Working paper</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Working Paper</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
    end # Article

    context "Book" do
      context "typeOfResource text," do
        it 'originInfo/issuance monographic' do
          m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><originInfo><issuance>monographic</issuance></originInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.format_main).to eq ['Book']
        end
        context "genre" do
          it "'conference publication'", :jira => 'GRYPHONDOR-207' do
            m = "<mods #{@ns_decl}><genre authority=\"marcgt\">conference publication</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
            m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Conference publication</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
            m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Conference Publication</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
          end
          it "'instruction'", :consul => '/NGDE/Format 2014-05-28' do
            # Hydrus 'textbook'
            m = "<mods #{@ns_decl}><genre authority=\"marcgt\">instruction</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
            m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Instruction</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
          end
          it "'libretto' isn't valid", :jira => 'INDEX-98' do
            m = "<mods #{@ns_decl}><genre>libretto</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq []
          end
          it "'librettos'", :jira => 'INDEX-98' do
            m = "<mods #{@ns_decl}><genre>librettos</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
            m = "<mods #{@ns_decl}><genre>Librettos</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
          end
          it "'thesis'" do
            m = "<mods #{@ns_decl}><genre authority=\"marcgt\">thesis</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
            m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Thesis</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
          end
        end
      end
    end # Book

    context "Dataset: typeOfResource 'software, multimedia'" do
      it "genre 'dataset'" do
        m = "<mods #{@ns_decl}><genre authority=\"local\">dataset</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Dataset']
        m = "<mods #{@ns_decl}><genre authority=\"local\">Dataset</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Dataset']
      end
    end

    it "Image: typeOfResource 'still image'" do
      m = "<mods #{@ns_decl}><typeOfResource>still image</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format_main).to eq ['Image']
    end

    it "Journal/Periodical: typeOfResource 'text', originInfo/issuance 'continuing'" do
      m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><originInfo><issuance>continuing</issuance></originInfo></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format_main).to eq ['Journal/Periodical']
    end

    it "Map: typeOfResource 'cartographic'" do
      m = "<mods #{@ns_decl}><typeOfResource>cartographic</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format_main).to eq ['Map']
    end

    context "Music - Recording: typeOfResource 'sound recording-musical'", :jira => 'GRYPHONDOR-207' do
      it "no genre" do
        m = "<mods #{@ns_decl}><typeOfResource>sound recording-musical</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Music recording']
      end
      it "genre 'sound'" do
        m = "<mods #{@ns_decl}><typeOfResource>sound recording-musical</typeOfResource><genre authority=\"marcgt\">sound</genre></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Music recording']
        m = "<mods #{@ns_decl}><typeOfResource>sound recording-musical</typeOfResource><genre authority=\"marcgt\">Sound</genre></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Music recording']
      end
    end

    it "Music - Score: typeOfResource 'notated music'" do
      m = "<mods #{@ns_decl}><typeOfResource>notated music</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format_main).to eq ['Music score']
    end

    context "Software/Multimedia: typeOfResource 'software, multimedia'" do
      it "no genre" do
        m = "<mods #{@ns_decl}><typeOfResource>software, multimedia</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Software/Multimedia']
      end
      it "genre 'game'", :jira => 'GRYPHONDOR-207' do
        m = "<mods #{@ns_decl}><genre authority=\"marcgt\">game</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Software/Multimedia']
        m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Game</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Software/Multimedia']
      end
    end

    context "Sound Recording:" do
      it "typeOfResource 'sound recording-nonmusical', genre 'sound", :jira => 'GRYPHONDOR-207' do
        m = "<mods #{@ns_decl}><genre>sound</genre><typeOfResource>sound recording-nonmusical</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Sound recording']
        m = "<mods #{@ns_decl}><genre>Sound</genre><typeOfResource>sound recording-nonmusical</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Sound recording']
      end
      it "typeOfResource 'sound recording', genre 'sound", :jira => 'INDEX-94' do
        m = "<mods #{@ns_decl}><genre>sound</genre><typeOfResource>sound recording</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Sound recording']
        m = "<mods #{@ns_decl}><genre>Sound</genre><typeOfResource>sound recording</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Sound recording']
      end
    end


    context "Video: typeOfResource 'moving image'" do
      it "no genre" do
        m = "<mods #{@ns_decl}><typeOfResource>moving image</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Video']
      end
      it "genre 'motion picture'", :jira => 'GRYPHONDOR-207' do
        m = "<mods #{@ns_decl}><genre>motion picture</genre><typeOfResource>moving image</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Video']
        m = "<mods #{@ns_decl}><genre>Motion picture</genre><typeOfResource>moving image</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Video']
        m = "<mods #{@ns_decl}><genre>Motion Picture</genre><typeOfResource>moving image</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Video']
      end
    end

    context "multiple values", :jira => 'INDEX-32' do
      it "multiple typeOfResource elements" do
        m = "<mods #{@ns_decl}><typeOfResource>moving image</typeOfResource><typeOfResource>sound recording</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Video', 'Sound recording']
      end
      it "multiple genre elements, single typeOfResource" do
        m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>librettos</genre><genre>article</genre></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
      it "mish mash" do
        m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><typeOfResource>still image</typeOfResource><genre>librettos</genre><genre>article</genre></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book', 'Image']
      end
      it "doesn't give duplicate values" do
        m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre>librettos</genre><genre>thesis</genre></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
    end

    it "empty Array if no typeOfResource field" do
      m = "<mods #{@ns_decl}><originInfo>
            <dateCreated>1904</dateCreated>
          </originInfo></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format_main).to eq []
    end

    it "empty Array if weird typeOfResource value" do
      m = "<mods #{@ns_decl}>
            <typeOfResource>foo</typeOfResource>
          </mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format_main).to eq []
    end
  end #format_main

  context "sw_genre" do
    it "Conference proceedings: typeOfResource 'text', genre 'conference publication'" do
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">conference publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Conference proceedings']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Conference publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Conference proceedings']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Conference Publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Conference proceedings']
    end
    it "Thesis/Dissertation: typeOfResource 'text', genre 'thesis'" do
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">thesis</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Thesis/Dissertation']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Thesis</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Thesis/Dissertation']
    end
    it "capitalizes the first letter of a genre value" do
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">student project report</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Student project report']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Student project report</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Student project report']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Student Project report</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Student project report']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Student Project Report</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Student project report']
    end
    # NOTE: may need to remove plurals and/or trailing punctuation in future
    it "returns all genre values" do
      m = "<mods #{@ns_decl}>
            <genre>game</genre>
            <genre>foo</genre>
            <genre>technical report</genre>
          </mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Game', 'Foo', 'Technical report']
    end
    it "doesn't have duplicates" do
      m = "<mods #{@ns_decl}>
            <genre>game</genre>
            <genre>technical report</genre>
            <genre>Game</genre>
          </mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Game', 'Technical report']
    end
    it "empty Array if no genre values" do
      m = "<mods #{@ns_decl}>
            <typeOfResource>text</typeOfResource>
          </mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq []
    end
  end # sw_genre
end
