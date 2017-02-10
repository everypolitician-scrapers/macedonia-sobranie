# frozen_string_literal: true
require_relative 'sobranie_page'
require_relative 'ceased_member_row'

class CeasedMembersPage < SobraniePage
  field :members do
    noko.xpath('//div[@class="row"]/p[a]').map do |p|
      fragment p => CeasedMemberRow
    end
  end
end
