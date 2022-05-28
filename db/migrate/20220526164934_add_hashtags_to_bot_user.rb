class AddHashtagsToBotUser < ActiveRecord::Migration[6.1]
  def change
    add_column :bot_users, :hashtags, :text, array: true, default: []
  end
end
