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
