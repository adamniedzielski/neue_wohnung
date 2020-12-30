# frozen_string_literal: true

module Scraper
  class Howoge
    BASE_URL = "https://www.howoge.de"
    # rubocop:disable Layout/LineLength
    LIST_URL = "#{BASE_URL}/?type=999&tx_howsite_json_list[action]=immoList&tx_howsite_json_list[wbs]=wbs-not-necessary&tx_howsite_json_list[limit]=100"
    # rubocop:enable Layout/LineLength

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      json = JSON.parse(http_client.get(LIST_URL).body)
      json.fetch("immoobjects").map do |listing|
        Apartment.new(
          external_id: "howoge-#{listing.fetch('title')}-#{listing.fetch('rent')}",
          properties: {
            address: listing.fetch("title"),
            url: "#{BASE_URL}#{listing.fetch('link')}",
            rooms_number: listing.fetch("rooms"),
            wbs: false
          }
        )
      end
    end

    private

    attr_accessor :http_client
  end
end
