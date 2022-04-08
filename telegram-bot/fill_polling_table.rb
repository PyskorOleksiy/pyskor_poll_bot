def fill_polling_table()
  polling_themes_file = File.open('../json/polling_themes.json',"rb")
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
