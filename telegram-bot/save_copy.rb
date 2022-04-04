require 'telegram/bot'
require 'json'

token = '5255604542:AAEVm5vBwtmiR2MiqeKLWenWJ_zSZetq_uo'

#message_flag = 0
questions_counter = 0
first_question = true
poll = false
points = 0
previously_markup = nil
previously_kb = nil
previously_message_id = 0
#wrong_command_cheking = false

test_file = File.open('questions.json',"rb")
test_hash = JSON.parse(test_file.read)
#test_hash_size = test_hash.size
#start_question = test_hash[0]["question"]
#start_question_answers = test_hash[0]["answers"]
#questions = test_hash[0..test_hash_size-1]
questions_count = 0
questions = []
terrible_mark = ""
bad_mark = ""
medium_mark = ""
good_mark = ""
unique_mark = ""
test_file.close

Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
  bot.logger.info('Bot has been started')
  bot.listen do |message|
    #puts(message_flag)
    #puts(poll)
    #bot.api.delete_message(chat_id: message.chat.id, message_id: message.message_id)
    puts(previously_message_id)
    puts(message.message_id)
    if message.class == Telegram::Bot::Types::Message and poll == true
      questions.each do |item|
        item["answers"].each do |el|
          if el.class == Hash
            if message.text == el["true"]
              bot.api.send_message(chat_id: message.chat.id, text: "That's true!")
              points += 1
            end
          end
        end
      end
      if questions_counter == questions_count-2
        custom_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
        bot.api.send_message(chat_id: message.from.id, text: 'Опитування завершено.', reply_markup: custom_kb)
        points_string = "Ваш результат: " + points.to_s
        bot.api.send_message(chat_id: message.chat.id, text: points_string)
        rating_scale = "#{terrible_mark}\n#{bad_mark}\n#{medium_mark}\n#{good_mark}\n#{unique_mark}"
        bot.api.send_message(chat_id: message.chat.id, text: rating_scale)
        points = 0
        poll = false
        first_question = true
        #message_flag = 0
        questions_counter = 0
      end

    #if message_flag == 0
    elsif message.class == Telegram::Bot::Types::Message and poll == false
      #wrong_command_cheking = true
      if message.text == "text"
        bot.api.edit_message_text(chat_id: message.chat.id, text: 'ddsfdsf', message_id: previously_message_id)
      end
      if message.text == "/menu"
        kb =
        [
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Історія України', callback_data: "ukraine_history")
          ],
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Футбол', callback_data: "football")
          ],
        ]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        #previously_kb = kb
        if previously_kb == kb
          puts("true")
        end
        previously_message_id = message.message_id
        previously_markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: previously_kb)
        bot.api.send_message(chat_id: message.chat.id, text: 'Опитування', reply_markup: markup)
        #message_flag += 1
      else
        #if wrong_command_cheking == true
        previously_message_id = message.message_id
        bot.api.send_message(chat_id: message.chat.id, text: 'Невірна команда!')
        #message_flag = 0
        #end
      end
    end

    if message.class == Telegram::Bot::Types::CallbackQuery
      puts(previously_markup)
      if message.data == "ukraine_history"
        kb =
        [
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Україна під час Другої світової війни', callback_data: "ukraine_ww2")
          ],
          [
            Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back")
          ]
        ]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
        bot.api.send_message(chat_id: message.from.id, text: 'Історія України', reply_markup: markup)
      elsif message.data == "back"
        bot.api.edit_message_text(chat_id: message.from.id, text: 'ddsfdsf', message_id: previously_message_id, reply_markup: previously_markup)
      end

      if test_hash[0].keys.include?(message.data) == true
        # See more: https://core.telegram.org/bots/api#replykeyboardmarkup
        start_question = test_hash[0][message.data][0]["question"]
        start_question_answers = test_hash[0][message.data][0]["answers"]
        questions_count = test_hash[0][message.data].size
        questions = test_hash[0][message.data][0..questions_count-2]
        terrible_mark = test_hash[0][message.data][questions_count-1]["terrible"]
        bad_mark = test_hash[0][message.data][questions_count-1]["bad"]
        medium_mark = test_hash[0][message.data][questions_count-1]["medium"]
        good_mark = test_hash[0][message.data][questions_count-1]["good"]
        unique_mark = test_hash[0][message.data][questions_count-1]["unique"]

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
        first_question = false
        poll = true
      end
    end

    if message.class == Telegram::Bot::Types::Message and first_question == false
      if message.text == "/stop"
        custom_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
        bot.api.send_message(chat_id: message.from.id, text: 'Sorry to see you go :(', reply_markup: custom_kb)
        poll = false
        first_question = true
        questions_counter = 0
      else
        questions_counter += 1
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
    end
  end
end
