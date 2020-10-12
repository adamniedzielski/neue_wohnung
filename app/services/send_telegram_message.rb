require 'telegram/bot'

class SendTelegramMessage
  def call(text)
    client = Telegram::Bot::Client.new(ENV.fetch("TELEGRAM_TOKEN"))
    client.api.send_message(
      chat_id: ENV.fetch("TELEGRAM_CHAT_ID"),
      text: text
    )
  end
end
