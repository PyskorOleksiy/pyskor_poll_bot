# coding: utf-8
#require '/home/oleksiy/documents/pyskor_poll_bot/config/environment'
require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require 'json'

token = '5255604542:AAEVm5vBwtmiR2MiqeKLWenWJ_zSZetq_uo'

#message_flag = 0
questions_counter = 0
first_question = true
poll = false
points = 0
previously_jenres_markup = nil
previously_chapters_markup = nil
previously_kb = nil
previously_message_id = 0
polling_name = ""
passed_polling_id = 0
polling_passed = false
confirm_back = false
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

polling_themes_file = File.open('polling_themes.json',"rb")
polling_themes = JSON.parse(polling_themes_file.read)
polling_themes.each do |polling|
  polling.keys.each do |key|
    polling[key].each do |el|
      if !Polling.exists?(name: el)
        Polling.create(name: el, topic: key)
      else
        next
      end
    end
  end
end
polling_themes_file.close

loop do
  begin
    Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
      bot.logger.info('Bot has been started')
      bot.listen do |message|
        Thread.start(message) do |message|
          begin
            #command = bot.get_my_commands()
            #puts(command)
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
                bot.api.send_message(chat_id: message.from.id, text: 'Опитування завершено. Ви можете його пройти знову, але попередньо набрані бали анулюються', reply_markup: custom_kb)
                points_string = "Ваш результат: " + points.to_s
                bot.api.send_message(chat_id: message.chat.id, text: points_string)
                rating_scale = "#{terrible_mark}\n#{bad_mark}\n#{medium_mark}\n#{good_mark}\n#{unique_mark}"
                bot.api.send_message(chat_id: message.chat.id, text: rating_scale)
                polling = nil
                if User.exists?(telegram_id: message.from.id)
                  user = User.where(telegram_id: message.from.id)
                  polling = Polling.find_by(name: polling_name)
                  flag = false
                  user.each do |us|
                    if us.polling_id == polling.id
                      puts("Update")
                      us.update(name: message.from.first_name, telegram_id: message.from.id, points: points)
                      flag = true
                    end
                  end
                  if flag == false
                    puts("Create")
                    poll_status = "passed"
                    polling.users.create(name: message.from.first_name, telegram_id: message.from.id, points: points, polling_id: polling.id, poll_status: poll_status)
                  end
                  #puts("User exists")
                  #user = User.find_by(telegram_id: message.from.id)
                  #if user.poll_status == "passed"
                  #if Polling.exists?(name: polling_name)
                    #polling = Polling.find_by(name: polling_name)
                    #puts(polling_name)
                    #puts(user.polling_id)
                    #puts(polling.id)
                    #flag = false
                    #polling.users.each do |us|
                      #if us.polling_id == polling.id and user.telegram_id == message.from.id
                        #polling.users.update(name: message.from.first_name, telegram_id: message.from.id, points: points)
                        #user.save
                        #polling.save
                        #flag = true
                      #end
                    #end
                    #if flag == false
                      #poll_status = "passed"
                      #polling.users.create(name: message.from.first_name, telegram_id: message.from.id, points: points, polling_id: polling.id, poll_status: poll_status)
                      #polling.save
                    #end
                  #end
                else
                  if Polling.exists?(name: polling_name)
                    puts("Polling exists")
                    polling = Polling.find_by(name: polling_name)
                    poll_status = "passed"
                    polling.users.create(name: message.from.first_name, telegram_id: message.from.id, points: points, polling_id: polling.id, poll_status: poll_status)
                  else
                    puts("Polling error")
                  end
                end
                points = 0
                poll = false
                first_question = true
                #message_flag = 0
                questions_counter = 0
              end

            #if message_flag == 0
          elsif message.class == Telegram::Bot::Types::Message and poll == false
              #wrong_command_cheking = true
              if message.text == "/start"
                hello_message = "Привіт, #{message.from.first_name}!"
                bot.api.send_message(chat_id: message.chat.id, text: hello_message)
              elsif message.text == "/hellobot"
                bot.api.send_message(chat_id: message.chat.id, text: "\u{1F600}")
                bot.api.send_message(chat_id: message.chat.id, text: "\u{1F44B}")
              elsif message.text == "/menu"
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
                #previously_kb = kb
                previously_jenres_markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
                bot.api.send_message(chat_id: message.chat.id, text: 'Опитування', reply_markup: markup)
                #message_flag += 1
              else
                bot.api.send_message(chat_id: message.chat.id, text: 'Невірна команда!')
              end
            end

            if message.class == Telegram::Bot::Types::CallbackQuery
              #puts(back_to_genre)
              if message.data == "Історія України"
                kb =
                [
                  [
                    Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Україна під час Другої світової війни', callback_data: "Україна в Другій світовій війні")
                  ],
                  [
                    Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back")
                  ]
                ]
                markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
                bot.api.edit_message_text(chat_id: message.from.id, text: "Історія України", message_id: message.message.message_id, reply_markup: markup)
                #if back_to_genre == false
                  #bot.api.send_message(chat_id: message.from.id, text: 'Історія України', reply_markup: markup)
                  #bot.api.edit_message_text(chat_id: message.from.id, text: "Історія України", message_id: message.message.message_id, reply_markup: previously_chapters_markup)
                #elsif back_to_genre == true
                  #bot.api.edit_message_text(chat_id: message.from.id, text: "Історія України", message_id: message.message.message_id, reply_markup: previously_chapters_markup)
                  #back_to_genre = false
                #end

              elsif message.data == "results"
                kb =
                [
                  [
                    Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back")
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
                  #users = User.all
                  #pollings = Polling.all
                  #pollings.each do |poll|
                    #users.each do |us|
                      #if us.polling_id == poll.id and us.telegram_id == message.from.id
                        #results += "#{poll.topic}: #{poll.name} - #{us.points} б.\n"
                      #end
                    #end
                  #end
                  results_string = "Ваші результати пройдених опитувань:\n" + results
                  bot.api.edit_message_text(chat_id: message.from.id, text: results_string, message_id: message.message.message_id, reply_markup: markup)
                else
                  bot.api.edit_message_text(chat_id: message.from.id, text: "Ви ще не пройшли жодного опитування!", message_id: message.message.message_id, reply_markup: markup)
                end

              elsif message.data == "back"
                bot.api.edit_message_text(chat_id: message.from.id, text: "Опитування", message_id: message.message.message_id, reply_markup: previously_jenres_markup)
                polling_passed = false
                #back_to_genre = true
              end

              if test_hash[0].keys.include?(message.data) == true
                polling_name = message.data
                if polling_passed == true
                  user = User.find_by(polling_id: passed_polling_id)
                  user.destroy
                  polling_passed = false
                end
                if User.exists?(telegram_id: message.from.id)
                  user = User.where(telegram_id: message.from.id)
                  polling = Polling.find_by(name: polling_name)
                  user.each do |us|
                    if us.polling_id == polling.id
                      polling_passed = true
                      passed_polling_id = us.polling_id
                      confirm_kb =
                      [
                        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Так', callback_data: polling_name),
                        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Ні', callback_data: "back")
                      ]
                      confirm_markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: confirm_kb)
                      bot.api.edit_message_text(chat_id: message.from.id, text: "Ви вже проходили дане опитування! Хочете пройти ще раз? Попередньо набрані бали будуть анульовані одразу після початку опитування", message_id: message.message.message_id, reply_markup: confirm_markup)
                    end
                  end
                end
                if polling_passed == false
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
            end

            if message.class == Telegram::Bot::Types::Message and first_question == false
              if message.text == "/stop"
                custom_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
                bot.api.send_message(chat_id: message.from.id, text: 'Ви перервали опитування. Набрані бали анульовано', reply_markup: custom_kb)
                bot.api.send_message(chat_id: message.chat.id, text: 'Опитування', reply_markup: previously_jenres_markup)
                poll = false
                first_question = true
                questions_counter = 0
                points = 0
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
          #rescue
            #bot.logger.info('Error!!!')
          end
        end
      end
      bot.logger.info('Bot has been finished')
    end
  rescue
    puts("Loop do error")
  end
end
