require 'spec_helper'

describe "computations from /originInfo field" do

  let(:smods_rec) { Stanford::Mods::Record.new }

  context '#get_u_year' do
    it "turns ending u to 0" do
      expect(smods_rec.send(:get_u_year, ["201u"])).to eql "2010"
      expect(smods_rec.send(:get_u_year, ["198u"])).to eql "1980"
      expect(smods_rec.send(:get_u_year, ["185u"])).to eql "1850"
    end
    it "turns ending uu to --" do
      expect(smods_rec.send(:get_u_year, ["19uu"])).to eql "19--"
      expect(smods_rec.send(:get_u_year, ["17uu"])).to eql "17--"
    end
    it 'ignores 9999' do
      expect(smods_rec.send(:get_u_year, ["9999"])).to be_nil
    end
  end
end