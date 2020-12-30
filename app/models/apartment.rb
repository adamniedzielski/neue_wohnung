# frozen_string_literal: true

class Apartment < ApplicationRecord
  validates :external_id, presence: true
end
