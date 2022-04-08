# coding: utf-8
#require '/home/oleksiy/documents/pyskor_poll_bot/config/environment'
require 'dotenv'
token = Dotenv.load('bot_token.env')
require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require 'json'

require File.expand_path('../bot_files/fill_polling_table', __dir__)
require File.expand_path('../bot_files/menu', __dir__)
require File.expand_path('../bot_files/ukraine_history', __dir__)
require File.expand_path('../bot_files/results', __dir__)
require File.expand_path('../bot_files/confirm_poll_again', __dir__)
require File.expand_path('../bot_files/first_question', __dir__)
require File.expand_path('../bot_files/all_next_questions', __dir__)
require File.expand_path('../bot_files/checking_message', __dir__)
require File.expand_path('../bot_files/finish_polling', __dir__)
require File.expand_path('../bot_files/update_users_table', __dir__)
#require '../bot_files/fill_polling_table'
#require '../bot_files/menu.rb'
#require '../bot_files/ukraine_history.rb'
#require '../bot_files/results.rb'
#require '../bot_files/confirm_poll_again.rb'
#require '../bot_files/first_question.rb'
#require '../bot_files/all_next_questions.rb'
#require '../bot_files/checking_message.rb'
#require '../bot_files/finish_polling.rb'
#require '../bot_files/update_users_table.rb'

token = ENV['POLL_BOT_TOKEN']

questions_counter = 0
first_question = true
poll = false
points = 0
previously_jenres_markup = nil
previously_chapters_markup = nil
previously_kb = nil
previously_message_id = 0
polling_name = ""
polling_passed = false
passed_polling_id = 0
confirm_back = false
check_message = false

#test_file = File.open('../json/questions.json',"rb")
test_file = File.open(File.expand_path('../json/questions.json', __dir__),"rb")
test_hash = JSON.parse(test_file.read)
questions_count = 0
questions = []
terrible_mark = ""
bad_mark = ""
medium_mark = ""
good_mark = ""
unique_mark = ""
test_file.close

fill_polling_table()

loop do
  begin
    Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
      bot.logger.info('Bot has been started')
      bot.listen do |message|
        Thread.start(message) do |message|
          begin
            if message.class == Telegram::Bot::Types::Message and poll == true
              if message.text != "/stop"
                check_message, points = checking_message(bot, message, questions, check_message, points)
              end

              if questions_counter == questions_count-2 and message.text != "/stop"
                finish_polling(bot, message, test_hash, questions_count, polling_name, points)
                poll = false
                first_question = true
                questions_counter = 0
                #bot.api.send_photo(chat_id: message.chat.id, photo: Faraday::UploadIO.new('~/Desktop/jennifer.jpg', 'image/jpeg'))
                update_users_table(bot, message, polling_name, points)
                points = 0
              end

          elsif message.class == Telegram::Bot::Types::Message and poll == false
              if message.text == "/start"
                hello_message = "Привіт, #{message.from.first_name}!"
                bot.api.send_message(chat_id: message.chat.id, text: hello_message)
              elsif message.text == "/hellobot"
                bot.api.send_message(chat_id: message.chat.id, text: "\u{1F600}")
                bot.api.send_message(chat_id: message.chat.id, text: "\u{1F44B}")
              elsif message.text == "/menu"
                previously_jenres_markup = menu(bot, message)
              else
                bot.api.send_message(chat_id: message.chat.id, text: "\u{26D4} Невірна команда!")
              end
            end

            if message.class == Telegram::Bot::Types::CallbackQuery

              if message.data == "Історія України"
                ukraine_history(bot, message)

              elsif message.data == "sources"
                back_kb =
                [
                  Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back")
                ]
                back_markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: back_kb)
                bot.api.edit_message_text(chat_id: message.from.id, text: "Джерела інформації", message_id: message.message.message_id, reply_markup: back_markup)

              elsif message.data == "results"
                results(bot, message)

              elsif message.data == "back"
                bot.api.edit_message_text(chat_id: message.from.id, text: "Опитування", message_id: message.message.message_id, reply_markup: previously_jenres_markup)
                polling_passed = false
              end

              if test_hash[0].keys.include?(message.data) == true
                polling_name = message.data
                if polling_passed == true
                  user = User.find_by(polling_id: passed_polling_id)
                  user.destroy
                  polling_passed = false
                end

                if User.exists?(telegram_id: message.from.id)
                  polling_passed, passed_polling_id = confirm_poll_again(bot, message, polling_name, polling_passed, passed_polling_id)
                end

                if polling_passed == false
                  # See more: https://core.telegram.org/bots/api#replykeyboardmarkup
                  questions_count, questions = first_question(bot, message, test_hash, polling_name)
                  first_question = false
                  poll = true
                end
              end
            end

            if message.class == Telegram::Bot::Types::Message and first_question == false
              if message.text == "/stop"
                custom_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
                bot.api.send_message(chat_id: message.from.id, text: "Ви перервали опитування.\u{2757}Набрані бали анульовано", reply_markup: custom_kb)
                bot.api.send_message(chat_id: message.chat.id, text: 'Опитування', reply_markup: previously_jenres_markup)
                poll = false
                first_question = true
                questions_counter = 0
                points = 0
              else
                questions_counter += 1
                all_next_questions(bot, message, questions, questions_counter)
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
