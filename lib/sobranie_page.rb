# frozen_string_literal: true
require 'scraped'

class SobraniePage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls
end
