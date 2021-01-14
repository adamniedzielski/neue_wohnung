# frozen_string_literal: true

module Scraper
  class EwgPankow
    class ContentChanged < RuntimeError; end

    URL = "https://www.ewg-pankow.de/wohnen/"

    def initialize(http_client: HTTParty)
      self.http_client = http_client
    end

    def call
      html = http_client.get(URL).body
      _page = Nokogiri::HTML(html)

      []
    end

    private

    attr_accessor :http_client
  end
end
