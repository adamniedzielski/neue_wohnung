# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe ScrapeDegewo do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("degewo.json")
    service = ScrapeDegewo.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 10
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("degewo.json")
    service = ScrapeDegewo.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("degewo.json")
    service = ScrapeDegewo.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Alfred-Döblin-Straße 12 | 12679 Berlin"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("degewo.json")
    service = ScrapeDegewo.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://immosuche.degewo.de/de/properties/W1400-40137-0620-0603"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("degewo.json")
    service = ScrapeDegewo.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "degewo-https://immosuche.degewo.de/de/properties/W1400-40137-0620-0603"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("degewo.json")
    service = ScrapeDegewo.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 1
  end

  it "gets the WBS status" do
    http_client = MockHTTPClient.new("degewo.json")
    service = ScrapeDegewo.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("wbs"))
      .to eq false
  end

  it "gets all apartments when pagination is present" do
    http_client = MockHTTPClient.new(["degewo_page_1.json", "degewo_page_2.json", "degewo_page_3.json"])
    service = ScrapeDegewo.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 25
  end
end
