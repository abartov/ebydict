class AddRejectCountToEbyDef < ActiveRecord::Migration
  def change
    add_column :eby_defs, :reject_count, :integer
  end
end
