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
end
