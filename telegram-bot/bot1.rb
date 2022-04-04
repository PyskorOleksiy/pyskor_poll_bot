require 'telegram/bot'

token = '5255604542:AAEVm5vBwtmiR2MiqeKLWenWJ_zSZetq_uo'

Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
  bot.logger.info('Bot has been started')
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::CallbackQuery
      # Here you can handle your callbacks from inline buttons
      if message.data == '1'
        bot.api.send_message(chat_id: message.from.id, text: "Don't touch me!")
      end
    when Telegram::Bot::Types::Message
      start_question = "Start question"
      custom_kb =
      [
        [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Text1', callback_data: "1"),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Text2', callback_data: "2"),
        ],
        [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Text3', callback_data: "3"),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Text4', callback_data: "4"),
        ],
      ]
      answers = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: custom_kb, one_time_keyboard: true)
      bot.api.send_message(chat_id: message.from.id, text: start_question, reply_markup: answers)
    end
  end
end

#
