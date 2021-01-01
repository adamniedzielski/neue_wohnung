# frozen_string_literal: true

require "rails_helper"

RSpec.describe GetNewApartments do
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
    receiver = Receiver.create!(
      name: "Adam",
      telegram_chat_id: "chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 4
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    notify_about_apartment = instance_double(NotifyAboutApartment, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      notify_about_apartment: notify_about_apartment
    )

    service.call

    expect(notify_about_apartment).to have_received(:call)
      .with(receiver, apartment)
  end

  it "filters out apartments that were already scraped" do
    _old_apartment = Apartment.create!(external_id: "12345")
    scrape_all = instance_double(ScrapeAll, call: [Apartment.new(external_id: "12345")])
    notify_about_apartment = instance_double(NotifyAboutApartment, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      notify_about_apartment: notify_about_apartment
    )

    service.call

    expect(Apartment.count).to eq 1
    expect(notify_about_apartment).not_to have_received(:call)
  end

  it "saves new apartment to the database" do
    scrape_all = instance_double(ScrapeAll, call: [Apartment.new(external_id: "12345")])
    notify_about_apartment = instance_double(NotifyAboutApartment, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      notify_about_apartment: notify_about_apartment
    )

    service.call

    expect(Apartment.count).to eq 1
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
    first_receiver = Receiver.create!(
      name: "Adam",
      telegram_chat_id: "first-chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 3
    )
    second_receiver = Receiver.create!(
      name: "Irene and Chris",
      telegram_chat_id: "second-chat-id",
      include_wbs: false,
      minimum_rooms_number: 3,
      maximum_rooms_number: 4
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    notify_about_apartment = instance_double(NotifyAboutApartment, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      notify_about_apartment: notify_about_apartment
    )

    service.call

    expect(notify_about_apartment).to have_received(:call)
      .with(first_receiver, apartment)
    expect(notify_about_apartment).to have_received(:call)
      .with(second_receiver, apartment)
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
    matching_receiver = Receiver.create!(
      name: "Irene and Chris",
      telegram_chat_id: "first-chat-id",
      include_wbs: false,
      minimum_rooms_number: 3,
      maximum_rooms_number: 4
    )
    nonmatching_receiver = Receiver.create!(
      name: "Adam",
      telegram_chat_id: "second-chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    notify_about_apartment = instance_double(NotifyAboutApartment, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      notify_about_apartment: notify_about_apartment
    )

    service.call

    expect(notify_about_apartment).to have_received(:call)
      .with(matching_receiver, apartment)
    expect(notify_about_apartment).not_to have_received(:call)
      .with(nonmatching_receiver, apartment)
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
    receiver = Receiver.create!(
      name: "Adam",
      telegram_chat_id: "first-chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    notify_about_apartment = instance_double(NotifyAboutApartment, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      notify_about_apartment: notify_about_apartment
    )

    service.call

    expect(notify_about_apartment).to have_received(:call)
      .with(receiver, apartment)
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
    matching_receiver = Receiver.create!(
      name: "Paula",
      telegram_chat_id: "first-chat-id",
      include_wbs: true,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    nonmatching_receiver = Receiver.create!(
      name: "Adam",
      telegram_chat_id: "second-chat-id",
      include_wbs: false,
      minimum_rooms_number: 1,
      maximum_rooms_number: 2
    )
    scrape_all = instance_double(ScrapeAll, call: [apartment])
    notify_about_apartment = instance_double(NotifyAboutApartment, call: nil)
    service = GetNewApartments.new(
      scrape_all: scrape_all,
      notify_about_apartment: notify_about_apartment
    )

    service.call

    expect(notify_about_apartment).to have_received(:call)
      .with(matching_receiver, apartment)
    expect(notify_about_apartment).not_to have_received(:call)
      .with(nonmatching_receiver, apartment)
  end
end
