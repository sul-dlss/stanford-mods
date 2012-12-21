require 'spec_helper'
require 'stanford-mods/searchworks'

describe "Values for SearchWorks Solr" do
  # from  https://consul.stanford.edu/display/NGDE/Required+and+Recommended+Solr+Fields+for+SearchWorks+documents
  before(:all) do
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  context "required fields" do
    context "DOR specific" do
      # in harvestdor code:  druid, parent_coll_ckey, id, collection

      it "url_fulltext" do
        pending "to be implemented"
      end
      it "mods_xml" do
        pending "to be implemented"
      end
    end
    
    it "all_search" do
      pending "to be implemented"
    end
    
    it "format" do
      pending "to be implemented, using SearchWorks controlled vocab"
    end
    
    # FIXME:  update per gryphDOR code / searcworks code / new schema
    it "collection" do
      pending "to be implemented, using controlled vocab, in harvestdor"
    end
    
    it "display_type" do
      pending "to be implemented, using controlled vocab"
    end
    
  end
  
  context "strongly recommended fields" do
    it "access_facet" do
      Stanford::Mods::Record.new.sw_access_facet.should == ['Online']
    end
    # title convenience methods are implemented in the Mods gem; no special work here
    context "title fields" do
      context "for display" do
        it "short title" do
          pending "to be implemented"
        end
        it "full title" do
          pending "to be implemented"
        end
      end
      context "for searching" do
        it "short title" do
          pending "to be implemented"
        end
        it "full title" do
          pending "to be implemented"
        end
      end
      it "sortable title" do
        pending "to be implemented"
      end
    end
  end
  
  context "recommended fields" do
    context "publication date" do
      it "for searching and facet" do
        pending "to be implemented"
      end
      it "for sorting" do
        pending "to be implemented"
      end
      it "for pub date grouping (hierarchical / date slider?)" do
        pending "to be implemented"
      end
    end
    context "language" do
      it "should use the SearchWorks controlled vocabulary" do
        m = "<mods #{@ns_decl}><language><languageTerm authority='iso639-2b' type='code'>per ara, dut</languageTerm></language></mods>"
        r = Stanford::Mods::Record.new()
        r.from_str(m)
        langs = r.sw_language_facet
        langs.size.should == 3
        langs.should include("Persian")
        langs.should include("Arabic")
        langs.should include("Dutch")
        langs.should_not include("Dutch; Flemish")
      end
      it "should not have duplicates" do
        m = "<mods #{@ns_decl}><language><languageTerm type='code' authority='iso639-2b'>eng</languageTerm><languageTerm type='text'>English</languageTerm></language></mods>"
        r = Stanford::Mods::Record.new
        r.from_str(m)
        langs = r.sw_language_facet
        langs.size.should == 1
        langs.should include("English")
      end
      
    end
    context "authors" do
      it "main author" do
        pending "to be implemented"
      end
      it "additional authors" do
        pending "to be implemented"
      end
      it "author sort" do
        pending "to be implemented"
      end
    end
  end
  
end