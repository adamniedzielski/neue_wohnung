# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::Howoge do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("howoge.json")
    service = Scraper::Howoge.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 13
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("howoge.json")
    service = Scraper::Howoge.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("howoge.json")
    service = Scraper::Howoge.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Genslerstraße 16, 13055 Berlin"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("howoge.json")
    service = Scraper::Howoge.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.howoge.de/wohnungen-gewerbe/wohnungssuche/detail/5998.html"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("howoge.json")
    service = Scraper::Howoge.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "howoge-5998"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("howoge.json")
    service = Scraper::Howoge.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "gets only the offers without WBS required" do
    http_client = MockHTTPClient.new("howoge.json")
    service = Scraper::Howoge.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("wbs"))
      .to eq false
  end
end
