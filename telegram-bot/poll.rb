# coding: utf-8
#require '/home/oleksiy/documents/pyskor_poll_bot/config/environment'
require 'dotenv'
#token = Dotenv.load('bot_token.env')
token = Dotenv.load(File.expand_path('../telegram-bot/bot_token.env', __dir__))
require File.expand_path('../config/environment', __dir__)
require 'telegram/bot'
require 'json'

require File.expand_path('../bot_files/fill_tables', __dir__)
require File.expand_path('../bot_files/menu', __dir__)
require File.expand_path('../bot_files/stop', __dir__)
require File.expand_path('../bot_files/results', __dir__)
require File.expand_path('../bot_files/confirm_poll_again', __dir__)
require File.expand_path('../bot_files/first_question', __dir__)
require File.expand_path('../bot_files/all_next_questions', __dir__)
require File.expand_path('../bot_files/checking_message', __dir__)
require File.expand_path('../bot_files/finish_polling', __dir__)
require File.expand_path('../bot_files/update_users_table', __dir__)
require File.expand_path('../bot_files/telegram_channels', __dir__)
require File.expand_path('../bot_files/hashtags', __dir__)
require File.expand_path('../bot_files/check_channel_message', __dir__)
require File.expand_path('../bot_files/comands_and_check_hashtags', __dir__)

token = ENV['POLL_BOT_TOKEN']

questions_counter = 0
first_question = true
poll = false
points = 0
previously_genres_markup = nil
previously_categories_markup = nil
previously_chapters_markup = nil
prev_didnot_subscribed_markup = nil
previously_hashtags_markup = nil
prev_interesting_htags_markup = nil
previously_markup_genre_text = ""
previously_markup_category_text = ""
previously_markup_chapter_text = ""
previously_kb = nil
previously_message_id = 0
polling_name = ""
polling_passed = false
passed_polling_id = 0
confirm_back = false
check_message = false
genres_array = ["Історія України", "Футбол"]

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
fill_telegram_channel_table()
fill_hashtags_table()
#puts(ENV['RAILS_ENV'])
loop do
  begin
    Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
      bot.logger.info('Bot has been started')
      #delete_kb = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
      #bot.api.send_message(reply_markup: delete_kb)
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

              if message.chat.id.to_s[0] != '-'
                previously_genres_markup = comands_and_check_hashtags(bot, message)

              else
                check_channel_message(bot, message)
              end
            end

            if message.class == Telegram::Bot::Types::CallbackQuery

              if genres_array.include?(message.data)
                previously_categories_markup = genres(bot, message)
                previously_markup_genre_text = message.data
              end

              if message.data == "Telegram-канали"
                previously_chapters_markup = telegram_channels(bot, message)
                previously_markup_category_text = message.data

              elsif message.data == "results"
                results(bot, message)
              end

              if message.data.include?("subscribed")
                put_in_channels_tables(bot, message, previously_markup_genre_text)

              elsif message.data.include?("#")
                if message.data == "#hashtags"
                  previously_hashtags_markup = hashtags(bot, message, previously_markup_genre_text)
                elsif message.data == "#interesting"
                  interesting_hashtags(bot, message, previously_markup_genre_text)
                else
                  if message.data.split("#")[0] == "" and !message.data.include?("delete")
                    add_hashtag_to_interesting(bot, message, previously_markup_genre_text)
                  elsif message.data.split("#")[0] == "interesting"
                    confirm_delete_hashtag(bot, message, previously_markup_genre_text)
                  elsif message.data.include?("delete")
                    delete_hashtag(bot, message, previously_markup_genre_text)
                  end
                end
              end

              if message.data[0] == '@'
                channel_info(bot, message)
              end

              md_split = message.data.split('_')
              if md_split[0] == "back"
                back_callbacks(bot, message, previously_genres_markup, previously_categories_markup, previously_chapters_markup, previously_markup_genre_text, previously_markup_category_text)
                polling_passed = false
              end

              if test_hash[0].keys.include?(md_split[0]) == true
                polling_name = md_split[0]
                #if polling_passed == true
                  #user = User.find_by(polling_id: passed_polling_id)
                  #user.destroy
                  #polling_passed = false
                #end

                if User.exists?(telegram_id: message.from.id) and md_split[1] != "restart"
                  polling_passed, passed_polling_id = confirm_poll_again(bot, message, polling_name, polling_passed, passed_polling_id)
                end

                if md_split[1] == "restart"
                  questions_count, questions = first_question(bot, message, test_hash, polling_name)
                  first_question = false
                  poll = true
                end

                #if polling_passed == false
                if polling_passed == false
                    questions_count, questions = first_question(bot, message, test_hash, polling_name)
                    first_question = false
                    poll = true
                  # See more: https://core.telegram.org/bots/api#replykeyboardmarkup
                end
              end
            end

            if message.class == Telegram::Bot::Types::Message and first_question == false
              if message.text == "/stop"
                poll, first_question, questions_counter, points = stop(bot, message, polling_name, previously_genres_markup)
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
