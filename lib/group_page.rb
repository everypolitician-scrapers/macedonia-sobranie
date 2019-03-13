# frozen_string_literal: true

require_relative 'sobranie_page'

class GroupPage < SobraniePage
  field :members do
    noko.css('.ns-category-main-area-left a').map { |a| fragment(a => LinkLine) }
  end
end
