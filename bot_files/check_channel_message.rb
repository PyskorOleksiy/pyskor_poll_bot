def check_channel_message(bot, message)
  channel_username = "@" + message.chat.username
  users = BotUser.all
  users.each do |user|
    chat_member = bot.api.get_chat_member(chat_id: channel_username, user_id: user.telegram_id)
    user_status = chat_member['result']['status']
    if user_status != "left"
      user.htags.each do |hashtag|
        htag = hashtag.split("_")[0]
        genre = hashtag.split("_")[1]
        channel = Channel.find_by(channel_id: channel_username)
        if message.text.include?(htag) and channel.genre == genre
          bot.api.send_message(chat_id: user.telegram_id, text: message.text)
          if !Hashtag.exists?(name: htag, genre: genre)
            Hashtag.create(name: htag, genre: genre)
          end
        end
      end
    end
  end
end
