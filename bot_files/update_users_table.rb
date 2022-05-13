def update_users_table(bot, message, polling_name, points)
  name = message.from.first_name + " " + message.from.last_name
  polling = nil
  if User.exists?(telegram_id: message.from.id)
    user = User.where(telegram_id: message.from.id)
    polling = Polling.find_by(name: polling_name)
    flag = false
    user.each do |us|
      if us.polling_id == polling.id
        puts("Update")
        poll_status = "update"
        us.update(name: name, telegram_id: message.from.id, points: points, poll_status: poll_status)
        flag = true
      end
    end
    if flag == false
      puts("Create")
      poll_status = "create"
      polling.users.create(name: name, telegram_id: message.from.id, points: points, polling_id: polling.id, poll_status: poll_status)
    end

  else
    if Polling.exists?(name: polling_name)
      puts("Polling exists")
      polling = Polling.find_by(name: polling_name)
      poll_status = "create"
      polling.users.create(name: name, telegram_id: message.from.id, points: points, polling_id: polling.id, poll_status: poll_status)
    else
      puts("Polling error")
    end
  end
end
