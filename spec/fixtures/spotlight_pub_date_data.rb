mods_origin_info_start_str = "<mods xmlns=\"#{Mods::MODS_NS}\"><originInfo>"
mods_origin_info_end_str = '</originInfo></mods>'

SPOTLIGHT_PUB_DATE_DATA = {
  'batchelor' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # ct961sj2730 coll rec:  no originInfo dates)
      # dr330jt7122
      mods_origin_info_start_str +
        '<dateIssued>1843</dateIssued>' +
        mods_origin_info_end_str => ['1843', '1843'],
      # ds825sq5748
      mods_origin_info_start_str +
        '<dateIssued>s.a. [1712]</dateIssued>' +
        '<dateIssued encoding="marc">1712</dateIssued>' +
        mods_origin_info_end_str => ['1712', '1712'],
      # fk998cd4214
      mods_origin_info_start_str +
        '<dateIssued>1806]</dateIssued>' +
        '<dateIssued encoding="marc">1806</dateIssued>' +
        mods_origin_info_end_str => ['1806', '1806'],
      # gy889yj2171
      mods_origin_info_start_str +
        '<dateIssued>1758]</dateIssued>' +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1758</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">uuuu</dateIssued>' +
        mods_origin_info_end_str => ['1758', '1758'],
      # gw369sx8109
      mods_origin_info_start_str +
        '<dateIssued>179-?]</dateIssued>' +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1790</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1799</dateIssued>' +
        mods_origin_info_end_str => ['1790', '1790'],
      # ty320hx2831
      mods_origin_info_start_str +
        '<dateIssued>[1860-1869?]</dateIssued>' +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1860</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1890</dateIssued>' +
        mods_origin_info_end_str => ['1860', '1860']
    },
  'feigenbaum' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # coll rec
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1950</dateIssued>' +
        '<dateIssued encoding="marc" point="end">2007</dateIssued>' +
        mods_origin_info_end_str => ['1950', '1950'],
      # py696hw1646, jc364jw8333
        mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">2001-11-19</dateCreated>' +
        mods_origin_info_end_str => ['2001', '2001'],
      # yt809jk3834, qb375hy6817
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">1998-03-25</dateCreated>' +
        mods_origin_info_end_str => ['1998', '1998'],
      # mg505sz9327, mx006md9511, sy619vt7106
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" point="start" qualifier="approximate">1950</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end" qualifier="approximate">2007</dateCreated>' +
        mods_origin_info_end_str => ['1950', '1950'],
      # wb033rz4421, rg190zp1039
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">1960</dateCreated>' +
        mods_origin_info_end_str => ['1960', '1960']
    },
  'fitch' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # tv206kh7995
      mods_origin_info_start_str +
          '<dateIssued encoding="w3cdtf" keyDate="yes">2003</dateIssued>' +
        '</originInfo>' +
        '<originInfo displayLabel="Date Created">
          <dateCreated encoding="w3cdtf" keyDate="yes">2002</dateCreated>' +
        mods_origin_info_end_str => ['2003', '2003'],
      # jg756mq6272
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf" point="start" qualifier="approximate">1968</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1975</dateCreated>' +
        mods_origin_info_end_str => ['1968', '1968'],
      # jc865hw9993
        mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf">1970</dateCreated>' +
        mods_origin_info_end_str => ['1970', '1970']
    },
  'hanna_house' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # gb597yd7556 coll rec
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1935</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1995</dateIssued>' +
        mods_origin_info_end_str => ['1935', '1935'],
      # gb597yd7556
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1935</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1995</dateIssued>' +
        mods_origin_info_end_str => ['1935', '1935'],
      # zr891kq4418
      mods_origin_info_start_str +
        '<dateCreated point="start" keyDate="yes" encoding="w3cdtf">1914</dateCreated>' +
        '<dateCreated point="end" encoding="w3cdtf">1985</dateCreated>' +
        mods_origin_info_end_str => ['1914', '1914'],
      # dx393nr2700
      mods_origin_info_start_str +
        '<dateCreated point="start" keyDate="yes" encoding="w3cdtf">1937</dateCreated>' +
        '<dateCreated point="end" qualifier="approximate" encoding="w3cdtf">1986</dateCreated>' +
        mods_origin_info_end_str => ['1937', '1937']
    },
  'harrison' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # yb643gf8754
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf" point="start">2004</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end">2005</dateCreated>' +
        mods_origin_info_end_str => ['2004', '2004'],
      # qj294cd5539
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" encoding="w3cdtf" point="start" qualifier="approximate">1982</dateCreated>' +
        '<dateCreated encoding="w3cdtf" point="end" qualifier="approximate">1983</dateCreated>' +
        mods_origin_info_end_str => ['1982', '1982']
    },
  'heckrotte' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # rx637sx4870
      mods_origin_info_start_str +
        '<dateIssued encoding="marc">1914</dateIssued>' +
        mods_origin_info_end_str => ['1914', '1914'],
      # ds207gt5399
      mods_origin_info_start_str +
        '<dateIssued encoding="marc">9999</dateIssued>' +
        mods_origin_info_end_str => [nil, nil]
    },
  'matter' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # pj169kw1971 coll rec
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1937</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1984</dateIssued>' +
        mods_origin_info_end_str => ['1937', '1937'],
      # vx584zf3939
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="questionable">1954</dateCreated>' +
        mods_origin_info_end_str => ['1954', '1954'],
      # cp851bp7190
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="approximate" point="start">1937</dateCreated>' +
        '<dateCreated encoding="w3cdtf" qualifier="approximate" point="end">1984</dateCreated>' +
        mods_origin_info_end_str => ['1937', '1937'],
      # hr768nf5908
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes">1948-02-05</dateCreated>' +
        mods_origin_info_end_str => ['1948', '1948']
    },
  'mss' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # dt056jp2574 coll rec
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start" keyDate="yes">0850</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1499</dateIssued>' +
        mods_origin_info_end_str => ['0850', '850 A.D.'],
      # nc881qb8504
      mods_origin_info_start_str +
        '<dateCreated point="start" qualifier="approximate" keyDate="yes">1000</dateCreated>' +
        '<dateCreated point="end" qualifier="approximate">1599</dateCreated>' +
        mods_origin_info_end_str => ['1000', '1000'],
      # gq464qc3817
      mods_origin_info_start_str +
        '<dateCreated keydate="yes">1371</dateCreated>' +
        mods_origin_info_end_str => ['1371', '1371'],
      # pn981gz2244  (a coll rec)
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start">1310</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1500</dateIssued>' +
        mods_origin_info_end_str => ['1310', '1310'],
      # zv022sd1415 (a coll rec)
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" keyDate="yes" point="start" qualifier="questionable">1100</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1499</dateIssued>' +
        mods_origin_info_end_str => ['1100', '1100']
    },
  'muybridge_date_issued' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # rs028yq2265
      mods_origin_info_start_str +
        '<dateIssued>1876</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1876</dateIssued>' +
        mods_origin_info_end_str => ['1876', '1876'],
      # mb109mb4776
      mods_origin_info_start_str +
        '<dateIssued>1878]</dateIssued>' +
        '<dateIssued encoding="marc" keyDate="yes">1878</dateIssued>' +
        mods_origin_info_end_str => ['1878', '1878'],
      # ff991hz8300
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start" keyDate="yes">1868</dateIssued>' +
        '<dateIssued encoding="marc" point="end">1929</dateIssued>' +
        mods_origin_info_end_str => ['1868', '1868']
    },
  'norwich' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # qb438pg7646 - coll record
      mods_origin_info_start_str +
        '<dateIssued encoding="marc" point="start" qualifier="questionable">1486</dateIssued>' +
        '<dateIssued encoding="marc" point="end" qualifier="questionable">1865</dateIssued>' +
        mods_origin_info_end_str => ['1486', '1486'],
      # zv656kg5843 - dateIssued item record
      mods_origin_info_start_str +
        '<dateIssued qualifier="questionable" point="start" keyDate="yes">1486</dateIssued>' +
        '<dateIssued qualifier="questionable" point="end">1865</dateIssued>' +
        mods_origin_info_end_str => ['1486', '1486'],
      # vv001qm0627
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="">1792</dateCreated>' +
        mods_origin_info_end_str => ['1792', '1792'],
      # fw686gh2768
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="inferred">1700</dateCreated>' +
        mods_origin_info_end_str => ['1700', '1700'],
      # xp797gj2926, bd251fw4676
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="approximate" point="start">1646</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="no" qualifier="approximate" point="end">1647</dateCreated>' +
        mods_origin_info_end_str => ['1646', '1646'],
      # rw174jv7999
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="approximate" point="start">1836</dateCreated>' +
        '<dateCreated encoding="w3cdtf" keyDate="no" qualifier="approximate" point="end">1839</dateCreated>' +
        mods_origin_info_end_str => ['1836', '1836'],
      # kw395pq8862
      mods_origin_info_start_str +
        '<dateCreated encoding="w3cdtf" keyDate="yes" qualifier="questionable">1737</dateCreated>' +
        mods_origin_info_end_str => ['1737', '1737']
    },
  'papyri' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # hd778hw9236
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" point="start" qualifier="approximate">200 B.C.</dateCreated>' +
        '<dateCreated keyDate="yes" point="end" qualifier="approximate">180 B.C.</dateCreated>' +
        mods_origin_info_end_str => ['-801', '200 B.C.'],
      # ww728rz0477
      mods_origin_info_start_str +
        '<dateCreated keyDate="yes" point="start" qualifier="approximate">211 B.C.</dateCreated>' +
        '<dateCreated keyDate="yes" point="end" qualifier="approximate">150 B.C.</dateCreated>' +
        mods_origin_info_end_str => ['-790', '211 B.C.']
    },
  'renaissance' =>
    { # key is mods_xml;  values = [pub date sortable facet value, pub date single string facet value]
      # qm115qm4767
      mods_origin_info_start_str +
        '<dateIssued>1621</dateIssued>' +
        mods_origin_info_end_str => ['1621', '1621'],
      # ph263cq3186
      mods_origin_info_start_str +
          '<dateIssued encoding="marc">16uu</dateIssued>' +
        '</originInfo>
        <originInfo>
          <dateIssued>approximately 1600-1700.</dateIssued>' +
        mods_origin_info_end_str => ['1600', '1600'],
      # vm330vk8699
      mods_origin_info_start_str +
          '<dateIssued encoding="marc" point="start">1552</dateIssued>' +
          '<dateIssued encoding="marc" point="end">1575</dateIssued>' +
        '</originInfo>
        <originInfo>
          <dateIssued>1544-1628]</dateIssued>' +
        mods_origin_info_end_str => ['1544', '1544'],
      # fs844yc9264
      mods_origin_info_start_str +
        '<dateIssued>1486]</dateIssued>' +
        '<dateIssued encoding="marc">1486</dateIssued>' +
        mods_origin_info_end_str => ['1486', '1486'],
      # yx539ps2472
      mods_origin_info_start_str +
        '<dateIssued>January 6th, 1801</dateIssued>' +
        '<dateIssued encoding="marc">1801</dateIssued>' +
        mods_origin_info_end_str => ['1801', '1801'],
      # tf692ty4668
      mods_origin_info_start_str +
        '<dateIssued>anno j65i [1651]</dateIssued>' +
        '<dateIssued encoding="marc">1651</dateIssued>' +
        mods_origin_info_end_str => ['1651', '1651'],
      # wd342hc6856
      mods_origin_info_start_str +
        '<dateIssued>[1657?]</dateIssued>' +
        '<dateIssued encoding="marc">1657</dateIssued>' +
        mods_origin_info_end_str => ['1657', '1657'],
      # tg585cq2576
      mods_origin_info_start_str +
        '<dateIssued encoding="marc">1681</dateIssued>' +
        '</originInfo>
        <originInfo>
          <dateIssued>im jahr 1681</dateIssued>' +
        mods_origin_info_end_str => ['1681', '1681'],
      # bf004gy8502
      mods_origin_info_start_str +
          '<dateIssued encoding="marc">1683</dateIssued>' +
        '</originInfo>
        <originInfo displayLabel="publisher">
          <dateIssued>anno Christi MDCLXXXIII [1683]</dateIssued>' +
        mods_origin_info_end_str => ['1683', '1683'],
      # vq586cs8631
      mods_origin_info_start_str +
        '<dateIssued encoding="marc">1686</dateIssued>' +
        mods_origin_info_end_str => ['1686', '1686'],
      # gx634bc5110
      mods_origin_info_start_str +
        '<dateIssued>[1692-1694]</dateIssued>' +
        '<dateIssued encoding="marc">1692</dateIssued>' +
        mods_origin_info_end_str => ['1692', '1692'],
      # mc166br4447
      mods_origin_info_start_str +
        '<dateIssued>approximately 1786]</dateIssued>' +
        '<dateIssued encoding="marc">1786</dateIssued>' +
        mods_origin_info_end_str => ['1786', '1786']
    }
}.freeze
