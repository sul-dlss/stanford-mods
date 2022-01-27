# encoding: UTF-8
describe "Date methods (searchworks.rb)" do
  let(:ns_decl) { "xmlns='#{Mods::MODS_NS}'" }
  let(:smods_rec) { Stanford::Mods::Record.new }

  # NOTE: walters dates are now:
  # dateIssued:  1500 CE
  # dateIssued:  15th century CE
  # dateIssued:  Ca. 1580 CE
  # or
  # dateCreated:  4 digit year
  #   and they should go in spec/fixtures searchworks_pub_date_data.rb
end
