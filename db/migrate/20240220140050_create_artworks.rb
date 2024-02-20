class CreateArtworks < ActiveRecord::Migration[7.1]
  def change
    create_table :artworks do |t|
      t.integer :duration

      t.timestamps
    end
  end
end
