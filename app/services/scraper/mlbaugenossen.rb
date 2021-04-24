# frozen_string_literal: true

module Scraper
  class Mlbaugenossen
    URL = "https://www.mlbaugenossen.de/angebote-mietobjekte/aktuelle-wohnangebote.html"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page.css(".angebotdetails").map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      Apartment.new(
        external_id: "mlbaugenossen-#{listing.css('.td')[0].text}",
        properties: {
          address: listing.css(".td")[1].text,
          url: URL,
          rooms_number: Integer(listing.css(".td")[2].text)
        }
      )
    end
  end
end
