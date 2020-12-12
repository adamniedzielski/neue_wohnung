# frozen_string_literal: true

class GetNewApartments
  def initialize(
    scrapers: [
      ScrapeGewobag.new,
      ScrapeWbm.new,
      ScrapeDpf.new,
      ScrapeWbgFriedrichshain.new,
      ScrapeDegewo.new,
      ScrapeEwgPankow.new
    ],
    send_telegram_message: SendTelegramMessage.new
  )
    self.scrapers = scrapers
    self.send_telegram_message = send_telegram_message
  end

  # rubocop:disable Style/MultilineBlockChain
  def call
    scrapers
      .flat_map(&:call)
      .reject do |apartment|
        Apartment.find_by(external_id: apartment.external_id).present?
      end
      .each do |apartment|
        apartment.save!
        notify_about_new_apartment(apartment)
      end
  end
  # rubocop:enable Style/MultilineBlockChain

  private

  attr_accessor :scrapers, :send_telegram_message

  def notify_about_new_apartment(apartment)
    send_telegram_message.call(
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
