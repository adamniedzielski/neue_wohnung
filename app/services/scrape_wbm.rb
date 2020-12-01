# frozen_string_literal: true

class ScrapeWbm
  URL = "https://www.wbm.de/wohnungen-berlin/angebote/"

  def initialize(http_client: HTTParty)
    self.http_client = http_client
  end

  def call
    page = Nokogiri::HTML(http_client.get(URL).body)
    page.css(".openimmo-search-list-item").map { |listing| parse(listing) }
  end

  private

  attr_accessor :http_client

  def parse(listing)
    Apartment.new(
      external_id: "wbm-#{listing.attribute('data-id').value}",
      properties: {
        address: listing.css(".address").text.split(",").join(", "),
        url: listing.css(".btn.sign").attribute("href").value,
        rooms_number: rooms_number(listing),
        wbs: listing.css(".check-property-list").text.include?("WBS")
      }
    )
  end

  def rooms_number(listing)
    Integer(listing.css(".main-property-list").text.match(/Zimmer:(\d*)/)[1])
  end
end
