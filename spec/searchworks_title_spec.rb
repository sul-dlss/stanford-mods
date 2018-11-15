# encoding: UTF-8
describe 'title fields (searchworks.rb)' do
  before(:all) do
    @smods_rec = Stanford::Mods::Record.new
    @ns_decl = "xmlns='#{Mods::MODS_NS}'"
    m = "<mods #{@ns_decl}><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>"
    @smods_rec.from_str m
  end

  context 'short title (for title_245a_search, title_245a_display)' do
    it 'should call :short_titles' do
      expect(@smods_rec).to receive(:short_titles) # in Mods gem
      @smods_rec.sw_short_title
    end
    it 'should be a String' do
      expect(@smods_rec.sw_short_title).to eq 'The Jerk'
    end
  end

  context 'blank title node' do
    it 'should deal with a second blank titleInfo node' do
      m = "<mods #{@ns_decl}><titleInfo> </titleInfo><otherStuff>goes here</otherStuff><titleInfo><title>Jerk</title><subTitle>A Tale of Tourettes</subTitle><nonSort>The</nonSort></titleInfo></mods>"
      smods_rec_blank_node = Stanford::Mods::Record.new
      smods_rec_blank_node.from_str m
      expect(smods_rec_blank_node.sw_short_title).to eq 'The Jerk'
      expect(smods_rec_blank_node.sw_full_title).to eq 'The Jerk : A Tale of Tourettes.'
    end
  end

  context 'when titleInfo contains a subTitle but no title' do
    let(:record) do
      m = "<mods #{@ns_decl}><titleInfo><subTitle>An overview from 1942-1950</subTitle></titleInfo></mods>"
      rec = Stanford::Mods::Record.new
      rec.from_str m
      rec
    end

    it 'returns nil' do
      expect(record.sw_full_title).to be_nil
    end
  end

  context 'missing title node' do
    it 'deals with missing titleInfo node' do
      m = "<mods #{@ns_decl}></mods>"
      smods_rec_blank_node = Stanford::Mods::Record.new
      smods_rec_blank_node.from_str m
      expect(smods_rec_blank_node.sw_short_title).to be_blank
      expect(smods_rec_blank_node.sw_full_title).to be_blank
      expect(smods_rec_blank_node.sw_sort_title).to be_blank
    end
  end

  context 'full title (for title_245_search, title_full_display)' do
    it 'should be a String' do
      expect(@smods_rec.sw_full_title).to eq 'The Jerk : A Tale of Tourettes.'
    end
    it 'should cope with regex chars' do
      m = "<mods #{@ns_decl}><titleInfo>
          <title>Pius V. Saint, [Michaele Gisleri),</title>
        </titleInfo></mods>"
      @smods_rec.from_str m
      expect(@smods_rec.sw_full_title).to eq 'Pius V. Saint, [Michaele Gisleri),'
    end

    context 'punctuation' do
      context 'no subtitle' do
        it 'end title with a period' do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_full_title).to eq 'The Olympics.'
        end
        it 'title already ends in period' do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics.</title>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_full_title).to eq 'The Olympics.'
        end
        it 'title already ends in other punctuation' do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics!</title>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_full_title).to eq 'The Olympics!'
        end
      end # no subtitle
      context 'subtitle' do
        it 'end title with a colon' do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
              <subTitle>a history</subTitle>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history.'
        end
        it 'title already ends with colon' do
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
        it 'subtitle already ends with period' do
          m = "<mods #{@ns_decl}>
            <titleInfo>
              <nonSort>The</nonSort>
              <title>Olympics</title>
              <subTitle>a history.</subTitle>
            </titleInfo></mods>"
          @smods_rec.from_str(m)
          expect(@smods_rec.sw_full_title).to eq 'The Olympics : a history.'
        end
        it 'subtitle already ends with other punctuation' do
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
      context 'partName' do
        context 'no partNumber' do
          it 'end partName with period' do
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
          it 'partName already ends with period' do
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
        context 'partNumber' do
          it 'end partNumber with comma' do
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
          it 'partNumber already ends with comma' do
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
      context 'no partName, but partNumber' do
        it 'end partNumber with period' do
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
        it 'parNumber already ends in period' do
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
        it 'partNumber already ends with other punctuation' do
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

  context 'sw_title_display removes end punctuation of sw_full_title_display' do
    # title_display = custom, removeTrailingPunct(245abdefghijklmnopqrstuvwxyz, [\\\\,/;:], ([A-Za-z]{4}|[0-9]{3}|\\)|\\,))
    context "should remove trailing \,/;:." do
      it 'retains other trailing chars' do
        m = "<mods #{@ns_decl}><titleInfo>
              <title>The Jerk?</title>
            </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Jerk?'
        m = "<mods #{@ns_decl}><titleInfo>
              <title>The Jerk!</title>
            </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Jerk!'
      end
      it 'removes trailing comma' do
        m = "<mods #{@ns_decl}><titleInfo>
              <title>The Jerk,</title>
            </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Jerk'
      end
      it 'removes trailing semicolon' do
        m = "<mods #{@ns_decl}><titleInfo>
              <title>The Jerk;</title>
            </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Jerk'
      end
      it 'removes trailing colon' do
        m = "<mods #{@ns_decl}><titleInfo>
              <title>The Jerk:</title>
            </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Jerk'
      end
      it 'removes trailing slash' do
        m = "<mods #{@ns_decl}><titleInfo>
              <title>The Jerk /</title>
            </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Jerk'
      end
      it 'removes trailing backslash' do
        m = "<mods #{@ns_decl}><titleInfo>
              <title>The Jerk \</title>
            </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Jerk'
      end
      it 'removes multiple trailing punctuation' do
        m = "<mods #{@ns_decl}><titleInfo>
              <title>The Jerk.,\</title>
            </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Jerk'
      end
    end
    context 'no subtitle' do
      it 'end title with a period' do
        m = "<mods #{@ns_decl}>
          <titleInfo>
            <nonSort>The</nonSort>
            <title>Olympics</title>
          </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Olympics'
      end
      it 'title already ends in period' do
        m = "<mods #{@ns_decl}>
          <titleInfo>
            <nonSort>The</nonSort>
            <title>Olympics.</title>
          </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Olympics'
      end
      it 'title already ends in other punctuation' do
        m = "<mods #{@ns_decl}>
          <titleInfo>
            <nonSort>The</nonSort>
            <title>Olympics!</title>
          </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Olympics!'
      end
    end # no subtitle
    context 'subtitle' do
      it 'end title with a colon' do
        m = "<mods #{@ns_decl}>
          <titleInfo>
            <nonSort>The</nonSort>
            <title>Olympics</title>
            <subTitle>a history</subTitle>
          </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history'
      end
      it 'title already ends with colon' do
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
      it 'subtitle already ends with period' do
        m = "<mods #{@ns_decl}>
          <titleInfo>
            <nonSort>The</nonSort>
            <title>Olympics</title>
            <subTitle>a history.</subTitle>
          </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history'
      end
      it 'subtitle already ends with other punctuation' do
        m = "<mods #{@ns_decl}>
          <titleInfo>
            <nonSort>The</nonSort>
            <title>Olympics</title>
            <subTitle>a history?</subTitle>
          </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history?'
      end
    end # subtitle
    context 'partName' do
      context 'no partNumber' do
        it 'end partName with period' do
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
        it 'partName already ends with period' do
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
      context 'partNumber' do
        it 'end partNumber with comma' do
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
        it 'partNumber already ends with comma' do
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
    context 'no partName, but partNumber' do
      it 'end partNumber with period' do
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
      it 'parNumber already ends in period' do
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
      it 'partNumber already ends with other punctuation' do
        m = "<mods #{@ns_decl}>
          <titleInfo>
            <nonSort>The</nonSort>
            <title>Olympics</title>
            <subTitle>a history</subTitle>
            <partNumber>Part 1!</partNumber>
          </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'The Olympics : a history. Part 1!'
        m = "<mods #{@ns_decl}>
          <titleInfo>
            <title>cfb</title>
            <partNumber>1894?</partNumber>
          </titleInfo></mods>"
        @smods_rec.from_str(m)
        expect(@smods_rec.sw_title_display).to eq 'cfb. 1894?'
      end
    end # no partName but partNumber
  end # sw_title_display

  context 'additional titles (for title_variant_search)' do
    before(:all) do
      m = "<mods #{@ns_decl}>
        <titleInfo type='alternative'><title>Alternative</title></titleInfo>
        <titleInfo><title>Jerk</title><nonSort>The</nonSort></titleInfo>
        <titleInfo><title>Joke</title></titleInfo>
        </mods>"
      @smods_rec.from_str(m)
      @addl_titles = @smods_rec.sw_addl_titles
    end
    it 'should not include the main title' do
      expect(@addl_titles.size).to eq 2
      expect(@addl_titles).not_to include(@smods_rec.sw_full_title)
    end
    it 'should include any extra main titles' do
      expect(@addl_titles).to include('Joke')
    end
    it 'should include all alternative titles' do
      expect(@addl_titles).to include('Alternative')
    end
    it 'should cope with regexp chars in the short title when determining addl titles' do
      m = "<mods #{@ns_decl}>
          <titleInfo type='alternative'><title>Alternative</title></titleInfo>
          <titleInfo><title>[Jerk)</title><nonSort>The</nonSort></titleInfo>
          <titleInfo><title>Joke]</title></titleInfo>
          </mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_addl_titles).to eq ['Alternative', 'Joke]']
    end
    it 'excludes weird cases where there is no short title' do
      m = <<-EOXML
        <mods #{@ns_decl}>
        <titleInfo></titleInfo>
        <titleInfo type="alternative">
          <title>Sponsored projects report for the year ended</title>
        </titleInfo>
        </mods>
      EOXML
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_addl_titles).to be_empty
    end
  end

  context 'sort title' do
    it 'should be a String' do
      expect(@smods_rec.sw_sort_title).to be_an_instance_of(String)
    end
    it 'should use the sw_full_title as a starting point' do
      expect(@smods_rec).to receive(:sw_full_title)
      @smods_rec.sw_sort_title
    end
    it 'should not begin or end with whitespace' do
      m = "<mods #{@ns_decl}>
        <titleInfo><title>      Jerk     </title></titleInfo>
        </mods>"
      @smods_rec.from_str(m)
      expect(@smods_rec.sw_sort_title).to eq @smods_rec.sw_sort_title.strip
    end
    it 'should not have any punctuation marks' do
      r = Stanford::Mods::Record.new
      r.from_str "<mods #{@ns_decl}><titleInfo><title>J,e.r;;;k</title></titleInfo></mods>"
      expect(r.sw_sort_title).to match(/^Jerk$/)
    end
    it 'should properly handle nonSort tags with metacharacters' do
      r = Stanford::Mods::Record.new
      r.from_str "<mods #{@ns_decl}><titleInfo><nonSort>[“</nonSort><title>In hat mappa lector... cum enim tota Chilensis regionus...”]</title></titleInfo></mods>"
      expect(r.sw_sort_title).to match(/^In hat mappa lector cum enim tota Chilensis regionus$/)
    end
  end

  context 'part number should be in full title and sort title', jira: ['INDEX-31', 'GRYPHONDOR-372'] do
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
    it 'short titles' do
      expect(@mccarthy_smods_rec.sw_short_title).to eql 'McCarthy, John'
      expect(@insp_general_smods_rec.sw_short_title).to eql 'Semiannual report to Congress'
      expect(@cfb_smods_rec.sw_short_title).to eql 'cfb'
      expect(@all_smods_rec.sw_short_title).to eql 'The Olympics'
    end
    it 'full titles' do
      expect(@mccarthy_smods_rec.sw_full_title).to eql 'McCarthy, John. Part 2.'
      expect(@insp_general_smods_rec.sw_full_title).to eql 'Semiannual report to Congress. October 1, 1998 - March 31, 1999.'
      expect(@cfb_smods_rec.sw_full_title).to eql 'cfb. 1894, Appendix.'
      expect(@all_smods_rec.sw_full_title).to eql 'The Olympics : a history. Part 1, Ancient.'
    end
    it 'additional titles' do
      expect(@mccarthy_smods_rec.sw_addl_titles).to eql []
      expect(@insp_general_smods_rec.sw_addl_titles).to eql []
      expect(@cfb_smods_rec.sw_addl_titles).to eql []
      expect(@all_smods_rec.sw_addl_titles).to eql []
    end
    it 'sort title' do
      expect(@mccarthy_smods_rec.sw_sort_title).to eql 'McCarthy John Part 2'
      expect(@insp_general_smods_rec.sw_sort_title).to eql 'Semiannual report to Congress October 1 1998 March 31 1999'
      expect(@cfb_smods_rec.sw_sort_title).to eql 'cfb 1894 Appendix'
      expect(@all_smods_rec.sw_sort_title).to eql 'Olympics a history Part 1 Ancient'
    end
  end
end
