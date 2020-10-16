# frozen_string_literal: true

require "rails_helper"

RSpec.describe SendTelegramMessage do
  it "successfully sends a message" do
    result = SendTelegramMessage.new.call("This is a test message")

    expect(result.fetch("ok")).to eq true
  end
end
