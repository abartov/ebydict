class AddIndexToEbyDef < ActiveRecord::Migration[4.2]
  def change
    add_index(:eby_defs, :assignedto)
  end
end
