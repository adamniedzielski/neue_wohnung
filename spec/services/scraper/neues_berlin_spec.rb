# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::NeuesBerlin do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("neues_berlin.html")
    service = Scraper::NeuesBerlin.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 1
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("neues_berlin.html")
    service = Scraper::NeuesBerlin.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("neues_berlin.html")
    service = Scraper::NeuesBerlin.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Ahrenshooper Str. 38 13051 Berlin"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("neues_berlin.html")
    service = Scraper::NeuesBerlin.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "neues-berlin-https://www.neues-berlin.de/fileadmin/angebote/cd3bf0c34d407c563a7a90f7a4f47f94.pdf"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("neues_berlin.html")
    service = Scraper::NeuesBerlin.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.neues-berlin.de/fileadmin/angebote/cd3bf0c34d407c563a7a90f7a4f47f94.pdf"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("neues_berlin.html")
    service = Scraper::NeuesBerlin.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 1
  end
end
