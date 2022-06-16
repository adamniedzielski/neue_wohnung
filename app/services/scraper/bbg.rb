# frozen_string_literal: true

module Scraper
  class Bbg
    URL = "https://bbg-eg.de/angebote/wohnungen-und-gewerbe/"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page.css("#std-content table.avia-table tr:not(.avia-heading-row)").map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      properties = {
        address: listing.css("td")[3].children.map(&:text).compact_blank.join(" "),
        url: URL
      }

      rooms_number = listing.css("td")[1].text
      properties.merge!(rooms_number: Integer(rooms_number)) if rooms_number.present?

      Apartment.new(
        external_id: "bbg-#{listing.css('td')[4].text}",
        properties: properties
      )
    end
  end
end
