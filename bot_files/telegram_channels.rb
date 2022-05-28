def telegram_channels(bot, message)
  kb =
  [
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Канали, на які ви ПІДПИСАНІ', callback_data: "subscribed")
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Канали, на які ви НЕ ПІДПИСАНІ', callback_data: "didn't subscribed")
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Хештеги(#)', callback_data: "#hashtags")
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back_to_categories")
    ]
  ]

  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  bot.api.edit_message_text(chat_id: message.from.id, text: "Telegram-канали", message_id: message.message.message_id, reply_markup: markup)
  return markup
end

def put_in_channels_tables(bot, message, previously_markup_genre_text)
  name = message.from.first_name + " " + message.from.last_name
  if !UserChannel.exists?(telegram_id: message.from.id)
    channels = Channel.all
    channels.each do |channel|
      chat_member = bot.api.get_chat_member(chat_id: channel.channel_id, user_id: message.from.id)
      user_status = chat_member['result']['status']
      if user_status == 'creator' or user_status == 'member'
        channel.user_channels.create(name: name, telegram_id: message.from.id, channel_id: channel.channel_id, status: "subscribed")
      elsif user_status == 'left'
        channel.user_channels.create(name: name, telegram_id: message.from.id, channel_id: channel.channel_id, status: "didn't subscribed")
      end
    end
  else
    users = UserChannel.where(telegram_id: message.from.id)
    users.each do |user|
      channel = Channel.find_by(id: user.channel_id)
      chat_member = bot.api.get_chat_member(chat_id: channel.channel_id, user_id: message.from.id)
      user_status = chat_member['result']['status']
      if user_status == 'creator' or user_status == 'member'
        user.update(status: "subscribed")
        user.save
        #if user.status = "didn't subscribed"
          #user.status = "subscribed"
          #user.save
        #end
      elsif user_status == 'left'
        user.update(status: "didn't subscribed")
        user.save
        #if user.status = "subscribed"
          #user.status = "didn't subscribed"
          #user.save
        #end
      end
    end
  end

  channels = check_subscribed_channels(bot, message, previously_markup_genre_text)
  return channels
end

def check_subscribed_channels(bot, message, previously_markup_genre_text)
  channels = []
  kb = []
  markup = nil
  previously_markup_chapters_text = message.data
  users = UserChannel.where(telegram_id: message.from.id, status: message.data)
  users.each do |user|
    channel = Channel.find_by(id: user.channel_id, genre: previously_markup_genre_text)
    if channel.class == NilClass
      next
    end
    channels.push(channel)
  end

  if message.data == "subscribed"
    channels.each do |channel|
      url = "https://t.me/" + channel.channel_id.delete("@")
      kb.push(
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: channel.name, callback_data: channel.channel_id, url: url)
        ]
      )
    end

  elsif message.data == "didn't subscribed"
    channels.each do |channel|
      kb.push(
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: channel.name, callback_data: channel.channel_id)
        ]
      )
    end
  end

  kb.push(
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back_to_chapters")
    ]
  )
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  if previously_markup_chapters_text == "subscribed"
    previously_markup_chapters_text = "Канали, на які ви ПІДПИСАНІ"
  elsif previously_markup_chapters_text == "didn't subscribed"
    previously_markup_chapters_text = "Канали, на які ви НЕ ПІДПИСАНІ"
  end
  bot.api.edit_message_text(chat_id: message.from.id, text: previously_markup_chapters_text, message_id: message.message.message_id, reply_markup: markup)

  return channels
end

def channel_info(bot, message)
  channel = bot.api.get_chat(chat_id: message.data)
  url = "https://t.me/" + message.data.delete("@")
  kb =
  [
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: "ПІДПИСАТИСЯ", callback_data: message.data, url: url)
    ],
    [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Назад', callback_data: "back_to_didnot_subscribed")
    ]
  ]
  markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
  bot.api.edit_message_text(chat_id: message.from.id, text: channel["result"]["description"], message_id: message.message.message_id, reply_markup: markup)
end
