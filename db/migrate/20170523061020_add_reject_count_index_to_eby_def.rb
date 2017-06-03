class AddRejectCountIndexToEbyDef < ActiveRecord::Migration
  def change
    add_index :eby_defs, [:reject_count, :proof_round_passed]
  end
end
