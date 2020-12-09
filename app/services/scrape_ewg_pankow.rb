# frozen_string_literal: true

class ScrapeEwgPankow
  class ContentChanged < RuntimeError; end

  URL = "https://www.ewg-pankow.de/wohnen/"

  def initialize(http_client: HTTParty, bugsnag_client: Bugsnag)
    self.http_client = http_client
    self.bugsnag_client = bugsnag_client
  end

  def call
    _page = Nokogiri::HTML(http_client.get(URL).body)

    bugsnag_client.notify(ContentChanged) do |report|
      report.add_tab(:html, html: html)
    end

    []
  end

  private

  attr_accessor :http_client, :bugsnag_client
end
