# encoding: utf-8
# fixture data from real MODS from prod purl pages for data in or soon to be in prod SearchWorks

mods_origin_info_start_str = "<mods xmlns=\"#{Mods::MODS_NS}\"><originInfo>"
mods_origin_info_end_str = '</originInfo></mods>'

# structure for imprint is:  Edition. - Place : Publisher, Date

SEARCHWORKS_IMPRINT_DATA = {
  'batchelor' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # ct961sj2730 coll rec:
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">cau</placeTerm>
        </place>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California',
      # dr330jt7122
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">gw</placeTerm>
        </place>
        <dateIssued>1843</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Germany, 1843',
      # wr055hy7401
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">gw</placeTerm>
        </place>
        <place>
          <placeTerm type="text">Gotha</placeTerm>
        </place>
        <publisher>Perthes</publisher>
        <dateIssued>[1881]</dateIssued>
        <dateIssued encoding="marc">1881</dateIssued>
        <edition>Rev. 1882</edition>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Rev. 1882 - Gotha : Perthes, [1881]',
      # wr055hy7401
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">enk</placeTerm>
        </place>
        <place>
          <placeTerm type="text">London</placeTerm>
        </place>
        <publisher>G. Philip and Son</publisher>
        <dateIssued>1885</dateIssued>
        <edition>3rd ed.</edition>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '3rd ed. - London : G. Philip and Son, 1885',
      # ww960jk4650
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">ne</placeTerm>
        </place>
        <place>
          <placeTerm type="text">Amstelodami</placeTerm>
        </place>
        <publisher>[s.n.</publisher>
        <dateIssued>167-?]</dateIssued>
        <dateIssued encoding="marc" point="start" qualifier="questionable">1670</dateIssued>
        <dateIssued encoding="marc" point="end" qualifier="questionable">1680</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Amstelodami : [s.n. 167-?]',
      # ct011mf9794
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">fr</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[Paris</placeTerm>
        </place>
        <publisher>s.n.</publisher>
        <dateIssued>17--]</dateIssued>
        <dateIssued encoding="marc">17uu</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[Paris : s.n. 17--]',
      # mm076bz8960
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">enk</placeTerm>
        </place>
        <place>
          <placeTerm type="text">London</placeTerm>
        </place>
        <publisher>Orr and Compy</publisher>
        <dateIssued>[ca. 1850?]</dateIssued>
        <dateIssued encoding="marc">185u</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'London : Orr and Compy, [ca. 1850?]',
      # vs807zh4960
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">xx</placeTerm>
        </place>
        <place>
          <placeTerm type="text">London: John Murray</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[S.l.]</placeTerm>
        </place>
        <publisher>[s.n.]</publisher>
        <dateIssued>[s.d.]</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'London: John Murray : [S.l.] : [s.n.], [s.d.]',
      # nr266xf1214
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">[S.l</placeTerm>
        </place>
        <publisher>s.n.</publisher>
        <dateIssued>ca. 1740-1800]</dateIssued>
        <dateIssued encoding="marc" point="start">1740</dateIssued>
        <dateIssued encoding="marc" point="end">1800</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[S.l : s.n. ca. 1740-1800]',
      # gy889yj2171
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">xx</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[S.l</placeTerm>
        </place>
        <publisher>s.n.</publisher>
        <dateIssued>1758]</dateIssued>
        <dateIssued encoding="marc" point="start" qualifier="questionable">1758</dateIssued>
        <dateIssued encoding="marc" point="end" qualifier="questionable">uuuu</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[S.l : s.n. 1758]'
    },
  # afro_am_music
  # ai
  # athletics intervies
  # amica
  # anthro
  # antiphonary.yml
  # baker
  # batchelor
  # big_idea
  # bio_ugrad_2014
  # bio_ugrad_2015
  # blume
  # carpentry
  # cfb  ???
  # cisac
  # city_nature
  # coll_barg
  # commencement
  # conservation
  # ccrma
  'dennis' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec  sg213ph2100 goes to marc 6780453
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">cau</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start">1850</dateIssued>
        <dateIssued encoding="marc" point="end">1906</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California, 1850 - 1906',
      # ps072wf8793
      mods_origin_info_start_str +
        '<dateIssued encoding="w3cdtf">1851-07-01</dateIssued>' +
        mods_origin_info_end_str => 'July  1, 1851',
      # bh059ts1689
      mods_origin_info_start_str +
        '<dateIssued>early 1890s</dateIssued>' +
        mods_origin_info_end_str => 'early 1890s'
    },
  # diplomatic
  # dig_hum
  # drosophila.yml
  # ehrlich
  # english_ugrad
  # eng_physics_ugrad
  # eng_ugrad
  # estonian_kgb
  'feigenbaum' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec ms016pb9280
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">cau</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start">1950</dateIssued>
        <dateIssued encoding="marc" point="end">2007</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California, 1950 - 2007',
      # py696hw1646
        mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">2001-11-19</dateCreated>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'November 19, 2001'
    },
  # fem_ugrad
  # film_arts
  # fitch_chavez
  'fitch' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll recs have no originInfo data
      # pd835hf9652 - MLK
      mods_origin_info_start_str +
        '<place supplied="yes">
          <placeTerm valueURI="http://id.loc.gov/authorities/names/n79042167">Birmingham (Ala.)</placeTerm>
        </place>
        <dateCreated keyDate="yes" encoding="w3cdtf" point="start" qualifier="approximate">1965</dateCreated>
        <dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1966</dateCreated>' +
        mods_origin_info_end_str => 'Birmingham (Ala.), [ca. 1965 - 1966]',
      # cq153cd4213 - Panther
      mods_origin_info_start_str +
        '<place supplied="yes">
          <placeTerm authorityURI="http://id.loc.gov/authorities/names" valueURI="http://id.loc.gov/authorities/names/n79118971">Oakland (Calif.)</placeTerm>
        </place>
        <dateCreated keyDate="yes" encoding="w3cdtf">1972-03-30</dateCreated>' +
        mods_origin_info_end_str => 'Oakland (Calif.), March 30, 1972',
      # rr577nj0391 - Alejo
      mods_origin_info_start_str +
        '<place supplied="yes">
          <placeTerm valueURI="http://id.loc.gov/authorities/names/n81080010">Salinas (Calif.)</placeTerm>
        </place>
        <dateCreated keyDate="yes" encoding="w3cdtf">2010-09</dateCreated>' +
        mods_origin_info_end_str => 'Salinas (Calif.), September 2010'
    },
  'fitch-mud' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec vr013gg9930  no originInfo
      # vd865fk6168
      mods_origin_info_start_str +
        '<place supplied="yes">
          <placeTerm authorityURI="http://id.loc.gov/authorities/names" valueURI="http://id.loc.gov/authorities/names/n79118971">Oakland (Calif.)</placeTerm>
          </place>
          <dateCreated keyDate="yes" encoding="w3cdtf">1967</dateCreated>' +
        mods_origin_info_end_str => 'Oakland (Calif.), 1967',
      # xr458wf5634
      mods_origin_info_start_str +
        '<place supplied="yes">
          <placeTerm authorityURI="http://id.loc.gov/authorities/names" valueURI="http://id.loc.gov/authorities/names/n81081214">Emeryville (Calif.)</placeTerm>
        </place>
        <dateCreated keyDate="yes" encoding="w3cdtf">1971</dateCreated>' +
        mods_origin_info_end_str => 'Emeryville (Calif.), 1971'
    },
  # fitch_seeger
  # flipside
  # folding
  # fracture
  # franklin
  # frantz
  'fugitive_us_agencies' =>  # WARC files
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec mk656nf8485  has no originInfo
      # rc607cp0203
      mods_origin_info_start_str +
        '<dateCaptured encoding="iso8601" point="start" keyDate="yes">20090511065738</dateCaptured>
        <dateCaptured encoding="edtf" point="end">open</dateCaptured>
        <publisher displayLabel="Publisher">GAO</publisher>' +
        mods_origin_info_end_str => 'GAO, May 11, 2009 - open',
      # gb089bd2251
      mods_origin_info_start_str +
        '<dateCaptured encoding="iso8601" point="start" keyDate="yes">20121129060351</dateCaptured>
        <dateCaptured encoding="edtf" point="end">open</dateCaptured>
        <frequency>Semiannual</frequency>
        <publisher displayLabel="Publisher">Cranfield University</publisher>' +
        mods_origin_info_end_str => 'Cranfield University, November 29, 2012 - open'
    },
  'fuller' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec rh056sr3313
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">cau</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start" qualifier="questionable" keyDate="yes">1920</dateIssued>
        <dateIssued encoding="marc" point="end" qualifier="questionable">1983</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California, [1920 - 1983?]',
      # fz116cn2445
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Stanford, CA</placeTerm>
        </place>
        <publisher>Stanford Special Collections</publisher>
        <dateCreated encoding="w3cdtf" keyDate="yes">1977</dateCreated>' +
        mods_origin_info_end_str => 'Stanford, CA : Stanford Special Collections, 1977'
    },
  # future_sp
  # geo
  # gimon
  'gis' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec sv325bx4406
      # mods_origin_info_start_str +
      #   '<place>
      #     <placeTerm type="code" authority="marccountry">cau</placeTerm>
      #   </place>
      #   <place>
      #     <placeTerm type="text">San Diego, CA</placeTerm>
      #   </place>
      #   <publisher>Hart Energy Publishing</publisher>
      #   <dateIssued>2011</dateIssued>
      #   <dateIssued encoding="marc" point="start">2012</dateIssued>
      #   <dateIssued encoding="marc" point="end">9999</dateIssued>
      #   <issuance>monographic</issuance>' +
      #   mods_origin_info_end_str => 'San Diego, CA : Hart Energy Publishing, 2011 2012-',
      # rt625ws6022
      mods_origin_info_start_str +
        '<publisher>Hart Energy Publishing</publisher>
        <place>
          <placeTerm type="text">San Diego, California, US</placeTerm>
        </place>
        <dateIssued encoding="w3cdtf" keyDate="yes">2011</dateIssued>
        <dateValid encoding="w3cdtf">2011</dateValid>
        <edition>1007 Update</edition>' +
        mods_origin_info_end_str => '1007 Update - San Diego, California, US : Hart Energy Publishing, 2011',
      # ww217dj0457
      mods_origin_info_start_str +
        '<publisher>Hart Energy Publishing</publisher>
        <place>
          <placeTerm type="text">San Diego, California, US</placeTerm>
        </place>
        <dateIssued encoding="w3cdtf" keyDate="yes">2012</dateIssued>
        <dateValid encoding="w3cdtf">2011</dateValid>
        <edition>1007 Update</edition>' +
        mods_origin_info_end_str => '1007 Update - San Diego, California, US : Hart Energy Publishing, 2012'
    },
  # gould
  'gould' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec sp673gr4168 no originInfo
      # cm311th5760
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">gw</placeTerm>
        </place>
        <place>
          <placeTerm type="text">Francofurti</placeTerm>
        </place>
        <publisher>impressa typis Ioannis Saurii, impensis Petri Kopffi</publisher>
        <dateIssued>1599-1601</dateIssued>
        <dateIssued encoding="marc" keyDate="yes" point="start">1599</dateIssued>
        <dateIssued encoding="marc" point="end">1601</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Francofurti : impressa typis Ioannis Saurii, impensis Petri Kopffi, 1599-1601',
      # mt060jf5269
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">it</placeTerm>
        </place>
        <place>
          <placeTerm type="text">In Padoua</placeTerm>
        </place>
        <publisher>per Pietro Paolo Tozzi.</publisher>
        <dateIssued>1616: Con licenza de\'svperiori</dateIssued>
        <dateIssued encoding="marc" keyDate="yes">1616</dateIssued>
        <edition>Opera noua,</edition>
        <edition>&amp; piena di dotta curiosità.</edition>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => "Opera noua, & piena di dotta curiosità. - In Padoua : per Pietro Paolo Tozzi. 1616: Con licenza de'svperiori",
      # nh718gy4718
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">ne</placeTerm>
        </place>
        <place>
          <placeTerm type="text">La Haye</placeTerm>
        </place>
        <publisher>Chez Jean Neaulme</publisher>' +
        '<dateIssued>1743-53</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes" point="start">1743</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1753</dateIssued>' +
        mods_origin_info_end_str => 'La Haye : Chez Jean Neaulme, 1743-53',
      # nh857kn6175
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">gw</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[Bonn</placeTerm>
        </place>
        <publisher>s.n.</publisher>
        <dateIssued>18--]</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[Bonn : s.n. 18--]',
      # zp382js2355
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">enk</placeTerm>
        </place>
        <place>
          <placeTerm type="text">London</placeTerm>
        </place>
        <publisher>[s.n.]</publisher>
        <dateIssued>[184-]</dateIssued>
        <dateIssued encoding="marc" keyDate="yes">184u</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'London : [s.n.], [184-]',
      # qg377px6180
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">nyu</placeTerm>
        </place>
        <place>
          <placeTerm type="text">New York</placeTerm>
        </place>
        <publisher>Harper &amp; Brothers</publisher>
        <dateIssued>1868, c1857</dateIssued>
        <dateIssued encoding="marc" keyDate="yes">1868</dateIssued>
        <copyrightDate encoding="marc">1857</copyrightDate>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'New York : Harper & Brothers, 1868, c1857 1868 1857',
      # yp117pm9679
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">enk</placeTerm>
        </place>
        <place>
          <placeTerm type="text">London</placeTerm>
        </place>
        <publisher>M.A. Nattali</publisher>
        <dateIssued>[etc</dateIssued>
        <dateIssued>1840]</dateIssued>
        <dateIssued encoding="marc" keyDate="yes">1840</dateIssued>
        <edition>3d ed.,</edition>
        <edition>with the author\'s latest corrections ...</edition>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => "3d ed., with the author's latest corrections ... - London : M.A. Nattali, [etc 1840]",
      # yp117pm9679
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">enk</placeTerm>
        </place>
        <place>
          <placeTerm type="text">London</placeTerm>
        </place>
        <publisher>Macmillan</publisher>
        <dateIssued>1881</dateIssued>
        <dateIssued encoding="marc" keyDate="yes">1881</dateIssued>
        <edition>[1st ed.]</edition>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[1st ed.] - London : Macmillan, 1881',
      # kh431hg6450
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">enk</placeTerm>
        </place>
        <place>
          <placeTerm type="text">London</placeTerm>
        </place>
        <publisher>Printed for Baldwin, Cradock, and Joy</publisher>
        <publisher>...</publisher>
        <publisher>and R. Hunter ...</publisher>
        <dateIssued>1825</dateIssued>
        <dateIssued encoding="marc" keyDate="yes">1825</dateIssued>
        <edition>A new ed. with additions and improvements.</edition>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'A new ed. with additions and improvements. - London : Printed for Baldwin, Cradock, and Joy : ... and R. Hunter ... 1825'
    },
  # gse_comp_ed_masters
  # gse_oa
  # gse_ugrad
  # hellman
  'homebrew' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec ht445nv3709  no originInfo
      # xt205qz2409
      mods_origin_info_start_str +
        '<dateIssued encoding="w3cdtf" keyDate="yes">1978-01</dateIssued>
        <issuance>continuing</issuance>' +
        mods_origin_info_end_str => 'January 1978'
    },
  # hopkins
  # hopkins_thesis
  # human_bio_lectures
  'human-impact-marine' => # geo data
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec wy139zd0043
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">cau</placeTerm>
        </place>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California',
      # tg926kp6619
      mods_origin_info_start_str +
        '<publisher>Science</publisher>
        <place>
          <placeTerm type="text">Washington, D.C., US</placeTerm>
        </place>
        <dateIssued encoding="w3cdtf" keyDate="yes">2008</dateIssued>
        <dateValid encoding="w3cdtf">2007</dateValid>
        <dateValid encoding="w3cdtf">2008</dateValid>' +
        mods_origin_info_end_str => 'Washington, D.C., US : Science, 2008'
    },
  # hummel
  # image_proc
  # image_video_multimedia
  # jane_stanford
  # jordan
  # kant
  # kemi
  'kitai' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec rw431mw4432
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">ru</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[Moscow?]</placeTerm>
        </place>
        <publisher>Generalʹnyĭ shtab</publisher>
        <dateIssued>[1968?-</dateIssued>
        <dateIssued encoding="marc" point="start" keyDate="yes">1968</dateIssued>
        <dateIssued encoding="marc" point="end">9999</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[Moscow?] : Generalʹnyĭ shtab, [1968?- 1968-',
      # tw488bz3281
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">ru</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[Moscow?]</placeTerm>
        </place>
        <publisher>Generalʹnyĭ shtab</publisher>
        <dateIssued>[1968?-</dateIssued>
        <dateIssued encoding="marc" point="start" keyDate="yes">1968</dateIssued>
        <dateIssued encoding="marc" point="end">9999</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[Moscow?] : Generalʹnyĭ shtab, [1968?-'
    },
  # kolb has no originInfo elements
  'labor' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec wf220dz0066  merges with 421708
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">xxu</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start">1948</dateIssued>
        <dateIssued encoding="marc" point="end">9999</dateIssued>
        <issuance>serial</issuance>' +
        mods_origin_info_end_str => 'United States, 1948 -',
      # vh590xb4582
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Washington [D.C.]</placeTerm>
        </place>
        <publisher>Bureau of Labor Statistics</publisher>
        <dateIssued encoding="w3cdtf" keyDate="yes" qualifier="approximate" point="start">1948</dateIssued>
        <dateIssued encoding="w3cdtf" qualifier="approximate" point="end">1951</dateIssued>
        <issuance>continuing</issuance>' +
        mods_origin_info_end_str => 'Washington [D.C.] : Bureau of Labor Statistics, [ca. 1948 - 1951]'
    },
  # lapp_practices
  # leland_stanford
  # lgbt
  # lobell
  # masters
  # matter
  # maxfield
  'mccarthy' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec kd453rz2514
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">cau</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start">1951</dateIssued>
        <dateIssued encoding="marc" point="end">2008</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California, 1951 - 2008',
      # kr251bd1719
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">Undated</dateCreated>
        <place>
          <placeTerm type="text">Stanford (Calif.)</placeTerm>
        </place>' +
        mods_origin_info_end_str => 'Stanford (Calif.), Undated',
      # kt770bs1887
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">1978-06</dateCreated>
        <place>
          <placeTerm type="text">Stanford (Calif.)</placeTerm>
        </place>' +
        mods_origin_info_end_str => 'Stanford (Calif.), June 1978'
    },
  'mclaughlin_ca_island' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec zb871zd0767 no originInfo
      # tt437zq0720
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">ne</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[Amsterdam</placeTerm>
        </place>
        <publisher>Hugo Allard</publisher>
        <dateIssued>1640-1665?]</dateIssued>
        <dateIssued encoding="marc" point="start" qualifier="questionable">1640</dateIssued>
        <dateIssued encoding="marc" point="end" qualifier="questionable">1665</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[Amsterdam : Hugo Allard, 1640-1665?]',
      # mk758ps0914
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">it</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[Venice</placeTerm>
        </place>
        <publisher>s.n.</publisher>
        <dateIssued>1598 or 1599]</dateIssued>
        <dateIssued encoding="marc">1599</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[Venice : s.n. 1598 or 1599] 1599',
      # kn933tp3421
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">it</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[Italy?</placeTerm>
        </place>
        <publisher>s.n.</publisher>
        <dateIssued>168-?]</dateIssued>
        <dateIssued encoding="marc">168u</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[Italy? : s.n. 168-?]',
      # cm303hd3051
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">gw</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[Germany</placeTerm>
        </place>
        <publisher>s.n.</publisher>
        <dateIssued>17--?]</dateIssued>
        <dateIssued encoding="marc">17uu</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[Germany : s.n. 17--?]',
      # dv052xw4248
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">xx</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[s.l</placeTerm>
        </place>
        <publisher>:s.n., c</publisher>
        <dateIssued encoding="marc">172u</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[s.l : :s.n., c, 1720s',
      # sm817db3005
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">enk</placeTerm>
        </place>
        <place>
          <placeTerm type="text">London</placeTerm>
        </place>
        <publisher>Printed &amp; sold by R. Marshall, No. 4 Aldermay Church Yard</publisher>
        <dateIssued>[1764-1782]</dateIssued>
        <dateIssued encoding="marc" point="start" qualifier="questionable">1764</dateIssued>
        <dateIssued encoding="marc" point="end" qualifier="questionable">1782</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'London : Printed & sold by R. Marshall, No. 4 Aldermay Church Yard, [1764-1782]',
      # px053ft5911
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">1732</dateCreated>
        <dateCreated encoding="w3cdtf" keyDate="no" qualifier="questionable">1732</dateCreated>
        <place>
          <placeTerm>London</placeTerm>
        </place>' +
        mods_origin_info_end_str => 'London, [1732?]',
      # xb526qv4524
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="no" point="end" qualifier="approximate">1939</dateCreated>
        <place>
          <placeTerm>[Seoul]</placeTerm>
        </place>
        <dateCreated keyDate="yes" point="" qualifier="approximate">1930</dateCreated>' +
        mods_origin_info_end_str => '[Seoul], - [ca. 1939] [ca. 1930]'
    },
  # mclaughlin_malta
  # medieval / mss
  'mss' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec dt056jp2574  (merges with marc 4082840)
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">cau</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start" keyDate="yes">0850</dateIssued>
        <dateIssued encoding="marc" point="end">1499</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California, 850 CE - 1499',
      # coll rec  bd001pp3337
      # coll rec fn508pj9953
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">cau</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start" qualifier="questionable">1400</dateIssued>
        <dateIssued encoding="marc" point="end" qualifier="questionable">1600</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California, [1400 - 1600?]',
      # coll rec nd057tw6238
      # coll rec pn981gz2244
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">xx</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start">1310</dateIssued>
        <dateIssued encoding="marc" point="end">1500</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '1310 - 1500',
      # coll rec zv022sd1415
      # hf970tz9706
      mods_origin_info_start_str +
        '<place><placeTerm type="text">England</placeTerm></place>
        <dateCreated point="start" qualifier="approximate" keyDate="yes">850</dateCreated>
        <dateCreated point="end" qualifier="approximate">1499</dateCreated>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'England, [ca. 850 CE - 1499]',
      # sc582cv9633
      mods_origin_info_start_str +
        '<dateCreated keydate="yes">1314</dateCreated>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '1314',
      # yc365tw0116
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Venice (?), Italy</placeTerm>
        </place>
        <dateCreated point="start" qualifier="approximate" keyDate="yes">1404</dateCreated>
        <dateCreated point="end" qualifier="approximate">1781</dateCreated>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Venice (?), Italy, [ca. 1404 - 1781]',
      # mf790cw8283
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Venice, Italy</placeTerm>
        </place>
        <dateCreated keydate="yes">August 18, 1552</dateCreated>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Venice, Italy, August 18, 1552'
    },
  # menuez
  'me310' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec kq629sd5182 no originInfo (empty elements)
      # sd594yd8504
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">2013-06-24</dateCreated>' +
        mods_origin_info_end_str => 'June 24, 2013',
      # sw321tg6624
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">2013-06</dateCreated>' +
        mods_origin_info_end_str => 'June 2013'
    },
  # mkultra
  # mlk
  'mlm' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec ft241sj7871
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">xx</placeTerm>
        </place>
        <dateIssued encoding="marc" keyDate="yes" point="start">16uu</dateIssued>
        <dateIssued encoding="marc" point="end">19uu</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '17th century - 20th century',
      # kf724zz4430
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">fr</placeTerm>
        </place>
        <place>
          <placeTerm type="text">A Paris</placeTerm>
        </place>
        <publisher>De J-B-Christophe Ballard</publisher>
        <dateIssued>1719</dateIssued>
        <edition>Imprimée pour la premiere fois.</edition>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Imprimée pour la premiere fois. - A Paris : De J-B-Christophe Ballard, 1719'
    },
  # mpeg
  # mullin-palmer
  # nanoscale
  'norwich' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec qb438pg7646
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">sa</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start" qualifier="questionable">1486</dateIssued>
        <dateIssued encoding="marc" point="end" qualifier="questionable">1865</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'South Africa, [1486 - 1865?]',
      # zv656kg5843
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Unknown</placeTerm>
        </place>
        <publisher>Anonymous</publisher>
        <dateIssued qualifier="questionable" point="start" keyDate="yes">1486</dateIssued>' +
        '<dateIssued qualifier="questionable" point="end">1865</dateIssued>' +
        mods_origin_info_end_str => 'Unknown : Anonymous, [1486 - 1865?]',
      # qx376cz2677
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="inferred">1814</dateCreated>
        <place>
          <placeTerm type="text">Edinburgh</placeTerm>
        </place>
        <publisher>John Thomson &amp; Co.</publisher>' +
        mods_origin_info_end_str => 'Edinburgh : John Thomson & Co. [1814]',
      # xp797gj2926
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="approximate" point="start">1646</dateCreated>
        <place>
          <placeTerm type="text">[Florence]</placeTerm>
        </place>
        <publisher>[Dudley, Robert, Sir, 1574-1649]</publisher>
        <dateCreated encoding="w3cdtf" keyDate="no" qualifier="approximate" point="end">1647</dateCreated>' +
        mods_origin_info_end_str => '[Florence] : [Dudley, Robert, Sir, 1574-1649], [ca. 1646 - 1647]'
    },
  # nowinsky
  # paleo
  'papyri' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec jr022nf7673 has no originInfo
      # jx555jt0710
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">199 B.C.</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="end" qualifier="approximate">100 B.C.</dateCreated>' +
        mods_origin_info_end_str => '[ca. 199 B.C. - 100 B.C.]',
      # ww728rz0477
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">211 B.C.</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="end" qualifier="approximate">150 B.C.</dateCreated>' +
        mods_origin_info_end_str => '[ca. 211 B.C. - 150 B.C.]'
    },
  # pcc
  # peace
  # peninsula_times ?
  # peoples_computer?
  # physics_ugrad
  # pippin
  # pleistocene
  'posada' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec fm601nw4733 merges with 4561410
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">cau</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start" qualifier="questionable">1875</dateIssued>
        <dateIssued encoding="marc" point="end" qualifier="questionable">1913</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California, [1875 - 1913?]',
      # wb612pd9842
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf" point="start" qualifier="approximate">1852</dateCreated>
        <dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1925</dateCreated>
        <place>
          <placeTerm type="text" authorityURI="http://id.loc.gov/authorities/names" valueURI="http://id.loc.gov/authorities/names/n81013960">Mexico</placeTerm>
        </place>
        <publisher>Antonio Vanegas Arroyo</publisher>
        <publisher>Antigua Imprenta de Murguia</publisher>' +
        mods_origin_info_end_str => 'Mexico : Antonio Vanegas Arroyo : Antigua Imprenta de Murguia, [ca. 1852 - 1925]'
    },
  # posttranslational
  # project_south
  # reaction_kinetics?
  # reliability
  'renaissance' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec sr605np6062 no originInfo
      # mj187xt5183
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">it</placeTerm>
        </place>
        <place>
          <placeTerm type="text">Venice</placeTerm>
        </place>
        <publisher>[s.n.]</publisher>
        <dateIssued>A1566</dateIssued>
        <dateIssued encoding="marc">1566</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Venice : [s.n.], A1566',
      # ym307qw6924
      mods_origin_info_start_str +
        ' <place>
            <placeTerm type="code" authority="marccountry">enk</placeTerm>
          </place>
          <dateIssued encoding="marc">1673</dateIssued>
          <edition>The second edition</edition>
          <issuance>monographic</issuance>
        </originInfo>
        <originInfo displayLabel="publisher">
          <place>
            <placeTerm>London :</placeTerm>
          </place>
          <publisher>printed by the author at his house in White-Friers,</publisher>
          <dateIssued>MDCLXXIII [1673]</dateIssued>' +
        mods_origin_info_end_str => 'The second edition - England, 1673; London : printed by the author at his house in White-Friers, MDCLXXIII [1673]',
      # jp656ch7273
      mods_origin_info_start_str +
        '</originInfo>
        <originInfo script="Latn">
          <place>
            <placeTerm type="code" authority="marccountry">ne</placeTerm>
          </place>
          <dateIssued encoding="marc">1635</dateIssued>
          <edition>Editae a Guiljel: et Ioanne Blaeu.</edition>
          <issuance>monographic</issuance>
        </originInfo>
        <originInfo displayLabel="publisher">
          <place>
            <placeTerm>Amsterdami [Amsterdam] :</placeTerm>
          </place>
          <publisher>apud Guiljelmum et Iohannem Blaue,</publisher>
          <dateIssued>anno MDCXXXV [1635].</dateIssued>' +
        mods_origin_info_end_str => 'Editae a Guiljel: et Ioanne Blaeu. - Netherlands, 1635; Amsterdami [Amsterdam] : apud Guiljelmum et Iohannem Blaue, anno MDCXXXV [1635].',
      # kn461sw8435
      mods_origin_info_start_str +
        ' <place>
            <placeTerm type="code" authority="marccountry">gw</placeTerm>
          </place>
          <dateIssued encoding="marc">1502</dateIssued>
          <edition>"1502 ed."</edition>
          <issuance>monographic</issuance>
        </originInfo>
        <originInfo displayLabel="publisher">
          <place>
            <placeTerm>[Speier :</placeTerm>
          </place>
          <publisher>Peter Drach],</publisher>
          <dateIssued>1502.</dateIssued>' +
        mods_origin_info_end_str => '"1502 ed." - Germany, 1502; [Speier : Peter Drach], 1502.',
      # mp684yf2282
      mods_origin_info_start_str +
        ' <place>
            <placeTerm type="code" authority="marccountry">be</placeTerm>
          </place>
          <dateIssued encoding="marc">1603</dateIssued>
          <edition>Editio ultima.</edition>
          <issuance>monographic</issuance>
        </originInfo>
        <originInfo displayLabel="publisher">
          <place>
            <placeTerm>Antuerpiae [Antwerp] :</placeTerm>
          </place>
          <publisher>apud Ioannem Bapt. Vrintium,</publisher>
          <dateIssued>anno MDCIII [1603]</dateIssued>' +
        mods_origin_info_end_str => 'Editio ultima. - Belgium, 1603; Antuerpiae [Antwerp] : apud Ioannem Bapt. Vrintium, anno MDCIII [1603]',
      # gj754dz9970
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">ne</placeTerm>
        </place>
        <place>
          <placeTerm type="text">Amstelodami</placeTerm>
        </place>
        <publisher>impensis Pet. Kaerii</publisher>
        <dateIssued>1622</dateIssued>
        <edition>[2nd edition].</edition>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[2nd edition]. - Amstelodami : impensis Pet. Kaerii, 1622',
      # xp087mn9497
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">gw</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[Tubingen]</placeTerm>
        </place>
        <publisher>[publisher not identified]</publisher>
        <dateIssued>[1629]</dateIssued>
        <dateIssued encoding="marc">1629</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[Tubingen] : [publisher not identified], [1629]',
      # mz459hh4339
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">it</placeTerm>
        </place>
        <place>
          <placeTerm type="text">Romae [Rome]</placeTerm>
        </place>
        <publisher>[haeredes Claudii Duchetti]</publisher>
        <dateIssued>MDLXXXIIII [1584]</dateIssued>
        <dateIssued encoding="marc">1584</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Romae [Rome] : [haeredes Claudii Duchetti], MDLXXXIIII [1584]',
      # kj619sr3867
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">enk</placeTerm>
        </place>
        <place>
          <placeTerm type="text">[London]</placeTerm>
        </place>
        <publisher>sold by Abel Swale, Awnsham &amp; Iohn Churchil</publisher>
        <dateIssued>[1695]</dateIssued>
        <dateIssued encoding="marc">1695</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '[London] : sold by Abel Swale, Awnsham & Iohn Churchil, [1695]'
    },
  # renuwit
  'research-data' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec md919gh6774 no originInfo
      # qt411pj4511
      mods_origin_info_start_str +
        '<dateCreated point="start" keyDate="yes" encoding="w3cdtf">2009-05-10</dateCreated>
        <dateCreated point="end" encoding="w3cdtf">2014-10-30</dateCreated>' +
        mods_origin_info_end_str => 'May 10, 2009 - October 30, 2014',
      # zp707tw3135
      mods_origin_info_start_str +
        '<dateCreated qualifier="approximate" keyDate="yes" encoding="w3cdtf">2008</dateCreated>' +
        mods_origin_info_end_str => '[ca. 2008]',
      # pw096jw7895
      mods_origin_info_start_str +
        '<dateCreated point="start" qualifier="approximate" keyDate="yes" encoding="w3cdtf">2014-03</dateCreated>
        <dateCreated point="end" qualifier="approximate" encoding="w3cdtf">2015-06</dateCreated>' +
        mods_origin_info_end_str => '[ca. March 2014 - June 2015]'
    },
  # reservoir ?
  'roman coins' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec dq017bh9237
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">it</placeTerm>
        </place>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Italy',
      # hs628wg6771
      mods_origin_info_start_str +
        ' <place supplied="yes">
            <placeTerm type="text" authority="naf" valueURI="http://id.loc.gov/authorities/names/n79006971">Spain</placeTerm>
          </place>
        </originInfo>
        <originInfo>
          <dateCreated encoding="edtf" point="start" keyDate="yes">-18</dateCreated>
          <dateCreated encoding="edtf" point="end">-17</dateCreated>' +
        mods_origin_info_end_str => 'Spain; 19 BCE - 18 BCE',
      # bb408km1389
      mods_origin_info_start_str +
        ' <place supplied="yes">
            <placeTerm type="text" authority="naf" valueURI="http://id.loc.gov/authorities/names/n81086849">Lyon (France)</placeTerm>
          </place>
        </originInfo>
        <originInfo>
          <dateCreated encoding="edtf" point="start" keyDate="yes">-1</dateCreated>
          <dateCreated encoding="edtf" point="end">11</dateCreated>' +
        mods_origin_info_end_str => 'Lyon (France); 2 BCE - 11 CE',
      # cs470ng8064
      mods_origin_info_start_str +
        ' <place supplied="yes">
            <placeTerm type="text" authority="naf" valueURI="http://id.loc.gov/authorities/names/n81125432">Antioch (Turkey) (?)</placeTerm>
          </place>
        </originInfo>
        <originInfo>
          <dateCreated encoding="edtf" point="start" keyDate="yes">-1</dateCreated>
          <dateCreated encoding="edtf" point="end">0</dateCreated>' +
        mods_origin_info_end_str => 'Antioch (Turkey) (?); 2 BCE - 1 BCE',
      # vh834jh5059
      mods_origin_info_start_str +
        ' <place supplied="yes">
            <placeTerm type="text" authority="naf" valueURI="http://id.loc.gov/authorities/names/n81086849">Lyon (France)</placeTerm>
          </place>
        </originInfo>
        <originInfo>
          <dateCreated encoding="edtf" point="start" keyDate="yes">13</dateCreated>
          <dateCreated encoding="edtf" point="end">14</dateCreated>' +
        mods_origin_info_end_str => 'Lyon (France); 13 CE - 14 CE',
      # sk424bh9379
      mods_origin_info_start_str +
        ' <place supplied="yes">
            <placeTerm type="text" authority="naf" valueURI="http://id.loc.gov/authorities/names/n80067694">Alexandria (Egypt)</placeTerm>
          </place>
        </originInfo>
        <originInfo>
          <dateCreated encoding="edtf" point="start" keyDate="yes">34</dateCreated>
          <dateCreated encoding="edtf" point="end">35</dateCreated>' +
        mods_origin_info_end_str => 'Alexandria (Egypt); 34 CE - 35 CE'
    },
  # rigler
  'rumsey' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec xh235dd9059 no originInfo
      # fy259fg4220
      mods_origin_info_start_str +
        ' <place>
            <placeTerm type="code" authority="marccountry">xxu</placeTerm>
          </place>
          <dateIssued encoding="marc">1855</dateIssued>
          <issuance>monographic</issuance>
        </originInfo>
        <originInfo displayLabel="publisher">
          <place>
            <placeTerm>Boston :</placeTerm>
          </place>
          <publisher>L.H. Bradford &amp; Co,</publisher>
          <dateIssued>1855.</dateIssued>' +
        mods_origin_info_end_str => 'United States, 1855; Boston : L.H. Bradford & Co, 1855.',
      # hp058zk7170
      mods_origin_info_start_str +
        ' <place>
            <placeTerm type="code" authority="marccountry">xxu</placeTerm>
          </place>
          <dateCreated encoding="marc">1861</dateCreated>
          <issuance>monographic</issuance>
        </originInfo>
        <originInfo displayLabel="publisher">
          <place>
            <placeTerm>Manuscript. :</placeTerm>
          </place>
          <publisher/>
          <dateIssued>1861.</dateIssued>' +
        mods_origin_info_end_str => 'United States, 1861; Manuscript. : 1861.'
    },
  # rock?
  # scrf
  # shale
  'shpc' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec kx532cb7981
      mods_origin_info_start_str +
        '<place>
          <placeTerm authority="marccountry" type="code">cau</placeTerm>
        </place>
        <dateIssued encoding="marc" point="start">1887</dateIssued>
        <dateIssued encoding="marc" point="end">1996</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'California, 1887 - 1996',
      # cr293hs9054
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Stanford, CA</placeTerm>
        </place>
        <publisher>Stanford University Archives</publisher>
        <dateCreated encoding="w3cdtf" keyDate="yes" qualifier="">0000-00-00</dateCreated>' +
        mods_origin_info_end_str => 'Stanford, CA : Stanford University Archives',
      # dk829wf6922
      mods_origin_info_start_str +
        '<dateOther encoding="w3cdtf" keyDate="no" qualifier="">1958-07-00</dateOther>
        <place>
          <placeTerm type="text">Stanford, CA</placeTerm>
        </place>
        <publisher>Stanford University Archives</publisher>
        <dateCreated encoding="w3cdtf" keyDate="yes" qualifier=" ">1869-00-00</dateCreated>' +
        mods_origin_info_end_str => 'Stanford, CA : Stanford University Archives, 1869',
      # fp085hf5015
      mods_origin_info_start_str +
        '<dateOther encoding="w3cdtf" keyDate="no" qualifier="">1963-10-11</dateOther>
        <place>
          <placeTerm type="text">Stanford, CA</placeTerm>
        </place>
        <publisher>Stanford University Archives</publisher>
        <dateCreated encoding="w3cdtf" keyDate="yes" qualifier=" ">1903-00-00</dateCreated>' +
        mods_origin_info_end_str => 'Stanford, CA : Stanford University Archives, 1903',
      # ns466nn0465
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="no" qualifier="">1918-00-00</dateCreated>
        <dateOther encoding="w3cdtf" keyDate="no" qualifier="">1968-02-00</dateOther>
        <place>
          <placeTerm type="text">Stanford, CA</placeTerm>
        </place>
        <publisher>Stanford University Archives</publisher>' +
        mods_origin_info_end_str => 'Stanford, CA : Stanford University Archives, 1918'
    },
  # social_research_tech_reports ?
  # sounds?
  # spoke
  # stafford
  # stop_aids
  # sul_staff
  # tide_prediction?
  'uganda' =>  # geo
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec rb371kw9607
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="code" authority="marccountry">ug</placeTerm>
        </place>
        <place>
          <placeTerm type="text">Kampala , Uganda</placeTerm>
        </place>
        <publisher>Uganda Bureau of Statistics</publisher>
        <dateIssued>2012</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Kampala , Uganda : Uganda Bureau of Statistics, 2012',
      # cz128vq0535
      mods_origin_info_start_str +
        '<publisher>Uganda Bureau of Statistics</publisher>
        <place>
          <placeTerm type="text">Kampala , UG</placeTerm>
        </place>
        <dateIssued encoding="w3cdtf" keyDate="yes">2005</dateIssued>
        <dateValid encoding="w3cdtf">2005</dateValid>' +
        mods_origin_info_end_str => 'Kampala , UG : Uganda Bureau of Statistics, 2005',
      # cz128vq0535
      mods_origin_info_start_str +
        '<publisher>Uganda Bureau of Statistics</publisher>
        <place>
          <placeTerm type="text">Kampala , UG</placeTerm>
        </place>
        <dateIssued encoding="w3cdtf" keyDate="yes">2012</dateIssued>
        <dateValid encoding="w3cdtf" point="start">2008</dateValid>
        <dateValid encoding="w3cdtf" point="end">2010</dateValid>' +
        mods_origin_info_end_str => 'Kampala , UG : Uganda Bureau of Statistics, 2012'
    },
  # understanding_911?
  # urban
  # virtual_worlds
  # visitations
  # vista
  'walters' =>
    { # key is mods_xml;  value is expected value for imprint_display
      # coll rec ww121ss5000
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">800</dateIssued>
        <dateIssued encoding="marc" point="end">1899</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '800 CE - 1899',
      # dc882bs3541
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Egypt</placeTerm>
        </place>
        <dateCreated encoding="w3cdtf" point="start" qualifier="approximate" keyDate="yes">0700</dateCreated>
        <dateCreated encoding="w3cdtf" point="end" qualifier="approximate">0799</dateCreated>
        <dateCreated encoding="w3cdtf" keyDate="yes"/>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Egypt, [ca. 700 CE - 799 CE]',
      # hg026ds6978
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Central Arab lands</placeTerm>
        </place>
        <dateCreated encoding="w3cdtf" keyDate="yes">0816</dateCreated>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Central Arab lands, 816 CE',
      # ch617yk2621
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Constantinople (?)</placeTerm>
        </place>
        <dateCreated encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">1000</dateCreated>
        <dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1040</dateCreated>
        <dateCreated encoding="w3cdtf" keyDate="yes"/>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Constantinople (?), [ca. 1000 - 1040]',
      # pc969nh5331
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Byzantine Empire</placeTerm>
        </place>
        <dateCreated encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">0950</dateCreated>
        <dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1000</dateCreated>
        <dateCreated encoding="w3cdtf" keyDate="yes"/>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Byzantine Empire, [ca. 950 CE - 1000]',
      # hj537kj5737
      mods_origin_info_start_str +
        '<dateIssued>15th century CE</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => '15th century CE',
      # gs755tr2814
      mods_origin_info_start_str +
        '<dateIssued>Ca. 1580 CE</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Ca. 1580 CE',
      # hp976mx6580
      mods_origin_info_start_str +
        '<place>
          <placeTerm type="text">Italy</placeTerm>
        </place>
        <dateIssued>1500 CE</dateIssued>
        <issuance>monographic</issuance>' +
        mods_origin_info_end_str => 'Italy, 1500 CE'
    }
  # water
  # wilpf?
  # yotsuba
}.freeze
