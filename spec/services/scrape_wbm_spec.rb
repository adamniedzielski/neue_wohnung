# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe ScrapeWbm do
  it "always gets zero apartments" do
    http_client = MockHTTPClient.new("wbm.html")
    service = ScrapeWbm.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 0
  end
end
