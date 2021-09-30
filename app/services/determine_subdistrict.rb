# frozen_string_literal: true

class DetermineSubdistrict
  SUBDISTRICTS_BY_ZIP_CODE = {
    "10439" => "Prenzlauer Berg"
  }.freeze

  def call(apartment)
    match = apartment.properties.fetch("address", "").match(/\d{5}/)

    return unless match

    zip_code = match[0]
    subdistrict = SUBDISTRICTS_BY_ZIP_CODE.fetch(zip_code, nil)

    return unless subdistrict

    apartment.properties["subdistrict"] = subdistrict
  end
end
