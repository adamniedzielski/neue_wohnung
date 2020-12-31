# frozen_string_literal: true

require "rails_helper"

RSpec.describe GetNewApartments do
  it "filters out apartments that were already scraped" do
    _old_apartment = Apartment.create!(external_id: "12345")
    scrape_all = instance_double(ScrapeAll, call: [Apartment.new(external_id: "12345")])
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(Apartment.count).to eq 1
  end

  it "saves new apartment to the database" do
    scrape_all = instance_double(ScrapeAll, call: [Apartment.new(external_id: "12345")])
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
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
        rooms_number: 4,
        wbs: false,
        url: "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
      }
    )
    Receiver.create!(
      name: "Adam",
      telegram_chat_id: "chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 4
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
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
        rooms_number: 3,
        wbs: false,
        url: "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
      }
    )
    Receiver.create!(
      name: "Adam",
      telegram_chat_id: "first-chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 3
    )
    Receiver.create!(
      name: "Irene and Chris",
      telegram_chat_id: "second-chat-id",
      include_wbs: false,
      minimum_rooms_number: 3,
      maximum_rooms_number: 4
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
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

  it "filters apartments based on receiver preferences" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        address: "Richard-Münch-Str. 42, 13591 Berlin/Staaken",
        rooms_number: 4,
        wbs: false,
        url: "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
      }
    )
    Receiver.create!(
      name: "Adam",
      telegram_chat_id: "first-chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    Receiver.create!(
      name: "Irene and Chris",
      telegram_chat_id: "second-chat-id",
      include_wbs: false,
      minimum_rooms_number: 3,
      maximum_rooms_number: 4
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(send_telegram_message).not_to have_received(:call)
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

  it "selects apartment when number of rooms is unknown" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        address: "Richard-Münch-Str. 42, 13591 Berlin/Staaken",
        wbs: false,
        url: "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
      }
    )
    Receiver.create!(
      name: "Adam",
      telegram_chat_id: "first-chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(send_telegram_message).to have_received(:call)
      .with(
        "first-chat-id",
        anything
      )
  end

  it "selects WBS apartments for recipients who have it" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        address: "Richard-Münch-Str. 42, 13591 Berlin/Staaken",
        rooms_number: 2,
        wbs: true,
        url: "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
      }
    )
    Receiver.create!(
      name: "Adam",
      telegram_chat_id: "first-chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    Receiver.create!(
      name: "Paula",
      telegram_chat_id: "second-chat-id",
      include_wbs: true,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      send_telegram_message: send_telegram_message
    )

    service.call

    expect(send_telegram_message).not_to have_received(:call)
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
    Receiver.create!(
      name: "Adam",
      telegram_chat_id: "chat-id",
      include_wbs: true,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
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
    Receiver.create!(
      name: "Adam",
      telegram_chat_id: "chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
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
