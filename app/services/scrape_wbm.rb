# frozen_string_literal: true

class ScrapeWbm
  BASE_URL = "https://www.wbm.de"
  LIST_URL = "#{BASE_URL}/wohnungen-berlin/angebote/"

  def initialize(http_client: HTTParty)
    self.http_client = http_client
  end

  def call
    page = Nokogiri::HTML(http_client.get(LIST_URL).body)
    page.css(".openimmo-search-list-item").map { |listing| parse(listing) }
  end

  private

  attr_accessor :http_client

  def parse(listing)
    Apartment.new(
      external_id: "wbm-#{listing.attribute('data-id').value}",
      properties: {
        address: listing.css(".address").text.split(",").join(", "),
        url: url(listing),
        rooms_number: rooms_number(listing),
        wbs: listing.css(".check-property-list").text.include?("WBS")
      }
    )
  end

  def url(listing)
    value = listing.css(".btn.sign").attribute("href").value

    if value.start_with?("https")
      value
    else
      "#{BASE_URL}#{value}"
    end
  end

  def rooms_number(listing)
    Integer(listing.css(".main-property-list").text.match(/Zimmer:(\d*)/)[1])
  end
end
