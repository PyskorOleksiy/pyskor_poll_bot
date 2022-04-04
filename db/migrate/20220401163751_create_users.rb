class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :telegram_id
      t.string :poll_title
      t.integer :points

      t.timestamps
    end
  end
end
