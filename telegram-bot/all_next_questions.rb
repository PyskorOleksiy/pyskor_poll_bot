def all_next_questions(bot, message, questions, questions_counter)
  question = questions[questions_counter]["question"]
  answer1 = questions[questions_counter]["answers"][0]
  if questions[questions_counter]["answers"][0].class == Hash
    answer1 = questions[questions_counter]["answers"][0]["true"]
  end
  answer2 = questions[questions_counter]["answers"][1]
  if questions[questions_counter]["answers"][1].class == Hash
    answer2 = questions[questions_counter]["answers"][1]["true"]
  end
  answer3 = questions[questions_counter]["answers"][2]
  if questions[questions_counter]["answers"][2].class == Hash
    answer3 = questions[questions_counter]["answers"][2]["true"]
  end
  answer4 = questions[questions_counter]["answers"][3]
  if questions[questions_counter]["answers"][3].class == Hash
    answer4 = questions[questions_counter]["answers"][3]["true"]
  end
  # See more: https://core.telegram.org/bots/api#replykeyboardmarkup
  custom_kb =
  [
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: answer1, callback_data: "1"),
      Telegram::Bot::Types::InlineKeyboardButton.new(text: answer2, callback_data: "2"),
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: answer3, callback_data: "3"),
      Telegram::Bot::Types::InlineKeyboardButton.new(text: answer4, callback_data: "4"),
    ],
  ]
  answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: custom_kb, one_time_keyboard: true)
  bot.api.send_message(chat_id: message.from.id, text: question, reply_markup: answers)
  answers_list = "#{answer1}\n#{answer2}\n#{answer3}\n#{answer4}\n"
  bot.api.send_message(chat_id: message.from.id, text: answers_list)
end
