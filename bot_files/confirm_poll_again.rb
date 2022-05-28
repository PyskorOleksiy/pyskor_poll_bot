def confirm_poll_again(bot, message, polling_name, polling_passed, passed_polling_id)
  user = User.where(telegram_id: message.from.id)
  polling = Polling.find_by(name: polling_name)
  user.each do |us|
    if us.polling_id == polling.id
      polling_passed = true
      passed_polling_id = us.polling_id
      callback_data = polling_name + "_restart"
      confirm_kb =
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Так', callback_data: callback_data),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Ні', callback_data: "back_to_genres")
      ]
      confirm_markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: confirm_kb)
      bot.api.edit_message_text(chat_id: message.from.id, text: "\u{2757}\u{2757}\u{2757} Ви вже проходили дане опитування! Хочете пройти ще раз? Всі бали, включно з балами за попереднє опитування будуть анульовані після переривання опитування!", message_id: message.message.message_id, reply_markup: confirm_markup)
    end
  end

  return polling_passed, passed_polling_id
end
