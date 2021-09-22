# frozen_string_literal: true

module Scraper
  class MaerkischeScholle
    class SkipSSLVerificationClient
      include HTTParty
      default_options.update(verify: false)
    end

    URL = "https://www.maerkische-scholle.de/wohnungsangebote.html"

    def initialize(http_client: SkipSSLVerificationClient)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      page.css("#main .ce_text").drop(1).map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      Apartment.new(
        external_id: "maerkische-scholle-#{listing.css('a').attribute('href').value}",
        properties: {
          address: listing.css("p strong").first.children.first.text,
          url: URL,
          rooms_number: Integer(listing.css("h2").text.match(/(\d+)\sZimmer/)[1])
        }
      )
    end
  end
end
