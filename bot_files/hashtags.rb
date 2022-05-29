def hashtags(bot, message, previously_markup_genre_text)
  kb = []
  hashtags_size = 0
  interesting_htags = []
  user_status_counter = 0
  text = "\u{0023}Хештеги\n" +
         + "Тут ви можете вибрати тему, на яку вам будуть приходити повідомлення в бота з тих Telegram-каналів жанру #{previously_markup_genre_text}, на які ви підписані.\n\n" +
         + "Натиснувши на кнопку «Теми, які вас цікавлять», ви зможете переглянути, на які теми вам вже приходять повідомлення в бота і також відписатися від будь-якої теми, натиснувши на неї.\n\n" +
         + "Ви також можете ввести потрібний вам хештег прямо в бот, але це необхідно зробити за певними шаблонами:\n" +
         + " - #назвахештегу_Жанр_каналу\n" +
         + " - #назвахештегу_Жанр_Каналу"
  channels = Channel.where(genre: previously_markup_genre_text)
  channels.each do |channel|
    chat_member = bot.api.get_chat_member(chat_id: channel.channel_id, user_id: message.from.id)
    user_status = chat_member['result']['status']
    if user_status != "left"
      user_status_counter += 1
      kb.push(
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Теми, які вас цікавлять', callback_data: "#interesting")
        ]
      )

      user = BotUser.find_by(telegram_id: message.from.id)
      hashtags = Hashtag.where(genre: previously_markup_genre_text)
      hashtags_size = hashtags.size
      hashtags.each do |hashtag|
        if !user.htags.include?(hashtag.name + "_" + previously_markup_genre_text)
          kb.push(
            [
              Telegram::Bot::Types::InlineKeyboardButton.new(text: hashtag.name, callback_data: hashtag.name)
            ]
          )
        else
          interesting_htags.push(hashtag.name)
        end
      end

      break
    end
  end

  if hashtags_size == interesting_htags.size
    text += "\n\n\u{2705} Ви цікавитесь всіма темами жанру #{previously_markup_genre_text}!"
  elsif kb.size == 0 and user_status_counter == 0
    text += "\n\n\u{274C} Ви не підписані на жоден канал жанру #{previously_markup_genre_text}!\n\u{2757}Щоб мати доступ до хештегів цього жанру підпишіться на будь-який Telegram-канал цього жанру"
  end
  kb.push(
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back_to_chapters")
    ]
  )
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

  bot.api.edit_message_text(chat_id: message.from.id, text: text, message_id: message.message.message_id, reply_markup: markup)
  return markup
end

def add_hashtag_to_interesting(bot, message, previously_markup_genre_text)
  user = BotUser.find_by(telegram_id: message.from.id)
  hashtag = Hashtag.find_by(name: message.data, genre: previously_markup_genre_text)
  hashtag_name = hashtag.name + "_" + previously_markup_genre_text
  if !user.htags.include?(hashtag_name)
    user.htags.push(hashtag_name)
    user.save
  end

  kb =
  [
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back_to_hashtags")
    ]
  ]
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  text = "Чудово! Тепер ви зможете отримувати найсвіжіші повідомлення на тему #{message.data} від Telegram-каналів, на які ви підписані"
  bot.api.edit_message_text(chat_id: message.from.id, text: text, message_id: message.message.message_id, reply_markup: markup)
end

def interesting_hashtags(bot, message, previously_markup_genre_text)
  text = "Це теми, по яких ви зараз отримуєте повідомлення від Telegram-каналів жанру #{previously_markup_genre_text}, на які ви підписані.\n" +
         + "Якщо ви бажаєте припинити отримувати повідомлення на одну з даних тем, просто оберіть тему, після чого підтвердіть або скасуйте свій вибір."
  kb = []
  user = BotUser.find_by(telegram_id: message.from.id)
  user.htags.each do |htag|
    if htag.split("_")[1] == previously_markup_genre_text
      hashtag_name = htag.split("_")[0]
      kb.push(
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: hashtag_name, callback_data: "interesting"+hashtag_name)
        ]
      )
    end
  end

  if kb.size == 0
    text = "\n\n\u{274C} Ви не підписані на жодну тему жанру #{previously_markup_genre_text}!\n\u{2757}Ви можете це зробити вибравши ту тему, яка вас цікавить, в розділі Хештеги(#)."
  end
  kb.push(
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back_to_hashtags")
    ]
  )
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

  bot.api.edit_message_text(chat_id: message.from.id, text: text, message_id: message.message.message_id, reply_markup: markup)
