# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotifyAboutApartment do
  it "sends Telegram notification that includes apartment details" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        address: "Richard-Münch-Str. 42, 13591|Berlin/Staaken",
        rooms_number: 4,
        wbs: false,
        url: "https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/"
      }
    )
    receiver = Receiver.new(
      telegram_chat_id: "chat-id"
    )
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = NotifyAboutApartment.new(
      send_telegram_message: send_telegram_message
    )

    service.call(receiver, apartment)

    expect(send_telegram_message).to have_received(:call)
      .with(
        "chat-id",
        <<~HEREDOC
          New apartment 🏠

          Address: Richard-Münch-Str. 42, 13591|Berlin/Staaken
          Rooms: 4
          WBS: not required

          https://www.gewobag.de/fuer-mieter-und-mietinteressenten/mietangebote/7100-74806-0305-0076/
          https://www.google.com/maps/search/?api=1&query=Richard-Münch-Str.+42++13591+Berlin+Staaken
        HEREDOC
      )
  end

  it "formats notification when WBS is required" do
    apartment = Apartment.new(
      external_id: "12345",
      properties: {
        wbs: true
      }
    )
    receiver = Receiver.new(
      telegram_chat_id: "chat-id"
    )
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = NotifyAboutApartment.new(
      send_telegram_message: send_telegram_message
    )

    service.call(receiver, apartment)

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
        address: "Richard-Münch-Str. 42, 13591|Berlin/Staaken"
      }
    )
    receiver = Receiver.new(
      telegram_chat_id: "chat-id"
    )
    send_telegram_message = instance_double(SendTelegramMessage, call: nil)
    service = NotifyAboutApartment.new(
      send_telegram_message: send_telegram_message
    )

    service.call(receiver, apartment)

    expect(send_telegram_message).to have_received(:call)
      .with(
        "chat-id",
        <<~HEREDOC
          New apartment 🏠

          Address: Richard-Münch-Str. 42, 13591|Berlin/Staaken
          Rooms: ?
          WBS: ?

          no link available
          https://www.google.com/maps/search/?api=1&query=Richard-Münch-Str.+42++13591+Berlin+Staaken
        HEREDOC
      )
  end
end
