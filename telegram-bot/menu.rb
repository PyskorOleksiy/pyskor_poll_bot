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
  previously_jenres_markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  bot.api.send_message(chat_id: message.chat.id, text: 'Опитування', reply_markup: markup)

  return previously_jenres_markup
end
