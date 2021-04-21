# frozen_string_literal: true

module Scraper
  class Gesobau
    BASE_URL = "https://www.gesobau.de"
    # rubocop:disable Layout/LineLength
    LIST_URL = "#{BASE_URL}/mieten/wohnungssuche.html?tx_kesearch_pi1%5Bsword%5D=&tx_kesearch_pi1%5Bzimmer%5D=&tx_kesearch_pi1%5BflaecheMin%5D=&tx_kesearch_pi1%5BmieteMax%5D=&tx_kesearch_pi1%5Bpage%5D=1&tx_kesearch_pi1%5BresetFilters%5D=0&tx_kesearch_pi1%5BsortByField%5D=&tx_kesearch_pi1%5BsortByDir%5D="
    # rubocop:enable Layout/LineLength

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(LIST_URL).body)
      second_list = page.css(".tx-openimmo.list")[1]

      return [] if second_list.blank?

      second_list.css(".tab-pane.active .list_item").map do |listing|
        parse(listing)
      end
    end

    private

    attr_accessor :http_client

    def parse(listing)
      Apartment.new(
        external_id: "gesobau-#{url(listing)}",
        properties: {
          address: listing.css(".list_item-location").text,
          url: url(listing),
          rooms_number: rooms_number(listing),
          wbs: listing.at(".list_item-title a").text.include?("WBS")
        }
      )
    end

    def url(listing)
      "#{BASE_URL}#{listing.at('.list_item-title a').attribute('href').value}"
    end

    def rooms_number(listing)
      Integer(
        listing.css(".list_item-details").text.match(/.*Zimmer: (\d+)/)[1]
      )
    end
  end
end
