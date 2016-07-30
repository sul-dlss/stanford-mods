describe "SearchWorks Publication methods" do
  let(:smods_rec) { Stanford::Mods::Record.new }
  RSpec.shared_examples "pub year" do |method_sym, exp_val_position|
    context 'searchworks actual data' do
      require 'fixtures/searchworks_pub_date_data'
      SEARCHWORKS_PUB_DATE_DATA.each_pair.each do |coll_name, coll_data|
        coll_data.each_pair do |mods_str, exp_vals|
          expected = exp_vals[exp_val_position]
          # TODO:  pub_year_display_str doesn't cope with date ranges yet
          expected = expected.split(' - ')[0] if method_sym == :pub_year_display_str && expected
          it "#{expected} for rec in #{coll_name}" do
            smods_rec.from_str(mods_str)
            expect(smods_rec.send(method_sym)).to eq expected
          end
        end
      end
    end
  end

  context '#pub_year_int' do
    it_behaves_like "pub year", :pub_year_int, 0
  end

  context '#pub_year_display_str' do
    it_behaves_like "pub year", :pub_year_display_str, 1
  end

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
