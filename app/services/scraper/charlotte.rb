# frozen_string_literal: true

module Scraper
  class Charlotte
    URL = "https://charlotte1907.de/wohnungsangebote/woechentliche-angebote"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page.css(".apartment-lists > .image-block-content").map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      # properties = {
      #   address: listing.css("td")[3].children.map(&:text).reject(&:blank?).join(" "),
      #   url: URL
      # }

      # rooms_number = listing.css("td")[1].text
      # properties.merge!(rooms_number: Integer(rooms_number)) if rooms_number.present?

      Apartment.new(
        external_id: "charlotte-#{listing.css(".header-green").text.match(/WOHNUNGS-Nr\.\s(.+)/)[1]}",
        properties: {
          address: listing.css(".item-wrp")[1].text.gsub(/\s+/, " ").strip,
          url: URL
        }
      )
    end
  end
end
