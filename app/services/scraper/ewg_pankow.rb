# frozen_string_literal: true

module Scraper
  class EwgPankow
    class ContentChanged < RuntimeError; end

    URL = "https://www.ewg-pankow.de/wohnen/"

    def initialize(http_client: HTTParty, bugsnag_client: Bugsnag)
      self.http_client = http_client
      self.bugsnag_client = bugsnag_client
    end

    def call
      html = http_client.get(URL).body
      page = Nokogiri::HTML(html)

      unless page.text.include?("Aktuell ist leider kein Wohnungsangebot verfügbar")
        bugsnag_client.notify(ContentChanged) do |report|
          report.add_tab(:html, html: html)
        end
      end

      []
    end

    private

    attr_accessor :http_client, :bugsnag_client
  end
end
