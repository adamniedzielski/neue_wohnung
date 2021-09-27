# frozen_string_literal: true

require "rails_helper"

RSpec.describe DetermineSubdistrict do
  it "assigns subdistrict based on zip code in the address" do
    apartment = Apartment.new(
      properties: {
        address: "Schönhauser Allee 107, 10439 Berlin"
      }
    )

    DetermineSubdistrict.new.call(apartment)

    expect(apartment.properties.fetch("subdistrict")).to eq "Prenzlauer Berg"
  end
end
