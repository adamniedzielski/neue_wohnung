# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::Charlotte do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 10
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Hohenzollernring 98-98d | 13585 Berlin"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "charlotte-040-0030"
  end

  it "links to the list of all offers" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://charlotte1907.de/wohnungsangebote/woechentliche-angebote"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "gets the number of rooms when there are half rooms" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.third.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "filters out offers only for members" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.map(&:external_id)).not_to include("charlotte-210-0109")
  end

  it "gets the WBS status when WBS is not required" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("wbs")).to eq false
  end

  it "gets the WBS status when WBS is required" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result[5].properties.fetch("wbs")).to eq true
  end

  it "gets the warm rent when warm rent is provided" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("warm_rent")).to eq "444.81"
  end

  it "gets the cold rent when cold rent is provided" do
    http_client = MockHTTPClient.new("charlotte.html")
    service = Scraper::Charlotte.new(http_client: http_client)
    result = service.call

    expect(result[6].properties.fetch("cold_rent")).to eq "515.06"
  end
end
