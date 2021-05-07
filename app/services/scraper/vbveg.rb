# frozen_string_literal: true

module Scraper
  class Vbveg
    URL = "https://www.vbveg.de/wohnungsangebote.html"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page.css("#article-127 .ce_text.block").map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      rooms_number, address, wbs = parse_title(listing)

      Apartment.new(
        external_id: "vbveg-#{address}-#{warm_rent(listing)}",
        properties: {
          address: address,
          url: URL,
          rooms_number: rooms_number,
          wbs: wbs,
          warm_rent: warm_rent(listing)
        }
      )
    end

    def parse_title(listing)
      title = listing.css("h5").text
      match_data = title.match(/(\d+(,5)?)-Zimmerwohnung,\s(.*)/)
      rooms_number = Float(match_data[1].gsub(",", ".")).round(half: :down)
      rest = match_data[3]
      address = rest.gsub(" - Nur mit WBS", "")
      wbs = rest.include?("WBS")

      [rooms_number, address, wbs]
    end

    def warm_rent(listing)
      match_data = listing.css("p").text.match(/(\d+(,\d{2})?)\s€/)
      BigDecimal(match_data[1].gsub(",", "."))
    end
  end
end
