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
      properties = {
        address: address(listing),
        url: URL,
        rooms_number: rooms_number(listing),
        wbs: listing.text.include?("WBS erforderl")
      }

      properties.merge!(rent(listing))

      Apartment.new(
        external_id: external_id(listing),
        properties: properties
      )
    end

    def address(listing)
      listing.css(".item-wrp")[1].text.gsub(/\s+/, " ").strip
    end

    def rooms_number(listing)
      Integer(listing.text.match(/Zimmer:\s(\d+)/)[1])
    end

    def rent(listing)
      match_data = listing.text.match(
        /Gesamtmiete in Euro: (?<value>\d+,\d{2})(?: €)?\s(?<type>kalt|warm)/
      )
      value = BigDecimal(match_data[:value].gsub(",", "."))

      if match_data[:type] == "kalt"
        { cold_rent: value }
      else
        { warm_rent: value }
      end
    end

    def external_id(listing)
      "charlotte-#{listing.css('.header-green').text.match(/WOHNUNGS-Nr\.\s(.+)/)[1]}"
    end
  end
end
