# frozen_string_literal: true
require 'scraped'

class CeasedMemberRow < Scraped::HTML
  field :source do
    noko.css('a @href').text
  end

  field :name do
    noko.css('a').text
  end

  field :party do
    # The layout is inconsistent. Scraping this way
    # we always get the party name for each row
    noko.xpath('a/following-sibling::text()').first.text.tidy
  end

  field :end_date do
    Date.parse(noko.text[/\d{1,2}\.\d{1,2}\.\d{4}/, 0]).to_s
  end
end
