def results(bot, message)
  kb =
  [
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back_to_genres")
    ]
  ]
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  pollings = nil
  results = ""
  if User.exists?(telegram_id: message.from.id)
    user = User.where(telegram_id: message.from.id)
    user.each do |us|
      polling = Polling.find_by(id: us.polling_id)
      results += "#{polling.topic}: #{polling.name} - #{us.points} б.\n"
    end
    results_string = "Ваші результати пройдених опитувань:\n" + results
    bot.api.edit_message_text(chat_id: message.from.id, text: results_string, message_id: message.message.message_id, reply_markup: markup)
  else
    bot.api.edit_message_text(chat_id: message.from.id, text: "Ви ще не пройшли жодного опитування!", message_id: message.message.message_id, reply_markup: markup)
  end
end
