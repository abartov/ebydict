class FixSessionStore < ActiveRecord::Migration[4.2]
  def change
    change_column :sessions, :data, :text, :limit => 4.megabytes
  end
end
