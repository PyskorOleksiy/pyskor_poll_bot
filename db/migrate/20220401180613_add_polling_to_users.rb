class AddPollingToUsers < ActiveRecord::Migration[6.1]
  def change
    add_reference :users, :polling, null: false, foreign_key: true
  end
end
