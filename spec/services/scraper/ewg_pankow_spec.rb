# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::EwgPankow do
  it "returns 0 apartments for empty page" do
    http_client = MockHTTPClient.new("ewg_pankow_empty.html")
    service = Scraper::EwgPankow.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 0
  end

  it "gets apartments when they are present" do
    http_client = MockHTTPClient.new("ewg_pankow.html")
    service = Scraper::EwgPankow.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 1
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("ewg_pankow.html")
    service = Scraper::EwgPankow.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("ewg_pankow.html")
    service = Scraper::EwgPankow.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Groscurthstraße, Buch"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("ewg_pankow.html")
    service = Scraper::EwgPankow.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "ewg-pankow-7989"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("ewg_pankow.html")
    service = Scraper::EwgPankow.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.ewg-pankow.de/wohnungen/3-zimmer-groscurthstrasse-buch/"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("ewg_pankow.html")
    service = Scraper::EwgPankow.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 3
  end
end
