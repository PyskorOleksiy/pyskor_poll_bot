def stop(bot, message, polling_name, previously_genres_markup)
  if User.exists?(telegram_id: message.from.id)
    user = User.where(telegram_id: message.from.id)
    polling = Polling.find_by(name: polling_name)
    user.each do |us|
      if us.polling_id == polling.id
        points = 0
        poll_status = "update"
        us.update(points: points, poll_status: poll_status)
      end
    end
  end
  delete_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
  bot.api.send_message(chat_id: message.from.id, text: "Ви перервали опитування.\u{2757}Набрані бали анульовано", reply_markup: delete_kb)
  bot.api.send_message(chat_id: message.chat.id, text: 'Опитування', reply_markup: previously_genres_markup)
  poll = false
  first_question = true
  questions_counter = 0
  points = 0

  return poll, first_question, questions_counter, points
end
