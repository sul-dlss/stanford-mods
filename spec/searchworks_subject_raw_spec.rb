# encoding: UTF-8
describe "Searchworks mixin for Stanford::Mods::Record" do
  before(:all) do
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
  end

  context "sw subject raw methods" do
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
    end

    let(:m) do
      "<mods #{@ns_decl}>
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
    end

    before do
      @smods_rec = Stanford::Mods::Record.new
      @smods_rec.from_str m
    end

    context "subject_names" do
      subject(:subject_names) do
        @smods_rec.send(:subject_names)
      end
      it "should contain <subject><name><namePart> values" do
        expect(subject_names).to include(@s_name)
      end
      it "should not contain non-name subject subelements" do
        expect(subject_names).not_to include(@cart_coord)
        expect(subject_names).not_to include(@s_genre)
        expect(subject_names).not_to include(@geo)
        expect(subject_names).not_to include(@geo_code)
        expect(subject_names).not_to include(@hier_geo_country)
        expect(subject_names).not_to include(@occupation)
        expect(subject_names).not_to include(@temporal)
        expect(subject_names).not_to include(@topic)
        expect(subject_names).not_to include(@s_title)
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
        expect(@smods_rec.send(:subject_names).find { |sn| sn =~ /cre/ }).to be_nil
      end
      it "should not contain subject/name/affiliation" do
        m = "<mods #{@ns_decl}>
              <subject><name type='personal'>
              	<namePart type='termsOfAddress'>Dr.</namePart>
              	<namePart>Brown, B. F.</namePart>
              	<affiliation>Chemistry Dept., American University</affiliation>
              </name></subject></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.send(:subject_names).find { |sn| sn =~ /Chemistry/ }).to be_nil
      end
      it "should not contain subject/name/description" do
        m = "<mods #{@ns_decl}>
              <subject><name type='personal'>
              	<namePart>Abrams, Michael</namePart>
              	<description>American artist, 20th c.</description>
              </name></subject></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.send(:subject_names).find { |sn| sn =~ /artist/ }).to be_nil
      end
      it "should not include top level name element" do
        m = "<mods #{@ns_decl}>
              <name type='personal'>
              	<namePart>Abrams, Michael</namePart>
              	<description>American artist, 20th c.</description>
              </name></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.send(:subject_names)).to eq([])
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
        expect(@smods_rec.send(:subject_names)).to eq(['first', 'second', 'third'])
      end
      it "should be an empty Array if there are no values in the mods" do
        m = "<mods #{@ns_decl}><note>notit</note></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.send(:subject_names)).to eq([])
      end
      it "should be an empty Array if there are empty values in the mods" do
        m = "<mods #{@ns_decl}><subject><name><namePart/></name></subject><note>notit</note></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.send(:subject_names)).to eq([])
      end
      context "combining subelements" do
        let(:m) do
          "<mods #{@ns_decl}>
            <subject>
              <name>
                <namePart>first</namePart>
                <namePart>second</namePart>
              </name>
            </subject>
          </mods>"
        end

        it "uses a ', ' as the separator by default" do
          expect(@smods_rec.send(:subject_names)).to eq ['first, second']
        end
      end
    end

    context "subject_titles" do
      subject(:subject_titles) { @smods_rec.send(:subject_titles) }

      it "should contain <subject><titleInfo> subelement values" do
        expect(subject_titles).to include(@s_title)
      end
      it "should not contain non-name subject subelements" do
        expect(subject_titles).not_to include(@cart_coord)
        expect(subject_titles).not_to include(@s_genre)
        expect(subject_titles).not_to include(@geo)
        expect(subject_titles).not_to include(@geo_code)
        expect(subject_titles).not_to include(@hier_geo_country)
        expect(subject_titles).not_to include(@s_name)
        expect(subject_titles).not_to include(@occupation)
        expect(subject_titles).not_to include(@temporal)
        expect(subject_titles).not_to include(@topic)
      end
      it "should not include top level titleInfo element" do
        m = "<mods #{@ns_decl}><titleInfo><title>Oklahoma</title></titleInfo></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.send(:subject_titles)).to eq([])
      end
      it "should have one value for each titleInfo element" do
        m = "<mods #{@ns_decl}>
              <subject>
                <titleInfo><title>first</title></titleInfo>
                <titleInfo><title>second</title></titleInfo>
              </subject>
              <subject>
                <titleInfo><title>third</title></titleInfo>
              </subject>
              </mods>"
        @smods_rec.from_str m
        expect(@smods_rec.send(:subject_titles)).to eq(['first', 'second', 'third'])
      end
      it "should be an empty Array if there are no values in the mods" do
        m = "<mods #{@ns_decl}><note>notit</note></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.send(:subject_titles)).to eq([])
      end
      it "should be an empty Array if there are empty values in the mods" do
        m = "<mods #{@ns_decl}><subject><titleInfo><title/></titleInfo></subject><note>notit</note></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.send(:subject_titles)).to eq([])
      end
      context "combining subelements" do
        let(:m) do
          "<mods #{@ns_decl}>
            <subject>
              <titleInfo>
                <title>first</title>
                <subTitle>second</subTitle>
              </titleInfo>
            </subject>
          </mods>"
        end

        it "uses a ' ' as the separator by default" do
          expect(@smods_rec.send(:subject_titles)).to eq ['first second']
        end

        it "includes all subelements in the order of occurrence" do
          m = "<mods #{@ns_decl}>
                <subject>
                  <titleInfo>
                    <partName>1</partName>
                    <nonSort>2</nonSort>
                    <partNumber>3</partNumber>
                    <title>4</title>
                    <subTitle>5</subTitle>
                  </titleInfo>
                </subject>
              </mods>"
          @smods_rec.from_str m
          expect(@smods_rec.send(:subject_titles)).to eq(['1 2 3 4 5'])
        end
      end
    end # subject_titles

    context "sw_geographic_search" do
      subject(:geographic_search) { @smods_rec.geographic_search }

      it "should contain subject <geographic> subelement data" do
        expect(geographic_search).to include(@geo)
      end
      it "should contain subject <hierarchicalGeographic> subelement data" do
        expect(geographic_search).to include(@hier_geo_country)
      end
      it "should contain translation of <geographicCode> subelement data with translated authorities" do
        m = "<mods #{@ns_decl}><subject><geographicCode authority='marcgac'>e-er</geographicCode></subject></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.geographic_search).to include('Estonia')
      end
      it "should not contain other subject element data" do
        expect(geographic_search).not_to include(@genre)
        expect(geographic_search).not_to include(@cart_coord)
        expect(geographic_search).not_to include(@s_genre)
        expect(geographic_search).not_to include(@s_name)
        expect(geographic_search).not_to include(@occupation)
        expect(geographic_search).not_to include(@temporal)
        expect(geographic_search).not_to include(@topic)
        expect(geographic_search).not_to include(@s_title)
      end
      it "should be [] if there are no values in the MODS" do
        m = "<mods #{@ns_decl}><note>notit</note></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.geographic_search).to eq([])
      end
      it "should not be empty Array if there are only subject/geographic elements" do
        m = "<mods #{@ns_decl}><subject><geographic>#{@geo}</geographic></subject></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.geographic_search).to eq([@geo])
      end
      it "should not be empty Array if there are only subject/hierarchicalGeographic" do
        m = "<mods #{@ns_decl}><subject><hierarchicalGeographic><country>#{@hier_geo_country}</country></hierarchicalGeographic></subject></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.geographic_search).to eq([@hier_geo_country])
      end
      it "should not be empty Array if there are only subject/geographicCode elements" do
        m = "<mods #{@ns_decl}><subject><geographicCode authority='marcgac'>e-er</geographicCode></subject></mods>"
        @smods_rec.from_str m
        expect(@smods_rec.geographic_search).to eq(['Estonia'])
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
          expect(@smods_rec.geographic_search).to eq(['Mississippi', 'Tippah County', 'Washington (D.C.)'])
        end
        it "should be empty Array if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><geographic/></subject><note>notit</note></mods>"
          @smods_rec.from_str m
          expect(@smods_rec.geographic_search).to eq([])
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
          expect(@smods_rec.geographic_search).to eq(['first', 'second', 'third'])
        end
        it "should be empty Array if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><hierarchicalGeographic/></subject><note>notit</note></mods>"
          @smods_rec.from_str m
          expect(@smods_rec.geographic_search).to eq([])
        end
        context "combining subelements" do
          let(:m) do
            "<mods #{@ns_decl}>
            <subject>
              <hierarchicalGeographic>
              	<country>Canada</country>
              	<province>British Columbia</province>
              	<city>Vancouver</city>
              </hierarchicalGeographic>
            </subject></mods>"
          end

          it "uses a space as the separator by default" do
            expect(@smods_rec.geographic_search).to eq ['Canada British Columbia Vancouver']
          end
        end
      end # hierarchicalGeographic

      context "geographicCode subelement" do
        let(:m) do
          "<mods #{@ns_decl}>
            <subject><geographicCode authority='marcgac'>n-us-md</geographicCode></subject>
            <subject><geographicCode authority='marcgac'>e-er</geographicCode></subject>
            <subject><geographicCode authority='marccountry'>mg</geographicCode></subject>
            <subject><geographicCode authority='iso3166'>us</geographicCode></subject>
          </mods>"
        end

        before do
          @geo_search_from_codes = @smods_rec.geographic_search
        end

        it "should not add untranslated values" do
          expect(@geo_search_from_codes).not_to include('n-us-md')
          expect(@geo_search_from_codes).not_to include('e-er')
          expect(@geo_search_from_codes).not_to include('mg')
          expect(@geo_search_from_codes).not_to include('us')
        end
        it "should translate marcgac codes" do
          expect(@geo_search_from_codes).to include('Estonia')
        end
        it "should translate marccountry codes" do
          expect(@geo_search_from_codes).to include('Madagascar')
        end
        it "should not translate other codes" do
          expect(@geo_search_from_codes).not_to include('United States')
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
          expect(@smods_rec.geographic_search).to eq(['Estonia', 'Madagascar', 'Maryland'])
        end
        it "should be empty Array if there are only empty values in the MODS" do
          m = "<mods #{@ns_decl}><subject><geographicCode/></subject><note>notit</note></mods>"
          @smods_rec.from_str m
          expect(@smods_rec.geographic_search).to eq([])
        end
        it "should add the translated value if it wasn't present already" do
          m = "<mods #{@ns_decl}>
            <subject><geographic>Somewhere</geographic></subject>
            <subject><geographicCode authority='marcgac'>e-er</geographicCode></subject>
          </mods>"
          @smods_rec.from_str m
          expect(@smods_rec.geographic_search.size).to eq(2)
          expect(@smods_rec.geographic_search).to include('Estonia')
        end
        it "should not add the translated value if it was already present" do
          m = "<mods #{@ns_decl}>
            <subject><geographic>Estonia</geographic></subject>
            <subject><geographicCode authority='marcgac'>e-er</geographicCode></subject>
          </mods>"
          @smods_rec.from_str m
          expect(@smods_rec.geographic_search.size).to eq(1)
          expect(@smods_rec.geographic_search).to eq(['Estonia'])
        end
      end
    end # sw_geographic_search
  end # context sw subject methods
end
