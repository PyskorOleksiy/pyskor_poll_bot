class AddTopicToPollings < ActiveRecord::Migration[6.1]
  def change
    add_column :pollings, :topic, :string
  end
end
