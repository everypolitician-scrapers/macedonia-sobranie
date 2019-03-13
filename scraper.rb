#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

require_rel 'lib'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def scrape(what)
  url, klass = what.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

start = 'https://sobranie.mk/current-structure.nspx'

groups_page = scrape(start => GroupsPage)

current_members = groups_page.groups.flat_map do |group|
  scrape(group.source => GroupPage).members.map do |mem|
    mem.to_h.merge(scrape(mem.source => MemberPage).to_h.merge(party: group.name, term: '2016'))
  end
end

# TODO: scrape ceased members
# ceased_members = scrape(groups_page.ceased_members_url => CeasedMembersPage).members.map do |mem|
  # mem.to_h.merge(scrape(mem.source => MemberPage).to_h.merge(party: mem.party, term: '2016')) rescue binding.pry
# end

# data = current_members + ceased_members
data = current_members
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id term], data)
