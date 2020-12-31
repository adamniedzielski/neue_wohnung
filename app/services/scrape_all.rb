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
      Scraper::Howoge.new
    ]
  )
    self.scrapers = scrapers
  end

  def call
    scrapers.flat_map(&:call)
  end

  private

  attr_accessor :scrapers
end
