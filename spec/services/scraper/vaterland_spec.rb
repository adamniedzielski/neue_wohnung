# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::Vaterland do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("vaterland.html")
    service = Scraper::Vaterland.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 3
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("vaterland.html")
    service = Scraper::Vaterland.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("vaterland.html")
    service = Scraper::Vaterland.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Manteuffelstraße 2, 12103 Berlin"
  end

  it "returns link to the list page as there are no individual pages" do
    http_client = MockHTTPClient.new("vaterland.html")
    service = Scraper::Vaterland.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.bg-vaterland.de/index.php?id=31"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("vaterland.html")
    service = Scraper::Vaterland.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq(
      "vaterland-Manteuffelstraße 2 | 12103 Berlin | 2-Zimmer-Wohnung | ca. 58,04 qm | 4. OG rechts"
    )
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("vaterland.html")
    service = Scraper::Vaterland.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 2
  end
end
