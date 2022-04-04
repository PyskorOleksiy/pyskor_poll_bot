class CreatePollings < ActiveRecord::Migration[6.1]
  def change
    create_table :pollings do |t|
      t.string :name

      t.timestamps
    end
  end
end
