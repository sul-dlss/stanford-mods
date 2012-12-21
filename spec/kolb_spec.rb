require 'spec_helper'
require 'stanford-mods/kolb'

describe "Kolb Collection Mods Record" do
  before(:all) do
    @krec = Stanford::Mods::KolbRecord.new
    @krec.from_str('<?xml version="1.0"?>
    <ns3:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns3="http://www.loc.gov/mods/v3" xmlns:ns2="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
        <ns3:titleInfo>
            <ns3:title>Edward VI, king of England,</ns3:title>
        </ns3:titleInfo>
        <ns3:language>
            <ns3:languageTerm type="code" authority="iso639-2b">eng</ns3:languageTerm>
            <ns3:languageTerm type="text">English</ns3:languageTerm>
        </ns3:language>
        <ns3:typeOfResource>still image</ns3:typeOfResource>
        <ns3:originInfo>
            <ns3:dateCreated>1537-1553.</ns3:dateCreated>
            <ns3:dateCreated point="start">1537</ns3:dateCreated>
            <ns3:dateCreated point="end">1553</ns3:dateCreated>
        </ns3:originInfo>
        <ns3:subject>
            <ns3:name type="personal" authority="ingest">
                <ns3:namePart type="family">Edward VI , king of England, </ns3:namePart>
                <ns3:displayForm>Edward VI , king of England, 1537-1553</ns3:displayForm>
            </ns3:name>
        </ns3:subject>
        <ns3:name type="personal" authority="ingest">
            <ns3:role>
                <ns3:roleTerm type="text" authority="marcrelator">creator</ns3:roleTerm>
                <ns3:roleTerm type="code" authority="marcrelator">cre</ns3:roleTerm>
            </ns3:role>
            <ns3:namePart type="family">Holbein, Han, 1497-1543</ns3:namePart>
            <ns3:displayForm>Holbein, Han, 1497-1543</ns3:displayForm>
        </ns3:name>
        <ns3:name type="personal" authority="ingest">
            <ns3:role>
                <ns3:roleTerm type="text" authority="marcrelator">creator</ns3:roleTerm>
                <ns3:roleTerm type="code" authority="marcrelator">cre</ns3:roleTerm>
            </ns3:role>
            <ns3:namePart type="family">Sheppard, Robert, 1732-1737</ns3:namePart>
            <ns3:displayForm>Sheppard, Robert, 1732-1737</ns3:displayForm>
        </ns3:name>
        <ns3:subject authority="ingest">
            <ns3:topic>Ruler, English.Ruler, English.</ns3:topic>
        </ns3:subject>
        <ns3:abstract displayLabel="Scope and Contents note"/>
        <ns3:physicalDescription>
            <ns3:note displayLabel="Material Specific Details note">0395</ns3:note>
        </ns3:physicalDescription>
    </ns3:mods>')
  end
  
  context "for SearchWorks Solr" do
    # from  https://consul.stanford.edu/display/NGDE/Required+and+Recommended+Solr+Fields+for+SearchWorks+documents
  
    context "required values" do

      it "catch all text field" do
        pending "to be implemented"
      end
    
      it "format" do
        # sometimes from contentMetadata, o.w. see   mods_mapper.is_a_map/image?
        pending "to be implemented"
        
        #<ns3:typeOfResource>still image</ns3:typeOfResource>
      end
    
      # FIXME:  update per gryphDOR code / searcworks code / new schema
    
      it "collection" do
        pending "to be implemented"
        #  from solr_mapper.rb
        # # Special treatment for collection objects
        #if is_a_collection?
        #  solr_doc[:display_type] = "Collection"
        #  solr_doc[:collection_type] = "Digital Collection"
        #else
        #  solr_doc[:display_type] = display_type
        #end
        
        #if collections   # An array of the druids of any collections this object is part of
        #  solr_doc[:collection] = collections
        #  solr_doc[:collection_with_title] = collections_with_titles
        #end
        
        
      end
    
      it "display_type" do
        pending "to be implemented"
      end
    end
  
    context "strongly recommended" do
      # access_facet has nothing to do with mods
      context "title" do
        context "for display and searching" do
          it "short title" do
            @krec.short_titles.should == ['Edward VI, king of England,']
          end
          it "full title" do
            @krec.full_titles.should == ['Edward VI, king of England,']
          end
          it "alternative titles" do
            @krec.alternative_titles.size.should == 0
          end
        end
        it "sortable title" do
          @krec.sort_title.should == 'Edward VI, king of England,'
        end
      end
    end
  
    context "recommended" do
      context "publication date" do
        it "for searching and facet" do
          pending "to be implemented"
          @krec.pub_date.should include('1537')
          @krec.pub_date.should include('1545')
          @krec.pub_date.should include('1553')
          @krec.pub_date.should_not include('1554')
          @krec.pub_date.should_not include('1536')
        end
        it "for sorting should be dateCreated start date" do
          pending "to be implemented"
          @krec.pub_date_sort.should == '1537'
        end
        it "for pub date grouping (hierarchical / date slider?)" do
          pending "to be implemented"
          @krec.pub_date_group_facet.should == 'More than 50 years ago'
        end
      end
      context "language" do
        it "facet should have a text value" do
          @krec.sw_language_facet.should == ['English'] 
        end
      end
      context "authors" do
        it "personal_names" do
          @krec.personal_names.size.should == 2
          @krec.personal_names.should include('Holbein, Han, 1497-1543')
          @krec.personal_names.should include('Sheppard, Robert, 1732-1737')
        end
        it "name object showing creator role" do
          pending "to be implemented"
        end
        it "author sort" do
          pending "to be implemented"
        end
      end
    end
    
  end # for SearchWorks Solr
  
  context "abstract" do
    # FIXME: move to stanford_mods, not kolb specific
    it "should not include empty elements" do
      pending "to be implemented"
      # <ns3:abstract displayLabel="Scope and Contents note"/>
      @krec.abstract.size.should == 0
      @krec.scope_and_contents_note.size.should == 0
    end
  end
  
  context "physicalDescription" do
#    <ns3:physicalDescription>
#        <ns3:note displayLabel="Material Specific Details note">0395</ns3:note>
#    </ns3:physicalDescription>
    it "should be included in catch all text" do
      pending "to be implemented"
    end
  end
  
  context "subject" do
    it "topic" do
      @krec.subject.topic.map { |e| e.text }.should == ['Ruler, English.Ruler, English.']
    end
    it "name" do
      pending "to be implemented"
      @krec.subject.name.map { |e| e.text }.should == ['Edward VI , king of England, 1537-1553']
    end
  end

  context "kolb record title issue" do
    before(:all) do
      @krec.from_str('<?xml version="1.0" encoding="UTF-8"?>
      <ns3:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:ns3="http://www.loc.gov/mods/v3" xmlns:ns2="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.loc.gov/mods/v3       http://www.loc.gov/standards/mods/v3/mods-3-2.xsd">
      	<ns3:titleInfo>
      		<ns3:title>Elizabeth I, queen of England,</ns3:title>
      	</ns3:titleInfo>
      	<ns3:language>
      		<ns3:languageTerm type="code" authority="iso639-2b">eng</ns3:languageTerm>
      		<ns3:languageTerm type="text">English</ns3:languageTerm>
      	</ns3:language>
      	<ns3:typeOfResource>still image</ns3:typeOfResource>
      	<ns3:originInfo>
      		<ns3:dateCreated>1533-1603.</ns3:dateCreated>
      		<ns3:dateCreated point="start">1533</ns3:dateCreated>
      		<ns3:dateCreated point="end">1603</ns3:dateCreated>
      	</ns3:originInfo>
      	<ns3:subject>
      		<ns3:name type="personal" authority="ingest">
      			<ns3:namePart type="family">Elizabeth I, Queen of England</ns3:namePart>
      			<ns3:displayForm>Elizabeth I, Queen of England, 1533-1603</ns3:displayForm>
      		</ns3:name>
      	</ns3:subject>
      	<ns3:name type="personal" authority="ingest">
      		<ns3:role>
      			<ns3:roleTerm type="text" authority="marcrelator">creator</ns3:roleTerm>
      			<ns3:roleTerm type="code" authority="marcrelator">cre</ns3:roleTerm>
      		</ns3:role>
      		<ns3:namePart type="family">Houston, Richard, 1721?-1775</ns3:namePart>
      		<ns3:displayForm>Houston, Richard, 1721?-1775</ns3:displayForm>
      	</ns3:name>
      	<ns3:subject authority="ingest">
      		<ns3:topic>Ruler, English. W</ns3:topic>
      	</ns3:subject>
      	<ns3:abstract displayLabel="Scope and Contents note">Elisabetha D.G./Angliae,Franciae &amp; Hiberniae,      
            Regina,./Printed for E.Bakewell &amp; H.Parker; opposite Birchin Lane       
            in Cornhill.</ns3:abstract>
      	<ns3:physicalDescription>
      		<ns3:note displayLabel="Material Specific Details note">0411</ns3:note>
      	</ns3:physicalDescription>
      </ns3:mods>')
    end
    it "should get full title" do
      @krec.title_info.full_title.should == ['Elizabeth I, queen of England,']
      @krec.full_titles.should == ['Elizabeth I, queen of England,']
    end
  end

end