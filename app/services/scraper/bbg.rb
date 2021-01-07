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
      Apartment.new(
        external_id: "bbg-#{listing.css('td')[4].text}",
        properties: {
          address: listing.css("td")[3].children.map(&:text).reject(&:blank?).join(" "),
          url: URL,
          rooms_number: Integer(listing.css("td")[1].text)
        }
      )
    end
  end
end
