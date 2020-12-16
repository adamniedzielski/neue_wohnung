# frozen_string_literal: true

require "rails_helper"

RSpec.describe GetNewApartments do
  it "calls each scraper" do
    first_scraper = double(call: [])
    second_scraper = double(call: [])
    send_telegram_message = double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrapers: [first_scraper, second_scraper],
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(first_scraper).to have_received(:call)
    expect(second_scraper).to have_received(:call)
  end

  it "filters out apartments that were already scraped" do
    _old_apartment = Apartment.create!(external_id: "12345")
    scraper = double(call: [Apartment.new(external_id: "12345")])
    send_telegram_message = double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrapers: [scraper],
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(Apartment.count).to eq 1
  end

  it "saves new apartment to the database" do
    scraper = double(call: [Apartment.new(external_id: "12345")])
    send_telegram_message = double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrapers: [scraper],
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(Apartment.count).to eq 1
  end

  it "notifies about new apartments" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        address: "Richard-Münch-Str. 42, 13591 Berlin/Staaken",
        rooms_number: "4",
        wbs: false,
        url: "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
      }
    )
    Receiver.create!(telegram_chat_id: "chat-id")
    scraper = double(call: [apartment])
    send_telegram_message = double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrapers: [scraper],
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(send_telegram_message).to have_received(:call)
      .with(
        "chat-id",
        <<~HEREDOC
          New apartment 🏠

          Address: Richard-Münch-Str. 42, 13591 Berlin/Staaken
          Rooms: 4
          WBS: not required

          https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/
        HEREDOC
      )
  end

  it "notifies multiple receivers" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        address: "Richard-Münch-Str. 42, 13591 Berlin/Staaken",
        rooms_number: "4",
        wbs: false,
        url: "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
      }
    )
    Receiver.create!(telegram_chat_id: "first-chat-id")
    Receiver.create!(telegram_chat_id: "second-chat-id")
    scraper = double(call: [apartment])
    send_telegram_message = double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrapers: [scraper],
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(send_telegram_message).to have_received(:call)
      .with(
        "first-chat-id",
        anything
      )
    expect(send_telegram_message).to have_received(:call)
      .with(
        "second-chat-id",
        anything
      )
  end

  it "formats notification when WBS is required" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        wbs: true
      }
    )
    Receiver.create!(telegram_chat_id: "chat-id")
    scraper = double(call: [apartment])
    send_telegram_message = double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrapers: [scraper],
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(send_telegram_message).to have_received(:call)
      .with(
        "chat-id",
        <<~HEREDOC
          New apartment 🏠

          Address: ?
          Rooms: ?
          WBS: required

          no link available
        HEREDOC
      )
  end

  it "formats notification when WBS status is unknown" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        address: "Richard-Münch-Str. 42, 13591 Berlin/Staaken"
      }
    )
    Receiver.create!(telegram_chat_id: "chat-id")
    scraper = double(call: [apartment])
    send_telegram_message = double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrapers: [scraper],
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(send_telegram_message).to have_received(:call)
      .with(
        "chat-id",
        <<~HEREDOC
          New apartment 🏠

          Address: Richard-Münch-Str. 42, 13591 Berlin/Staaken
          Rooms: ?
          WBS: ?

          no link available
        HEREDOC
      )
  end
end
