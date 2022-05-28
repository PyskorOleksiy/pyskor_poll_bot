class CreateBotUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :bot_users do |t|
      t.string :name
      t.bigint :telegram_id

      t.timestamps
    end
  end
end
