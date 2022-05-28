class AddHtagsToBotUser < ActiveRecord::Migration[6.1]
  def change
    add_column :bot_users, :htags, :text, array: true, default: []
  end
end
