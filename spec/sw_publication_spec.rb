describe "SearchWorks Publication methods" do
  let(:smods_rec) { Stanford::Mods::Record.new }

  context '#imprint_display' do
    require 'fixtures/searchworks_imprint_data'
    SEARCHWORKS_IMPRINT_DATA.each_pair.each do |coll_name, coll_data|
      coll_data.each_pair do |mods_str, expected|
        it "#{expected} for rec in #{coll_name}" do
          smods_rec.from_str(mods_str)
          expect(smods_rec.imprint_display_str).to eq expected
        end
      end
    end
  end
end
