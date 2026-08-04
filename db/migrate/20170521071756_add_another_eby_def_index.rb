class AddAnotherEbyDefIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :eby_defs, [:id, :assignedto]
  end
end
