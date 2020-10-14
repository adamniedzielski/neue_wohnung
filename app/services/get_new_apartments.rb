class GetNewApartments
  def initialize(
    scrapers: [ScrapeGewobag.new],
    send_telegram_message: SendTelegramMessage.new
  )
    self.scrapers = scrapers
    self.send_telegram_message = send_telegram_message
  end

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

  private

  attr_accessor :scrapers
  attr_accessor :send_telegram_message

  def notify_about_new_apartment(apartment)
    send_telegram_message.call(
      "New apartment: #{apartment.properties.to_s}")
  end
end
