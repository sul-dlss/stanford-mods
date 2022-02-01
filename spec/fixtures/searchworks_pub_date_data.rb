# fixture data from real MODS from prod purl pages for data in or soon to be in prod SearchWorks

mods_origin_info_start_str = "<mods xmlns=\"#{Mods::MODS_NS}\"><originInfo>"
mods_origin_info_end_str = '</originInfo></mods>'

SEARCHWORKS_PUB_DATE_DATA = {
  'batchelor' =>
    { # key is mods_xml;  values = [pub year int, pub years display str]
      # ct961sj2730 coll rec:  no originInfo dates)
      # dr330jt7122
      mods_origin_info_start_str +
        '<dateIssued>1843</dateIssued>' +
        mods_origin_info_end_str => [1843, '1843'],
      # jg216qn0081
      mods_origin_info_start_str +
        '<dateIssued>12th May 1800</dateIssued>' +
        '<dateIssued encoding="marc">1800</dateIssued>' +
        mods_origin_info_end_str => [1800, '1800'],
      # sx557zn4953
      mods_origin_info_start_str +
        '<dateIssued>1570</dateIssued>' +
        mods_origin_info_end_str => [1570, '1570'],
      # mb505bx7548
      mods_origin_info_start_str +
        '<dateIssued>15 Feby. 1850</dateIssued>' +
        '<dateIssued encoding="marc">1850</dateIssued>' +
        mods_origin_info_end_str => [1850, '1850'],
      # nn603hs6182
      mods_origin_info_start_str +
        '<dateIssued>[1583]</dateIssued>' +
        '<dateIssued encoding="marc">1583</dateIssued>' +
        mods_origin_info_end_str => [1583, '1583'],
      # qm011nb3364
      mods_origin_info_start_str +
        '<dateIssued>1606?]</dateIssued>' +
        '<dateIssued encoding="marc">1606</dateIssued>' +
        mods_origin_info_end_str => [1606, '1606'],
      # ww960jk4650
      mods_origin_info_start_str +
        '<dateIssued>167-?]</dateIssued>' +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1670</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1680</dateIssued>' +
        mods_origin_info_end_str => [1670, '1670 - 1680'],
      # xf190qy2958
      mods_origin_info_start_str +
        '<dateIssued>1670]</dateIssued>' +
        '<dateIssued encoding="marc">1670</dateIssued>' +
        mods_origin_info_end_str => [1670, '1670'],
      # nt714wx8371
      mods_origin_info_start_str +
        '<dateIssued>1690?]</dateIssued>' +
        '<dateIssued encoding="marc">169u</dateIssued>' +
        mods_origin_info_end_str => [1690, '1690s'],
      # ct011mf9794
      mods_origin_info_start_str +
        '<dateIssued>17--]</dateIssued>' +
        '<dateIssued encoding="marc">17uu</dateIssued>' +
        mods_origin_info_end_str => [1700, '18th century'],
      # kv453gh8092
      mods_origin_info_start_str +
        '<dateIssued>1809 [ca. 1810]</dateIssued>' +
        '<dateIssued encoding="marc">1809</dateIssued>' +
        mods_origin_info_end_str => [1809, '1809'],
      # ms639jm9954
      mods_origin_info_start_str +
        '<dateIssued>183-?</dateIssued>' +
        '<dateIssued encoding="marc">1830</dateIssued>' +
        mods_origin_info_end_str => [1830, '1830'],
      # mm076bz8960
      mods_origin_info_start_str +
        '<dateIssued>[ca. 1850?]</dateIssued>' +
        '<dateIssued encoding="marc">185u</dateIssued>' +
        mods_origin_info_end_str => [1850, '1850s'],
      # kt670wv9626
      mods_origin_info_start_str +
        '<dateIssued>1860, [1862]</dateIssued>' +
        '<dateIssued encoding="marc">1862</dateIssued>' +
        mods_origin_info_end_str => [1860, '1860'],
      # nq311rg5326
      mods_origin_info_start_str +
        '<dateIssued>1860?]</dateIssued>' +
        '<dateIssued encoding="marc">186?</dateIssued>' +
        mods_origin_info_end_str => [1860, '1860'],
      # cw097mp1488
      mods_origin_info_start_str +
        '<dateIssued>1877?</dateIssued>' +
        '<dateIssued encoding="marc">1877</dateIssued>' +
        mods_origin_info_end_str => [1877, '1877'],
      # bb987ch8177
      mods_origin_info_start_str +
        '<dateIssued>June1st.1805</dateIssued>' +
        '<dateIssued encoding="marc">1805</dateIssued>' +
        mods_origin_info_end_str => [1805, '1805'],
      # pb745bf0151
      mods_origin_info_start_str +
        '<dateIssued>[ca. 1730]</dateIssued>' +
        '<dateIssued encoding="marc">1730</dateIssued>' +
        mods_origin_info_end_str => [1730, '1730'],
      # vs807zh4960
      mods_origin_info_start_str +
        '<dateIssued>[s.d.]</dateIssued>' +
        mods_origin_info_end_str => [nil, nil],
      # kk981sj7811
      mods_origin_info_start_str +
        '<dateIssued>ca. 1697]</dateIssued>' +
        '<dateIssued encoding="marc">1697</dateIssued>' +
        mods_origin_info_end_str => [1697, '1697'],
      # nr266xf1214
      mods_origin_info_start_str +
        '<dateIssued>ca. 1740-1800]</dateIssued>' +
        '<dateIssued encoding="marc" point="start">1740</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1800</dateIssued>' +
        mods_origin_info_end_str => [1740, '1740 - 1800'],
      # ds825sq5748
      mods_origin_info_start_str +
        '<dateIssued>s.a. [1712]</dateIssued>' +
        '<dateIssued encoding="marc">1712</dateIssued>' +
        mods_origin_info_end_str => [1712, '1712'],
      # hk649cc3149
      mods_origin_info_start_str +
        '<dateIssued>s.a. [ca. 1780-1781]</dateIssued>' +
        '<dateIssued encoding="marc">1780</dateIssued>' +
        mods_origin_info_end_str => [1780, '1780'],
      # vk991dv1917
      mods_origin_info_start_str +
        '<dateIssued>s.a. [zwischen 1740 und 1760]</dateIssued>' +
        '<dateIssued encoding="marc">1740</dateIssued>' +
        mods_origin_info_end_str => [1740, '1740'],
      # gy889yj2171
      mods_origin_info_start_str +
        '<dateIssued>1758]</dateIssued>' +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1758</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">uuuu</dateIssued>' +
        mods_origin_info_end_str => [1758, '1758']
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
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec  sg213ph2100 goes to marc 6780453
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1850</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1906</dateIssued>' +
        mods_origin_info_end_str => [1850, '1850 - 1906'],
      # ps072wf8793
      mods_origin_info_start_str +
        '<dateIssued encoding="w3cdtf">1851-07-01</dateIssued>' +
        mods_origin_info_end_str => [1851, '1851'],
      # cq482hj7635
      mods_origin_info_start_str +
        '<dateIssued>1892, Jan. 1</dateIssued>' +
        mods_origin_info_end_str => [1892, '1892'],
      # ps292jd8410
      mods_origin_info_start_str +
        '<dateIssued>December 19th, 1897</dateIssued>' +
        mods_origin_info_end_str => [1897, '1897'],
      # wt030np1013
      mods_origin_info_start_str +
        '<dateIssued>Dec. 10 & 11, 1855</dateIssued>' +
        mods_origin_info_end_str => [1855, '1855'],
      # pd337xr9038
      mods_origin_info_start_str +
        '<dateIssued>October 3, [18]91</dateIssued>' +
        mods_origin_info_end_str => [1891, '1891'],
      # cj765pw7168
      mods_origin_info_start_str +
        '<dateIssued>circa 1900</dateIssued>' +
        mods_origin_info_end_str => [1900, '1900'],
      # rc301fn5504
      mods_origin_info_start_str +
        '<dateIssued>circa 1851-1852</dateIssued>' +
        mods_origin_info_end_str => [1851, '1851'],
      # zz400gd3785
      mods_origin_info_start_str +
        '<dateIssued>copyright 1906</dateIssued>' +
        mods_origin_info_end_str => [1906, '1906'],
      # bh059ts1689
      mods_origin_info_start_str +
        '<dateIssued>early 1890s</dateIssued>' +
        mods_origin_info_end_str => [1890, '1890s'],
      # rm673kv3302
      mods_origin_info_start_str +
        '<dateIssued>published 1st July, 1851</dateIssued>' +
        mods_origin_info_end_str => [1851, '1851'],
      # ym037xp1637
      mods_origin_info_start_str +
        '<dateIssued>view of approximately 1848, published about 1865</dateIssued>' +
        mods_origin_info_end_str => [1848, '1848']
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
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec ms016pb9280
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1950</dateIssued>' +
        '<dateIssued encoding="marc" point="end">2007</dateIssued>' +
        mods_origin_info_end_str => [1950, '1950 - 2007'],
      # py696hw1646, jc364jw8333
        mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">2001-11-19</dateCreated>' +
        mods_origin_info_end_str => [2001, '2001']
    },
  # fem_ugrad
  # film_arts
  # fitch_chavez
  'fitch' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll recs have no originInfo data
      # pd835hf9652 - MLK
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf" point="start" qualifier="approximate">1965</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1966</dateCreated>' +
        mods_origin_info_end_str => [1965, '1965 - 1966'],
      # cq153cd4213 - Panther
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">1972-03-30</dateCreated>' +
        mods_origin_info_end_str => [1972, '1972'],
      # rr577nj0391 - Alejo
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">2010-09</dateCreated>' +
        mods_origin_info_end_str => [2010, '2010']
    },
  'fitch-mud' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec vr013gg9930  no originInfo
      # vd865fk6168
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">1967</dateCreated>' +
        mods_origin_info_end_str => [1967, '1967'],
      # xr458wf5634
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">1971</dateCreated>' +
        mods_origin_info_end_str => [1971, '1971']
    },
  # fitch_seeger
  # flipside
  # folding
  # fracture
  # franklin
  # frantz
  'fugitive_us_agencies' =>  # WARC files
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec mk656nf8485  has no dates
      # rc607cp0203
      mods_origin_info_start_str +
        '<dateCaptured encoding="iso8601" point="start" keyDate="yes">20090511065738</dateCaptured>' +
        '<dateCaptured encoding="edtf" point="end">open</dateCaptured>' +
        mods_origin_info_end_str => [2009, '2009'],
      # gb089bd2251
      mods_origin_info_start_str +
        '<dateCaptured encoding="iso8601" point="start" keyDate="yes">20121129060351</dateCaptured>' +
        '<dateCaptured encoding="edtf" point="end">open</dateCaptured>' +
        mods_origin_info_end_str => [2012, '2012']
    },
  # fuller
  'fuller' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec rh056sr3313
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start" qualifier="questionable" keyDate="yes">1920</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1983</dateIssued>' +
        mods_origin_info_end_str => [1920, '1920 - 1983'],
      # fz116cn2445
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">1977</dateCreated>' +
        mods_origin_info_end_str => [1977, '1977']
    },
  # future_sp
  # geo
  # gimon
  # gould
  'gould' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec sp673gr4168 no originInfo
      # cm311th5760
      mods_origin_info_start_str +
        '<dateIssued>1599-1601</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes" point="start">1599</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1601</dateIssued>' +
        mods_origin_info_end_str => [1599, '1599 - 1601'],
      # mt060jf5269
      mods_origin_info_start_str +
        "<dateIssued>1616: Con licenza de'svperiori</dateIssued>" +
        '<dateIssued encoding="marc" keyDate="yes">1616</dateIssued>' +
        mods_origin_info_end_str => [1616, '1616'],
      # nq614fg2641
      mods_origin_info_start_str +
        '<dateIssued>1689 [i.e. 1688-89]</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1689</dateIssued>' +
        mods_origin_info_end_str => [1689, '1689'],
      # vq462ct4039
      mods_origin_info_start_str +
        '<dateIssued>1717-1720</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1717</dateIssued>' +
        mods_origin_info_end_str => [1717, '1717'],
      # nh718gy4718
      mods_origin_info_start_str +
        '<dateIssued>1743-53</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes" point="start">1743</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1753</dateIssued>' +
        mods_origin_info_end_str => [1743, '1743 - 1753'],
      # vr992zn5309
      mods_origin_info_start_str +
        '<dateIssued>MDCCLII. [1752-</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes" point="start">1752</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1769</dateIssued>' +
        mods_origin_info_end_str => [1752, '1752 - 1769'],
      # ms437pv1661
      mods_origin_info_start_str +
        '<dateIssued>1752 [i.e. 1753]</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1752</dateIssued>' +
        mods_origin_info_end_str => [1752, '1752'],
      # hn969cv3410
      mods_origin_info_start_str +
        '<dateIssued>1772]</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1772</dateIssued>' +
        mods_origin_info_end_str => [1772, '1772'],
      # nh857kn6175
      mods_origin_info_start_str +
        '<dateIssued>18--]</dateIssued>' +
        mods_origin_info_end_str => [1800, '19th century'],
      # fz691jq4431
      mods_origin_info_start_str +
        '<dateIssued>1846-</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes" point="start">1846</dateIssued>' +
        '<dateIssued encoding="marc" point="end">9999</dateIssued>' +
        mods_origin_info_end_str => [1846, '1846'],
      # zp382js2355
      mods_origin_info_start_str +
        '<dateIssued>[184-]</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">184u</dateIssued>' +
        mods_origin_info_end_str => [1840, '1840s'],
      # qg377px6180
      mods_origin_info_start_str +
        '<dateIssued>1868, c1857</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1868</dateIssued>' +
        '<copyrightDate encoding="marc">1857</copyrightDate>' +
        mods_origin_info_end_str => [1868, '1868'],
      # df994hc9746
      mods_origin_info_start_str +
        '<dateIssued>[18--?]</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">18uu</dateIssued>' +
        mods_origin_info_end_str => [1800, '19th century'],
      # wt924zz1420
      mods_origin_info_start_str +
        '<dateIssued>c1999</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1999</dateIssued>' +
        mods_origin_info_end_str => [1999, '1999'],
      # pk964hd1543
      mods_origin_info_start_str +
        '<dateIssued>1920</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1900</dateIssued>' +
        mods_origin_info_end_str => [1900, '1900'],
      # nq054by6214
      mods_origin_info_start_str +
        '<dateIssued>200-?]</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">200u</dateIssued>' +
        mods_origin_info_end_str => [2000, '2000s'],
      # sf621tq9900
      mods_origin_info_start_str +
        '<dateIssued>an X, 1802</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1802</dateIssued>' +
        mods_origin_info_end_str => [1802, '1802'],
      # sn157dn6711
      mods_origin_info_start_str +
        '<dateIssued>c1964</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1964</dateIssued>' +
        mods_origin_info_end_str => [1964, '1964'],
      # yp117pm9679
      mods_origin_info_start_str +
        '<dateIssued>[etc</dateIssued>' +
        '<dateIssued>1840]</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1840</dateIssued>' +
        mods_origin_info_end_str => [1840, '1840'],
      # qt751sy2894
      mods_origin_info_start_str +
        '<dateIssued>MDCLXXXVII</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1687</dateIssued>' +
        mods_origin_info_end_str => [1687, '1687']
    },
  # gse_comp_ed_masters
  # gse_oa
  # gse_ugrad
  # hellman
  'homebrew' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec ht445nv3709  no originInfo
      # xt205qz2409
      mods_origin_info_start_str +
        '<dateIssued encoding="w3cdtf" keyDate="yes">1978-01</dateIssued>' +
        mods_origin_info_end_str => [1978, '1978']
    },
  # hopkins
  # hopkins_thesis
  # human_bio_lectures
  'human-impact-marine' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec wy139zd0043: no originInfo dates
      # tg926kp6619
      mods_origin_info_start_str +
        '<publisher>Science</publisher>
        <place>
          <placeTerm type="text">Washington, D.C., US</placeTerm>
        </place>
        <dateIssued encoding="w3cdtf" keyDate="yes">2008</dateIssued>
        <dateValid encoding="w3cdtf">2007</dateValid>
        <dateValid encoding="w3cdtf">2008</dateValid>' +
        mods_origin_info_end_str => [2008, '2008']
    },
  # hummel
  # image_proc
  # image_video_multimedia
  # jane_stanford
  # jordan
  # kant
  # kemi
  'kitai' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec rw431mw4432
      mods_origin_info_start_str +
        '<dateIssued>[1968?-</dateIssued>' +
        '<dateIssued encoding="marc" point="start" keyDate="yes">1968</dateIssued>' +
        '<dateIssued encoding="marc" point="end">9999</dateIssued>' +
        mods_origin_info_end_str => [1968, '1968'],
      # tw488bz3281
      mods_origin_info_start_str +
        '<dateIssued>[1968?-</dateIssued>' +
        '<dateIssued encoding="marc" point="start" keyDate="yes">1968</dateIssued>' +
        '<dateIssued encoding="marc" point="end">9999</dateIssued>' +
        mods_origin_info_end_str => [1968, '1968']
    },
  # kolb has no originInfo elements
  'labor' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec wf220dz0066  merges with 421708
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1948</dateIssued>' +
        '<dateIssued encoding="marc" point="end">9999</dateIssued>' +
        mods_origin_info_end_str => [1948, '1948'],
      # vh590xb4582
      mods_origin_info_start_str +
        '<dateIssued encoding="w3cdtf" keyDate="yes" qualifier="approximate" point="start">1948</dateIssued>' +
        '<dateIssued encoding="w3cdtf" qualifier="approximate" point="end">1951</dateIssued>' +
        mods_origin_info_end_str => [1948, '1948 - 1951']
    },
  # lapp_practices
  # leland_stanford
  # lgbt
  # lobell
  # masters
  # matter
  # maxfield
  'mccarthy' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec kd453rz2514
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1951</dateIssued>' +
        '<dateIssued encoding="marc" point="end">2008</dateIssued>' +
        mods_origin_info_end_str => [1951, '1951 - 2008'],
      # kr251bd1719
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">Undated</dateCreated>' +
        mods_origin_info_end_str => [nil, nil],
      # kt770bs1887
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">1978-06</dateCreated>' +
        mods_origin_info_end_str => [1978, '1978'],
      # zw479my8350
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">2010-12-09</dateCreated>' +
        mods_origin_info_end_str => [2010, '2010']
    },
  'mclaughlin_ca_island' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec zb871zd0767 no dates
      # tt437zq0720
      mods_origin_info_start_str +
        '<dateIssued>1640-1665?]</dateIssued>' +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1640</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1665</dateIssued>' +
        mods_origin_info_end_str => [1640, '1640 - 1655'],
      # rk097dw1744
      mods_origin_info_start_str +
        '<dateIssued>1640]</dateIssued>' +
        '<dateIssued encoding="marc">1640</dateIssued>' +
        mods_origin_info_end_str => [1640, '1640'],
      # mk758ps0914
      mods_origin_info_start_str +
        '<dateIssued>1598 or 1599]</dateIssued>' +
        '<dateIssued encoding="marc">1599</dateIssued>' +
        mods_origin_info_end_str => [1598, '1598'],
      # nc111sz1016
      mods_origin_info_start_str +
        '<dateIssued>1643?]</dateIssued>' +
        '<dateIssued encoding="marc">1643</dateIssued>' +
        mods_origin_info_end_str => [1643, '1643'],
      # nh040md8464
      mods_origin_info_start_str +
        '<dateIssued>1643]</dateIssued>' +
        '<dateIssued encoding="marc">1643</dateIssued>' +
        mods_origin_info_end_str => [1643, '1643'],
      # kn933tp3421
      mods_origin_info_start_str +
        '<dateIssued>168-?]</dateIssued>' +
        '<dateIssued encoding="marc">168u</dateIssued>' +
        mods_origin_info_end_str => [1680, '1680s'],
      # cm303hd3051
      mods_origin_info_start_str +
        '<dateIssued>17--?]</dateIssued>' +
        '<dateIssued encoding="marc">17uu</dateIssued>' +
        mods_origin_info_end_str => [1700, '18th century'],
      # qg633rp87199h
      mods_origin_info_start_str +
        '<dateIssued>17--]</dateIssued>' +
        '<dateIssued encoding="marc">17uu</dateIssued>' +
        mods_origin_info_end_str => [1700, '18th century'],
      # cg009ks6415
      mods_origin_info_start_str +
        '<dateIssued>ca.170-?]</dateIssued>' +
        '<dateIssued encoding="marc">170u</dateIssued>' +
        mods_origin_info_end_str => [1700, '1700s'],
      # cy085vp3914
      mods_origin_info_start_str +
        '<dateIssued>[171-?]</dateIssued>' +
        '<dateIssued encoding="marc">171u</dateIssued>' +
        mods_origin_info_end_str => [1710, '1710s'],
      # nn822ff0715
      mods_origin_info_start_str +
        '<dateIssued>Anno 1622</dateIssued>' +
        '<dateIssued encoding="marc">1622</dateIssued>' +
        mods_origin_info_end_str => [1622, '1622'],
      # mn182sb2675
      mods_origin_info_start_str +
        '<dateIssued>[17--]</dateIssued>' +
        '<dateIssued encoding="marc">17uu</dateIssued>' +
        mods_origin_info_end_str => [1700, '18th century'],
      # ws465kb7898
      mods_origin_info_start_str +
        '<dateIssued>[17--?]</dateIssued>' +
        '<dateIssued encoding="marc">17uu</dateIssued>' +
        mods_origin_info_end_str => [1700, '18th century'],
      # sm817db3005
      mods_origin_info_start_str +
        '<dateIssued>[1764-1782]</dateIssued>' +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1764</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1782</dateIssued>s' +
        mods_origin_info_end_str => [1764, '1764 - 1782'],
      # dt360jc3286
      mods_origin_info_start_str +
        '<dateIssued>[ca. 1700]</dateIssued>' +
        '<dateIssued encoding="marc">1700</dateIssued>' +
        mods_origin_info_end_str => [1700, '1700'],
      # qc461vk9235
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">1666</dateCreated>' +
        '<dateCreated keyDate="no" qualifier="inferred">1666</dateCreated>' +
        mods_origin_info_end_str => [1666, '1666'],
      # pt603pv6417
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes">1698/1715</dateCreated>' +
        mods_origin_info_end_str => [1698, '1698'],
      # cr498zz3120
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" qualifier="inferred">1700?</dateCreated>' +
        mods_origin_info_end_str => [1700, '1700'],
      # px053ft5911
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">1732</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="no" qualifier="questionable">1732</dateCreated>' +
        mods_origin_info_end_str => [1732, '1732'],
      # xb526qv4524
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="no" point="end" qualifier="approximate">1939</dateCreated>' +
        '<dateCreated keyDate="yes" point="" qualifier="approximate">1930</dateCreated>' +
        mods_origin_info_end_str => [1930, '1930']
    },
  # mclaughlin_malta
  # medieval / mss
  'mss' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec dt056jp2574  (actually merges with marc 4082840)
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start" keyDate="yes">0850</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1499</dateIssued>' +
        mods_origin_info_end_str => [850, '850 A.D. - 1499'],
      # coll rec  bd001pp3337
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" keyDate="yes" point="start">1000</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1599</dateIssued>' +
        mods_origin_info_end_str => [1000, '1000 - 1599'],
      # coll rec fn508pj9953
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1400</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1600</dateIssued>' +
        mods_origin_info_end_str => [1400, '1400 - 1600'],
      # coll rec nd057tw6238
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start" keyDate="yes">1404</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1781</dateIssued>' +
        mods_origin_info_end_str => [1404, '1404 - 1781'],
      # coll rec pn981gz2244
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1310</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1500</dateIssued>' +
        mods_origin_info_end_str => [1310, '1310 - 1500'],
      # coll rec zv022sd1415
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" keyDate="yes" point="start" qualifier="questionable">1100</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1499</dateIssued>' +
        mods_origin_info_end_str => [1100, '1100 - 1499'],
      # hf970tz9706
      mods_origin_info_start_str +
        '<dateCreated point="start" qualifier="approximate" keyDate="yes">850</dateCreated>' +
        '<dateCreated point="end" qualifier="approximate">1499</dateCreated>' +
        mods_origin_info_end_str => [850, '850 A.D. - 1499'],
      # sc582cv9633
      mods_origin_info_start_str +
        '<dateCreated keydate="yes">1314</dateCreated>' +
        mods_origin_info_end_str => [1314, '1314'],
      # yc365tw0116
      mods_origin_info_start_str +
        '<dateCreated point="start" qualifier="approximate" keyDate="yes">1404</dateCreated>' +
        '<dateCreated point="end" qualifier="approximate">1781</dateCreated>' +
        mods_origin_info_end_str => [1404, '1404 - 1781'],
      # mf790cw8283
      mods_origin_info_start_str +
        '<dateCreated keydate="yes">August 18, 1552</dateCreated>' +
        mods_origin_info_end_str => [1552, '1552']
    },
  # menuez
  'me310' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec kq629sd5182 no date
      # sd594yd8504
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">2013-06-24</dateCreated>' +
        mods_origin_info_end_str => [2013, '2013'],
      # sw321tg6624
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">2013-06</dateCreated>' +
        mods_origin_info_end_str => [2013, '2013']
    },
  # mkultra
  # mlk
  # mlm ?
  # mpeg
  # mullin-palmer
  # nanoscale
  'norwich' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec qb438pg7646
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1486</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1865</dateIssued>' +
        mods_origin_info_end_str => [1486, '1486 - 1865'],
      # zv656kg5843
      mods_origin_info_start_str +
        '<dateIssued qualifier="questionable" point="start" keyDate="yes">1486</dateIssued>' +
        '<dateIssued qualifier="questionable" point="end">1865</dateIssued>' +
        mods_origin_info_end_str => [1486, '1486 - 1865'],
      # qx376cz2677
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="inferred">1814</dateCreated>' +
        mods_origin_info_end_str => [1814, '1814'],
      # fw226jy0133
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="inferred">1486</dateCreated>' +
        mods_origin_info_end_str => [1486, '1486'],
      # xp797gj2926
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="approximate" point="start">1646</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="no" qualifier="approximate" point="end">1647</dateCreated>' +
        mods_origin_info_end_str => [1646, '1646 - 1647'],
      # by909qy2837
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="">1795</dateCreated>' +
        mods_origin_info_end_str => [1795, '1795']
    },
  'nowinsky' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec sk882gx0113  but merges to marc 9685083
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="start">1981</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end">1982</dateCreated>' +
        mods_origin_info_end_str => [1981, '1981 - 1982'],
      # st181pw3134
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="start">1981</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end">1982</dateCreated>' +
        mods_origin_info_end_str => [1981, '1981 - 1982']
    },
  # paleo
  'papyri' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec jr022nf7673 has no dates
      # jx555jt0710
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" point="start" qualifier="approximate">199 B.C.</dateCreated>' +
        '<dateCreated keyDate="yes" point="end" qualifier="approximate">100 B.C.</dateCreated>' +
        mods_origin_info_end_str => [-198, '199 B.C. - 100 B.C.'],
      # ww728rz0477
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" point="start" qualifier="approximate">211 B.C.</dateCreated>' +
        '<dateCreated keyDate="yes" point="end" qualifier="approximate">150 B.C.</dateCreated>' +
        mods_origin_info_end_str => [-210, '211 B.C. - 150 B.C.']
    },
  # pcc
  # peace
  # peninsula_times ?
  # peoples_computer?
  # physics_ugrad
  # pippin
  # pleistocene
  'posada' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec fm601nw4733 merges with 4561410
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1875</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1913</dateIssued>' +
        mods_origin_info_end_str => [1875, '1875 - 1913'],
      # wb612pd9842
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf" point="start" qualifier="approximate">1852</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1925</dateCreated>' +
        mods_origin_info_end_str => [1852, '1852 - 1925']
    },
  # posttranslational
  # project_south
  # reaction_kinetics?
  # reliability
  'renaissance' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec sr605np6062 no originInfo
      # mj187xt5183
      mods_origin_info_start_str +
        '<dateIssued>A1566</dateIssued>' +
        '<dateIssued encoding="marc">1566</dateIssued>' +
        mods_origin_info_end_str => [1566, '1566'],
      # sy295vm4054
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1613</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1622</dateIssued>' +
        '<dateIssued>1613</dateIssued>' +
        '<dateIssued/>' +
        mods_origin_info_end_str => [1613, '1613 - 1622']
    },
  # renuwit
  'research-data' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec md919gh6774 no originInfo
      # qt411pj4511
      mods_origin_info_start_str +
        '<dateCreated point="start" keyDate="yes" encoding="w3cdtf">2009-05-10</dateCreated>' +
        '<dateCreated point="end" encoding="w3cdtf">2014-10-30</dateCreated>' +
        mods_origin_info_end_str => [2009, '2009 - 2014'],
      # zp707tw3135
      mods_origin_info_start_str +
        '<dateCreated qualifier="approximate" keyDate="yes" encoding="w3cdtf">2008</dateCreated>' +
        mods_origin_info_end_str => [2008, '2008'],
      # pw096jw7895
      mods_origin_info_start_str +
        '<dateCreated point="start" qualifier="approximate" keyDate="yes" encoding="w3cdtf">2014-03</dateCreated>' +
        '<dateCreated point="end" qualifier="approximate" encoding="w3cdtf">2015-06</dateCreated>' +
        mods_origin_info_end_str => [2014, '2014 - 2015']
    },
  # reservoir ?
  'roman coins' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec dq017bh9237 no dates
      # hs628wg6771
      mods_origin_info_start_str +
        '<dateCreated encoding="edtf" point="start" keyDate="yes">-18</dateCreated>' +
        '<dateCreated encoding="edtf" point="end">-17</dateCreated>' +
        mods_origin_info_end_str => [-18, '19 B.C. - 17 B.C.'],
      # bb408km1389
      mods_origin_info_start_str +
        '<dateCreated encoding="edtf" point="start" keyDate="yes">-1</dateCreated>' +
        '<dateCreated encoding="edtf" point="end">11</dateCreated>' +
        mods_origin_info_end_str => [-1, '2 B.C. - 11 A.D.'],
      # cs470ng8064
      mods_origin_info_start_str +
        '<dateCreated encoding="edtf" point="start" keyDate="yes">-1</dateCreated>' +
        '<dateCreated encoding="edtf" point="end">0</dateCreated>' +
        mods_origin_info_end_str => [-1, '2 B.C. - 0 A.D.'],
      # vh834jh5059
      mods_origin_info_start_str +
        '<dateCreated encoding="edtf" point="start" keyDate="yes">13</dateCreated>' +
        '<dateCreated encoding="edtf" point="end">14</dateCreated>' +
        mods_origin_info_end_str => [13, '13 A.D. - 14 A.D.'],
      # sk424bh9379
      mods_origin_info_start_str +
        '<dateCreated encoding="edtf" point="start" keyDate="yes">34</dateCreated>' +
        '<dateCreated encoding="edtf" point="end">35</dateCreated>' +
        mods_origin_info_end_str => [34, '34 A.D. - 35 A.D.']
    },
  # rigler
  # rumsey
  'rumsey' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec xh235dd9059 no originInfo
      # fy259fg4220
      mods_origin_info_start_str +
        '<dateIssued>1855.</dateIssued>' +
        mods_origin_info_end_str => [1855, '1855'],
      # hp058zk7170
      mods_origin_info_start_str +
        '<dateCreated encoding="marc">1861</dateCreated>' +
        '<dateIssued>1861.</dateIssued>' +
        mods_origin_info_end_str => [1861, '1861']
    },
  # rock?
  # scrf
  # shale
  'shpc' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec kx532cb7981
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1887</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1996</dateIssued>' +
        mods_origin_info_end_str => [1887, '1887 - 1996'],
      # cr293hs9054
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="">0000-00-00</dateCreated>' +
        mods_origin_info_end_str => [nil, nil],
      # dk829wf6922
      mods_origin_info_start_str +
        '<dateOther encoding="w3cdtf" keyDate="no" qualifier="">1958-07-00</dateOther>' +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier=" ">1869-00-00</dateCreated>' +
        mods_origin_info_end_str => [1869, '1869'],
      # fp085hf5015
      mods_origin_info_start_str +
        '<dateOther encoding="w3cdtf" keyDate="no" qualifier="">1963-10-11</dateOther>' +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier=" ">1903-00-00</dateCreated>' +
        mods_origin_info_end_str => [1903, '1903'],
      # jw898zj1914
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="no" qualifier="">1903-00-00</dateCreated>' +
        mods_origin_info_end_str => [1903, '1903'],
      # qc093gq8747
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier=" ">1903-00-00</dateCreated>' +
        mods_origin_info_end_str => [1903, '1903'],
      # rb666zx7087
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="approximate">1903-00-00</dateCreated>' +
        mods_origin_info_end_str => [1903, '1903'],
      # ft626rm4963
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier=" ">1972-07-00</dateCreated>' +
        mods_origin_info_end_str => [1972, '1972'],
      # ns466nn0465
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="no" qualifier="">1918-00-00</dateCreated>' +
        '<dateOther encoding="w3cdtf" keyDate="no" qualifier="">1968-02-00</dateOther>' +
        mods_origin_info_end_str => [1918, '1918']
    },
  # social_research_tech_reports ?
  # sounds?
  # spoke
  # stafford
  # stop_aids
  # sul_staff
  # tide_prediction?
  'uganda' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
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
        mods_origin_info_end_str => [2012, '2012'],
      # cz128vq0535
      mods_origin_info_start_str +
        '<publisher>Uganda Bureau of Statistics</publisher>
        <place>
          <placeTerm type="text">Kampala , UG</placeTerm>
        </place>
        <dateIssued encoding="w3cdtf" keyDate="yes">2005</dateIssued>
        <dateValid encoding="w3cdtf">2005</dateValid>' +
        mods_origin_info_end_str => [2005, '2005'],
      # cz128vq0535
      mods_origin_info_start_str +
        '<publisher>Uganda Bureau of Statistics</publisher>
        <place>
          <placeTerm type="text">Kampala , UG</placeTerm>
        </place>
        <dateIssued encoding="w3cdtf" keyDate="yes">2012</dateIssued>
        <dateValid encoding="w3cdtf" point="start">2008</dateValid>
        <dateValid encoding="w3cdtf" point="end">2010</dateValid>' +
        mods_origin_info_end_str => [2012, '2012']
    },
  # understanding_911?
  # urban
  # virtual_worlds
  # visitations
  # vista
  'walters' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec ww121ss5000
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">800</dateIssued>' +
        '<dateIssued encoding="marc" point="start">1899</dateIssued>' +
        mods_origin_info_end_str => [800, '800 A.D.'],
      # dc882bs3541
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" point="start" qualifier="approximate" keyDate="yes">0700</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end" qualifier="approximate">0799</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="yes"/>' +
        mods_origin_info_end_str => [700, '700 A.D. - 799 A.D.'],
      # hg026ds6978
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">0816</dateCreated>' +
        mods_origin_info_end_str => [816, '816 A.D.'],
      # ct437ht0445
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">0900</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end" qualifier="approximate">0999</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="yes"/>' +
        mods_origin_info_end_str => [900, '900 A.D. - 999 A.D.'],
      # ch617yk2621
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">1000</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1040</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="yes"/>' +
        mods_origin_info_end_str => [1000, '1000 - 1040'],
      # pc969nh5331
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">0950</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1000</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="yes"/>' +
        mods_origin_info_end_str => [950, '950 A.D. - 1000'],
      # hj537kj5737
      mods_origin_info_start_str +
        '<dateIssued>15th century CE</dateIssued>' +
        mods_origin_info_end_str => [1400, '15th century'],
      # gs755tr2814
      mods_origin_info_start_str +
        '<dateIssued>Ca. 1580 CE</dateIssued>' +
        mods_origin_info_end_str => [1580, '1580'],
      # hp976mx6580
      mods_origin_info_start_str +
        '<dateIssued>1500 CE</dateIssued>' +
        mods_origin_info_end_str => [1500, '1500']
    }
  # water
  # wilpf?
  # yotsuba
}.freeze
