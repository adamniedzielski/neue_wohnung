# frozen_string_literal: true

module Scraper
  class Vaterland
    URL = "https://www.bg-vaterland.de/index.php?id=31"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page.css("table.contenttable").map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      Apartment.new(
        external_id: "vaterland-#{listing.css('th').text}",
        properties: {
          address: listing.css("th").text.split(" | ").take(2).join(", "),
          url: URL,
          rooms_number: Integer(listing.css("th").text.match(/(\d+)-Zimmer-Wohnung/)[1])
        }
      )
    end
  end
end
