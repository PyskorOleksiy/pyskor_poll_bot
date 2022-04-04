require 'telegram/bot'
require 'rss'
require 'sdbm'
require 'json'
require 'logger'

logger = Logger.new(STDOUT)

token = '5255604542:AAEVm5vBwtmiR2MiqeKLWenWJ_zSZetq_uo'

rss = RSS::Parser.parse('https://doam.ru/feed.xml', false)

SDBM.open 'doam_posts.db' do |posts|
  rss.items.each do |item|
    key       = item.link.href
    title     = item.title.content
    published = item.published.content
    # next if posts[key]
    if posts.has_key?(key)
      logger.info "Post exist in DB will not rewrite"
    else
      posts[key] = JSON.dump(
        title: title,
        published: published,
        sended: 0
      )
    end
  end

  hash = {}
  posts.each do |k,v|
    hash[k] = JSON.parse(v)
    if hash[k]["sended"] == 0
      text = "Новая запись в блоге: #{hash[k]["title"]} - #{k}"
      Telegram::Bot::Client.run(token) do |bot|
        if bot.api.sendMessage(chat_id: "@doam_ru", text: text)
          posts[k] = JSON.dump(
            title: hash[k]["title"],
            published: hash[k]["published"],
            sended: 1
          )
          logger.info "Successfuly send #{hash[k]} to telegram!"
        else
          logger.error "Can not send #{hash[k]} to telegram!"
        end
      end
    end
  end
end
