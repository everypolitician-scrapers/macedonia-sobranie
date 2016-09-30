#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('div.toc li a').each do |a|
    link = URI.join url, a.attr('href')
    scrape_group(a.text, link)
  end
end

def scrape_group(name, url)
  noko = noko_for(url)
  noko.css('h2 a').each do |a|
    link = URI.join url, a.attr('href')
    scrape_person(link, a.text, name)
  end
end

def valid_uri(url, path)
  begin
    URI.join(url, path)
  rescue URI::InvalidURIError
    URI.join(url, URI.escape(path))
  end
end

def scrape_person(url, name, group)
  noko = noko_for(url)

  box = noko.css('.article-holder')
  images = box.css('img/@src')
  data = {
    id: url.to_s[/ns_article-(.*?)-(\d+)/, 1],
    name: name.tidy,
    party: group.tidy,
    image: images.size.zero? ? '' : images.first.text,
    term: 2014,
    source: url.to_s,
  }
  data[:image] = valid_uri(url, data[:image]).to_s unless data[:image].to_s.empty?
  ScraperWiki.save_sqlite([:id, :term], data)
end

scrape_list('http://sobranie.mk/current-structure-2014-2018.nspx')
