# encoding: utf-8
describe "Cartographic coordinates" do
  let(:smods_rec) { Stanford::Mods::Record.new }
  let(:no_coord)  do
    <<-EOF
      <mods xmlns="#{Mods::MODS_NS}">
        <subject>
          <cartographics>
          <scale>Scale 1:500,000</scale>
          <coordinates></coordinates>
          </cartographics>
        </subject>
      </mods>
    EOF
  end
  let(:with_coords) do
    <<-EOF
      <mods xmlns="#{Mods::MODS_NS}">
        <subject>
          <cartographics>
          <scale>Scale 1:500,000</scale>
          <coordinates>(W16°--E28°/N13°--S15°).</coordinates>
          </cartographics>
        </subject>
      </mods>
    EOF
  end
  let(:with_bad_data) do
    <<-EOF
      <mods xmlns="#{Mods::MODS_NS}">
        <subject>
          <cartographics>
          <scale>Scale 1:500,000</scale>
          <coordinates>(Unknown).</coordinates>
          </cartographics>
        </subject>
      </mods>
    EOF
  end

  context "coordinates" do
    it "returns empty array if no coordinates in the mods" do
      smods_rec.from_str(no_coord)
      expect(smods_rec.coordinates).to eq([""])
    end
    it "returns decimal representation of latitude and longitude" do
      smods_rec.from_str(with_coords)
      expect(smods_rec.coordinates).to eq(["(W16°--E28°/N13°--S15°)."])
    end
  end

  describe "#coordinates_as_bbox" do
    it "returns empty array if no coordinates in the mods" do
      smods_rec.from_str(no_coord)
      expect(smods_rec.point_bbox).to eq([])
    end
    it "returns empty array if bad data is in the mods" do
      smods_rec.from_str(with_bad_data)
      expect(smods_rec.point_bbox).to eq([])
    end
    it "returns decimal representation of latitude and longitude" do
      smods_rec.from_str(with_coords)
      expect(smods_rec.point_bbox).to eq(["-16.0 -15.0 28.0 13.0"])
    end
  end

  describe "#coordinates_as_envelope" do
    it "returns empty array if no coordinates in the mods" do
      smods_rec.from_str(no_coord)
      expect(smods_rec.coordinates_as_envelope).to eq([])
    end
    it "returns empty array if bad data is in the mods" do
      smods_rec.from_str(with_bad_data)
      expect(smods_rec.coordinates_as_envelope).to eq([])
    end
    it "returns decimal representation of latitude and longitude" do
      smods_rec.from_str(with_coords)
      expect(smods_rec.coordinates_as_envelope).to eq(["ENVELOPE(-16.0, 28.0, 13.0, -15.0)"])
    end
  end
end # describe Cartographic coordinates

describe '#geo_extension_as_envelope' do
  let(:modsbody) { '' }
  let(:mods) do
    rec = Stanford::Mods::Record.new
    rec.from_str %(<mods xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://www.loc.gov/mods/v3" version="3.5"
      xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">#{modsbody}</mods>)
    rec
  end

  it 'without data, returns emtpy array' do
    expect(mods.geo_extensions_as_envelope).to eq []
  end

  describe 'with geo extension bounding-box data' do
    let(:modsbody) do
      <<-EOF
        <extension displayLabel="geo">
          <rdf:RDF xmlns:gml="http://www.opengis.net/gml/3.2/" xmlns:dc="http://purl.org/dc/elements/1.1/">
            <rdf:Description rdf:about="http://purl.stanford.edu/cw222pt0426">
            <dc:format>image/jpeg</dc:format>
            <dc:type>Image</dc:type>
            <gml:boundedBy>
              <gml:Envelope>
                <gml:lowerCorner>-122.191292 37.4063388</gml:lowerCorner>
                <gml:upperCorner>-122.149475 37.4435369</gml:upperCorner>
              </gml:Envelope>
            </gml:boundedBy>
            </rdf:Description>
          </rdf:RDF>
        </extension>
      EOF
    end

    it 'returns an empty array' do
      allow(mods.mods_ng_xml).to receive(:extension).and_raise(RuntimeError)
      expect(mods.geo_extensions_as_envelope).to eq []
    end

    it 'extract envelope strings' do
      expect(mods.geo_extensions_as_envelope).to eq ["ENVELOPE(-122.191292, -122.149475, 37.4435369, 37.4063388)"]
    end
  end

  describe 'with geo-extension point data' do
    let(:modsbody) do
      <<-EOF
        <extension displayLabel="geo">
          <rdf:RDF xmlns:gml="http://www.opengis.net/gml/3.2/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:gmd="http://www.isotc211.org/2005/gmd">
            <rdf:Description rdf:about="http://www.stanford.edu/cm896kp1291">
              <dc:format>image/jpeg</dc:format>
              <dc:type>Image</dc:type>
              <gmd:centerPoint>
                <gml:Point gml:id="ID">
                  <gml:pos>41.8898687280593 12.4913412520789</gml:pos>
                </gml:Point>
              </gmd:centerPoint>
            </rdf:Description>
          </rdf:RDF>
        </extension>
      EOF
    end

    it 'extract point strings' do
      expect(mods.geo_extensions_point_data).to eq ["12.4913412520789 41.8898687280593"]
    end
  end
end
