# frozen_string_literal: true

module Scraper
  class WbgZentrum
    URL = "https://www.wbg-zentrum.de/wohnen/wohnungsangebot-2/wohnungsangebot/"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page.css(".overview .vc_row").drop(1).map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      Apartment.new(
        external_id: "wbg-zentrum-#{url(listing)}",
        properties: {
          address: listing.css(".vc_col-sm-8 span")[1].text,
          url: url(listing),
          rooms_number: rooms_number(listing),
          wbs: listing.text.include?("mit WBS")
        }
      )
    end

    def url(listing)
      listing.css("a").attribute("href").value
    end

    def rooms_number(listing)
      Integer(listing.text.match(/(\d*)-Zimmer-Wohnung/)[1])
    end
  end
end
