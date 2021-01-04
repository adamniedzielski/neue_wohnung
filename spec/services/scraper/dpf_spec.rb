# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::Dpf do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("dpf.html")
    service = Scraper::Dpf.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 2
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("dpf.html")
    service = Scraper::Dpf.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("dpf.html")
    service = Scraper::Dpf.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Mittelstraße 2, 13158 Berlin"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("dpf.html")
    service = Scraper::Dpf.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "dpf-https://www.dpfonline.de/immobilien/wohnkomfort-in-rosenthal-2-grosszuegige-zimmer-mit-wohlfuehl-terasse/"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("dpf.html")
    service = Scraper::Dpf.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.dpfonline.de/immobilien/wohnkomfort-in-rosenthal-2-grosszuegige-zimmer-mit-wohlfuehl-terasse/"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("dpf.html")
    service = Scraper::Dpf.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "rounds down the number of rooms when there are half rooms" do
    http_client = MockHTTPClient.new("dpf_half_room.html")
    service = Scraper::Dpf.new(http_client: http_client)
    result = service.call

    expect(result.fourth.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "gets the WBS status when the listing is without WBS" do
    http_client = MockHTTPClient.new("dpf.html")
    service = Scraper::Dpf.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("wbs"))
      .to eq false
  end

  it "gets the WBS status when the listing is with WBS" do
    http_client = MockHTTPClient.new("dpf.html")
    service = Scraper::Dpf.new(http_client: http_client)
    result = service.call

    expect(result.second.properties.fetch("wbs"))
      .to eq true
  end
end
