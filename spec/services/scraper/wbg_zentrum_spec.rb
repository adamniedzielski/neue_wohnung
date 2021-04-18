# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::WbgZentrum do
  it "gets apartments" do
    http_client = MockHTTPClient.new("wbg_zentrum.html")
    service = Scraper::WbgZentrum.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 1
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("wbg_zentrum.html")
    service = Scraper::WbgZentrum.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("wbg_zentrum.html")
    service = Scraper::WbgZentrum.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Thälmann Park | Lilli-Henoch-Straße 9"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("wbg_zentrum.html")
    service = Scraper::WbgZentrum.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "wbg-zentrum-https://www.wbg-zentrum.de/wp-content/uploads/2020/12/LH-9-WE-603.pdf"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("wbg_zentrum.html")
    service = Scraper::WbgZentrum.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.wbg-zentrum.de/wp-content/uploads/2020/12/LH-9-WE-603.pdf"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("wbg_zentrum.html")
    service = Scraper::WbgZentrum.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 1
  end

  it "gets the WBS status" do
    http_client = MockHTTPClient.new("wbg_zentrum.html")
    service = Scraper::WbgZentrum.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("wbs"))
      .to eq true
  end
end
