require 'telegram/bot'

test_file = File.open('questions.json',"rb")
test_hash = JSON.parse(test_file.read)
questions = test_hash.shuffle
questions.each do |item|
  item["answers"].each do |el|
    if el.class == Hash
      if el.keys[0] == "true"
        puts(el["true"])
      end
    end
  end
end


test_hash.each do |hash|
  hash.keys.each do |key|
    if message.data == key
      poll_index =
    end
  end
end
poll_index = test_hash.index(message.data)
puts(poll_index)
