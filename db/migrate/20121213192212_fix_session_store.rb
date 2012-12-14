class FixSessionStore < ActiveRecord::Migration
  def change
    change_column :sessions, :data, :text, :limit => 4.megabytes
  end
end
