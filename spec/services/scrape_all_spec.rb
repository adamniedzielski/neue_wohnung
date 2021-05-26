# frozen_string_literal: true

require "rails_helper"

RSpec.describe ScrapeAll do
  it "calls each scraper" do
    first_scraper = instance_double(Scraper::Degewo, call: [])
    second_scraper = instance_double(Scraper::Gewobag, call: [])
    service = ScrapeAll.new(scrapers: [first_scraper, second_scraper])

    service.call

    expect(first_scraper).to have_received(:call)
    expect(second_scraper).to have_received(:call)
  end

  it "gracefully handles network problems with one of the scrapers" do
    apartment = Apartment.new
    first_scraper = instance_double(Scraper::Degewo)
    allow(first_scraper).to receive(:call) { raise SocketError }
    second_scraper = instance_double(Scraper::Gewobag, call: [apartment])

    bugsnag_client = class_double(Bugsnag, notify: nil)

    service = ScrapeAll.new(
      scrapers: [first_scraper, second_scraper],
      bugsnag_client: bugsnag_client
    )

    expect(service.call).to eq [apartment]
    expect(bugsnag_client).to have_received(:notify)
  end

  it "rescues all unhandled exceptions" do
    apartment = Apartment.new
    first_scraper = instance_double(Scraper::Degewo)
    allow(first_scraper).to receive(:call) { raise NoMethodError }
    second_scraper = instance_double(Scraper::Gewobag, call: [apartment])

    bugsnag_client = class_double(Bugsnag, notify: nil)

    service = ScrapeAll.new(
      scrapers: [first_scraper, second_scraper],
      bugsnag_client: bugsnag_client
    )

    expect(service.call).to eq [apartment]
    expect(bugsnag_client).to have_received(:notify)
  end
end
