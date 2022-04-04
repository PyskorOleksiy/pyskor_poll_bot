require 'telegram/bot'

token = '5255604542:AAEVm5vBwtmiR2MiqeKLWenWJ_zSZetq_uo'
previously_message_id = 0

Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
  bot.logger.info('Bot has been started')
  bot.listen do |message|
    if message.class == Telegram::Bot::Types::Message
      if message.text == "/menu"
        kb =
        [
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Історія України', callback_data: "ukraine_history")
          ],
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Футбол', callback_data: "football")
          ],
        ]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        puts(message.message_id)
        previously_message_id = message.message_id
        bot.api.send_message(chat_id: message.chat.id, text: 'Опитування', reply_markup: markup)
      end
    end
    if message.class == Telegram::Bot::Types::CallbackQuery
      if message.data == "ukraine_history"
        puts(message.id)
        puts(previously_message_id)
        kb =
        [
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Україна під час Другої світової війни', callback_data: "ukraine_ww2")
          ],
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back")
          ]
        ]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        bot.api.send_message(chat_id: message.from.id, text: 'Історія України', reply_markup: markup)
      end
      if message.data == "back"
        puts(previously_message_id)
        kb =
        [
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Історія України', callback_data: "ukraine_history")
          ],
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Футбол', callback_data: "football")
          ],
        ]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        bot.api.edit_message_text(chat_id: message.from.id, text: "Опитування", message_id: message.message.message_id, reply_markup: markup)
      end
    end
  end
end
