# frozen_string_literal: true

module Scraper
  class Dpf
    URL = "https://www.dpfonline.de/interessenten/immobilien/"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page.css(".immo-archive-cc").map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      Apartment.new(
        external_id: "dpf-#{url(listing)}",
        properties: {
          address: listing.css(".uk-list li").first.text.strip,
          url: url(listing),
          rooms_number: rooms_number(listing),
          wbs: listing.css("a").text.include?("WBS")
        }
      )
    end

    def url(listing)
      listing.css("a").attribute("href").value
    end

    def rooms_number(listing)
      element_with_data = listing.css(".uk-width-medium-1-4").find do |element|
        element.text.match(/(\d*).*Zimmer/)
      end

      Integer(element_with_data.at(".immo-data").text.strip)
    end
  end
end
