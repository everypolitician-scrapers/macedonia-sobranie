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

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil

start = 'http://sobranie.mk/current-structure-2014-2018.nspx'
term = 2014

groups_page = scrape(start => GroupsPage)

current_members = groups_page.groups.flat_map do |group|
  scrape(group.source => GroupPage).members.map do |mem|
    mem.to_h.merge(scrape(mem.source => MemberPage).to_h.merge(party: group.name, term: term))
  end
end

ceased_members = scrape(groups_page.ceased_members_url => CeasedMembersPage).members.map do |mem|
  mem.to_h.merge(scrape(mem.source => MemberPage).to_h.merge(party: mem.party, term: term))
end

data = current_members + ceased_members
# puts data.map { |r| r.reject { |k, v| v.to_s.empty? }.sort_by { |k,v| k }.to_h }
ScraperWiki.save_sqlite(%i(id term), data)
