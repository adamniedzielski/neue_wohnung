# frozen_string_literal: true

class NotifyAboutApartment
  def initialize(send_telegram_message: SendTelegramMessage.new)
    self.send_telegram_message = send_telegram_message
  end

  def call(receiver, apartment)
    send_telegram_message.call(
      receiver.telegram_chat_id,
      <<~HEREDOC
        New apartment 🏠

        Address: #{apartment.properties.fetch('address', '?')}
        Rooms: #{apartment.properties.fetch('rooms_number', '?')}
        WBS: #{format_wbs_status(apartment)}

        #{apartment.properties.fetch('url', 'no link available')}
        #{format_google_maps_link(apartment)}
      HEREDOC
    )
  end

  private

  attr_accessor :send_telegram_message

  def format_google_maps_link(apartment)
    return "" unless apartment.properties.key?("address")
    return "" unless apartment.properties["address"].present?

    params = apartment.properties["address"]
                      .gsub(" ", "+")
                      .gsub(",", "+")
                      .gsub("/", "+")
                      .gsub("|", "+")

    "https://www.google.com/maps/search/?api=1&query=#{params}"
  end

  def format_wbs_status(apartment)
    return "?" unless apartment.properties.key?("wbs")

    if apartment.properties.fetch("wbs")
      "required"
    else
      "not required"
    end
  end
end
