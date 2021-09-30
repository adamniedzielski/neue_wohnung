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

  it "does not assign subdistrict when the zip code is incorrect" do
    apartment = Apartment.new(
      properties: {
        address: "Schönhauser Allee 107, 12345 Berlin"
      }
    )

    DetermineSubdistrict.new.call(apartment)

    expect(apartment.properties.key?("subdistrict")).to eq false
  end

  it "does not assign subdistrict when the zip code cannot be found in the address" do
    apartment = Apartment.new(
      properties: {
        address: "Schönhauser Allee 107 Berlin"
      }
    )

    DetermineSubdistrict.new.call(apartment)

    expect(apartment.properties.key?("subdistrict")).to eq false
  end

  it "does not assign subdistrict when address is not available" do
    apartment = Apartment.new(properties: {})

    DetermineSubdistrict.new.call(apartment)

    expect(apartment.properties.key?("subdistrict")).to eq false
  end
end
