require 'spec_helper'

describe "name/author concepts" do
  
  context "main_author" do
    before(:all) do
      @smods_rec = Stanford::Mods::Record.new
      @ns_decl = "xmlns='#{Mods::MODS_NS}'"
      @mods_start = "<mods #{@ns_decl}>"
      @mods_end = "</mods>"
      @plain_no_role = "<name><namePart>plain_no_role</namePart></name>"
      @plain_creator_code = "<name>
                                <namePart>plain_creator_code</namePart>
                                <role><roleTerm type='code' authority='marcrelator'>cre</roleTerm></role>
                            </name>"
      @plain_creator_text = "<name>
                                <namePart>plain_creator_text</namePart>
                                <role><roleTerm type='text' authority='marcrelator'>Creator</roleTerm></role>
                            </name>"
      @plain_creator_non_mr = "<name>
                                <namePart>plain_creator_non_mr</namePart>
                                <role><roleTerm type='text'>Creator</roleTerm></role>
                            </name>"
      @plain_author_code = "<name>
                                <namePart>plain_author_code</namePart>
                                <role><roleTerm type='code' authority='marcrelator'>aut</roleTerm></role>
                            </name>"
      @plain_author_text = "<name>
                                <namePart>plain_author_text</namePart>
                                <role><roleTerm type='text' authority='marcrelator'>Author</roleTerm></role>
                            </name>"
      @plain_author_non_mr = "<name>
                                <namePart>plain_author_non_mr</namePart>
                                <role><roleTerm type='text'>Author</roleTerm></role>
                            </name>"
      @plain_other_role_mr = "<name>
                                <namePart>plain_other_role_mr</namePart>
                                <role><roleTerm type='text' authority='marcrelator'>Actor</roleTerm></role>
                            </name>"
                            
      @personal_no_role = "<name><namePart type='personal'>personal_no_role</namePart></name>"
      @personal_creator_code = "<name>
                                    <namePart type='personal'>personal_creator_code</namePart>
                                    <role><roleTerm type='code' authority='marcrelator'>cre</roleTerm></role>
                                </name>"
      @personal_author_text = "<name>
                                    <namePart type='personal'>personal_author_text</namePart>
                                    <role><roleTerm type='text' authority='marcrelator'>Author</roleTerm></role>
                                </name>"
      @personal_other_role = "<name>
                                  <namePart type='personal'>personal_author_text</namePart>
                                  <role><roleTerm type='text' authority='marcrelator'>Auctioneer</roleTerm></role>
                              </name>"
      @corp_no_role = "<name><namePart type='corporate'>corp_no_role</namePart></name>"
      @corp_author_code = "<name>
                                <namePart type='corporate'>corp_author_code</namePart>
                                <role><roleTerm type='code' authority='marcrelator'>aut</roleTerm></role>
                            </name>"
      @corp_creator_text = "<name>
                                <namePart type='corporate'>corp_creator_text</namePart>
                                <role><roleTerm type='text' authority='marcrelator'>Creator</roleTerm></role>
                            </name>"
      @other_no_role = "<name><namePart type='conference'>conference_no_role</namePart></name>"
    end
    context "marcrelator role Creator" do
      it "should find role with roleTerm type text" do
        @smods_rec.from_str(@mods_start + @plain_creator_text + @mods_end)
        @smods_rec.main_author.should == 'plain_creator_text'
      end
      it "should find role with roleTerm type code" do
        @smods_rec.from_str(@mods_start + @plain_creator_code + @mods_end)
        @smods_rec.main_author.should == 'plain_creator_code'
      end
      it "should skip names when role isn't marcrelator authority" do
        @smods_rec.from_str(@mods_start + @plain_creator_non_mr + @mods_end)
        @smods_rec.main_author.should == nil
      end
      it "should skip names without roles in favor of marcrelator role of 'Creator'" do
        @smods_rec.from_str(@mods_start + @personal_no_role + @plain_creator_text + @other_no_role + @mods_end)
        @smods_rec.main_author.should == 'plain_creator_text'
        @smods_rec.from_str(@mods_start + @corp_no_role + @plain_creator_code + @mods_end)
        @smods_rec.main_author.should == 'plain_creator_code'
      end
      it "shouldn't care about name type" do
        @smods_rec.from_str(@mods_start + @personal_creator_code + @corp_creator_text + @mods_end)
        @smods_rec.main_author.should == 'personal_creator_code'
        @smods_rec.from_str(@mods_start + @personal_no_role + @corp_creator_text + @mods_end)
        @smods_rec.main_author.should == 'corp_creator_text'
      end
    end
    
    context "marcrelator role Author" do
      it "should find role with roleTerm type text" do
        @smods_rec.from_str(@mods_start + @plain_author_text + @mods_end)
        @smods_rec.main_author.should == 'plain_author_text'
      end
      it "should find role with roleTerm type code" do
        @smods_rec.from_str(@mods_start + @plain_author_code + @mods_end)
        @smods_rec.main_author.should == 'plain_author_code'
      end
      it "should skip names when role isn't marcrelator authority" do
        @smods_rec.from_str(@mods_start + @plain_author_non_mr + @mods_end)
        @smods_rec.main_author.should == nil
      end
      it "should skip names without roles in favor of marcrelator role of 'Author'" do
        @smods_rec.from_str(@mods_start + @personal_no_role + @plain_author_text + @other_no_role + @mods_end)
        @smods_rec.main_author.should == 'plain_author_text'
        @smods_rec.from_str(@mods_start + @corp_no_role + @personal_no_role + @plain_author_code + @mods_end)
        @smods_rec.main_author.should == 'plain_author_code'
      end
      it "shouldn't care about name type" do
        @smods_rec.from_str(@mods_start + @personal_author_text + @corp_author_code + @mods_end)
        @smods_rec.main_author.should == 'personal_author_text'
        @smods_rec.from_str(@mods_start + @personal_no_role + @corp_author_code + @mods_end)
        @smods_rec.main_author.should == 'corp_author_code'
      end
    end
    
    it "should take first name with marcrelator role of 'Creator' or 'Author'" do
      @smods_rec.from_str(@mods_start + @personal_author_text + @corp_creator_text + @mods_end)
      @smods_rec.main_author.should == 'personal_author_text'
      @smods_rec.from_str(@mods_start + @corp_creator_text + @personal_author_code + @mods_end)
      @smods_rec.main_author.should == 'corp_creator_text'
    end
    
    it "should take the first name without a role if there are no instances of marcrelator role 'Creator' or 'Actor'" do
      @smods_rec.from_str(@mods_start + @plain_author_non_mr + @personal_other_role + @personal_no_role + @plain_no_role + @mods_end)
      @smods_rec.main_author.should == 'personal_no_role'
    end
    
    it "should be nil if there is no name with marcrelator role of 'Creator' or 'Author' and no name without a role" do
      @smods_rec.from_str(@mods_start + @plain_author_non_mr + @personal_other_role + @mods_end)
      @smods_rec.main_author.should == nil
    end

    it "should use the dislay name if it is present" do
      m = "<mods><name type='personal'>
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
      @smods_rec.from_str(m)
      @smods_rec.main_author.should == 'q'
    end
  end # main_author

  it "additional_authors" do
    pending "to be implemented"
  end
  context "author_sort" do
    it "should be a single value" do
      pending "to be implemented"
    end
    it "should be last name first if its a personal name" do
      pending "to be implemented"
    end
    it "should ignore non-sorting characters" do
      pending "to be implemented"
    end
  end
  
end