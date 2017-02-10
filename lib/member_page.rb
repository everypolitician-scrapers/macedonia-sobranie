# frozen_string_literal: true
require_relative 'sobranie_page'

class MemberPage < SobraniePage
  field :id do
    url.to_s[/ns_article-(.*?)-(\d+)/, 1]
  end

  field :image do
    images.size.zero? ? '' : images.first.text
  end

  private

  def box
    noko.css('.article-holder')
  end

  def images
    box.css('img/@src')
  end
end
