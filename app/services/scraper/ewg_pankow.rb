# frozen_string_literal: true

module Scraper
  class EwgPankow
    URL = "https://www.ewg-pankow.de/wohnen/"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      page = Nokogiri::HTML(http_client.get(URL).body)
      container = page.css(".elementor-posts-container").first

      return [] if container.text.include?("Aktuell ist leider kein Wohnungsangebot verfügbar")

      container.css(".elementor-post.type-wohnungen").map { |listing| parse(listing) }
    end

    private

    attr_accessor :http_client

    def parse(listing)
      Apartment.new(
        external_id: external_id(listing),
        properties: {
          address: address(listing),
          url: url(listing),
          rooms_number: rooms_number(listing)
        }
      )
    end

    def external_id(listing)
      post_id = listing.attr("class").match(/post-(\d*).*/)[1]
      "ewg-pankow-#{post_id}"
    end

    def address(listing)
      listing.css(".elementor-post__title").text.strip.gsub(/(\d*).*Zimmer,\s/, "")
    end

    def url(listing)
      listing.css(".elementor-post__read-more").attr("href").value
    end

    def rooms_number(listing)
      Integer(listing.css(".elementor-post__excerpt").text.match(/(\d*).*Zimmer/)[1])
    end
  end
end
