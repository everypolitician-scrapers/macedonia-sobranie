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
    noko.text
  end

  field :url do
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

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  scrape(url => GroupsPage).groups.each do |group|
    scrape_group(group.name, group.url)
  end
end

def scrape_group(name, url)
  scrape(url => GroupPage).members.each do |mem|
    scrape_person(mem.url, mem.name, name)
  end
end

def scrape_person(url, name, group)
  noko = noko_for(url)

  box = noko.css('.article-holder')
  images = box.css('img/@src')
  data = {
    id:     url.to_s[/ns_article-(.*?)-(\d+)/, 1],
    name:   name.tidy,
    party:  group.tidy,
    image:  images.size.zero? ? '' : images.first.text,
    term:   2014,
    source: url.to_s,
  }
  data[:image] = URI.join(url, URI.escape(data[:image])).to_s unless data[:image].to_s.empty?
  ScraperWiki.save_sqlite(%i(id term), data)
end

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_list('http://sobranie.mk/current-structure-2014-2018.nspx')
