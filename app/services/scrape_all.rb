# frozen_string_literal: true

class ScrapeAll
  def initialize(
    scrapers: [
      Scraper::Gewobag.new,
      Scraper::Wbm.new,
      Scraper::Dpf.new,
      Scraper::WbgFriedrichshain.new,
      Scraper::Degewo.new,
      Scraper::EwgPankow.new,
      Scraper::StadtUndLand.new,
      Scraper::Vaterland.new,
      Scraper::Gesobau.new,
      Scraper::Howoge.new,
      Scraper::Bbg.new
    ]
  )
    self.scrapers = scrapers
  end

  def call
    scrapers.map do |scraper|
      scraper.call
    rescue OpenSSL::SSL::SSLError, Net::OpenTimeout, Net::ReadTimeout, SocketError => e
      Bugsnag.notify(e) do |report|
        report.severity = "warning"
      end

      []
    end.flatten
  end

  private

  attr_accessor :scrapers
end
