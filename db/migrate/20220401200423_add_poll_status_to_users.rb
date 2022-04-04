class AddPollStatusToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :poll_status, :string
  end
end
