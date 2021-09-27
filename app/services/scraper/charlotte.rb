# frozen_string_literal: true

module Scraper
  class Charlotte
    URL = "https://charlotte1907.de/wohnungsangebote/woechentliche-angebote"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page
        .css(".apartment-lists > .image-block-content")
        .reject { |listing| only_for_members?(listing) }
        .map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def only_for_members?(listing)
      listing.text.include?("Nur für Mitglieder")
    end

    def parse(listing)
      Apartment.new(
        external_id: "charlotte-#{listing.css('.header-green').text.match(/WOHNUNGS-Nr\.\s(.+)/)[1]}",
        properties: {
          address: listing.css(".item-wrp")[1].text.gsub(/\s+/, " ").strip,
          url: URL,
          rooms_number: Integer(listing.text.match(/Zimmer:\s(\d+)/)[1])
        }
      )
    end
  end
end
