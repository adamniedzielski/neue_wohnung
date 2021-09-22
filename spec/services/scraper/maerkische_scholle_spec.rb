# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe Scraper::MaerkischeScholle do
  it "gets multiple apartments" do
    http_client = MockHTTPClient.new("maerkische_scholle.html")
    service = Scraper::MaerkischeScholle.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 2
  end

  it "returns Apartment instances" do
    http_client = MockHTTPClient.new("maerkische_scholle.html")
    service = Scraper::MaerkischeScholle.new(http_client: http_client)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    http_client = MockHTTPClient.new("maerkische_scholle.html")
    service = Scraper::MaerkischeScholle.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Holtheimer Weg 30 (Lichterfelde-Süd)"
  end

  it "assigns external identifier" do
    http_client = MockHTTPClient.new("maerkische_scholle.html")
    service = Scraper::MaerkischeScholle.new(http_client: http_client)
    result = service.call

    expect(result.first.external_id)
      .to eq "maerkische-scholle-files/bilder/content/wohungsangebote/2020/A3a_Holth.30_2_Zi_2.OGre.png"
  end

  it "links to the page with all offers" do
    http_client = MockHTTPClient.new("maerkische_scholle.html")
    service = Scraper::MaerkischeScholle.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.maerkische-scholle.de/wohnungsangebote.html"
  end

  it "gets the number of rooms" do
    http_client = MockHTTPClient.new("maerkische_scholle.html")
    service = Scraper::MaerkischeScholle.new(http_client: http_client)
    result = service.call

    expect(result.first.properties.fetch("rooms_number"))
      .to eq 2
  end

  it "skips SSL verification because of 'unable to get local issuer certificate' error" do
    http_client = Scraper::MaerkischeScholle::SkipSSLVerificationClient

    expect(http_client.default_options.fetch(:verify)).to eq false
  end
end
