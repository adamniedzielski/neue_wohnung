# frozen_string_literal: true

class ScrapeGewobag
  URL = "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/?bezirke_all=&bezirke%5B%5D=friedrichshain-kreuzberg&bezirke%5B%5D=friedrichshain-kreuzberg-friedrichshain&bezirke%5B%5D=friedrichshain-kreuzberg-kreuzberg&bezirke%5B%5D=lichtenberg&bezirke%5B%5D=lichtenberg-alt-hohenschoenhausen&bezirke%5B%5D=lichtenberg-falkenberg&bezirke%5B%5D=lichtenberg-fennpfuhl&bezirke%5B%5D=neukoelln&bezirke%5B%5D=neukoelln-britz&bezirke%5B%5D=neukoelln-buckow&bezirke%5B%5D=pankow&bezirke%5B%5D=pankow-prenzlauer-berg&bezirke%5B%5D=reinickendorf&bezirke%5B%5D=reinickendorf-waidmannslust&bezirke%5B%5D=spandau&bezirke%5B%5D=spandau-haselhorst&bezirke%5B%5D=spandau-staaken&bezirke%5B%5D=steglitz-zehlendorf&bezirke%5B%5D=steglitz-zehlendorf-lichterfelde&bezirke%5B%5D=tempelhof-schoeneberg&bezirke%5B%5D=tempelhof-schoeneberg-mariendorf&bezirke%5B%5D=treptow-koepenick&bezirke%5B%5D=treptow-koepenick-adlershof&bezirke%5B%5D=treptow-koepenick-alt-treptow&nutzungsarten%5B%5D=wohnung&gesamtmiete_von=&gesamtmiete_bis=&gesamtflaeche_von=&gesamtflaeche_bis=&zimmer_von=3&zimmer_bis=4&keinwbs=1"

  def initialize(http_client: HTTParty)
    self.http_client = http_client
  end

  def call
    page = Nokogiri::HTML(http_client.get(URL).body)
    page.css("article.angebot").map do |listing|
      Apartment.new(
        external_id: listing.attribute("id").value.gsub("post", "gewobag"),
        properties: {
          address: listing.css("address").text.strip,
          url: listing.css(".read-more-link").attribute("href").value,
          rooms_number: 3..4,
          wbs: false
        }
      )
    end
  end

  private

  attr_accessor :http_client
end
