class CreateSpotifyUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :spotify_users do |t|
      t.text :auth_data
      t.string :mail

      t.timestamps
    end
    add_index :spotify_users, :mail
  end
end
