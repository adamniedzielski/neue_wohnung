# frozen_string_literal: true

module Scraper
  class StadtUndLand
    BASE_URL = "https://www.stadtundland.de"
    # rubocop:disable Layout/LineLength
    LIST_URL = "#{BASE_URL}/Wohnungssuche/Wohnungssuche.php?form=stadtundland-expose-search-1.form&sp%3AroomsFrom%5B%5D=&sp%3AroomsTo%5B%5D=&sp%3ArentPriceFrom%5B%5D=&sp%3ArentPriceTo%5B%5D=&sp%3AareaFrom%5B%5D=&sp%3AareaTo%5B%5D=&sp%3Afeature%5B%5D=__last__&action=submit"
    # rubocop:enable Layout/LineLength

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(LIST_URL).body)
      page.css(".SP-TeaserList__item").map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      Apartment.new(
        external_id: "stadt-und-land-#{url(listing)}",
        properties: {
          address: listing.css("tr").find { |element| element.text.include?("Adresse") }.css("td").text,
          url: url(listing),
          rooms_number: rooms_number(listing),
          wbs: listing.css(".SP-Teaser__headline").text.downcase.include?("wbs")
        }
      )
    end

    def url(listing)
      "#{BASE_URL}#{listing.css('.SP-Link').first.attribute('href').value}"
    end

    def rooms_number(listing)
      listing.css("tr").find do |element|
        element.text.include?("Zimmer")
      end.css("td").text.to_i
    end
  end
end
