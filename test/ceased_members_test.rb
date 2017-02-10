# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/ceased_members_page.rb'

describe 'ceased member' do
  URL = 'http://sobranie.mk/mps-whose-mandate-has-not-been-completed-2014-2018.nspx'
  around { |test| VCR.use_cassette(URL.split('/').last, &test) }
  subject do
    CeasedMembersPage.new(response: Scraped::Request.new(url: URL).response)
                     .members
  end

  describe 'Romeo Trenov' do
    it 'should have the expected data' do
      subject.first.to_h.must_equal(
        source: 'http://www.sobranie.mk/current-structure-2014-2018-ns_article-romeo-trenov-2014-en.nspx',
        name:   'Romeo Trenov',
        party:  'VMRO-DPMNE'
      )
    end
  end

  # Second test for a row with a slightly different layout
  describe 'Emil Dimitriev' do
    it 'should have the expected data' do
      subject.last.to_h.must_equal(
        source: 'http://sobranie.mk/vmro-dpmne-2014-ns_article-emil-dimitriev-2014-en.nspx',
        name:   'Emil Dimitriev',
        party:  'VMRO-DPMNE'
      )
    end
  end
end
