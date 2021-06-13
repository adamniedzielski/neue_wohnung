# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::StadtUndLand do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("stadt_und_land.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 5
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("stadt_und_land.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("stadt_und_land.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Potsdamer Str. 80, 14974 Ludwigsfelde"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("stadt_und_land.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.stadtundland.de/exposes/immo.MO_I998_5199_103.php"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("stadt_und_land.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "stadt-und-land-https://www.stadtundland.de/exposes/immo.MO_I998_5199_103.php"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("stadt_und_land.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "gets the WBS status when the listing is without WBS" do
    http_client = MockHTTPClient.new("stadt_und_land.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("wbs"))
      .to eq false
  end

  it "gets the WBS status when the listing is with WBS" do
    http_client = MockHTTPClient.new("stadt_und_land.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.second.properties.fetch("wbs"))
      .to eq true
  end

  it "ignores listing for garage" do
    http_client = MockHTTPClient.new("stadt_und_land_garage.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 9
  end

  it "ignores listing for parking place" do
    http_client = MockHTTPClient.new("stadt_und_land_parking_place.html")
    service = Scraper::StadtUndLand.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 6
  end
end
