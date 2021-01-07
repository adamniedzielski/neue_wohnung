# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::Bbg do
  it "returns 0 apartments for empty page" do
    http_client = MockHTTPClient.new("bbg_empty.html")
    service = Scraper::Bbg.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 0
  end

  it "gets multiple apartments when they are available" do
    http_client = MockHTTPClient.new("bbg.html")
    service = Scraper::Bbg.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 2
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("bbg.html")
    service = Scraper::Bbg.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("bbg.html")
    service = Scraper::Bbg.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Mariendorfer Damm 8 12109 Berlin"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("bbg.html")
    service = Scraper::Bbg.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "bbg-117/116/181"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("bbg.html")
    service = Scraper::Bbg.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://bbg-eg.de/angebote/wohnungen-und-gewerbe/"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("bbg.html")
    service = Scraper::Bbg.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 2
  end
end
