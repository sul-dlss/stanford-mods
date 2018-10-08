# encoding: UTF-8
describe "Format fields (searchworks.rb)" do
  before(:all) do
    @smods_rec = Stanford::Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

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

    it "Archived website: typeOfResource text, genre 'archived website'" do
      m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre authority=\"local\">archived website</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.format_main).to eq ['Archived website']
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
      it "'book chapter'", email: 'mods-squad 2014-05-22, Joanna Dyla' do
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
      it "'issue brief'", email: 'mods-squad 2014-05-22, Joanna Dyla' do
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
      it "'project report'", jira: 'GRYP-170', github: 'gdor-indexer/#7' do
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
      it "'report' isn't valid, so defaults to book", jira: 'GRYP-170', github: 'gdor-indexer/#7' do
        m = "<mods #{@ns_decl}><genre>report</genre><typeOfResource>text</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Book']
      end
      it "'student project report'", consul: '/NGDE/Format 2014-05-28' do
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
      it "'technical report'", jira: 'GRYPHONDOR-207' do
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
      it "'working paper'", email: 'mods-squad 2014-05-22, Joanna Dyla' do
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
          it "'conference publication'", jira: 'GRYPHONDOR-207' do
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
          it "'instruction'", consul: '/NGDE/Format 2014-05-28' do
            # Hydrus 'textbook'
            m = "<mods #{@ns_decl}><genre authority=\"marcgt\">instruction</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
            m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Instruction</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
          end
          it "'libretto' isn't valid, so it defaults to book", jira: 'INDEX-98' do
            m = "<mods #{@ns_decl}><genre>libretto</genre><typeOfResource>text</typeOfResource></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.format_main).to eq ['Book']
          end
          it "'librettos'", jira: 'INDEX-98' do
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

    context "Music - Recording: typeOfResource 'sound recording-musical'", jira: 'GRYPHONDOR-207' do
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
      it "genre 'game'", jira: 'GRYPHONDOR-207' do
        m = "<mods #{@ns_decl}><genre authority=\"marcgt\">game</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Software/Multimedia']
        m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Game</genre><typeOfResource>software, multimedia</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Software/Multimedia']
      end
      # https://github.com/sul-dlss/stanford-mods/issues/66 - For geodata, the
      # resource type should be only Map and not include Software, multimedia.
      it "typeOfResource 'cartographic' and 'software, multimedia'" do
        m = "<mods #{@ns_decl}><typeOfResource>cartographic</typeOfResource><typeOfResource>software, multimedia</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Map']
      end
    end

    context "Sound Recording:" do
      it "typeOfResource 'sound recording-nonmusical', genre 'sound", jira: 'GRYPHONDOR-207' do
        m = "<mods #{@ns_decl}><genre>sound</genre><typeOfResource>sound recording-nonmusical</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Sound recording']
        m = "<mods #{@ns_decl}><genre>Sound</genre><typeOfResource>sound recording-nonmusical</typeOfResource></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.format_main).to eq ['Sound recording']
      end
      it "typeOfResource 'sound recording', genre 'sound", jira: 'INDEX-94' do
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
      it "genre 'motion picture'", jira: 'GRYPHONDOR-207' do
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

    context "multiple values", jira: 'INDEX-32' do
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
  end # format_main

  context "sw_genre" do
    it "includes values that are not in the prescribed list" do
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Not on the list</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Not on the list']
    end
    it "Conference proceedings: typeOfResource 'text', genre 'conference publication'" do
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">conference publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['conference publication', 'Conference proceedings']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Conference publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Conference publication', 'Conference proceedings']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Conference Publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Conference Publication', 'Conference proceedings']
    end
    it "Thesis/Dissertation: typeOfResource 'text', genre 'thesis'" do
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">thesis</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['thesis', 'Thesis/Dissertation']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Thesis</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Thesis', 'Thesis/Dissertation']
    end
    it "Government Document: typeOfResource 'text', genre 'government publication'" do
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">government publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['government publication', 'Government document']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Government publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Government publication', 'Government document']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Government Publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Government Publication', 'Government document']
      m = "<mods #{@ns_decl}><genre>government publication</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['government publication', 'Government document']
    end
    it "Technical Report: typeOfResource 'text', genre 'technical report'" do
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">technical report</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['technical report', 'Technical report']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Technical report</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Technical report']
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">Technical Report</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Technical Report', 'Technical report']
      m = "<mods #{@ns_decl}><genre>technical report</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['technical report', 'Technical report']
    end
    it "it does not include Archived website: typeOfResource 'text', genre 'archived website'" do
      m = "<mods #{@ns_decl}><genre authority=\"marcgt\">archived website</genre><typeOfResource>text</typeOfResource></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).not_to eq ['Archived website']
    end
    it "capitalizes the first letter of a genre value" do
      m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre authority=\"marcgt\">technical report</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['technical report', 'Technical report']
      m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre authority=\"marcgt\">Technical report</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Technical report']
      m = "<mods #{@ns_decl}><typeOfResource>text</typeOfResource><genre authority=\"marcgt\">Technical Report</genre></mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['Technical Report', 'Technical report']
    end
    # NOTE: may need to remove plurals and/or trailing punctuation in future
    it "returns all genre values" do
      m = "<mods #{@ns_decl}>
            <typeOfResource>text</typeOfResource>
            <genre>government publication</genre>
            <genre>conference publication</genre>
            <genre>thesis</genre>
          </mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['government publication', 'conference publication', 'thesis', 'Thesis/Dissertation', 'Conference proceedings', 'Government document']
    end
    it "doesn't have duplicates" do
      m = "<mods #{@ns_decl}>
            <typeOfResource>text</typeOfResource>
            <genre>conference publication</genre>
            <genre>technical report</genre>
            <genre>Conference publication</genre>
          </mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_genre).to eq ['conference publication', 'technical report', 'Conference publication', 'Conference proceedings', 'Technical report']
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
