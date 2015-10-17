class AddIndicesToEbyDef < ActiveRecord::Migration
  def change
    add_index :eby_defs, :status
    add_index :eby_defs, :defhead
    add_index :eby_defs, :proof_round_passed
  end
end
