class AddTitleAndIconUrlToStreams < ActiveRecord::Migration[7.1]
  def change
    add_column :streams, :title, :string
    add_column :streams, :icon_url, :string
  end
end
