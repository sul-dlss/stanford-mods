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
    
    context "full title (for title_245_search, title_full_display)" do
      it "should be a String" do
        @smods_rec.sw_full_title.should == 'The Jerk : A Tale of Tourettes.'
      end
      it 'should cope with regex chars' do
        m = "<mods #{@ns_decl}><titleInfo>
            <title>Pius V. Saint, [Michaele Gisleri),</title>
          </titleInfo></mods>"
        @smods_rec.from_str m
        @smods_rec.sw_full_title.should == 'Pius V. Saint, [Michaele Gisleri),'
      end

      context "punctuation" do
        context "no subtitle" do
          it "end title with a period" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics.'
          end
          it "title already ends in period" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics.</title>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics.'
          end
          it "title already ends in other punctuation" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics!</title>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics!'
          end
        end # no subtitle
        context "subtitle" do
          it "end title with a colon" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history</subTitle>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history.'
          end
          it "title already ends with colon" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics:</title>
                <subTitle>a history</subTitle>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history.'
          end #
          # "end subtitle with period" - see above
          it "subtitle already ends with period" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history.</subTitle>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history.'
          end
          it "subtitle already ends with other punctuation" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history?</subTitle>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history?'
          end
        end # subtitle
        context "partName" do
          context "no partNumber" do
            it "end partName with period" do
              m = "<mods #{@ns_decl}>
                <titleInfo>
                  <nonSort>The</nonSort>
                  <title>Olympics</title>
                  <subTitle>a history</subTitle>
                  <partName>Ancient</partName>
                </titleInfo></mods>"
              @smods_rec.from_str(m)
              expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history. Ancient.'
              m = "<mods #{@ns_decl}>
                <titleInfo>
                  <title>cfb</title>
                  <partName>Appendix</partName>
                </titleInfo></mods>"
              @smods_rec.from_str(m)
              expect(@smods_rec.sw_full_title).to eq 'cfb. Appendix.'
            end
            it "partName already ends with period" do
              m = "<mods #{@ns_decl}>
                <titleInfo>
                  <nonSort>The</nonSort>
                  <title>Olympics</title>
                  <subTitle>a history</subTitle>
                  <partName>Ancient.</partName>
                </titleInfo></mods>"
              @smods_rec.from_str(m)
              expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history. Ancient.'
              m = "<mods #{@ns_decl}>
                <titleInfo>
                  <title>cfb</title>
                  <partName>Appendix.</partName>
                </titleInfo></mods>"
              @smods_rec.from_str(m)
              expect(@smods_rec.sw_full_title).to eq 'cfb. Appendix.'
            end
          end # no partNumber
          context "partNumber" do
            it "end partNumber with comma" do
              m = "<mods #{@ns_decl}>
                <titleInfo>
                  <nonSort>The</nonSort>
                  <title>Olympics</title>
                  <subTitle>a history</subTitle>
                  <partNumber>Part 1</partNumber>
                  <partName>Ancient</partName>
                </titleInfo></mods>"
              @smods_rec.from_str(m)
              expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history. Part 1, Ancient.'
              m = "<mods #{@ns_decl}>
                <titleInfo>
                  <title>cfb</title>
                  <partNumber>1894</partNumber>
                  <partName>Appendix</partName>
                </titleInfo></mods>"
              @smods_rec.from_str(m)
              expect(@smods_rec.sw_full_title).to eq 'cfb. 1894, Appendix.'
            end
            it "partNumber already ends with comma" do
              m = "<mods #{@ns_decl}>
                <titleInfo>
                  <nonSort>The</nonSort>
                  <title>Olympics</title>
                  <subTitle>a history</subTitle>
                  <partNumber>Part 1,</partNumber>
                  <partName>Ancient</partName>
                </titleInfo></mods>"
              @smods_rec.from_str(m)
              expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history. Part 1, Ancient.'
              m = "<mods #{@ns_decl}>
                <titleInfo>
                  <title>cfb</title>
                  <partNumber>1894,</partNumber>
                  <partName>Appendix</partName>
                </titleInfo></mods>"
              @smods_rec.from_str(m)
              expect(@smods_rec.sw_full_title).to eq 'cfb. 1894, Appendix.'
            end
          end
        end # partName
        context "no partName, but partNumber" do
          it "end partNumber with period" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history</subTitle>
                <partNumber>Part 1</partNumber>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history. Part 1.'
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <title>cfb</title>
                <partNumber>1894</partNumber>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'cfb. 1894.'
          end
          it "parNumber already ends in period" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history</subTitle>
                <partNumber>Part 1.</partNumber>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history. Part 1.'
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <title>cfb</title>
                <partNumber>1894.</partNumber>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'cfb. 1894.'
          end
          it "partNumber already ends with other punctuation" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history</subTitle>
                <partNumber>Part 1!</partNumber>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history. Part 1!'
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <title>cfb</title>
                <partNumber>1894?</partNumber>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_full_title).to eq 'cfb. 1894?'
          end
        end # no partName but partNumber
      end # punctuation
    end # sw_full_title
    
    context "sw_title_display removes end punctuation of sw_full_title_display" do
      context "no subtitle" do
        it "end title with a period" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics'
        end
        it "title already ends in period" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics.</title>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics'
        end
        it "title already ends in other punctuation" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics!</title>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics'
        end
      end # no subtitle
      context "subtitle" do
        it "end title with a colon" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
              <subTitle>a history</subTitle>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history'
        end
        it "title already ends with colon" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics:</title>
              <subTitle>a history</subTitle>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history'
        end #
        # "end subtitle with period" - see above
        it "subtitle already ends with period" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
              <subTitle>a history.</subTitle>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history'
        end
        it "subtitle already ends with other punctuation" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
              <subTitle>a history?</subTitle>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history'
        end
      end # subtitle
      context "partName" do
        context "no partNumber" do
          it "end partName with period" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history</subTitle>
                <partName>Ancient</partName>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history. Ancient'
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <title>cfb</title>
                <partName>Appendix</partName>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_title_display).to eq 'cfb. Appendix'
          end
          it "partName already ends with period" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history</subTitle>
                <partName>Ancient.</partName>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history. Ancient'
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <title>cfb</title>
                <partName>Appendix.</partName>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_title_display).to eq 'cfb. Appendix'
          end
        end # no partNumber
        context "partNumber" do
          it "end partNumber with comma" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history</subTitle>
                <partNumber>Part 1</partNumber>
                <partName>Ancient</partName>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history. Part 1, Ancient'
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <title>cfb</title>
                <partNumber>1894</partNumber>
                <partName>Appendix</partName>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_title_display).to eq 'cfb. 1894, Appendix'
          end
          it "partNumber already ends with comma" do
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <nonSort>The</nonSort>
                <title>Olympics</title>
                <subTitle>a history</subTitle>
                <partNumber>Part 1,</partNumber>
                <partName>Ancient</partName>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history. Part 1, Ancient'
            m = "<mods #{@ns_decl}>
              <titleInfo>
                <title>cfb</title>
                <partNumber>1894,</partNumber>
                <partName>Appendix</partName>
              </titleInfo></mods>"
            @smods_rec.from_str(m)
            expect(@smods_rec.sw_title_display).to eq 'cfb. 1894, Appendix'
          end
        end
      end # partName
      context "no partName, but partNumber" do
        it "end partNumber with period" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
              <subTitle>a history</subTitle>
              <partNumber>Part 1</partNumber>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history. Part 1'
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <title>cfb</title>
              <partNumber>1894</partNumber>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'cfb. 1894'
        end
        it "parNumber already ends in period" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
              <subTitle>a history</subTitle>
              <partNumber>Part 1.</partNumber>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history. Part 1'
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <title>cfb</title>
              <partNumber>1894.</partNumber>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'cfb. 1894'
        end
        it "partNumber already ends with other punctuation" do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
              <subTitle>a history</subTitle>
              <partNumber>Part 1!</partNumber>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history. Part 1'
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <title>cfb</title>
              <partNumber>1894?</partNumber>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_title_display).to eq 'cfb. 1894'
        end
      end # no partName but partNumber
    end # sw_title_display
    
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
      it 'should cope with regexp chars in the short title when determining addl titles' do
         m = "<mods #{@ns_decl}>
            <titleInfo type='alternative'><title>Alternative</title></titleInfo>
            <titleInfo><title>[Jerk)</title><nonSort>The</nonSort></titleInfo>
            <titleInfo><title>Joke]</title></titleInfo>
            </mods>"
          @smods_rec.from_str(m)
          @smods_rec.sw_addl_titles.should == ['Alternative', 'Joke]']
      end
    end    
    
    context "sort title" do
      it "should be a String" do
        @smods_rec.sw_sort_title.should be_an_instance_of(String)
      end
      it "should use the sw_full_title as a starting point" do
        @smods_rec.should_receive(:sw_full_title)
        @smods_rec.sw_sort_title
      end
      it "should not begin or end with whitespace" do
        m = "<mods #{@ns_decl}>
          <titleInfo><title>      Jerk     </title></titleInfo>
          </mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_sort_title).to eq @smods_rec.sw_sort_title.strip
      end
      it "should not have any punctuation marks" do
        r = Stanford::Mods::Record.new
        r.from_str "<mods #{@ns_decl}><titleInfo><title>J,e.r;;;k</title></titleInfo></mods>"
        expect(r.sw_sort_title).to match /^Jerk$/
      end
    end
    
    context "part number should be in full title and sort title", :jira => ['INDEX-31', 'GRYPHONDOR-372'] do
      before(:all) do
        @mccarthy_smods_rec = Stanford::Mods::Record.new
        mccarthy = "<mods #{@ns_decl}>
          <titleInfo>
            <title>McCarthy, John</title>
            <partNumber>Part 2</partNumber>
          </titleInfo></mods>"
        @mccarthy_smods_rec.from_str(mccarthy)
        @insp_general_smods_rec = Stanford::Mods::Record.new
        insp_general = "<mods #{@ns_decl}>
          <titleInfo>
            <title>Semiannual report to Congress</title>
            <partNumber>October 1, 1998 - March 31, 1999</partNumber>
          </titleInfo>
          <titleInfo type=\"uniform\">
            <title>Semiannual report to Congress (Online)</title>
          </titleInfo></mods>"
        @insp_general_smods_rec.from_str(insp_general)
        @cfb_smods_rec = Stanford::Mods::Record.new
        cfb = "<mods #{@ns_decl}>
          <titleInfo>
            <title>cfb</title>
            <partNumber>1894</partNumber>
            <partName>Appendix</partName>
          </titleInfo></mods>"
        @cfb_smods_rec.from_str(cfb)
        @all_smods_rec = Stanford::Mods::Record.new
        all = "<mods #{@ns_decl}>
          <titleInfo>
            <nonSort>The</nonSort>
            <title>Olympics</title>
            <subTitle>a history</subTitle>
            <partNumber>Part 1</partNumber>
            <partName>Ancient</partName>
          </titleInfo></mods>"
        @all_smods_rec.from_str(all)
      end
      it "short titles" do
        expect(@mccarthy_smods_rec.sw_short_title).to eql 'McCarthy, John'
        expect(@insp_general_smods_rec.sw_short_title).to eql 'Semiannual report to Congress'
        expect(@cfb_smods_rec.sw_short_title).to eql 'cfb'
        expect(@all_smods_rec.sw_short_title).to eql 'The Olympics'
      end
      it "full titles" do
        expect(@mccarthy_smods_rec.sw_full_title).to eql 'McCarthy, John. Part 2.'
        expect(@insp_general_smods_rec.sw_full_title).to eql 'Semiannual report to Congress. October 1, 1998 - March 31, 1999.'
        expect(@cfb_smods_rec.sw_full_title).to eql 'cfb. 1894, Appendix.'
        expect(@all_smods_rec.sw_full_title).to eql 'The Olympics : a history. Part 1, Ancient.'
      end
      it "additional titles" do
        expect(@mccarthy_smods_rec.sw_addl_titles).to eql []
        expect(@insp_general_smods_rec.sw_addl_titles).to eql []
        expect(@cfb_smods_rec.sw_addl_titles).to eql []
        expect(@all_smods_rec.sw_addl_titles).to eql []
      end
      it "sort title" do
        expect(@mccarthy_smods_rec.sw_sort_title).to eql 'McCarthy John Part 2'
        expect(@insp_general_smods_rec.sw_sort_title).to eql 'Semiannual report to Congress October 1 1998 March 31 1999'
        expect(@cfb_smods_rec.sw_sort_title).to eql 'cfb 1894 Appendix'
        expect(@all_smods_rec.sw_sort_title).to eql 'Olympics a history Part 1 Ancient'
      end
    end
  end # content sw title methods

end