# encoding: utf-8
describe "date parsing methods" do
  unparseable = [ # here to remind us of what they might look like in our data
    nil,
    '',
    '[]',
    '?',
    'uuuu',
    'Aug',
    'publiée le 26 germinal an VI',
    "l'an IVe",
    'Feb',
    "L'AN 2 DE LA // LIBERTÉ",
    'Paris',
    "publié en frimaire l'an 3.e de la République française",
    'an 6',
    'an sept',
    's.n.]',
    'M. D. LXI',
    '[An 4]',
    '[s.d.]',
    'Undated',
    '1uuu'
  ]
  # example string as key, expected parsed value as value
  invalid_but_can_get_year = {
    '1966-14-14' => '1966',  # 14 isn't a valid month ...
    '1966\4\11' => '1966',   # slashes wrong way
    '2/31/1950' => '1950',   # no 31 of Feb
    '1869-00-00' => '1869',
    '1862-01-00' => '1862',
    '1985-05-00' => '1985'
  }
  # example string as key, expected parsed value as value
  single_year = {
    '0700' => '0700',
    '0999' => '0999',
    '1000' => '1000',
    '1798' => '1798',
    '1583.' => '1583',
    '1885-' => '1885',
    '1644.]' => '1644',
    '1644]' => '1644',
    '1584].' => '1584',
    '1729?]' => '1729',
    '1500 CE' => '1500',
    '1877?' => '1877',
    '1797 goda' => '1797',
    "1616: Con licenza de'svperiori" => '1616',

    '[1789]' => '1789',
    '[1968?-' => '1968',
    '[1860?]' => '1860',
    '[1789 ?]' => '1789',
    '[[1790]]' => '1790',
    '[1579].' => '1579',
    '[Ca 1790]' => '1790',
    '[c1926]' => '1926',
    '[ca 1790]' => '1790',
    '[ca. 1790]' => '1790',
    '[ca. 1850?]' => '1850',
    '[ca.1600]' => '1600',
    '[after 1726]' => '1726',
    '[an II, i.e. 1794]' => '1794',
    '[approximately 1600]' => '1600',
    '[approximately 1558].' => '1558',
    '[approximately 1717?]' => '1717',
    '[not after 1652]' => '1652',
    '[not before 1543].' => '1543',

    "A' 1640" => '1640',
    'A1566' => '1566',
    'Ans. 1656' => '1656',
    'Antonio Laffreri 1570' => '1570',
    'An 6. 1798' => '1798',
    'An 6 1798' => '1798',
    'a. 1652' => '1652',
    'ad decennium 1592' => '1592',
    'after 1622' => '1622',
    'an 10 (1802)' => '1802',
    'an 14, 1805' => '1805',
    'anno 1801' => '1801',
    'anno 1603.' => '1603',
    'approximately 1580.' => '1580',
    'approximately 1700?' => '1700',
    'approximately 1544]' => '1544',
    'anno 1599 (v. 1).' => '1599',
    'anno MDCXXXV [1635].' => '1635',
    'anno dom. 1600 (v. 3).' => '1600',
    'anno j65i [1651]' => '1651',
    'Ca. 1580 CE' => '1580',
    'c1887' => '1887',
    'ca 1796]' => '1796',
    'ca. 1558' => '1558',
    'ca. 1560?]' => '1560',
    'ca. 1700]' => '1700',
    'circa 1860' => '1860',
    'copyright 1855' => '1855',
    'en 1788' => '1788',
    'im jahr 1681' => '1681',
    "l'an 1.er de la Rep. 1792" => '1792',
    "l'anno1570" => '1570',
    'MDLXXXVIII [1588]]' => '1588',
    'MDLXI [1561]' => '1561',
    'MDCCLII. [1752-' => '1752',
    'No. 15 1792' => '1792',
    's.a. [1712]' => '1712',
    'publié le 24 floréal [1796]' => '1796',
    "Fructidor l'an 3.e [i.e. 1795]" => '1795'
  }
  # example string as key, expected parsed value as value
  specific_month = {
    '1975-05' => '1975', # vs 1918-27
    '1996 Jun' => '1996',
    'February 1798' => '1798',
    'March, 1794' => '1794',
    '[ ?] 10 1793' => '1793',
    'agosto 1799' => '1799',
    'Jan.y. thes.et 1798' => '1798',
    '[[décembre 1783]]' => '1783',
    'im Mai 1793' => '1793',
    'in Febr. 1795' => '1795',
    "juin année 1797" => '1797'
  }
  # example string as key, expected parsed value as value
  specific_day = {
    '1/1/1961' => '1961',
    '10/1/1987' => '1987',
    '5-1-1959' => '1959',

    # year first
    '1888-02-18' => '1888',
    '1966-2-5' => '1966',

    # text; starts with day
    '1 July 1799' => '1799',
    '1 Feb. 1782' => '1782',
    '15 Jan.y 1797' => '1797',
    '12.th May 1794' => '1794',
    '12th May 1794' => '1794',
    '12th Dec.r 1794' => '1794',
    '14th Feb.y 1794' => '1794',
    '18 Febr. 1790' => '1790',
    '23 Nov.r 1797' => '1797',

    # text; starts with year
    '1793 March 1st' => '1793',
    '1892, Jan. 1' => '1892',
    '1991 May 14' => '1991',
    '1997 Sep 6' => '1997',

    # text starts with words
    'Boston, November 25, 1851' => '1851',
    'd. 16 Feb. 1793' => '1793',
    'published the 30 of June 1799' => '1799',
    'Published the 1 of June 1799' => '1799',
    'Pub.d Nov.r 1st 1798' => '1798',
    'Published July 5th, 1784' => '1784',

    # text starts with month
    'April 01 1797' => '1797',
    'April 1 1796' => '1796',
    'April 1. 1796' => '1796',
    'April 16, 1632' => '1632',
    'April 11th 1792' => '1792',
    '[April 1 1795]' => '1795',

    'Aug. 1st 1797' => '1797',
    'Aug 30th 1794' => '1794',
    'Aug. 16 1790' => '1790',
    'Aug. 20, 1883' => '1883',
    'Aug. 3rd, 1886' => '1886',
    'Aug.st 4 1795' => '1795',
    'Aug.t 16 1794' => '1794',
    'Augt. 29, 1804' => '1804',
    'August 1 1794' => '1794',

    'Dec. 1 1792' => '1792',
    'Dec.r 1 1792' => '1792',
    'Dec.r 8th 1798' => '1798',
    'Decb.r 1, 1789' => '1789',
    'December 16 1795' => '1795',

    'Feb 12 1800' => '1800',
    'Feb. 10 1798' => '1798',
    'Feb. 25, 1744]' => '1744',
    'Feb.ry 12 1793' => '1793',
    'Feb.ry 7th 1796' => '1796',
    'Feb.y 1 1794' => '1794',
    'Feb.y 13th 1798' => '1798',
    'Feb.y 23rd 1799' => '1799',
    '[Feb.y 18 1793]' => '1793',

    'Jan. 1 1789' => '1789',
    'Jan. 1. 1795' => '1795',
    'Jan.y 15. 1795' => '1795',
    'Jan.y 12st 1793' => '1793',
    'Jan.y 18th 1790' => '1790',

    'July 1 1796' => '1796',
    'July 1. 1793' => '1793',
    'July 13, 1787' => '1787',
    'July 15th 1797' => '1797',

    'June 1 1793' => '1793',
    'June 1. 1800' => '1800',
    'June1st.1805' => '1805',
    'June 22, 1804' => '1804',
    'July 23d 1792' => '1792',
    'June 30th 1799' => '1799',
    '[June 2 1793]' => '1793',

    'May 9, 1795' => '1795',
    'May 12 1792' => '1792',
    'May 21st 1798' => '1798',
    'May 15th 1798' => '1798',

    'Mar. 1. 1792' => '1792',
    'March 1 1795' => '1795',
    'March 1.t 1797' => '1797',
    'March 1, 1793' => '1793',
    'March 1st 1797' => '1797',
    'March 6th 1798' => '1798',
    '[March 16 1798]' => '1798',

    'Nov. 1. 1796' => '1796',
    'Nov. 14th 1792' => '1792',
    'Nov. 20 1789' => '1789',
    'Nov.r 9, 1793' => '1793',
    'Novem. 13th 1797' => '1797',
    'Novembr 22nd 1794' => '1794',

    'Oct 12 1792' => '1792',
    'Oct 18th 1794' => '1794',
    'Oct. 29 1796' => '1796',
    'Oct. 11th 1794' => '1794',
    'Oct.er 1st 1786' => '1786',
    'Oct.r 25 1796' => '1796',
    'Oct.r 25th 1794' => '1794',
    'Octo.r 15 1795' => '1795',

    'Sep.r 1, 1795' => '1795',
    'Sep.tr 15.th 1796' => '1796',
    'Sept.r 5th 1793' => '1793'
  }
  specific_day_ruby_parse_fail = {
    # note ruby Date.parse only handles american or euro date order, not both ??
    '1/30/1979' => '1979',
    '10/20/1976' => '1976',
    '5-18-2014' => '2014',
    # year first
    '1980-23-02' => '1980',
    '1792 20 Dec' => '1792',
    # text
    'le 22 juin 1794' => '1794',
    'mis au jour le 26 juillet 1791' => '1791',
    'April 12 sd 1794' => '1794',
    'Dec. 10 & 11, 1855' => '1855',
    'January 22th [1800]' => '1800',
    'June the 12, 1794' => '1794',
    'Mai 1st 1789' => '1789',
    'March 22 d. 1794' => '1794',
    'N. 7 1796' => '1796',
    'N[ovember] 21st 1786' => '1786',
    'Oct. the 2.d 1793' => '1793'
  }
  # example string as key, expected parsed value as value
  specific_day_2_digit_year = {
    '1/2/79' => '1979',
    '2/12/15' => '2015',
    '6/11/99' => '1999',
    '10/1/90' => '1990',
    '10/21/08' => '2008',
    '5-1-59' => '1959',
    '5-1-21' => '1921',
    '5-1-14' => '2014'
  }
  # example string as key, expected parsed value as value
  multiple_years = {
    '1783-1788' => ['1783', '1784', '1785', '1786', '1787', '1788'],
    '1862-1868]' => ['1862', '1863', '1864', '1865', '1866', '1867', '1868'],
    '1640-1645?]' => ['1640', '1641', '1642', '1643', '1644', '1645'],
    '1578, 1584]' => ['1578', '1584'],
    '1860, [1862]' => ['1860', '1862'],
    '1901, c1900' => ['1901', '1900'], # pub date is one without the c,
    '1627 [i.e. 1646]' => ['1627', '1646'],
    '1698/1715' => ['1698', '1715'],
    '1965,1968' => ['1965', '1968'], # revs
    '1965|1968' => ['1965', '1968'], # revs
    '1789 ou 1790]' => ['1789', '1790'],
    '1689 [i.e. 1688-89]' => ['1689', '1688'],
    '1598 or 1599' => ['1598', '1599'],
    '1890 [c1884]' => ['1890', '1884'], # pub date is one without the c
    '1873,c1868' => ['1873', '1868'], # # pub date is one without the c
    '1872-1877 [t.5, 1874]' => ['1872', '1873', '1874', '1875', '1876', '1877'],
    '1809 [ca. 1810]' => ['1809', '1810'],
    '1726 or 1738]' => ['1726', '1738'],

    '[1789-1791]' => ['1789', '1790', '1791'],
    '[1627-1628].' => ['1627', '1628'],
    '[1789-1791' => ['1789', '1790', '1791'],
    '[1793 ou 1794]' => ['1793', '1794'],
    '[entre 1789 et 1791]' => ['1789', '1790', '1791'],
    '[Entre 1789 et 1791]' => ['1789', '1790', '1791'],
    '[entre 1789-1791]' => ['1789', '1790', '1791'],
    '[entre 1789 et 1791 ?]' => ['1789', '1790', '1791'],
    '[between 1882 and 1887]' => ['1882', '1883', '1884', '1885', '1886', '1887'],
    '[ca 1789-1791]' => ['1789', '1790', '1791'],
    '[ca 1790 et 1792]' => ['1790', '1791', '1792'],
    '[ca. 1550-1552]' => ['1550', '1551', '1552'],

    'Anno 1789-1790' => ['1789', '1790'],
    "L'an VII de la République [1798 or 1799]" => ['1798', '1799'],
    'MDCXIII [1613] (v. 1); MDLXXXIII [1583] (v. 2); and MDCVI [1606] (v. 3).' => ['1613', '1583', '1606'],
    'entre 1793 et 1795' => ['1793', '1794', '1795'],
    'entre 1793 et 1795]' => ['1793', '1794', '1795'],
    'approximately 1600-1602.' => ['1600', '1601', '1602'],
    'approximately 1650-1652]' => ['1650', '1651', '1652'],
    'approximately 1643-1644.]' => ['1643', '1644'],
    'ca. 1740-1745]' => ['1740', '1741', '1742', '1743', '1744', '1745'],
    'circa 1851-1852' => ['1851', '1852'],
    's.a. [ca. 1660, erschienen: 1782]' => ['1660', '1782'],
    'view of approximately 1848, published about 1865' => ['1848', '1865']
  }
  # example string as key, expected parsed value as value
  multiple_years_4_digits_once = {
    '1918-20' => ['1918', '1919', '1920'], # vs. 1961-04
    '1965-8' => ['1965', '1966', '1967', '1968'], # revs
    '[1846-51]' => ['1846', '1847', '1848', '1849', '1850', '1851']
  }
  # example string as key, expected parsed value as value
  decade_only_4_digits = {
    'early 1890s' => ['1890', '1891', '1892', '1893', '1894', '1895', '1896', '1897', '1898', '1899'],
    '1950s' => ['1950', '1951', '1952', '1953', '1954', '1955', '1956', '1957', '1958', '1959'],
    "1950's" => ['1950', '1951', '1952', '1953', '1954', '1955', '1956', '1957', '1958', '1959']
  }
  decade_only = {
    '156u' => ['1560', '1561', '1562', '1563', '1564', '1565', '1566', '1567', '1568', '1569'],
    '167-?]' => ['1670', '1671', '1672', '1673', '1674', '1675', '1676', '1677', '1678', '1679'],
    '[171-?]' => ['1710', '1711', '1712', '1713', '1714', '1715', '1716', '1717', '1718', '1719'],
    '[189-]' => ['1890', '1891', '1892', '1893', '1894', '1895', '1896', '1897', '1898', '1899'],
    'ca.170-?]' => ['1700', '1701', '1702', '1703', '1704', '1705', '1706', '1707', '1708', '1709'],
    '200-?]' => ['2000', '2001', '2002', '2003', '2004', '2005', '2006', '2007', '2008', '2009'],
    '186?' => ['1860', '1861', '1862', '1863', '1864', '1865', '1866', '1867', '1868', '1869'],
    '195x' => ['1950', '1951', '1952', '1953', '1954', '1955', '1956', '1957', '1958', '1959']
  }
  century_only = {
    '18th century CE' => '18th century',
    '17uu' => '18th century',
    '17--?]' => '18th century',
    '17--]' => '18th century',
    '[17--]' => '18th century',
    '[17--?]' => '18th century'
  }
  brackets_in_middle_of_year = {
    '169[5]' => '1695',
    'October 3, [18]91' => '1891'
  }
  # we have data like this for our Roman coins collection
  early_numeric_dates = {
    # note that values must lexically sort to create a chronological sort. (-999 before -914)
    '-999' => '-001',
    '-914' => '-086',
    '-18' => '-982',
    '-1' => '-999',
    '0' => '0000',
    '5' => '0005',
    '33' => '0033',
    '945' => '0945'
  }
  bc_dates = {
    # note that values must lexically sort to create a chronological sort (800 B.C. before 750 B.C.)
    '801 B.C.' => '-199',
    '800 B.C.' => '-200',
    '750 B.C.' => '-250',
    '700 B.C.' => '-300',
    '699 B.C.' => '-301',
    '75 B.C.' => '-925',
    '8 B.C.' => '-992'
  }
  bc_dates_to_int = {
    '801 B.C.' => -801,
    '800 B.C.' => -800,
    '750 B.C.' => -750,
    '700 B.C.' => -700,
    '699 B.C.' => -699,
    '75 B.C.' => -75,
    '8 B.C.' => -8
  }

  context '*date_str_for_display' do
    it 'calls instance method date_str_for_display' do
      expect_any_instance_of(Stanford::Mods::DateParsing).to receive(:date_str_for_display)
      Stanford::Mods::DateParsing.date_str_for_display('1666')
    end
  end
  context '*sortable_year_string_from_date_str' do
    it 'calls instance method sortable_year_string_from_date_str' do
      expect_any_instance_of(Stanford::Mods::DateParsing).to receive(:sortable_year_string_from_date_str)
      Stanford::Mods::DateParsing.sortable_year_string_from_date_str('1666')
    end
  end
  context '*year_int_from_date_str' do
    it 'calls instance method year_int_from_date_str' do
      expect_any_instance_of(Stanford::Mods::DateParsing).to receive(:year_int_from_date_str)
      Stanford::Mods::DateParsing.year_int_from_date_str('1666')
    end
  end

  context '#date_str_for_display' do
    single_year
      .merge(specific_month)
      .merge(specific_day)
      .merge(specific_day_2_digit_year)
      .merge(specific_day_ruby_parse_fail)
      .merge(century_only)
      .merge(brackets_in_middle_of_year)
      .merge(invalid_but_can_get_year).each do |example, expected|
      expected = expected.to_i.to_s if expected =~ /^\d+$/
      expected = "#{expected} A.D." if expected =~ /^\d{1,3}$/
      it "#{expected} for single value #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).date_str_for_display).to eq expected
      end
    end

    decade_only
      .merge(decade_only_4_digits).each do |example, expected|
      expected = "#{expected.first.to_i}s" if expected.first =~ /^\d+$/
      it "#{expected} for decade #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).date_str_for_display).to eq expected
      end
    end

    multiple_years
      .merge(multiple_years_4_digits_once).each do |example, expected|
      it "#{expected.first} for multi-value #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).date_str_for_display).to eq expected.first
      end
    end

    early_numeric_dates.each do |example, expected|
      if example.start_with?('-') || example == '0'
        exp = "#{example[1..-1].to_i + 1} B.C."
        it "#{exp} for #{example}" do
          expect(Stanford::Mods::DateParsing.new(example).date_str_for_display).to eq exp
        end
      else
        expected = "#{expected.to_i} A.D." if expected =~ /^\d+$/
        it "#{expected} for #{example}" do
          expect(Stanford::Mods::DateParsing.new(example).date_str_for_display).to eq expected
        end
      end
    end

    it 'handled year "0" correctly' do
      expect(Stanford::Mods::DateParsing.new('0').date_str_for_display).to eq '1 B.C.'
    end

    bc_dates.keys.each do |example|
      it "#{example} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).date_str_for_display).to eq example
      end
    end
    it '1600 B.C. for 1600 B.C.' do
      expect(Stanford::Mods::DateParsing.new('1600 B.C.').date_str_for_display).to eq '1600 B.C.'
    end

    [ # bad dates
      '9999',
      '2035',
      '0000-00-00',
      'uuuu',
      '1uuu'
    ].each do |example|
      it "nil for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).date_str_for_display).to eq nil
      end
    end
  end

  context '#year_int_from_date_str' do
    single_year
      .merge(specific_month)
      .merge(specific_day)
      .merge(specific_day_2_digit_year)
      .merge(bc_dates_to_int)
      .merge(specific_day_ruby_parse_fail)
      .merge(brackets_in_middle_of_year)
      .merge(invalid_but_can_get_year).each do |example, expected|
      it "#{expected} for single value #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).year_int_from_date_str).to eq expected.to_i
      end
    end

    multiple_years
      .merge(multiple_years_4_digits_once)
      .merge(decade_only)
      .merge(decade_only_4_digits).each do |example, expected|
      it "#{expected.first} for multi-value #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).year_int_from_date_str).to eq expected.first.to_i
      end
    end

    century_only.keys.each do |example|
      it "1700 from #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).year_int_from_date_str).to eq 1700
      end
    end

    early_numeric_dates.each do |example, _expected|
      it "#{example} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).year_int_from_date_str).to eq example.to_i
      end
    end

    it 'nil for -1666' do
      skip("code broken for -yyyy dates but no existing data for this yet")
      expect(Stanford::Mods::DateParsing.new('-1666').year_int_from_date_str).to eq nil
    end
    it '-1666 for 1666 B.C.' do
      expect(Stanford::Mods::DateParsing.new('1666 B.C.').year_int_from_date_str).to eq(-1666)
    end

    [ # bad dates
      '9999',
      '2035',
      '0000-00-00',
      'uuuu',
      '1uuu'
    ].each do |example|
      it "nil for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).year_int_from_date_str).to eq nil
      end
    end
  end

  context '#sortable_year_string_from_date_str' do
    single_year
      .merge(specific_month)
      .merge(specific_day)
      .merge(specific_day_2_digit_year)
      .merge(specific_day_ruby_parse_fail)
      .merge(early_numeric_dates)
      .merge(bc_dates)
      .merge(brackets_in_middle_of_year)
      .merge(invalid_but_can_get_year).each do |example, expected|
      it "#{expected} for single value #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_string_from_date_str).to eq expected
      end
    end

    multiple_years
      .merge(multiple_years_4_digits_once)
      .merge(decade_only)
      .merge(decade_only_4_digits).each do |example, expected|
      it "#{expected.first} for multi-value #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_string_from_date_str).to eq expected.first
      end
    end

    century_only.keys.each do |example|
      it "1700 from #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_string_from_date_str).to eq '1700'
      end
    end
    it '0700 for 7--' do
      expect(Stanford::Mods::DateParsing.new('7--').sortable_year_string_from_date_str).to eq '0700'
    end

    it 'nil for 1600 B.C.' do
      skip "code broken for dddd B.C. but no existing data for this yet"
      expect(Stanford::Mods::DateParsing.new('1600 B.C.').sortable_year_string_from_date_str).to eq nil
    end

    [ # bad dates
      '9999',
      '2035',
      '0000-00-00',
      'uuuu',
      '1uuu'
    ].each do |example|
      it "nil for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_string_from_date_str).to eq nil
      end
    end
  end

  context '*year_str_valid?' do
    { # example string as key, expected result as value
      '-1000' => false,
      '-999' => true,
      '-35' => true,
      '-3' => true,
      '0000' => true,
      '0' => true,
      '5' => true,
      '33' => true,
      '150' => true,
      (Date.today.year + 1).to_s => true, # current year + 1
      (Date.today.year + 2).to_s => false, # current year + 2
      '9999' => false,
      '165x' => false,
      '198-' => false,
      'random text' => false,
      nil => false
    }.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.year_str_valid?(example)).to eq expected
      end
    end
  end

  context '*year_int_valid?' do
    { # example int as key, expected result as value
      -1666 => false,
      -999 => true,
      -35 => true,
      -3 => true,
      0 => true,
      5 => true,
      33 => true,
      150 => true,
      (Date.today.year + 1) => true, # current year + 1
      (Date.today.year + 2) => false, # current year + 2
      9999 => false,
      '165x' => false,
      '198-' => false,
      'random text' => false,
      nil => false
    }.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.year_int_valid?(example)).to eq expected
      end
    end
    it 'true for 0000' do
      expect(Stanford::Mods::DateParsing.year_int_valid?(0000)).to eq true
    end
  end

  context '#sortable_year_for_yyyy' do
    single_year
      .merge(specific_month)
      .merge(specific_day)
      .merge(invalid_but_can_get_year)
      .merge(specific_day_ruby_parse_fail).each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_for_yyyy).to eq expected
      end
    end

    multiple_years
      .merge(multiple_years_4_digits_once)
      .merge(decade_only_4_digits).each do |example, expected|
      it "#{expected.first} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_for_yyyy).to eq expected.first
      end
    end

    # indicate some of the strings this method cannot handle (so must be parsed with other instance methods)
    unparseable
      .push(*brackets_in_middle_of_year.keys)
      .push(*specific_day_2_digit_year.keys)
      .push(*decade_only.keys)
      .push(*century_only.keys).each do |example|
      it "nil for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_for_yyyy).to eq nil
      end
    end
  end

  context '#sortable_year_for_yy' do
    specific_day_2_digit_year.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_for_yy).to eq expected
      end
    end
    it '2000 for 12/25/00' do
      expect(Stanford::Mods::DateParsing.new('12/25/00').sortable_year_for_yy).to eq '2000'
    end

    # indicate some of the strings this method cannot handle (so must be parsed with other instance methods)
    [
      '92/1/31',  # yy/mm/dd:  doesn't work.  :-(
      '92-31-1',  # yy-dd-mm:  doesn't work.  :-(
    ].push(*decade_only.keys).each do |example|
      it "nil for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_for_yy).to eq nil
      end
    end
  end

  context '#sortable_year_for_decade' do
    decade_only.each do |example, expected|
      it "#{expected.first} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_for_decade).to eq expected.first
      end
    end
    { # example string as key, expected result as value
      '199u' => '1990',
      '200-' => '2000',
      '201?' => '2010',
      '202x' => '2020'
    }.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_for_decade).to eq expected
      end
    end

    # some of the strings this method cannot handle (so must be parsed with other instance methods)
    decade_only_4_digits.keys
      .push(*specific_day_2_digit_year.keys).each do |example|
      it "nil for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_for_decade).to eq nil
      end
    end
  end

  context '#display_str_for_decade' do
    decade_only.each do |example, expected|
      it "#{expected.first} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).display_str_for_decade).to eq "#{expected.first}s"
      end
    end
    { # example string as key, expected result as value
      '199u' => '1990s',
      '200-' => '2000s',
      '201?' => '2010s',
      '202x' => '2020s',
      'early 1890s' => '1890s',
      '1950s' => '1950s',
      "1950's" => '1950s'
    }.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).display_str_for_decade).to eq expected
      end
    end

    # some of the strings this method cannot handle (so must be parsed with other instance methods)
    specific_day_2_digit_year.keys.each do |example|
      it "nil for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).display_str_for_decade).to eq nil
      end
    end
  end

  context '#sortable_year_for_century' do
    century_only.keys.each do |example|
      it "1700 from #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_for_century).to eq '1700'
      end
    end
    it '0700 for 7--' do
      expect(Stanford::Mods::DateParsing.new('7--').sortable_year_for_century).to eq '0700'
    end
    it 'nil for 7th century B.C. (to be handled in different method)' do
      expect(Stanford::Mods::DateParsing.new('7th century B.C.').sortable_year_for_century).to eq nil
    end
  end

  context '#display_str_for_century' do
    century_only.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).display_str_for_century).to eq expected
      end
    end
    { # example string as key, expected result as value
      '16--' => '17th century',
      '7--' => '8th century',
      # check suffixes
      '20--' => '21st century',
      '1--' => '2nd century',
      '2--' => '3rd century'
    }.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).display_str_for_century).to eq expected
      end
    end

    it 'nil for 7th century B.C. (to be handled in different method)' do
      expect(Stanford::Mods::DateParsing.new('7th century B.C.').display_str_for_century).to eq nil
    end
  end

  context '#sortable_year_int_for_early_numeric' do
    early_numeric_dates.each do |example, _expected|
      it "#{example} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_int_for_early_numeric).to eq example.to_i
      end
    end
  end

  context '#sortable_year_str_for_early_numeric' do
    early_numeric_dates.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_str_for_early_numeric).to eq expected
      end
    end
  end

  context '#display_str_for_early_numeric' do
    early_numeric_dates.each do |example, expected|
      expected = expected.to_i.to_s if expected =~ /^\d+$/
      if example.start_with?('-') || example == '0'
        exp = "#{example[1..-1].to_i + 1} B.C."
        it "#{exp} for #{example}" do
          expect(Stanford::Mods::DateParsing.new(example).display_str_for_early_numeric).to eq exp
        end
      else
        exp = "#{expected} A.D."
        it "#{expected} for #{example}" do
          expect(Stanford::Mods::DateParsing.new(example).display_str_for_early_numeric).to eq exp
        end
      end
    end
  end

  context '#sortable_year_int_for_bc' do
    bc_dates_to_int.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_int_for_bc).to eq expected
      end
    end
  end

  context '#sortable_year_str_for_bc' do
    bc_dates.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).sortable_year_str_for_bc).to eq expected
      end
    end
  end

  context '#display_str_for_bc' do
    bc_dates.keys.each do |example|
      it "#{example} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).display_str_for_bc).to eq example
      end
    end
    it '1600 B.C. for 1600 B.C.' do
      expect(Stanford::Mods::DateParsing.new('1600 B.C.').display_str_for_bc).to eq '1600 B.C.'
    end
  end

  context '#year_via_ruby_parsing' do
    specific_day.each do |example, expected|
      it "#{expected} for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).year_via_ruby_parsing).to eq expected
      end
    end

    # some of the strings this method cannot handle (and must be parsed with other instance methods)
    multiple_years.keys
      .push(*multiple_years_4_digits_once.keys)
      .push(*decade_only_4_digits.keys)
      .push(*century_only.keys)
      .push(*invalid_but_can_get_year.keys).each do |example|
      it "nil for #{example}" do
        expect(Stanford::Mods::DateParsing.new(example).year_via_ruby_parsing).to eq nil
      end
    end

    # data works via #sortable_year_for_yyyy (and don't all work here):
    #   single_year
    #   specific_month
    #   specific_day_ruby_parse_fail

    # data fails *sortable_year_for_yyyy AND for *year_via_ruby_parsing:
    #   multiple_years
    #   century_only

    # data fails *sortable_year_for_yyyy
    # and partially works for *year_via_ruby_parsing:
    skip 'parsed incorrectly' do
      # assigns incorrect values to 13 out of 92 (rest with no val assigned)
      unparseable.each do |example|
        it "nil for unparseable: #{example}" do
          expect(Stanford::Mods::DateParsing.new(example).year_via_ruby_parsing).to eq nil
        end
      end

      # assigns incorrect values to 2 out of 2
      brackets_in_middle_of_year.keys.each do |example|
        it "nil for brackets_in_middle_of_year: #{example}" do
          expect(Stanford::Mods::DateParsing.new(example).year_via_ruby_parsing).to eq nil
        end
      end

      # assigns incorrect values to 3 out of 8 (5 with no val assigned)
      specific_day_2_digit_year.keys.each do |example|
        it "nil for specific_day_2_digit_year: #{example}" do
          expect(Stanford::Mods::DateParsing.new(example).year_via_ruby_parsing).to eq nil
        end
      end

      # assigns incorrect values to 8 out of 8
      decade_only.keys.each do |example|
        it "nil for decade_only: #{example}" do
          expect(Stanford::Mods::DateParsing.new(example).year_via_ruby_parsing).to eq nil
        end
      end
    end
  end
end
