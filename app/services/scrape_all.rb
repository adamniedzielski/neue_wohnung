# frozen_string_literal: true

class ScrapeAll
  def initialize(
    scrapers: [
      Scraper::Bbg.new,
      Scraper::Degewo.new,
      Scraper::Dpf.new,
      Scraper::EwgPankow.new,
      Scraper::Gesobau.new,
      Scraper::Gewobag.new,
      Scraper::Howoge.new,
      Scraper::MaerkischeScholle.new,
      Scraper::Mlbaugenossen.new,
      Scraper::NeuesBerlin.new,
      Scraper::StadtUndLand.new,
      Scraper::Vaterland.new,
      Scraper::Vbveg.new,
      Scraper::WbgFriedrichshain.new,
      Scraper::WbgHub.new,
      Scraper::WbgZentrum.new,
      Scraper::Wbm.new
    ]
  )
    self.scrapers = scrapers
  end

  def call
    scrapers.map do |scraper|
      scraper.call
    rescue Errno::ECONNREFUSED, Errno::ECONNRESET, OpenSSL::SSL::SSLError,
           Net::OpenTimeout, Net::ReadTimeout, SocketError => e
      Bugsnag.notify(e) do |report|
        report.severity = "warning"
      end

      []
    end.flatten
  end

  private

  attr_accessor :scrapers
end
