def finish_polling(bot, message, test_hash, questions_count, polling_name, points)
  custom_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
  bot.api.send_message(chat_id: message.from.id, text: 'Опитування завершено. Ви можете пройти його знову, але попередньо набрані бали анулюються', reply_markup: custom_kb)
  points_string = "Ваш результат: " + points.to_s
  bot.api.send_message(chat_id: message.chat.id, text: points_string)

  terrible_mark = test_hash[0][polling_name][questions_count-1]["terrible"]
  bad_mark = test_hash[0][polling_name][questions_count-1]["bad"]
  medium_mark = test_hash[0][polling_name][questions_count-1]["medium"]
  good_mark = test_hash[0][polling_name][questions_count-1]["good"]
  unique_mark = test_hash[0][polling_name][questions_count-1]["unique"]
  rating_scale = "#{terrible_mark}\n#{bad_mark}\n#{medium_mark}\n#{good_mark}\n#{unique_mark}"
  bot.api.send_message(chat_id: message.chat.id, text: rating_scale)

  #questions_count = test_hash[0][polling_name].size
  books_sources = test_hash[0][polling_name][questions_count-1]["sources"]["books"]
  you_tube_sources = test_hash[0][polling_name][questions_count-1]["sources"]["you_tube"]
  sources_title = "Рекомендовані джерела інформації по даній темі\n"
  books = "Література:\n"
  you_tube_videos = "YouTube:\n"
  books_sources.each do |book|
    books += "#{book}\n"
  end
  you_tube_sources.each do |video|
    you_tube_videos += "#{video}\n"
  end
  sources = sources_title + books + you_tube_videos
  bot.api.send_message(chat_id: message.chat.id, text: "\u{2757}\u{2757}\u{2757}#{sources}")
end
