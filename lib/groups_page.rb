# frozen_string_literal: true
require_relative 'sobranie_page'

class GroupsPage < SobraniePage
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :groups do
    # The rejected page is not a list of members grouped by party
    noko.css('div.toc li a')
        .reject { |a| a.attr('href') == 'http://sobranie.mk/mps-whose-mandate-has-not-been-completed-2014-2018.nspx' }
        .map { |a| fragment a => LinkLine }
  end
end
