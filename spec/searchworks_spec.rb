# encoding: UTF-8
require 'spec_helper'

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
    it "main author (for author_1xx_search)" do
      @smods_rec.should_receive(:main_author_w_date) # in stanford-mods.rb
      @smods_rec.sw_main_author
    end
    it "additional authors (for author_7xx_search)" do
      @smods_rec.should_receive(:additional_authors_w_dates) # in stanford-mods.rb
      @smods_rec.sw_addl_authors
    end
    it "person authors (for author_person_facet, author_person_display)" do
      @smods_rec.should_receive(:personal_names_w_dates) # in Mods gem
      @smods_rec.sw_person_authors
    end
    it "non-person authors (for author_other_facet)" do
      @smods_rec.sw_impersonal_authors.should == ['Watchful Eye, 1850-', 'Exciting Prints', 'plain', 'conference', 'family']
    end
    it "corporate authors (for author_corp_display)" do
      @smods_rec.sw_corporate_authors.should == ['Watchful Eye, 1850-', 'Exciting Prints']
    end
    it "meeting authors (for author_meeting_display)" do
      @smods_rec.sw_meeting_authors.should == ['conference']
    end    
    context "sort author" do
      it "should be a String" do
        @smods_rec.sw_sort_author.should == 'qJerk'
      end
      it "should include the main author, as retrieved by :main_author_w_date" do
        @smods_rec.should_receive(:main_author_w_date) # in stanford-mods.rb
        @smods_rec.sw_sort_author
      end
      it "should append the sort title, as retrieved by :sort_title" do
        @smods_rec.should_receive(:sort_title) # in Mods gem
        @smods_rec.sw_sort_author
      end
      it "should not begin or end with whitespace" do
        @smods_rec.sw_sort_author.should == @smods_rec.sw_sort_author.strip
      end
      it "should substitute the java Character.MAX_CODE_POINT for nil main_author so missing main authors sort last" do
        r = Stanford::Mods::Record.new
        r.from_str "<mods #{@ns_decl}><titleInfo><title>Jerk</title></titleInfo></mods>"
        r.sw_sort_author.should =~ / Jerk$/
        r.sw_sort_author.should match("\u{FFFF}")
        r.sw_sort_author.should match("\xEF\xBF\xBF")
      end
      it "should not have any punctuation marks" do
        r = Stanford::Mods::Record.new
        r.from_str "<mods #{@ns_decl}><titleInfo><title>J,e.r;;;k</title></titleInfo></mods>"
        r.sw_sort_author.should =~ / Jerk$/
      end
    end
  end # context sw author methods
  
  context "sw title methods" do
    before(:all) do
      m = "<mods #{@ns_decl}><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>"
      @smods_rec.from_str m      
    end
    context "short title (for title_245a_search, title_245a_display) " do
      it "should call :short_titles" do
        @smods_rec.should_receive(:short_titles) # in Mods gem
        @smods_rec.sw_short_title
      end
      it "should be a String" do
        @smods_rec.sw_short_title.should == 'The Jerk'
      end
    end
    context "full title (for title_245_search, title_display, title_full_display)" do
      it "should call :full_titles" do
        @smods_rec.should_receive(:full_titles) # in Mods gem
        @smods_rec.sw_full_title
      end
      it "should be a String" do
        @smods_rec.sw_full_title.should == 'The Jerk A Tale of Tourettes'
      end
    end
    context "additional titles (for title_variant_search)" do
      before(:all) do
        m = "<mods #{@ns_decl}>
          <titleInfo type='alternative'><title>Alternative</title></titleInfo>
          <titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo>
          <titleInfo><title>Joke</title></titleInfo>
          </mods>"
        @smods_rec.from_str(m)
        @addl_titles = @smods_rec.sw_addl_titles
      end
      it "should not include the main title" do
        @addl_titles.size.should == 2
        @addl_titles.should_not include(@smods_rec.sw_full_title)
      end
      it "should include any extra main titles" do
        @addl_titles.should include('Joke')
      end
      it "should include all alternative titles" do
        @addl_titles.should include('Alternative')
      end
    end    
    context "sort title" do
      it "should be a String" do
        @smods_rec.sw_sort_title.should be_an_instance_of(String)
      end
      it "should use the sort title, as retrieved by :sort_title" do
        @smods_rec.should_receive(:sort_title) # in Mods gem
        @smods_rec.sw_sort_title
      end
      it "should not begin or end with whitespace" do
        m = "<mods #{@ns_decl}>
        <titleInfo><title>      Jerk     </title></titleInfo>
        </mods>"
        @smods_rec.from_str(m)
        @smods_rec.sw_sort_title.should == @smods_rec.sw_sort_title.strip
      end
      it "should not have any punctuation marks" do
        r = Stanford::Mods::Record.new
        r.from_str "<mods #{@ns_decl}><titleInfo><title>J,e.r;;;k</title></titleInfo></mods>"
        r.sw_sort_title.should =~ /^Jerk$/
      end
    end
  end # content sw title methods

  context "sw subject methods" do
    before(:all) do
      @genre = 'genre top level'
      @cart_coord = '6 00 S, 71 30 E'
      @s_genre = 'genre in subject'
      @geo = 'Somewhere'
      @geo_code = 'us'
      @hier_geo_country = 'France'
      @s_name = 'name in subject'
      @occupation = 'worker bee'
      @temporal = 'temporal'
      @s_title = 'title in subject'
      @topic = 'topic'
      m = "<mods #{@ns_decl}>
        <genre>#{@genre}</genre>
        <subject><cartographics><coordinates>#{@cart_coord}</coordinates></cartographics></subject>
        <subject><genre>#{@s_genre}</genre></subject>
        <subject><geographic>#{@geo}</geographic></subject>
        <subject><geographicCode authority='iso3166'>#{@geo_code}</geographicCode></subject>
        <subject><hierarchicalGeographic><country>#{@hier_geo_country}</country></hierarchicalGeographic></subject>
        <subject><name><namePart>#{@s_name}</namePart></name></subject>
        <subject><occupation>#{@occupation}</occupation></subject>
        <subject><temporal>#{@temporal}</temporal></subject>
        <subject><titleInfo><title>#{@s_title}</title></titleInfo></subject>
        <subject><topic>#{@topic}</topic></subject>      
      </mods>"
      @smods_rec.from_str m
      @sw_geographic_search = @smods_rec.sw_geographic_search   
    end
    
    context "sw_subject_names" do
      before(:all) do
        @sw_subject_names = @smods_rec.sw_subject_names
      end
      it "should contain <subject><name><namePart> values" do
        @sw_subject_names.should include(@s_name)
      end
      it "should not contain non-name subject subelements" do
        @sw_subject_names.should_not include(@genre)
        @sw_subject_names.should_not include(@geo)
        @sw_subject_names.should_not include(@geo_code)
        @sw_subject_names.should_not include(@hier_geo_country)
        @sw_subject_names.should_not include(@cart_coord)
        @sw_subject_names.should_not include(@s_genre)
        @sw_subject_names.should_not include(@occupation)
        @sw_subject_names.should_not include(@temporal)
        @sw_subject_names.should_not include(@topic)
        @sw_subject_names.should_not include(@s_title)
      end
      it "should not contain subject/name/role" do
        m = "<mods #{@ns_decl}>
              <subject><name type='personal'>
              	<namePart>Alterman, Eric</namePart>
              	<displayForm>Eric Alterman</displayForm>
              	<role>
              	  	<roleTerm type='text'>creator</roleTerm>
              	  	<roleTerm type='code'>cre</roleTerm>
              	</role>
              </name></subject></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_subject_names.find { |sn| sn =~ /cre/ }.should == nil
      end
      it "should not contain subject/name/affiliation" do
        m = "<mods #{@ns_decl}>
              <subject><name type='personal'>
              	<namePart type='termsOfAddress'>Dr.</namePart>
              	<namePart>Brown, B. F.</namePart>
              	<affiliation>Chemistry Dept., American University</affiliation>
              </name></subject></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_subject_names.find { |sn| sn =~ /Chemistry/ }.should == nil
      end
      it "should not contain subject/name/description" do
        m = "<mods #{@ns_decl}>
              <subject><name type='personal'>
              	<namePart>Abrams, Michael</namePart>
              	<description>American artist, 20th c.</description>
              </name></subject></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_subject_names.find { |sn| sn =~ /artist/ }.should == nil
      end
      it "should not include top level name element" do
        m = "<mods #{@ns_decl}>
              <name type='personal'>
              	<namePart>Abrams, Michael</namePart>
              	<description>American artist, 20th c.</description>
              </name></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_subject_names.should == []
      end
      it "should have one value for each name element" do
        m = "<mods #{@ns_decl}>
              <subject>
                <name><namePart>first</namePart></name>
                <name><namePart>second</namePart></name>
              </subject>
              <subject>
                <name><namePart>third</namePart></name>
              </subject>
              </mods>"
        @smods_rec.from_str m
        @smods_rec.sw_subject_names.should == ['first', 'second', 'third']
      end
      it "should be an empty Array if there are no values in the mods" do
        m = "<mods #{@ns_decl}><note>notit</note></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_subject_names.should == []
      end
      it "should be an empty Array if there are empty values in the mods" do
        m = "<mods #{@ns_decl}><subject><name><namePart/></name></subject><note>notit</note></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_subject_names.should == []
      end
      context "combining subelements" do
        before(:all) do
          m = "<mods #{@ns_decl}>
                <subject>
                  <name>
                    <namePart>first</namePart>
                    <namePart>second</namePart>
                  </name>
                </subject>
              </mods>"
          @smods_rec.from_str m
        end
        it "uses a ', ' as the separator by default" do
          @smods_rec.sw_subject_names.should == ['first, second']
        end          
        it "honors any string value passed in for the separator" do
          @smods_rec.sw_subject_names(' --').should == ['first --second']
        end
      end
    end # sw_subject_names
    
    context "sw_geographic_search" do
      it "should contain subject <geographic> subelement data" do
        @sw_geographic_search.should include(@geo)
      end
      it "should contain subject <hierarchicalGeographic> subelement data" do
        @sw_geographic_search.should include(@hier_geo_country)
      end
      it "should contain translation of <geographicCode> subelement data with translated authorities" do
        m = "<mods #{@ns_decl}><subject><geographicCode authority='marcgac'>e-er</geographicCode></subject></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_geographic_search.should include('Estonia')
      end
      it "should not contain other subject element data" do
        @sw_geographic_search.should_not include(@genre)
        @sw_geographic_search.should_not include(@cart_coord)
        @sw_geographic_search.should_not include(@s_genre)
        @sw_geographic_search.should_not include(@s_name)
        @sw_geographic_search.should_not include(@occupation)
        @sw_geographic_search.should_not include(@temporal)
        @sw_geographic_search.should_not include(@topic)
        @sw_geographic_search.should_not include(@s_title)
      end
      it "should be [] if there are no values in the MODS" do
        m = "<mods #{@ns_decl}><note>notit</note></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_geographic_search.should == []
      end
      it "should not be empty Array if there are only subject/geographic elements" do
        m = "<mods #{@ns_decl}><subject><geographic>#{@geo}</geographic></subject></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_geographic_search.should == [@geo]
      end
      it "should not be empty Array if there are only subject/hierarchicalGeographic" do
        m = "<mods #{@ns_decl}><subject><hierarchicalGeographic><country>#{@hier_geo_country}</country></hierarchicalGeographic></subject></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_geographic_search.should == [@hier_geo_country]
      end
      it "should not be empty Array if there are only subject/geographicCode elements" do
        m = "<mods #{@ns_decl}><subject><geographicCode authority='marcgac'>e-er</geographicCode></subject></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_geographic_search.should == ['Estonia']
      end
      context "geographic subelement" do
        it "should have a separate value for each geographic element" do
          m = "<mods #{@ns_decl}>
                <subject>
                <geographic>Mississippi</geographic>
                <geographic>Tippah County</geographic>
                </subject>
                <subject><geographic>Washington (D.C.)</geographic></subject>
              </mods>"
          @smods_rec.from_str m
          @smods_rec.sw_geographic_search.should == ['Mississippi', 'Tippah County', 'Washington (D.C.)']
        end
        it "should be empty Array if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><geographic/></subject><note>notit</note></mods>"
          @smods_rec.from_str m
          @smods_rec.sw_geographic_search.should == []
        end
      end
      context "hierarchicalGeographic subelement" do
        it "should have a separate value for each hierarchicalGeographic element" do
          m = "<mods #{@ns_decl}>
                <subject>
                  <hierarchicalGeographic><area>first</area></hierarchicalGeographic>
                  <hierarchicalGeographic><area>second</area></hierarchicalGeographic>
                </subject>
                <subject><hierarchicalGeographic><area>third</area></hierarchicalGeographic></subject>
              </mods>"
          @smods_rec.from_str m
          @smods_rec.sw_geographic_search.should == ['first', 'second', 'third']
        end
        it "should be empty Array if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><hierarchicalGeographic/></subject><note>notit</note></mods>"
          @smods_rec.from_str m
          @smods_rec.sw_geographic_search.should == []
        end
        context "combining subelements" do
          before(:all) do
            m = "<mods #{@ns_decl}>
            <subject>
              <hierarchicalGeographic>
              	<country>Canada</country>
              	<province>British Columbia</province>
              	<city>Vancouver</city>
              </hierarchicalGeographic>
            </subject></mods>"
            @smods_rec.from_str m
          end
          it "uses a space as the separator by default" do
            @smods_rec.sw_geographic_search.should == ['Canada British Columbia Vancouver']
          end          
          it "honors any string value passed in for the separator" do
            @smods_rec.sw_geographic_search(' --').should == ['Canada --British Columbia --Vancouver']
          end
        end
      end # hierarchicalGeographic
      context "geographicCode subelement" do
        before(:all) do
          m = "<mods #{@ns_decl}>
            <subject><geographicCode authority='marcgac'>n-us-md</geographicCode></subject>
            <subject><geographicCode authority='marcgac'>e-er</geographicCode></subject>
            <subject><geographicCode authority='marccountry'>mg</geographicCode></subject>
            <subject><geographicCode authority='iso3166'>us</geographicCode></subject>
          </mods>"
          @smods_rec.from_str m
          @geo_search_from_codes = @smods_rec.sw_geographic_search   
        end
        it "should not add untranslated values" do
          @geo_search_from_codes.should_not include('n-us-md')
          @geo_search_from_codes.should_not include('e-er')
          @geo_search_from_codes.should_not include('mg')
          @geo_search_from_codes.should_not include('us')
        end
        it "should translate marcgac codes" do
          @geo_search_from_codes.should include('Estonia')
        end
        it "should translate marccountry codes" do
          @geo_search_from_codes.should include('Madagascar')
        end
        it "should not translate other codes" do
          @geo_search_from_codes.should_not include('United States')
        end
        it "should have a separate value for each geographicCode element" do
          m = "<mods #{@ns_decl}>
                <subject>
                  <geographicCode authority='marcgac'>e-er</geographicCode>
                	<geographicCode authority='marccountry'>mg</geographicCode>
                </subject>
                <subject><geographicCode authority='marcgac'>n-us-md</geographicCode></subject>
              </mods>"
          @smods_rec.from_str m
          @smods_rec.sw_geographic_search.should == ['Estonia', 'Madagascar', 'Maryland']
        end
        it "should be empty Array if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><geographicCode/></subject><note>notit</note></mods>"
          @smods_rec.from_str m
          @smods_rec.sw_geographic_search.should == []
        end
        it "should add the translated value if it wasn't present already" do
          m = "<mods #{@ns_decl}>
            <subject><geographic>Somewhere</geographic></subject>
            <subject><geographicCode authority='marcgac'>e-er</geographicCode></subject>
          </mods>"
          @smods_rec.from_str m
          @smods_rec.sw_geographic_search.size.should == 2
          @smods_rec.sw_geographic_search.should include('Estonia')
        end
        it "should not add the translated value if it was already present" do
          m = "<mods #{@ns_decl}>
            <subject><geographic>Estonia</geographic></subject>
            <subject><geographicCode authority='marcgac'>e-er</geographicCode></subject>
          </mods>"
          @smods_rec.from_str m
          @smods_rec.sw_geographic_search.size.should == 1
          @smods_rec.sw_geographic_search.should == ['Estonia']
        end
      end
    end # sw_geographic_search
  end # context sw subject methods

end