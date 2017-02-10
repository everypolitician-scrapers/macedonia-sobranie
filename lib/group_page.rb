# frozen_string_literal: true
require_relative 'sobranie_page'

class GroupPage < SobraniePage
  field :members do
    noko.css('h2 a').map do |a|
      fragment a => LinkLine
    end
  end
end
