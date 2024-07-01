class CreateDeveloperSettings < ActiveRecord::Migration[7.1]
  def self.up
    create_table :developer_settings do |t|
      t.string  :var,        null: false
      t.text    :value,      null: true
      t.timestamps
    end

    add_index :developer_settings, %i(var), unique: true
  end

  def self.down
    drop_table :developer_settings
  end
end
