# frozen_string_literal: true

module Scraper
  class WbgHub
    URL = "https://www.wbg-hub.de/wohnen/wohnungsangebote"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page.css(".immo-flexbox").map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      Apartment.new(
        external_id: "wbg-hub-#{url(listing)}",
        properties: {
          address: listing.css(".card-text").text.strip.split(/\s+/).join(" "),
          url: url(listing),
          rooms_number: Integer(listing.css(".text-center").text.match(/(\d)+\s+Zimmer/)[1])
        }
      )
    end

    def url(listing)
      "#{URL}/#{listing.at('a.stretched-link').attribute('href').value}"
    end
  end
end
