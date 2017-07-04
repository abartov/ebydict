class IncreaseDefTextSize < ActiveRecord::Migration
  def up
    change_column :eby_defs, :deftext, :text, :limit => 16777210 # near mediumtext limit, more than enough for any def.
  end

  def down
    change_column :eby_defs, :deftext, :text, :limit => 65535 # default
  end
end
