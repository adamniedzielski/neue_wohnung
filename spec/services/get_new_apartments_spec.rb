require "rails_helper"

RSpec.describe GetNewApartments do
  it "calls each scraper" do
    first_scraper = double(call: [])
    second_scraper = double(call: [])
    service = GetNewApartments.new(scrapers: [first_scraper, second_scraper])

    service.call

    expect(first_scraper).to have_received(:call)
    expect(second_scraper).to have_received(:call)
  end

  it "filters out apartments that were already scraped" do
    old_apartment = Apartment.create!(external_id: "12345")
    scraper = double(call: [Apartment.new(external_id: "12345")])
    service = GetNewApartments.new(scrapers: [scraper])

    service.call

    expect(Apartment.count).to eq 1
  end

  it "saves new apartment to the database" do
    scraper = double(call: [Apartment.new(external_id: "12345")])
    service = GetNewApartments.new(scrapers: [scraper])

    service.call

    expect(Apartment.count).to eq 1
  end

  it "notifies about new apartments" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        adddress: "Richard-Münch-Str. 42, 13591 Berlin/Staaken"
      }
    )
    scraper = double(call: [apartment])
    send_telegram_message = double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrapers: [scraper],
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(send_telegram_message).to have_received(:call)
      .with('New apartment: {"adddress"=>"Richard-Münch-Str. 42, 13591 Berlin/Staaken"}')
  end
end
