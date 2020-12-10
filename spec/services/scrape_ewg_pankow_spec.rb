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

  it "sends Bugnsnag notification when there's some change in HTML" do
    http_client = MockHTTPClient.new("ewg_pankow_different.html")
    bugnsnag_client = double(Bugsnag, notify: nil)
    service = ScrapeEwgPankow.new(
      http_client: http_client,
      bugsnag_client: bugnsnag_client
    )

    service.call

    expect(bugnsnag_client)
      .to have_received(:notify).with(ScrapeEwgPankow::ContentChanged)
  end

  it "does not send Bugnsnag notification when there's a message about no flats" do
    http_client = MockHTTPClient.new("ewg_pankow_empty.html")
    bugnsnag_client = double(Bugsnag, notify: nil)
    service = ScrapeEwgPankow.new(
      http_client: http_client,
      bugsnag_client: bugnsnag_client
    )

    service.call

    expect(bugnsnag_client).not_to have_received(:notify)
  end
end
