# frozen_string_literal: true

namespace :apartments do
  task get_new: :environment do
    GetNewApartments.new.call
  end
end
