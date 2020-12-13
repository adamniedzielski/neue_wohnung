# frozen_string_literal: true

class ScrapeStadtUndLand
  URL = "https://www.stadtundland.de/Wohnungssuche/Wohnungssuche.php?form=stadtundland-expose-search-1.form&sp%3AroomsFrom%5B%5D=&sp%3AroomsTo%5B%5D=&sp%3ArentPriceFrom%5B%5D=&sp%3ArentPriceTo%5B%5D=&sp%3AareaFrom%5B%5D=&sp%3AareaTo%5B%5D=&sp%3Afeature%5B%5D=__last__&action=submit"

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
