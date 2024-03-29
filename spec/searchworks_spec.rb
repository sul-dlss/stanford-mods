# encoding: UTF-8
describe "Searchworks mixin for Stanford::Mods::Record" do
  before(:all) do
    @smods_rec = Stanford::Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  context "languages" do
    it "should use the SearchWorks controlled vocabulary" do
      m = "<mods #{@ns_decl}><language><languageTerm authority='iso639-2b' type='code'>per ara, dut</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      expect(langs.size).to eq(3)
      expect(langs).to include("Persian", "Arabic", "Dutch")
      expect(langs).not_to include("Dutch; Flemish")
    end
    it "should return a language string from lookup for a valid language code that has a type=code specified but no authority" do
      m = "<mods #{@ns_decl}> <language><languageTerm type='code'>eng</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      expect(langs.size).to eq(1)
      expect(langs).to eq ["English"]
      expect(langs).not_to include("eng")
    end    
    it "should return nil for a language code that has a type=code specified but no authority" do
      m = "<mods #{@ns_decl}> <language><languageTerm type='code'>bogus</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      expect(langs.size).to be 1
      expect(langs).to eq [nil]
    end
    it "should return nothing when the authority and type=code are specified but the language code cannot be found" do
      m = "<mods #{@ns_decl}><language><languageTerm authority='iso639-2b' type='code'>bogus</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      expect(langs.size).to eq(0)
    end       
    it "should return nothing for a language code that has no authority or type specified" do
      m = "<mods #{@ns_decl}> <language><languageTerm>bogus</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      expect(langs.size).to be 0
      expect(langs).to eq []
    end  
    it "should return nothing for a language code that has an unknown authority and doesn't have a type specified" do
      m = "<mods #{@ns_decl}> <language><languageTerm authority='bogus-authority'>bogus</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      expect(langs.size).to be 0
      expect(langs).to eq []
    end       
    it "should return nothing for a blank languageTerm node (even when the authority is valid)" do
      m = "<mods #{@ns_decl}> <language><languageTerm authority='iso639-2b' type='code'></languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      expect(langs.size).to be 0
      expect(langs).to eq []
    end        
    it "should not have duplicates" do
      m = "<mods #{@ns_decl}><language><languageTerm type='code' authority='iso639-2b'>eng</languageTerm><languageTerm type='text'>English</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      expect(langs.size).to eq 1
      expect(langs).to include "English"
    end
    it "handles codes without authority elements" do
      m = "<mods #{@ns_decl}><language><languageTerm type='code'>eng</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      expect(langs.size).to eq 1
      expect(langs).to include "English"
    end
  end

  context "sw author methods" do
    before(:all) do
      m = "<mods #{@ns_decl}><name type='personal'>
        <namePart type='given'>John</namePart>
        <namePart type='family'>Huston</namePart>
        <displayForm>  q</displayForm>
      </name>
      <name type='personal'>
        <namePart>Crusty The Clown</namePart>
        <namePart type='date'>1990-</namePart>
      </name>
      <name type='corporate'>
        <namePart>Watchful Eye</namePart>
        <namePart type='date'>1850-</namePart>
      </name>
      <name type='corporate'>
        <namePart>Exciting Prints</namePart>
      </name>
      <name>
        <namePart>plain</namePart>
      </name>
      <name type='conference'>
        <namePart>conference</namePart>
      </name>
      <name type='family'>
        <namePart>family</namePart>
      </name>
      <titleInfo><title>Jerk</title><nonSort>The   </nonSort></titleInfo>
      </mods>"
      @smods_rec.from_str(m)
    end

    it "non-person authors (for author_other_facet)" do
      expect(@smods_rec.sw_impersonal_authors).to eq(['Watchful Eye, 1850-', 'Exciting Prints', 'plain', 'conference', 'family'])
    end
    it "corporate authors (for author_corp_display)" do
      expect(@smods_rec.sw_corporate_authors).to eq(['Watchful Eye, 1850-', 'Exciting Prints'])
    end
    it "meeting authors (for author_meeting_display)" do
      expect(@smods_rec.sw_meeting_authors).to eq(['conference'])
    end
    context "sort author" do
      it "should be a String" do
        expect(@smods_rec.sw_sort_author).to eq('qJerk')
      end
      it "should not begin or end with whitespace" do
        expect(@smods_rec.sw_sort_author).to eq(@smods_rec.sw_sort_author.strip)
      end
      it "should substitute the java Character.MAX_CODE_POINT for nil main_author so missing main authors sort last" do
        r = Stanford::Mods::Record.new
        r.from_str "<mods #{@ns_decl}><titleInfo><title>Jerk</title></titleInfo></mods>"
        expect(r.sw_sort_author).to match(/ Jerk$/)
        expect(r.sw_sort_author).to match("\u{10FFFF}")
        expect(r.sw_sort_author).to match("\xF4\x8F\xBF\xBF")
      end
      it "should not have any punctuation marks" do
        r = Stanford::Mods::Record.new
        r.from_str "<mods #{@ns_decl}><titleInfo><title>J,e.r;;;k</title></titleInfo></mods>"
        expect(r.sw_sort_author).to match(/ Jerk$/)
      end
    end
  end # context sw author methods
end
