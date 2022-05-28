class CreateHashtags < ActiveRecord::Migration[6.1]
  def change
    create_table :hashtags do |t|
      t.string :name
      t.string :genre

      t.timestamps
    end
  end
end
