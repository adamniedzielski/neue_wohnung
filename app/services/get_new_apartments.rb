# frozen_string_literal: true

class GetNewApartments
  def initialize(
    scrape_all: ScrapeAll.new,
    notify_about_apartment: NotifyAboutApartment.new,
    determine_subdistrict: DetermineSubdistrict.new
  )
    self.scrape_all = scrape_all
    self.notify_about_apartment = notify_about_apartment
    self.determine_subdistrict = determine_subdistrict
  end

  # rubocop:disable Style/MultilineBlockChain
  def call
    apartments = new_apartments

    Receiver.all.each do |receiver|
      apartments.select do |apartment|
        matches_preferences?(receiver, apartment)
      end.each do |apartment|
        notify_about_apartment.call(receiver, apartment)
      end
    end
  end
  # rubocop:enable Style/MultilineBlockChain

  private

  attr_accessor :scrape_all, :notify_about_apartment, :determine_subdistrict

  def new_apartments
    scrape_all
      .call
      .each { |apartment| determine_subdistrict.call(apartment) }
      .reject do |apartment|
        Apartment.find_by(external_id: apartment.external_id).present?
      end
      .each(&:save!)
  end

  def matches_preferences?(receiver, apartment)
    rooms_number = apartment.properties.fetch("rooms_number", nil)
    wbs = apartment.properties.fetch("wbs", false)

    return false if rooms_number && !(receiver.minimum_rooms_number..receiver.maximum_rooms_number).cover?(rooms_number)
    return false if wbs && !receiver.include_wbs?

    true
  end
end
