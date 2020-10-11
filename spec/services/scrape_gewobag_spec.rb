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

  it "gets apartment address" do
    service = ScrapeGewobag.new(http_client: MockHTTPClient.new)
    result = service.call

    expect(result.first.fetch(:address))
      .to eq "\n\t\t\t\tRichard-Münch-Str. 42, 13591 Berlin/Staaken\t\t\t"
  end
end
