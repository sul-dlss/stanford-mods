# Stanford::Mods

[<img
src="https://secure.travis-ci.org/sul-dlss/stanford-mods.png?branch=master" alt="Build Status"/>](http://travis-ci.org/sul-dlss/stanford-mods) [<img
src="https://coveralls.io/repos/sul-dlss/stanford-mods/badge.png" alt="Coverage Status"/>](https://coveralls.io/r/sul-dlss/stanford-mods) [<img
src="https://gemnasium.com/sul-dlss/stanford-mods.png" alt="Dependency Status"/>](https://gemnasium.com/sul-dlss/stanford-mods) [<img
src="https://badge.fury.io/rb/stanford-mods.svg" alt="Gem Version"/>](http://badge.fury.io/rb/stanford-mods)

A Gem with Stanford specific wranglings of MODS (Metadata Object Description Schema)
metadata from DOR, the Stanford Digital Object Repository.

Source code at [github](https://github.com/sul-dlss/stanford-mods/).

Generated API docs at [rubydoc.info](http://rubydoc.info/github/sul-dlss/stanford-mods/).

## Installation

Add this line to your application's Gemfile:

    gem 'stanford-mods'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stanford-mods

## Usage

1.  add stanford-mods to your gemfile
2.  
```ruby
require 'stanford-mods'
m = Stanford::Mods::Record.new
m.from_str('<mods><genre>ape</genre></mods>')
m.genre      # <Nokogiri::XML::Element:0x3fe07b48bb24 name="genre" children=[#<Nokogiri::XML::Text:0x3fe07a09a7dc "ape">]>
m.genre.text # "ape"
```

Example Using SearchWorks Mixins:

```ruby
require 'stanford-mods/searchworks'
m = Stanford::Mods::Record.new
m.from_str('<mods><language><languageTerm authority="iso639-2b" type="code">dut</languageTerm></language></mods>')
m.language_facet  # ['Dutch'], from Searchworks mixin
m.languages       # ['Dutch; Flemish'] from mods gem
```

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Write code and tests.
4.  Commit your changes (`git commit -am 'Added some feature'`)
5.  Push to the branch (`git push origin my-new-feature`)
6.  Create new Pull Request

## Releases
*   **1.1.2** Corrected java `Character.MAX_CODE_POINT` value from u{FFFF} to u{10FFFF}
*   **1.1.1** Minor bug fixes
*   **1.1.0** Changed mechanism for determining dates for display only and for
    indexing, sorting, and faceting and removed deprecated pub_date_group method
*   **1.0.3** `format_main` value 'Article' is now 'Book'
*   **1.0.2** add `format_main` and `sw_genre` tests to searchworks.rb
*   **1.0.1** `sw_title_display` keeps appropriate trailing punct more or less per spec in solrmarc-sw `sw_index.properties`
*   **1.0.0** `sw_full_title` now includes partName and partNumber;
    `sw_title_display` created to be like `sw_full_title` but without trailing punctuation; sw format for typeOfResource sound recording; genre value is
    librettos, plural; sw format algorithm accommodates first letter upcase; genre value report does NOT map to a format, genre value 'project report'
    with ToR text is 'Book'
*   **0.0.27** add genres 'Issue brief', 'Book chapter' and 'Working paper' to map to searchworks format 'Book'
*   **0.0.26** map typeOfResource 'sound recording-musical' to searchworks format 'Music - Recording' with spaces
*   **0.0.25** map typeOfResource 'text' and genre 'report' to searchworks format 'Book'
*   **0.0.24** Largely cosmetic refactoring for easier maintenance.
*   **0.0.23** Added logic for dealing with "u-notation" approximate dates, e.g., 198u
*   **0.0.20** Added mapping for typeOfResource notated music
*   **0.0.19** Additional mappings, including Hydrus formats (GRYPHONDOR-207)
*   **0.0.11** escape regex special characters when using short title in a regex
*   **0.0.10** get rid of `ignore_me` files
*   **0.0.9** add `sw_subject_names` and `sw_subject_titles` methods to searchworks mixin
*   **0.0.8** require stanford-mods/searchworks in stanford-mods (top level)
*   **0.0.7** added `sw_geographic_search` to searchworks mixin
*   **0.0.6** various title methods added to searchworks mixin
*   **0.0.5** `main_author_w_date`, `additional_authors_w_dates` added to Stanford::Mods::Record; various author methods added to searchworks mixin
*   **0.0.4** KolbRecord started
*   **0.0.3** began SearchWorks mixins with `sw_access_facet` and `sw_language_facet`
*   **0.0.2** add usage instructions to README
*   **0.0.1** Initial commit - grab name

