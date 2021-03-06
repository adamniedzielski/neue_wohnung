# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::Gesobau do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("gesobau.html")
    service = Scraper::Gesobau.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 9
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("gesobau.html")
    service = Scraper::Gesobau.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("gesobau.html")
    service = Scraper::Gesobau.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Gadebuscher Straße 25A / 12619 Berlin"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("gesobau.html")
    service = Scraper::Gesobau.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.gesobau.de/wohnung/gadebuscher-strasse-1zi-10-03239-1221-g.html"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("gesobau.html")
    service = Scraper::Gesobau.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "gesobau-https://www.gesobau.de/wohnung/gadebuscher-strasse-1zi-10-03239-1221-g.html"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("gesobau.html")
    service = Scraper::Gesobau.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 1
  end

  it "handles the loading error on Gesobau side" do
    http_client = MockHTTPClient.new("gesobau_error.html")
    service = Scraper::Gesobau.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 0
  end

  it "gets the WBS status when WBS is required" do
    http_client = MockHTTPClient.new("gesobau_wbs.html")
    service = Scraper::Gesobau.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("wbs")).to eq true
  end

  it "gets the WBS status when WBS is not required" do
    http_client = MockHTTPClient.new("gesobau_wbs.html")
    service = Scraper::Gesobau.new(http_client: http_client)
    result = service.call

    expect(result.second.properties.fetch("wbs")).to eq false
  end
end
