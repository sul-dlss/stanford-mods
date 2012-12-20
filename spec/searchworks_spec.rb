require 'spec_helper'
require 'stanford-mods/searchworks'

describe "Searchworks mixin for Stanford::Mods::Record" do

  before(:all) do
    @smods_rec = Stanford::Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  it "sw_access_facet" do
    @smods_rec.sw_access_facet.should == ['Online']
  end
  
  context "languages" do
    it "should use the SearchWorks controlled vocabulary" do
      m = "<mods #{@ns_decl}><language><languageTerm authority='iso639-2b' type='code'>per ara, dut</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      langs.size.should == 3
      langs.should include("Persian")
      langs.should include("Arabic")
      langs.should include("Dutch")
      langs.should_not include("Dutch; Flemish")
    end
    it "should not have duplicates" do
      m = "<mods #{@ns_decl}><language><languageTerm type='code' authority='iso639-2b'>eng</languageTerm><languageTerm type='text'>English</languageTerm></language></mods>"
      @smods_rec.from_str m
      langs = @smods_rec.sw_language_facet
      langs.size.should == 1
      langs.should include("English")
    end    
  end
  
  context "authors" do
    before(:all) do
      m = "<mods #{@ns_decl}><name type='personal'>
        <namePart type='given'>John</namePart>
        <namePart type='family'>Huston</namePart>
        <displayForm>q</displayForm>
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
      </mods>"
      @smods_rec.from_str(m)
    end
    it "main author (for author_1xx_search)" do
      @smods_rec.should_receive(:main_author_w_date) # in stanford-mods.rb
      @smods_rec.sw_main_author
    end
    it "additional authors (for author_7xx_search)" do
      @smods_rec.should_receive(:additional_authors_w_dates) # in stanford-mods.rb
      @smods_rec.sw_addl_authors
    end
    it "person_authors (for author_person_facet, author_person_display)" do
      @smods_rec.should_receive(:personal_names_w_dates) # in Mods gem
      @smods_rec.sw_person_authors
    end
    it "non-person authors (for author_other_facet)" do
      @smods_rec.sw_impersonal_authors.should == ['Watchful Eye, 1850-', 'Exciting Prints', 'plain', 'conference', 'family']
    end
    it "corporate_authors (for author_corp_display)" do
      @smods_rec.sw_corporate_authors.should == ['Watchful Eye, 1850-', 'Exciting Prints']
    end
    it "meeting_authors (for author_meeting_display)" do
      @smods_rec.sw_meeting_authors.should == ['conference']
    end    
    context "author sort" do
      context "author_sort" do
        it "should be a single value" do
          pending "to be implemented"
        end
        it "should be last name first if its a personal name" do
          pending "to be implemented"
        end
        it "should ignore non-sorting characters" do
          pending "to be implemented"
        end
      end
    end
  end
  
end