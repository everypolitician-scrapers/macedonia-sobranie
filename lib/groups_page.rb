# frozen_string_literal: true
require_relative 'sobranie_page'

class GroupsPage < SobraniePage
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :groups do
    noko.css('div.toc li a').map do |a|
      fragment a => LinkLine
    end
  end
end
