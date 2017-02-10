# frozen_string_literal: true
require 'scraped'

class LinkLine < Scraped::HTML
  field :name do
    noko.text.tidy
  end

  field :source do
    noko.attr('href')
  end
end
