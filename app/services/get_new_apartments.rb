# frozen_string_literal: true

class GetNewApartments
  def initialize(
    scrapers: [
      ScrapeGewobag.new,
      ScrapeWbm.new,
      ScrapeDpf.new,
      ScrapeWbgFriedrichshain.new,
      ScrapeDegewo.new,
      ScrapeEwgPankow.new,
      ScrapeStadtUndLand.new,
      ScrapeVaterland.new,
      ScrapeGesobau.new,
      ScrapeHowoge.new
    ],
    send_telegram_message: SendTelegramMessage.new
  )
    self.scrapers = scrapers
    self.send_telegram_message = send_telegram_message
  end

  def call
    new_apartments =
      scrapers
      .flat_map(&:call)
      .reject do |apartment|
        Apartment.find_by(external_id: apartment.external_id).present?
      end
      .each(&:save!)

    Receiver.all.each do |receiver|
      new_apartments.each do |apartment|
        notify_about_new_apartment(receiver, apartment) if matches_preferences?(receiver, apartment)
      end
    end
  end

  private

  attr_accessor :scrapers, :send_telegram_message

  def matches_preferences?(receiver, apartment)
    rooms_number = apartment.properties.fetch("rooms_number", nil)
    wbs = apartment.properties.fetch("wbs", false)

    return false if rooms_number && !(receiver.minimum_rooms_number..receiver.maximum_rooms_number).cover?(rooms_number)
    return false if wbs && !receiver.include_wbs?

    true
  end

  def notify_about_new_apartment(receiver, apartment)
    send_telegram_message.call(
      receiver.telegram_chat_id,
      <<~HEREDOC
        New apartment 🏠

        Address: #{apartment.properties.fetch('address', '?')}
        Rooms: #{apartment.properties.fetch('rooms_number', '?')}
        WBS: #{format_wbs_status(apartment)}

        #{apartment.properties.fetch('url', 'no link available')}
      HEREDOC
    )
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
