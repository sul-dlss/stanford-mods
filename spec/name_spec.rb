describe "name/author concepts" do
  let(:smods_rec) { Stanford::Mods::Record.new }
  let(:mods_start) { "<mods xmlns=\"#{Mods::MODS_NS}\">" }
  let(:mods_end) { "</mods>" }

  context "main_author_w_date" do
    let(:plain_no_role) { "<name><namePart>plain_no_role</namePart></name>" }
    let(:plain_creator_code) { "<name>
                              <namePart>plain_creator_code</namePart>
                              <role><roleTerm type='code' authority='marcrelator'>cre</roleTerm></role>
                          </name>" }
    let(:plain_creator_text) { "<name>
                              <namePart>plain_creator_text</namePart>
                              <role><roleTerm type='text' authority='marcrelator'>Creator</roleTerm></role>
                          </name>" }
    let(:plain_creator_non_mr) { "<name>
                              <namePart>plain_creator_non_mr</namePart>
                              <role><roleTerm type='text'>Creator</roleTerm></role>
                          </name>" }
    let(:plain_author_code) { "<name>
                              <namePart>plain_author_code</namePart>
                              <role><roleTerm type='code' authority='marcrelator'>aut</roleTerm></role>
                          </name>" }
    let(:plain_author_text) { "<name>
                              <namePart>plain_author_text</namePart>
                              <role><roleTerm type='text' authority='marcrelator'>Author</roleTerm></role>
                          </name>" }
    let(:plain_author_non_mr) { "<name>
                              <namePart>plain_author_non_mr</namePart>
                              <role><roleTerm type='text'>Author</roleTerm></role>
                          </name>" }
    let(:plain_other_role_mr) { "<name>
                              <namePart>plain_other_role_mr</namePart>
                              <role><roleTerm type='text' authority='marcrelator'>Actor</roleTerm></role>
                          </name>" }

    let(:personal_no_role) { "<name><namePart type='personal'>personal_no_role</namePart></name>" }
    let(:personal_creator_code) { "<name>
                                  <namePart type='personal'>personal_creator_code</namePart>
                                  <role><roleTerm type='code' authority='marcrelator'>cre</roleTerm></role>
                              </name>" }
    let(:personal_author_text) { "<name>
                                  <namePart type='personal'>personal_author_text</namePart>
                                  <role><roleTerm type='text' authority='marcrelator'>Author</roleTerm></role>
                              </name>" }
    let(:personal_other_role) { "<name>
                                <namePart type='personal'>personal_author_text</namePart>
                                <role><roleTerm type='text' authority='marcrelator'>Auctioneer</roleTerm></role>
                            </name>" }
    let(:corp_no_role) { "<name><namePart type='corporate'>corp_no_role</namePart></name>" }
    let(:corp_author_code) { "<name>
                              <namePart type='corporate'>corp_author_code</namePart>
                              <role><roleTerm type='code' authority='marcrelator'>aut</roleTerm></role>
                          </name>" }
    let(:corp_creator_text) { "<name>
                              <namePart type='corporate'>corp_creator_text</namePart>
                              <role><roleTerm type='text' authority='marcrelator'>Creator</roleTerm></role>
                          </name>" }
    let(:other_no_role) { "<name><namePart type='conference'>conference_no_role</namePart></name>" }
    context "marcrelator role Creator" do
      it "finds role with roleTerm type text" do
        smods_rec.from_str(mods_start + plain_creator_text + mods_end)
        expect(smods_rec.main_author_w_date).to eq('plain_creator_text')
      end
      it "finds role with roleTerm type code" do
        smods_rec.from_str(mods_start + plain_creator_code + mods_end)
        expect(smods_rec.main_author_w_date).to eq('plain_creator_code')
      end
      it "skips names when role isn't marcrelator authority" do
        smods_rec.from_str(mods_start + plain_creator_non_mr + mods_end)
        expect(smods_rec.main_author_w_date).to be_nil
      end
      it "skips names without roles in favor of marcrelator role of 'Creator'" do
        smods_rec.from_str(mods_start + personal_no_role + plain_creator_text + other_no_role + mods_end)
        expect(smods_rec.main_author_w_date).to eq('plain_creator_text')
        smods_rec.from_str(mods_start + corp_no_role + plain_creator_code + mods_end)
        expect(smods_rec.main_author_w_date).to eq('plain_creator_code')
      end
      it "does not care about name type" do
        smods_rec.from_str(mods_start + personal_creator_code + corp_creator_text + mods_end)
        expect(smods_rec.main_author_w_date).to eq('personal_creator_code')
        smods_rec.from_str(mods_start + personal_no_role + corp_creator_text + mods_end)
        expect(smods_rec.main_author_w_date).to eq('corp_creator_text')
      end
    end # marcrelator role Creator

    context "marcrelator role Author" do
      it "finds role with roleTerm type text" do
        smods_rec.from_str(mods_start + plain_author_text + mods_end)
        expect(smods_rec.main_author_w_date).to eq('plain_author_text')
      end
      it "finds role with roleTerm type code" do
        smods_rec.from_str(mods_start + plain_author_code + mods_end)
        expect(smods_rec.main_author_w_date).to eq('plain_author_code')
      end
      it "skips names when role isn't marcrelator authority" do
        smods_rec.from_str(mods_start + plain_author_non_mr + mods_end)
        expect(smods_rec.main_author_w_date).to be_nil
      end
      it "skips names without roles in favor of marcrelator role of 'Author'" do
        smods_rec.from_str(mods_start + personal_no_role + plain_author_text + other_no_role + mods_end)
        expect(smods_rec.main_author_w_date).to eq('plain_author_text')
        smods_rec.from_str(mods_start + corp_no_role + personal_no_role + plain_author_code + mods_end)
        expect(smods_rec.main_author_w_date).to eq('plain_author_code')
      end
      it "doesn't care about name type" do
        smods_rec.from_str(mods_start + personal_author_text + corp_author_code + mods_end)
        expect(smods_rec.main_author_w_date).to eq('personal_author_text')
        smods_rec.from_str(mods_start + personal_no_role + corp_author_code + mods_end)
        expect(smods_rec.main_author_w_date).to eq('corp_author_code')
      end
    end # marcrelator role Author

    it "is a String" do
      smods_rec.from_str(mods_start + personal_author_text + corp_creator_text + mods_end)
      expect(smods_rec.main_author_w_date).to be_an_instance_of(String)
    end

    it "takes first name with marcrelator role of 'Creator' or 'Author'" do
      smods_rec.from_str(mods_start + personal_author_text + corp_creator_text + mods_end)
      expect(smods_rec.main_author_w_date).to eq('personal_author_text')
      smods_rec.from_str(mods_start + corp_creator_text + personal_creator_code + mods_end)
      expect(smods_rec.main_author_w_date).to eq('corp_creator_text')
    end

    it "takes the first name without a role if there are no instances of marcrelator role 'Creator' or 'Actor'" do
      smods_rec.from_str(mods_start + plain_author_non_mr + personal_other_role + personal_no_role + plain_no_role + mods_end)
      expect(smods_rec.main_author_w_date).to eq('personal_no_role')
    end

    it "nil if there is no name with marcrelator role of 'Creator' or 'Author' and no name without a role" do
      smods_rec.from_str(mods_start + plain_author_non_mr + personal_other_role + mods_end)
      expect(smods_rec.main_author_w_date).to be_nil
    end

    it "uses the display name if it is present" do
      m = "<mods xmlns=\"#{Mods::MODS_NS}\">
            <name type='personal'>
              <namePart type='given'>John</namePart>
              <namePart type='family'>Huston</namePart>
              <displayForm>q</displayForm>
            </name>
            <name type='personal'><namePart>Crusty The Clown</namePart></name>
            <name type='corporate'><namePart>Watchful Eye</namePart></name>
            <name type='corporate'>
              <namePart>Exciting Prints</namePart>
              <role><roleTerm type='text'>lithographer</roleTerm></role>
            </name>
          </mods>"
      smods_rec.from_str(m)
      expect(smods_rec.main_author_w_date).to eq('q')
    end
    it "includes dates, when available" do
      m = "<mods xmlns=\"#{Mods::MODS_NS}\">
            <name type='personal'>
              <namePart>personal</namePart>
              <namePart type='date'>1984-</namePart>
            </name>
          </mods>"
      smods_rec.from_str(m)
      expect(smods_rec.main_author_w_date).to eq('personal, 1984-')
      m = "<mods xmlns=\"#{Mods::MODS_NS}\">
            <name>
              <namePart>plain</namePart>
              <namePart type='date'>1954-</namePart>
            </name>
          </mods>"
      smods_rec.from_str(m)
      expect(smods_rec.main_author_w_date).to eq('plain, 1954-')
      m = "<mods xmlns=\"#{Mods::MODS_NS}\">
            <name type='corporate'>
              <namePart>corporate</namePart>
              <namePart type='date'>1990-</namePart>
            </name>
          </mods>"
      smods_rec.from_str(m)
      expect(smods_rec.main_author_w_date).to eq('corporate, 1990-')
    end
  end # main_author_w_date

  context "additional_authors_w_dates" do
    let(:addl_authors) do
      m = "<mods xmlns=\"#{Mods::MODS_NS}\">
            <name type='personal'>
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
              <role><roleTerm type='text'>lithographer</roleTerm></role>
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
      smods_rec.from_str(m)
      smods_rec.additional_authors_w_dates
    end
    it "is an Array of Strings" do
      expect(addl_authors).to be_an_instance_of(Array)
      expect(addl_authors.first).to be_an_instance_of(String)
    end
    it "does not include main author" do
      expect(addl_authors).not_to include(smods_rec.main_author_w_date)
    end
    it "includes personal authors that are not main author" do
      expect(addl_authors).to include('Crusty The Clown, 1990-')
    end
    it "includes corporate (and other) authors that are not main author" do
      expect(addl_authors).to include('Watchful Eye, 1850-')
      expect(addl_authors).to include('Exciting Prints')
    end
    it "includes plain authors" do
      expect(addl_authors).to include('plain')
    end
    it "includes conference and other typed authors" do
      expect(addl_authors).to include('conference')
      expect(addl_authors).to include('family')
    end
    it "includes dates, when available" do
      expect(addl_authors).to include('Crusty The Clown, 1990-')
      expect(addl_authors).to include('Watchful Eye, 1850-')
    end
    it "does not include roles" do
      expect(addl_authors.find { |a| a =~ Regexp.new('lithographer') }).to be_nil
    end
  end # additional_authors_w_dates

  context '#non_collector_person_authors' do
    let(:name) { 'Hermione Grainger' }
    let(:name2) { 'Ron Weasley' }
    context 'has personal names that are not collectors' do
      it 'only non-collector persons' do
        name_snippet =
          <<-EOF
            <name type="personal">
              <namePart>#{name}</namePart>
              <role>
                <roleTerm type="code" authority="marcrelator">cre</roleTerm>
              </role>
            </name>
            <name type="personal">
              <namePart>#{name2}</namePart>
              <role>
                <roleTerm type="code" authority="marcrelator">con</roleTerm>
              </role>
            </name>
          EOF
        smods_rec.from_str(mods_start + name_snippet + mods_end)
        expect(smods_rec.non_collector_person_authors).to include(name, name2)
      end
      it 'some collectors, some non-collectors' do
        name_snippet =
          <<-EOF
            <name type="personal">
              <namePart>#{name}</namePart>
              <role>
                <roleTerm type="code" authority="marcrelator">cre</roleTerm>
              </role>
            </name>
            <name type="personal">
              <namePart>#{name2}</namePart>
              <role>
                <roleTerm type="code" authority="marcrelator">col</roleTerm>
              </role>
            </name>
          EOF
        smods_rec.from_str(mods_start + name_snippet + mods_end)
        expect(smods_rec.non_collector_person_authors).to eq [name]
      end
    end
    it 'nil if only collectors' do
      name_snippet =
        <<-EOF
          <name type="personal">
            <namePart>#{name}</namePart>
            <role>
              <roleTerm type="code" authority="marcrelator">col</roleTerm>
            </role>
          </name>
          <name type="personal">
            <namePart>Ron Weasley</namePart>
            <role>
              <roleTerm type="code" authority="marcrelator">col</roleTerm>
            </role>
          </name>
        EOF
      smods_rec.from_str(mods_start + name_snippet + mods_end)
      expect(smods_rec.non_collector_person_authors).to eq nil
    end
    it 'no role present' do
      name_snippet =
        <<-EOF
          <name type="personal" usage="primary">
            <namePart>#{name}</namePart>
          </name>
        EOF
      smods_rec.from_str(mods_start + name_snippet + mods_end)
      expect(smods_rec.non_collector_person_authors).to eq nil
    end
  end

  context '#collectors_w_dates' do
    let(:collector_name) { 'Dr. Seuss' }
    context 'valueURI for roleTerm' do
      it 'roleTerm has value' do
        name_snippet =
          <<-EOF
            <name type="personal">
              <namePart>#{collector_name}</namePart>
              <role>
                <roleTerm type="text" authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/col">Collector</roleTerm>
              </role>
            </name>
          EOF
        smods_rec.from_str(mods_start + name_snippet + mods_end)
        expect(smods_rec.collectors_w_dates).to eq [collector_name]
      end
      it 'empty roleTerm' do
        name_snippet =
          <<-EOF
            <name type="personal">
              <namePart>#{collector_name}</namePart>
              <role>
                <roleTerm authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators" valueURI="http://id.loc.gov/vocabulary/relators/col" />
              </role>
            </name>
          EOF
        smods_rec.from_str(mods_start + name_snippet + mods_end)
        expect(smods_rec.collectors_w_dates).to eq [collector_name]
      end
    end
    context 'no valueURI for roleTerm' do
      it 'collector marc relator code' do
        name_snippet =
          <<-EOF
            <name type="personal">
              <namePart>#{collector_name}</namePart>
              <role>
                <roleTerm type="code" authority="marcrelator">col</roleTerm>
              </role>
            </name>
          EOF
        smods_rec.from_str(mods_start + name_snippet + mods_end)
        expect(smods_rec.collectors_w_dates).to eq [collector_name]
      end
      it 'collector marc relator text' do
        name_snippet =
          <<-EOF
            <name type="personal">
              <namePart>#{collector_name}</namePart>
              <role>
                <roleTerm type="text" authority="marcrelator">Collector</roleTerm>
              </role>
            </name>
          EOF
        smods_rec.from_str(mods_start + name_snippet + mods_end)
        expect(smods_rec.collectors_w_dates).to eq [collector_name]
      end
    end
    it 'does not include non-collectors' do
      name_snippet =
        <<-EOF
          <name type="personal">
            <namePart>#{collector_name}</namePart>
            <role>
              <roleTerm type="text" authority="marcrelator">Collector</roleTerm>
            </role>
          </name>
          <name type="personal">
            <namePart>Freddy</namePart>
            <role>
              <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
            </role>
          </name>
        EOF
      smods_rec.from_str(mods_start + name_snippet + mods_end)
      expect(smods_rec.collectors_w_dates).to eq [collector_name]
    end
    it 'multiple collectors' do
      addl_name = 'Feigenbaum, Edward A.'
      name_snippet =
        <<-EOF
          <name type="personal">
            <namePart>#{collector_name}</namePart>
            <role>
              <roleTerm type="text" authority="marcrelator">Collector</roleTerm>
            </role>
          </name>
          <name type="personal">
            <namePart>#{addl_name}</namePart>
            <role>
              <roleTerm type='code' authority='marcrelator'>col</roleTerm>
            </role>
          </name>
        EOF
      smods_rec.from_str(mods_start + name_snippet + mods_end)
      expect(smods_rec.collectors_w_dates).to include(collector_name, addl_name)
    end
    it 'nil if no collectors' do
      name_snippet =
        <<-EOF
          <name type="personal">
            <namePart>Freddy</namePart>
            <role>
              <roleTerm type='code' authority='marcrelator'>cre</roleTerm>
            </role>
          </name>
        EOF
      smods_rec.from_str(mods_start + name_snippet + mods_end)
      expect(smods_rec.collectors_w_dates).to eq nil
    end
    it 'no role present' do
      name_snippet =
        <<-EOF
          <name type="personal" usage="primary">
            <namePart>Nobody</namePart>
          </name>
        EOF
      smods_rec.from_str(mods_start + name_snippet + mods_end)
      expect(smods_rec.collectors_w_dates).to eq nil
    end
  end
end
