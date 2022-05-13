class AddMessagesToChannels < ActiveRecord::Migration[6.1]
  def change
    add_column :channels, :messages, :text, array: true, default: []
  end
end
