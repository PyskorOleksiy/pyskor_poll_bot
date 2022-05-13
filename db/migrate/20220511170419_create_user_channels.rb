class CreateUserChannels < ActiveRecord::Migration[6.1]
  def change
    create_table :user_channels do |t|
      t.string :name
      t.bigint :telegram_id
      t.references :channel, null: false, foreign_key: true
      t.string :status

      t.timestamps
    end
  end
end
