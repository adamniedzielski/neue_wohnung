# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::Vbveg do
  it "gets apartments" do
    http_client = MockHTTPClient.new("vbveg.html")
    service = Scraper::Vbveg.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 1
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("vbveg.html")
    service = Scraper::Vbveg.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("vbveg.html")
    service = Scraper::Vbveg.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Hussitenstr. 7, 13355 Berlin"
  end

  it "returns link to the list page as there are no individual pages" do
    http_client = MockHTTPClient.new("vbveg.html")
    service = Scraper::Vbveg.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.vbveg.de/wohnungsangebote.html"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("vbveg.html")
    service = Scraper::Vbveg.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq(
      "vbveg-Hussitenstr. 7, 13355 Berlin-484.81"
    )
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("vbveg.html")
    service = Scraper::Vbveg.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 1
  end

  it "gets the WBS status when WBS is required" do
    http_client = MockHTTPClient.new("vbveg.html")
    service = Scraper::Vbveg.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("wbs"))
      .to eq true
  end

  it "gets the warm rent" do
    http_client = MockHTTPClient.new("vbveg.html")
    service = Scraper::Vbveg.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("warm_rent"))
      .to eq "484.81"
  end

  it "returns zero apartments when the page is empty" do
    http_client = MockHTTPClient.new("vbveg_empty.html")
    service = Scraper::Vbveg.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 0
  end
end
