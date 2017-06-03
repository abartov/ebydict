class AddAnotherEbyDefIndex < ActiveRecord::Migration
  def change
    add_index :eby_defs, [:id, :assignedto]
  end
end
