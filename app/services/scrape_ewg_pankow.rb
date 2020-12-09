# frozen_string_literal: true

class ScrapeEwgPankow
  URL = "https://www.ewg-pankow.de/wohnen/"

  def initialize(http_client: HTTParty)
    self.http_client = http_client
  end

  def call
    _page = Nokogiri::HTML(http_client.get(URL).body)

    []
  end

  private

  attr_accessor :http_client
end
