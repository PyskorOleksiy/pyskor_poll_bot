class CreateChannels < ActiveRecord::Migration[6.1]
  def change
    create_table :channels do |t|
      t.string :name
      t.string :channel_id
      t.string :genre

      t.timestamps
    end
  end
end
