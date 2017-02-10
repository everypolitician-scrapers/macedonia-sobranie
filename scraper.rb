#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

require_rel 'lib'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil

start = 'http://sobranie.mk/current-structure-2014-2018.nspx'
groups = scrape(start => GroupsPage).groups
# The structure of the last page differs from the others.
# We will scrape it separately.
party_groups = groups[0...-1]
ceased_members_group = groups.last
term = 2014

current_members = party_groups.flat_map do |group|
  puts group.source
  scrape(group.source => GroupPage).members.map do |mem|
    mem.to_h.merge(scrape(mem.source => MemberPage).to_h.merge(party: group.name, term: term))
  end
end

ceased_members = scrape(ceased_members_group.source => CeasedMembersPage).members.map do |mem|
  mem.to_h.merge(scrape(mem.source => MemberPage).to_h.merge(party: mem.party, term: term))
end

data = current_members + ceased_members
# puts data.map { |r| r.reject { |k, v| v.to_s.empty? }.sort_by { |k,v| k }.to_h }
ScraperWiki.save_sqlite(%i(id term), data)
