# require 'spec_helper'
# not using spec_helper here: testing require
require 'stanford-mods/searchworks'

describe 'Basic construction' do
  before(:each) do
    @dsxml =<<-EOF
      <mods xmlns="http://www.loc.gov/mods/v3"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3"
        xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
        <titleInfo>
          <title>Electronic Theses and Dissertations</title>
        </titleInfo>
        <abstract>Abstract contents.</abstract>
        <name type="corporate">
          <namePart>Stanford University Libraries, Stanford Digital Repository</namePart>
          <role>
            <roleTerm authority="marcrelator" type="text">creator</roleTerm>
          </role>
        </name>
        <typeOfResource collection="yes"/>
        <language>
          <languageTerm authority="iso639-2b" type="code">eng</languageTerm>
        </language>
        <subject>
          <geographic>First Place</geographic>
          <geographic>Other Place, Nation;</geographic>
          <temporal>1890-1910</temporal>
          <temporal>20th century</temporal>
          <topic>Topic1: Boring Part</topic>
        </subject>
        <subject><temporal>another</temporal></subject>
        <genre>first</genre>
        <genre>second</genre>
        <subject><topic>Topic2: The Interesting Part!</topic></subject>
      </mods>
    EOF
  end

  describe "from_str" do
    it "should work" do
      m = Stanford::Mods::Record.new
      expect(m).not_to be_nil
      m.from_str(@dsxml)
      expect(m).not_to be_nil
    end
  end
end