end

def confirm_delete_hashtag(bot, message, previously_markup_genre_text)
  message_data = message.data.remove("interesting")
  kb =
  [
    Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Так', callback_data: message_data+"delete"),
    Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Ні', callback_data: "back_to_interesting_hashtags")
  ]
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  text = "\u{2757}\u{2757}\u{2757} Ви дійсно бажаєте припинити отримувати повідомлення на тему #{message.data.remove("interesting")}?"
  bot.api.edit_message_text(chat_id: message.from.id, text: text, message_id: message.message.message_id, reply_markup: markup)
end

def delete_hashtag(bot, message, previously_markup_genre_text)
  user = BotUser.find_by(telegram_id: message.from.id)
  hashtag_name = message.data.remove("delete")
  hashtag_name += "_" + previously_markup_genre_text
  if user.htags.include?(hashtag_name)
    user.htags.delete(hashtag_name)
    user.save
  end

  kb =
  [
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back_to_interesting_hashtags")
    ]
  ]
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  bot.api.edit_message_text(chat_id: message.from.id, text: "\u{1F5D1}Хештег успішно видалено з ваших уподобань!", message_id: message.message.message_id, reply_markup: markup)
end

def add_hashtag(bot, message)
  if BotUser.exists?(telegram_id: message.chat.id)
    user = BotUser.find_by(telegram_id: message.chat.id)
    htag = ""
    genre = ""
    hashtag = message.text.split("_")
    if hashtag.size <= 2
      htag = message.text
      genre = hashtag[1]
    else
      hashtag.each_with_index{ |word, index| if index >= 1 and index < hashtag.size-1
        genre += word + " "
      elsif index == hashtag.size-1
        genre += word
      end }
      htag = hashtag[0] + "_" + genre
    end
    if !user.htags.include?(htag)
      if Channel.exists?(genre: genre)
        subscribed = true
        channels = Channel.where(genre: genre)
        channels.each do |channel|
          chat_member = bot.api.get_chat_member(chat_id: channel.channel_id, user_id: message.from.id)
          user_status = chat_member['result']['status']
          if user_status != "left"
            user.htags.push(htag)
            user.save
            bot.api.send_message(chat_id: message.chat.id, text: "\u{2705} Готово! Хештег успішно додано в «Теми, які вас цікавлять» жанру «#{genre}»")
            #interesting_hashtags(bot, message, genre)
            subscribed = true
            break
          else
            subscribed = false
          end
        end
        if subscribed == false
          bot.api.send_message(chat_id: message.chat.id, text: "\u{26D4} Ви не підписані на жоден канал жанру «#{genre}»!")
        end
      else
        text = "\u{26D4} Бот не є адміністратором жодного Telegram-каналу жанру «#{genre}»! Тому він не може приймати жодне повідомлення від будь-якого такого Telegram-каналу." +
               + "\n Можливо, ви неправильно ввели назву жанру або ввели її правильно, але не за шаблоном:" +
               + " - #назвахештегу_Жанр_каналу\n" +
               + " - #назвахештегу_Жанр_Каналу"
        bot.api.send_message(chat_id: message.chat.id, text: text)
      end
    else
      bot.api.send_message(chat_id: message.chat.id, text: "\u{26A0} Цей хештег вже знаходиться в «Темах, які вас цікавлять» жанру «#{genre}»!")
    end
  end
end
