class RemoveHashtagsFromBotUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :bot_users, :hashtags, :text
  end
end
