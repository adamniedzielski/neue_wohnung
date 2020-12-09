# frozen_string_literal: true

require "rails_helper"
require "test_helpers/mock_http_client"

RSpec.describe ScrapeEwgPankow do
  it "returns 0 apartments for empty page" do
    http_client = MockHTTPClient.new("ewg_pankow_empty.html")
    service = ScrapeEwgPankow.new(http_client: http_client)
    result = service.call

    expect(result.size).to eq 0
  end
end
