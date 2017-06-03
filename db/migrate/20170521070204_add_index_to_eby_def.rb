class AddIndexToEbyDef < ActiveRecord::Migration
  def change
    add_index(:eby_defs, :assignedto)
  end
end
