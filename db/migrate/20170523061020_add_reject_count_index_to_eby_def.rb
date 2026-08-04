class AddRejectCountIndexToEbyDef < ActiveRecord::Migration[4.2]
  def change
    add_index :eby_defs, [:reject_count, :proof_round_passed]
  end
end
