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

def back_callbacks(bot, message, previously_genres_markup, previously_categories_markup, previously_chapters_markup, previously_markup_genre_text, previously_markup_category_text)
  if message.data == "back_to_genres"
    bot.api.edit_message_text(chat_id: message.from.id, text: "Опитування", message_id: message.message.message_id, reply_markup: previously_genres_markup)
    #restart = false

  elsif message.data == "back_to_categories"
    bot.api.edit_message_text(chat_id: message.from.id, text: previously_markup_genre_text, message_id: message.message.message_id, reply_markup: previously_categories_markup)

  elsif message.data == "back_to_chapters"
    bot.api.edit_message_text(chat_id: message.from.id, text: previously_markup_category_text, message_id: message.message.message_id, reply_markup: previously_chapters_markup)

  #elsif message.data == "back_to_didnot_subscribed"
    #put_in_channels_tables(bot, message, previously_markup_genre_text)
    #bot.api.edit_message_text(chat_id: message.from.id, text: "Канали, на які ви НЕ ПІДПИСАНІ", message_id: message.message.message_id, reply_markup: prev_didnot_subscribed_markup)
    #polling_passed = false

  elsif message.data == "back_to_hashtags"
    #previously_hashtags_markup = hashtags(bot, message, previously_markup_genre_text)
    hashtags(bot, message, previously_markup_genre_text)

  elsif message.data == "back_to_interesting_hashtags"
    interesting_hashtags(bot, message, previously_markup_genre_text)
  end
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
