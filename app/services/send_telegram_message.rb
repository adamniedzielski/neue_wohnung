# frozen_string_literal: true

require "telegram/bot"

class SendTelegramMessage
  def call(chat_id, text)
    client = Telegram::Bot::Client.new(Rails.application.config.telegram_token)
    client.api.send_message(
      chat_id: chat_id,
      text: text
    )
  end
end
