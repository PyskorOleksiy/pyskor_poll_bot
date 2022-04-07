def ukraine_history(bot, message)
  kb =
  [
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Україна під час Другої світової війни', callback_data: "Україна в Другій світовій війні")
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Джерела інформації', callback_data: "sources")
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back")
    ]
  ]
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  bot.api.edit_message_text(chat_id: message.from.id, text: "Історія України", message_id: message.message.message_id, reply_markup: markup)
end
