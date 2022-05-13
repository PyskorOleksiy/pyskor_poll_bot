def menu(bot, message)
  kb =
  [
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Історія України', callback_data: "Історія України")
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Футбол', callback_data: "Футбол")
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Ваші результати', callback_data: "results")
    ],
  ]
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  previously_genres_markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  bot.api.send_message(chat_id: message.chat.id, text: 'Опитування', reply_markup: markup)

  return previously_genres_markup
end

def genres(bot, message)
  kb = []
  if message.data == "Історія України"
    kb =
    [
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Україна під час Другої світової війни', callback_data: "Друга Світова війна")
      ]
    ]
  elsif message.data == "Футбол"
    kb =
    [
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Футбол(test polling)', callback_data: "Футбол(test polling)")
      ]
    ]
  end

  kb.push([ Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Telegram-канали', callback_data: "Telegram-канали") ])
  kb.push([ Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back_to_genres") ])
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  bot.api.edit_message_text(chat_id: message.from.id, text: message.data, message_id: message.message.message_id, reply_markup: markup)

  return markup
end
