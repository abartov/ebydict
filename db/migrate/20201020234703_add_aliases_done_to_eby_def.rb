class AddAliasesDoneToEbyDef < ActiveRecord::Migration[6.0]
  def change
    add_column :eby_defs, :aliases_done, :boolean
    add_index :eby_defs, :aliases_done
  end
end
