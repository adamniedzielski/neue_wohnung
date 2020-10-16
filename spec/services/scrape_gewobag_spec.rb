# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScrapeGewobag do
  class MockHTTPClient
    class Response
      def body
        File.read(Rails.root.join("spec", "fixtures", "gewobag.html"))
      end
    end

    def get(_url)
      Response.new
    end
  end

  it "gets multiple apartments" do
    service = ScrapeGewobag.new(http_client: MockHTTPClient.new)
    result = service.call

    expect(result.size).to eq 8
  end

  it "returns Apartment instances" do
    service = ScrapeGewobag.new(http_client: MockHTTPClient.new)
    result = service.call

    expect(result.first.class).to eq Apartment
  end

  it "gets apartment address" do
    service = ScrapeGewobag.new(http_client: MockHTTPClient.new)
    result = service.call

    expect(result.first.properties.fetch("address"))
      .to eq "Richard-Münch-Str. 42, 13591 Berlin/Staaken"
  end

  it "assigns external identifier" do
    service = ScrapeGewobag.new(http_client: MockHTTPClient.new)
    result = service.call

    expect(result.first.external_id).to eq "gewobag-43925"
  end

  it "gets link to the full offer" do
    service = ScrapeGewobag.new(http_client: MockHTTPClient.new)
    result = service.call

    expect(result.first.properties.fetch("url"))
      .to eq "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
  end
end
