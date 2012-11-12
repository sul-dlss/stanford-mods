# key: method name
# value:  xpath
name_to_xpath = {
  # are we deliberately seeking nested values, or just incidentally?
  # some string, some array
  # some return nil if missing -- do all?

# TOP_LEVEL_SIMPLE
  'abstract' => '//abstract/text()', # .to_s
  'access_condition' => '//accessCondition/text()',  # .to_s
  'genre' => '//genre/text()', #.to_s as array
  'type_of_resource' => '//typeOfResource/text()', # .to_s

# name
  'corporate_authors' => '//mods/name[@type="corporate"]', # .ea .xpath('namePart').collect{ |a| a.text }.join(' ') 
  'personal_authors' => '//mods/name[@type="personal"]', # .ea .xpath('namePart').collect{ |a| a.text }.join(' ') 

# titleInfo
  'title' => '//mods/titleInfo[not(@type="alternative")]', # .first, extract_title_from_title_info(node)
  'subtitle' => '//mods/titleInfo/subTitle' #.first.text
  'full_title' => '//mods/titleInfo', # .first, extract_full_title_from_title_info(node)
  'title_variant' => '//mods/titleInfo[@type="alternative"]', # .first, extract_title_from_title_info(node)

# language
  'language_codes' => "//language/languageTerm[@authority='iso639-2b'][@type='code']/text()", 
  'language_words' => "//language/languageTerm[@type='text']/text()|//language/text()", 

# physicalDescription
  'physical_description_extent' => '//physicalDescription/extent/text()', # .to_s
  'physical_description_form' => '//physicalDescription/form/text()', # .to_s
  'physical_description_media_type' => '//physicalDescription/internetMediaType/text()', # .to_s

# location
  'physical_location' => '//location/physicalLocation/text()', # .to_s
  'location_url' => '//location/url/text()', # .to_s

# relatedItem
  'relateditem_location_url' => '//relatedItem/location/url/text()', # .to_s
  'relateditem_title' => '//relatedItem/titleInfo/title/text()', # .to_s

# originInfo
  'create_start_date' => '//originInfo/dateCreated[@point="start"]/text()', #.to_s  - comes from passed node, not root
  'create_end_date' => '//originInfo/dateCreated[@point="end"]/text()', #.to_s  - comes from passed node, not root
  'date_issued' => '//originInfo/dateIssued/text()', #.to_s  - comes from passed node, not root
  'place_terms' => '//originInfo/place/placeTerm/text()', # .to_s  put in array, then .flatten.uniq
  'publishers' => '//originInfo/publisher/text()', # .to_s  put in array, then .flatten.uniq
  # pub_date / pub_year

# subject
  'subject_names' => '//subject/name', # .ea .xpath('namePart/text().to_a.join(' ')  then .uniq
  'subject_topics' => '//subject/topic/text()', # .ea .to_s  as array then .uniq
  'subject_geographic' => '//subject/geographic/text()', # .ea .to_s  as array then .uniq
  'subject_temporal' => '//subject/temporal/text()', # .ea .to_s  as array then .uniq
  #  # TODO: subject/temporal can be either a string or an iso8601 date
  # At some point we may need to handle date parsing here, but as a first
  # pass, just assume everything is a string
  # if mt.xpath('@encoding="iso8601"')
  #   begin
  #     d = DateTime.iso8601(mt.xpath('text()').to_s)
  #   rescue
  #     puts "#{mt.xpath('text()').to_s} is not a valid iso8601 date"
  #   end
  # else
  'subject_title_info' => '//subject/titleInfo', # .ea  extract_full_title_from_title_info(node), then .flatten.uniq
  
  'fulltext' => '//text()', #  .collect { |n| n.to_s }.join(' ')
  
  # TODO:  simple element variants:
  # 
  # genre authority
  # accessCondition type
  # note displayLabel
  # MISSING:
  #   date_created
  
  # TODO:  collections
  
}

