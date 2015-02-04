# encoding: UTF-8
require 'spec_helper'

describe "Subject fields (searchworks.rb)" do

  before(:all) do
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
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
    @subject_mods = "<mods #{@ns_decl}>
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
    @smods_rec = Stanford::Mods::Record.new
    @smods_rec.from_str(@subject_mods)
    @ng_mods = Nokogiri::XML(@subject_mods)
    m_no_subject = "<mods #{@ns_decl}><note>notit</note></mods>"
    @ng_mods_no_subject = Nokogiri::XML(m_no_subject)
  end

  context "search fields" do
    context "topic_search" do
      it "should be nil if there are no values in the MODS" do
        m = "<mods #{@ns_decl}></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.topic_search).to be_nil
      end
      it "should contain subject <topic> subelement data" do
        expect(@smods_rec.topic_search).to include(@topic)
      end
      it "should contain top level <genre> element data" do
        expect(@smods_rec.topic_search).to include(@genre)
      end
      it "should not contain other subject element data" do
        expect(@smods_rec.topic_search).not_to include(@cart_coord)
        expect(@smods_rec.topic_search).not_to include(@s_genre)
        expect(@smods_rec.topic_search).not_to include(@geo)
        expect(@smods_rec.topic_search).not_to include(@geo_code)
        expect(@smods_rec.topic_search).not_to include(@hier_geo_country)
        expect(@smods_rec.topic_search).not_to include(@s_name)
        expect(@smods_rec.topic_search).not_to include(@occupation)
        expect(@smods_rec.topic_search).not_to include(@temporal)
        expect(@smods_rec.topic_search).not_to include(@s_title)
      end
      it "should not be nil if there are only subject/topic elements (no <genre>)" do
        m = "<mods #{@ns_decl}><subject><topic>#{@topic}</topic></subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.topic_search).to eq([@topic])
      end
      it "should not be nil if there are only <genre> elements (no subject/topic elements)" do
        m = "<mods #{@ns_decl}><genre>#{@genre}</genre></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.topic_search).to eq([@genre])
      end
      context "topic subelement" do
        it "should have a separate value for each topic element" do
          m = "<mods #{@ns_decl}>
          <subject>
          <topic>first</topic>
          <topic>second</topic>
          </subject>
          <subject><topic>third</topic></subject>
          </mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
          expect(@smods_rec.topic_search).to eq(['first', 'second', 'third'])
        end
        it "should be nil if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><topic/></subject><note>notit</note></mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
          expect(@smods_rec.topic_search).to be_nil
        end
      end
    end # topic_search

    context "geographic_search" do
      it "should call sw_geographic_search (from stanford-mods gem)" do
        m = "<mods #{@ns_decl}><subject><geographic>#{@geo}</geographic></subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec).to receive(:sw_geographic_search)
        @smods_rec.geographic_search
      end
      it "should log an info message when it encounters a geographicCode encoding it doesn't translate" do
        m = "<mods #{@ns_decl}><subject><geographicCode authority='iso3166'>ca</geographicCode></subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_logger).to receive(:info).with(/ has subject geographicCode element with untranslated encoding \(iso3166\): <geographicCode authority=.*>ca<\/geographicCode>/)
        @smods_rec.geographic_search
      end
    end # geographic_search

    context "subject_other_search" do
      it "should call sw_subject_names (from stanford-mods gem)" do
        smods_rec = Stanford::Mods::Record.new
        smods_rec.from_str(@subject_mods)
        expect(smods_rec).to receive(:sw_subject_names)
        smods_rec.subject_other_search
      end
      it "should call sw_subject_titles (from stanford-mods gem)" do
        expect(@smods_rec).to receive(:sw_subject_titles)
        @smods_rec.subject_other_search
      end
      it "should be nil if there are no values in the MODS" do
        m = "<mods #{@ns_decl}></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.subject_other_search).to be_nil
      end
      it "should contain subject <name> SUBelement data" do
        expect(@smods_rec.subject_other_search).to include(@s_name)
      end
      it "should contain subject <occupation> subelement data" do
        expect(@smods_rec.subject_other_search).to include(@occupation)
      end
      it "should contain subject <titleInfo> SUBelement data" do
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(@subject_mods)
        expect(@smods_rec.subject_other_search).to include(@s_title)
      end
      it "should not contain other subject element data" do
        expect(@smods_rec.subject_other_search).not_to include(@genre)
        expect(@smods_rec.subject_other_search).not_to include(@cart_coord)
        expect(@smods_rec.subject_other_search).not_to include(@s_genre)
        expect(@smods_rec.subject_other_search).not_to include(@geo)
        expect(@smods_rec.subject_other_search).not_to include(@geo_code)
        expect(@smods_rec.subject_other_search).not_to include(@hier_geo_country)
        expect(@smods_rec.subject_other_search).not_to include(@temporal)
        expect(@smods_rec.subject_other_search).not_to include(@topic)
      end
      it "should not be nil if there are only subject/name elements" do
        m = "<mods #{@ns_decl}><subject><name><namePart>#{@s_name}</namePart></name></subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.subject_other_search).to eq([@s_name])
      end
      it "should not be nil if there are only subject/occupation elements" do
        m = "<mods #{@ns_decl}><subject><occupation>#{@occupation}</occupation></subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.subject_other_search).to eq([@occupation])
      end
      it "should not be nil if there are only subject/titleInfo elements" do
        m = "<mods #{@ns_decl}><subject><titleInfo><title>#{@s_title}</title></titleInfo></subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.subject_other_search).to eq([@s_title])
      end
      context "occupation subelement" do
        it "should have a separate value for each occupation element" do
          m = "<mods #{@ns_decl}>
          <subject>
          <occupation>first</occupation>
          <occupation>second</occupation>
          </subject>
          <subject><occupation>third</occupation></subject>
          </mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
          expect(@smods_rec.subject_other_search).to eq(['first', 'second', 'third'])
        end
        it "should be nil if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><occupation/></subject><note>notit</note></mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
          expect(@smods_rec.subject_other_search).to be_nil
        end
      end
    end # subject_other_search

    context "subject_other_subvy_search" do
      it "should be nil if there are no values in the MODS" do
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(@ng_mods_no_subject.to_s)
        expect(@smods_rec.subject_other_subvy_search).to be_nil
      end
      it "should contain subject <temporal> subelement data" do
        expect(@smods_rec.subject_other_subvy_search).to include(@temporal)
      end
      it "should contain subject <genre> SUBelement data" do
        expect(@smods_rec.subject_other_subvy_search).to include(@s_genre)
      end
      it "should not contain other subject element data" do
        expect(@smods_rec.subject_other_subvy_search).not_to include(@genre)
        expect(@smods_rec.subject_other_subvy_search).not_to include(@cart_coord)
        expect(@smods_rec.subject_other_subvy_search).not_to include(@geo)
        expect(@smods_rec.subject_other_subvy_search).not_to include(@geo_code)
        expect(@smods_rec.subject_other_subvy_search).not_to include(@hier_geo_country)
        expect(@smods_rec.subject_other_subvy_search).not_to include(@s_name)
        expect(@smods_rec.subject_other_subvy_search).not_to include(@occupation)
        expect(@smods_rec.subject_other_subvy_search).not_to include(@topic)
        expect(@smods_rec.subject_other_subvy_search).not_to include(@s_title)
      end
      it "should not be nil if there are only subject/temporal elements (no subject/genre)" do
        m = "<mods #{@ns_decl}><subject><temporal>#{@temporal}</temporal></subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.subject_other_subvy_search).to eq([@temporal])
      end
      it "should not be nil if there are only subject/genre elements (no subject/temporal)" do
        m = "<mods #{@ns_decl}><subject><genre>#{@s_genre}</genre></subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.subject_other_subvy_search).to eq([@s_genre])
      end
      context "temporal subelement" do
        it "should have a separate value for each temporal element" do
          m = "<mods #{@ns_decl}>
          <subject>
          <temporal>1890-1910</temporal>
          <temporal>20th century</temporal>
          </subject>
          <subject><temporal>another</temporal></subject>
          </mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
          expect(@smods_rec.subject_other_subvy_search).to eq(['1890-1910', '20th century', 'another'])
        end
        it "should log an info message when it encounters an encoding it doesn't translate" do
          m = "<mods #{@ns_decl}><subject><temporal encoding='iso8601'>197505</temporal></subject></mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_logger).to receive(:info).with(/ has subject temporal element with untranslated encoding: <temporal encoding=.*>197505<\/temporal>/)
          @smods_rec.subject_other_subvy_search
        end
        it "should be nil if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><temporal/></subject><note>notit</note></mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
          expect(@smods_rec.subject_other_subvy_search).to be_nil
        end
      end
      context "genre subelement" do
        it "should have a separate value for each genre element" do
          m = "<mods #{@ns_decl}>
          <subject>
          <genre>first</genre>
          <genre>second</genre>
          </subject>
          <subject><genre>third</genre></subject>
          </mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
          expect(@smods_rec.subject_other_subvy_search).to eq(['first', 'second', 'third'])
        end
        it "should be nil if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><genre/></subject><note>notit</note></mods>"
          @smods_rec = Stanford::Mods::Record.new
          @smods_rec.from_str(m)
          expect(@smods_rec.subject_other_subvy_search).to be_nil
        end
      end
    end # subject_other_subvy_search

    context "subject_all_search" do
      before :each do
        allow(@smods_rec.sw_logger).to receive(:info).with(/ has subject geographicCode element with untranslated encoding \(iso3166\): <geographicCode authority=.*>us<\/geographicCode>/)
      end
      it "should be nil if there are no values in the MODS" do
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(@ng_mods_no_subject.to_s)
        expect(@smods_rec.subject_all_search).to be_nil
      end
      it "should contain top level <genre> element data" do
         expect(@smods_rec.subject_all_search).to include(@genre)
      end
      it "should not contain cartographic sub element" do
        expect(@smods_rec.subject_all_search).not_to include(@cart_coord)
      end
      it "should not include codes from hierarchicalGeographic sub element" do
        expect(@smods_rec.subject_all_search).not_to include(@geo_code)
      end
      it "should contain all other subject subelement data" do
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(@subject_mods)
        ## need to re-allow/expect :info message with newly assigned object
        expect(@smods_rec.sw_logger).to receive(:info).with(/ has subject geographicCode element with untranslated encoding \(iso3166\): <geographicCode authority=.*>us<\/geographicCode>/)
        expect(@smods_rec.subject_all_search).to include(@s_genre)
        expect(@smods_rec.subject_all_search).to include(@geo)
        expect(@smods_rec.subject_all_search).to include(@hier_geo_country)
        expect(@smods_rec.subject_all_search).to include(@s_name)
        expect(@smods_rec.subject_all_search).to include(@occupation)
        expect(@smods_rec.subject_all_search).to include(@temporal)
        expect(@smods_rec.subject_all_search).to include(@s_title)
        expect(@smods_rec.subject_all_search).to include(@topic)
      end
    end # subject_all_search

  end  # search fields

  context "facet fields" do

    context "topic_facet" do
      it "should include topic subelement" do
        expect(@smods_rec.topic_facet).to include(@topic)
      end
      it "should include sw_subject_names" do
        expect(@smods_rec.topic_facet).to include(@s_name)
      end
      it "should include sw_subject_titles" do
        expect(@smods_rec.topic_facet).to include(@s_title)
      end
      it "should include occupation subelement" do
        expect(@smods_rec.topic_facet).to include(@occupation)
      end
      it "should have the trailing punctuation removed" do
        m = "<mods #{@ns_decl}><subject>
        <topic>comma,</topic>
        <occupation>semicolon;</occupation>
        <titleInfo><title>backslash \\</title></titleInfo>
        <name><namePart>internal, punct;uation</namePart></name>
        </subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.topic_facet).to include('comma')
        expect(@smods_rec.topic_facet).to include('semicolon')
        expect(@smods_rec.topic_facet).to include('backslash')
        expect(@smods_rec.topic_facet).to include('internal, punct;uation')
      end
      it "should be nil if there are no values" do
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(@ng_mods_no_subject.to_s)
        expect(@smods_rec.topic_facet).to be_nil
      end
    end

    context "geographic_facet" do
      it "should call geographic_search" do
        expect(@smods_rec).to receive(:geographic_search)
        @smods_rec.geographic_facet
      end
      it "should be like geographic_search with the trailing punctuation (and preceding spaces) removed" do
        m = "<mods #{@ns_decl}><subject>
        <geographic>comma,</geographic>
        <geographic>semicolon;</geographic>
        <geographic>backslash \\</geographic>
        <geographic>internal, punct;uation</geographic>
        </subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.geographic_facet).to include('comma')
        expect(@smods_rec.geographic_facet).to include('semicolon')
        expect(@smods_rec.geographic_facet).to include('backslash')
        expect(@smods_rec.geographic_facet).to include('internal, punct;uation')
      end
      it "should be nil if there are no values" do
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(@ng_mods_no_subject.to_s)
        expect(@smods_rec.geographic_facet).to be_nil
      end
    end

    context "era_facet" do
      it "should be temporal subelement with the trailing punctuation removed" do
        m = "<mods #{@ns_decl}><subject>
              <temporal>comma,</temporal>
              <temporal>semicolon;</temporal>
              <temporal>backslash \\</temporal>
              <temporal>internal, punct;uation</temporal>
            </subject></mods>"
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(m)
        expect(@smods_rec.era_facet).to include('comma')
        expect(@smods_rec.era_facet).to include('semicolon')
        expect(@smods_rec.era_facet).to include('backslash')
        expect(@smods_rec.era_facet).to include('internal, punct;uation')
      end
      it "should be nil if there are no values" do
        @smods_rec = Stanford::Mods::Record.new
        @smods_rec.from_str(@ng_mods_no_subject.to_s)
        expect(@smods_rec.era_facet).to be_nil
      end
    end

  end # facet fields

end
