class AddFillModeToArtworks < ActiveRecord::Migration[7.1]
  def change
    add_column :artworks, :fill_mode, :integer
  end
end
