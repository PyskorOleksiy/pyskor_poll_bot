class RemoveTelegramIdFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :telegram_id, :integer
  end
end
