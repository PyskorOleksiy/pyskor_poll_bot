require 'open-uri'
require 'nokogiri'
require 'json'


url = 'https://test.izno.com.ua/ukrayina-pid-chas-drugoyi-svitovoyi-viyni-1939-1945-rr/'
html = open(url)
doc = Nokogiri::HTML(html)

script = ""
doc.css('.entry').each do |entry_item|
  script = entry_item.css('script').text.delete(' ').gsub(/\n/, '')
  puts JSON.pretty_generate(script)
end

puts(script.index('json'))
