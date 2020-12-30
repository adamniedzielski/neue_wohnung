# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::WbgFriedrichshain do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("wbg_friedrichshain.html")
    service = Scraper::WbgFriedrichshain.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 3
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("wbg_friedrichshain.html")
    service = Scraper::WbgFriedrichshain.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("wbg_friedrichshain.html")
    service = Scraper::WbgFriedrichshain.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Zechliner Str. 2A, 2B 13055 Berlin, Hohenschönhausen"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("wbg_friedrichshain.html")
    service = Scraper::WbgFriedrichshain.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id).to eq "wbg-friedrichshain-https://www.wbg-friedrichshain-eg.de/wohnungsangebote/343-moderne-2-zimmer-wohnung-mit-grosser-kueche"
  end

  it "gets link to the full offer" do
    http_client = MockHTTPClient.new("wbg_friedrichshain.html")
    service = Scraper::WbgFriedrichshain.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.wbg-friedrichshain-eg.de/wohnungsangebote/343-moderne-2-zimmer-wohnung-mit-grosser-kueche"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("wbg_friedrichshain.html")
    service = Scraper::WbgFriedrichshain.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 2
  end
end
