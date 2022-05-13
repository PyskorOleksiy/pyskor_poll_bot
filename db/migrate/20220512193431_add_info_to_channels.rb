class AddInfoToChannels < ActiveRecord::Migration[6.1]
  def change
    add_column :channels, :info, :text
  end
end
