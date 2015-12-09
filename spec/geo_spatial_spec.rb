# encoding: utf-8
require 'spec_helper'

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
  let(:with_coords)  do
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

  context "point_bbox" do
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

    {
      %((W 123°23ʹ16ʺ--W 122°31ʹ22ʺ/N 39°23ʹ57ʺ--N 38°17ʹ53ʺ)) =>
        ['-123.38777777777779 38.29805555555556 -122.52277777777778 39.399166666666666'],
      %(E 10°03'00"--E 12°58'00"/N 45°00'00"--N 41°46'00") =>
        ['10.05 41.766666666666666 12.966666666666667 45.0'],
      %(W80°--E100°/N487°--S42°) =>
        [], # N487 is out of bounds for the bounding box
      %(W 650--W 100/N 700--N 550) =>
        [] # missing degree character, and all coordinates are out of bounds.
    }.each do |value, expected|
      describe 'data mappings' do
        let(:mods) do
          <<-EOF
            <mods xmlns="#{Mods::MODS_NS}">
              <subject>
                <cartographics>
                  <coordinates>#{value}</coordinates>
                </cartographics>
              </subject>
            </mods>
          EOF
        end

        let(:smods_rec) { Stanford::Mods::Record.new.from_str(mods) }

        it 'maps to the right bounding box' do
          expect(smods_rec.point_bbox).to eq expected
        end
      end
    end
  end
end # describe Cartographic coordinates
