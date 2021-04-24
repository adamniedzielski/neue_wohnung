# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::Mlbaugenossen do
  it "gets available apartments" do
    http_client = MockHTTPClient.new("mlbaugenossen.html")
    service = Scraper::Mlbaugenossen.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 1
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("mlbaugenossen.html")
    service = Scraper::Mlbaugenossen.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("mlbaugenossen.html")
    service = Scraper::Mlbaugenossen.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Rathausstraße 93 Gartenhaus, 12105 Berlin"
  end

  it "links to the page with all offers" do
    http_client = MockHTTPClient.new("mlbaugenossen.html")
    service = Scraper::Mlbaugenossen.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.mlbaugenossen.de/angebote-mietobjekte/aktuelle-wohnangebote.html"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("mlbaugenossen.html")
    service = Scraper::Mlbaugenossen.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "mlbaugenossen-2/12/131"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("mlbaugenossen.html")
    service = Scraper::Mlbaugenossen.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 1
  end
end
