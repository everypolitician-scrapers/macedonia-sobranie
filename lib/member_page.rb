# frozen_string_literal: true

require_relative 'sobranie_page'

class String
  def to_date
    return if empty?

    Date.parse(self).to_s
  end
end

class MemberPage < SobraniePage
  field :id do
    url.to_s[/ns_article-(.*?)-?(\d+)/, 1]
  end

  field :image do
    box.css('img/@src').map(&:text).first
  end

  field :email do
    box.css('a[href*=mailto]/@href').map(&:text).first.to_s.gsub('mailto:', '')
  end

  field :birth_date do
    box.text[/Born on (\d+\.\d+\.\d{4})/, 1].to_s.split('.').reverse.join('-').to_date
  end

  private

  def box
    noko.css('.article-holder')
  end
end
