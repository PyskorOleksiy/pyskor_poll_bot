def comands_and_check_hashtags(bot, message)
  previously_genres_markup = nil
  if message.text == "/start"
    if !BotUser.exists?(telegram_id: message.chat.id)
      name = message.from.first_name + " " + message.from.last_name
      BotUser.create(name: name, telegram_id: message.chat.id)
    end
    hello_message = "Привіт, #{message.from.first_name}!"
    bot.api.send_message(chat_id: message.chat.id, text: hello_message)

  elsif message.text == "/hellobot"
    bot.api.send_message(chat_id: message.chat.id, text: "\u{1F600}")
    bot.api.send_message(chat_id: message.chat.id, text: "\u{1F44B}")

  elsif message.text == "/menu"
    previously_genres_markup = menu(bot, message)

  elsif message.text =~ /^#[a-zа-яьюяїієґ]+.*$/
    if message.text =~ /^#[a-zа-яьюяїієґ]+_[_[A-ZА-ЯЯЩЬЮЯЇІЄҐ][a-zа-яьюяїієґ]]+$/
      add_hashtag(bot, message)
    else
      text = "\u{26D4}Ви неправильно ввели хештег для даного бота! Якщо ви намагались саме це зробити, то ось шаблони, для коректного виконання даної дії:\n" +
           + " - #назвахештегу_Жанр_каналу\n" +
           + " - #назвахештегу_Жанр_Каналу"
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end
  else
    bot.api.send_message(chat_id: message.chat.id, text: "\u{26D4} Невірна команда!")
  end

  return previously_genres_markup
end
