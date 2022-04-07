def checking_message(bot, message, questions, check_message, points)
  if message.text != "/stop"
    check_message = false
  end
  questions.each do |item|
    item["answers"].each do |el|
      if el.class == Hash
        if message.text == el["true"]
          bot.api.send_message(chat_id: message.chat.id, text: "\u{2705}\u{1F389}Вірно!\u{1F387}Геніально!\u{1F37E}Неперевершено!\u{1F44F}Бравіссімо! \u{1F60E}\u{26A0}Тільки не зазнавайтесь!")
          points += 1
          check_message = true
        end
      end
    end
  end
  if check_message == false
    bot.api.send_message(chat_id: message.chat.id, text: "\u{2757}Невірно! Але ви тримайтесь там\u{270A}")
  end

  return check_message, points
end
