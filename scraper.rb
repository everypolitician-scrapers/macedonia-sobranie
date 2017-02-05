#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class SobraniePage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls
end

class GroupsPage < SobraniePage
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :groups do
    noko.css('div.toc li a').map do |a|
      fragment a => LinkLine
    end
  end
end

class LinkLine < Scraped::HTML
  field :name do
    noko.text.tidy
  end

  field :source do
    noko.attr('href')
  end
end

class GroupPage < SobraniePage
  field :members do
    noko.css('h2 a').map do |a|
      fragment a => LinkLine
    end
  end
end

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

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil

start = 'http://sobranie.mk/current-structure-2014-2018.nspx'
data = scrape(start => GroupsPage).groups.flat_map do |group|
  scrape(group.source => GroupPage).members.map do |mem|
    mem.to_h.merge(scrape(mem.source => MemberPage).to_h.merge(party: group.name, term: 2014))
  end
end
# puts data.map { |r| r.reject { |k, v| v.to_s.empty? }.sort_by { |k,v| k }.to_h }

ScraperWiki.save_sqlite(%i(id term), data)
