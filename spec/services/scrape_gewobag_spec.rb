# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe ScrapeGewobag do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("gewobag.html")
    service = ScrapeGewobag.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 8
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("gewobag.html")
    service = ScrapeGewobag.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("gewobag.html")
    service = ScrapeGewobag.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Richard-Münch-Str. 42, 13591 Berlin/Staaken"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("gewobag.html")
    service = ScrapeGewobag.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "gewobag-43925"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("gewobag.html")
    service = ScrapeGewobag.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("gewobag.html")
    service = ScrapeGewobag.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq "3..4"
  end

  it "gets the WBS status" do
    http_client = MockHTTPClient.new("gewobag.html")
    service = ScrapeGewobag.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("wbs"))
      .to eq false
  end
end
