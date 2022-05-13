def fill_polling_table()
  polling_themes_file = File.open(File.expand_path('../json/polling_themes.json', __dir__), "rb")
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
end

def fill_telegram_channel_table()
  channels_themes_file = File.open(File.expand_path('../json/telegram_channels.json', __dir__), "rb")
  channels_themes = JSON.parse(channels_themes_file.read)
  channels_themes.each do |genre|
    genre.keys.each do |key|
      if !Channel.exists?(genre: key)
        genre[key].each do |channel|
          if !Channel.exists?(channel_id: channel["channel_id"])
            Channel.create(name: channel["name"], channel_id: channel["channel_id"], genre: key, info: channel["info"])
          else
            next
          end
        end
      else
        next
      end
    end
  end
  channels_themes_file.close
end
