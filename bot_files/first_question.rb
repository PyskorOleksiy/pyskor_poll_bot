def first_question(bot, message, test_hash, polling_name)
  start_question = test_hash[0][polling_name][0]["question"]
  start_question_answers = test_hash[0][polling_name][0]["answers"]
  questions_count = test_hash[0][polling_name].size
  questions = test_hash[0][polling_name][0..questions_count-2]
  #terrible_mark = test_hash[0][polling_name][questions_count-1]["terrible"]
  #bad_mark = test_hash[0][polling_name][questions_count-1]["bad"]
  #medium_mark = test_hash[0][polling_name][questions_count-1]["medium"]
  #good_mark = test_hash[0][polling_name][questions_count-1]["good"]
  #unique_mark = test_hash[0][polling_name][questions_count-1]["unique"]
  s = "~"
  s += start_question + '~'


  answer1 = start_question_answers[0]
  if start_question_answers[0].class == Hash
    answer1 = start_question_answers[0]["true"]
  end
  answer2 = start_question_answers[1]
  if start_question_answers[1].class == Hash
    answer2 = start_question_answers[1]["true"]
  end
  answer3 = start_question_answers[2]
  if start_question_answers[2].class == Hash
    answer3 = start_question_answers[2]["true"]
  end
  answer4 = start_question_answers[3]
  if start_question_answers[3].class == Hash
    answer4 = start_question_answers[3]["true"]
  end
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
  bot.api.send_message(chat_id: message.from.id, text: start_question, reply_markup: answers)
  answers_list = "#{answer1}\n#{answer2}\n#{answer3}\n#{answer4}\n"
  bot.api.send_message(chat_id: message.from.id, text: answers_list)

  return questions_count, questions
end
