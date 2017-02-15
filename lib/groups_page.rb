# frozen_string_literal: true
require_relative 'sobranie_page'

class GroupsPage < SobraniePage
  decorator Scraped::Response::Decorator::AbsoluteUrls

  CEASED_MEMBERS_URL = 'mps-whose-mandate-has-not-been-completed'

  field :groups do
    groups_links.last.map { |a| fragment a => LinkLine }
  end

  field :ceased_members_url do
    groups_links.first.first.attr('href')
  end

  private

  # The layout of this page is to list all the groups, but at the end,
  # in an otherwise undistinguished entry, there's a list to a separate
  # page of all the ceased members.
  def groups_links
    noko.css('div.toc li a').partition { |a| a.attr('href').include? CEASED_MEMBERS_URL }
  end
end
