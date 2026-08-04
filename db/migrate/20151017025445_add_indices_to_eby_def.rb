class AddIndicesToEbyDef < ActiveRecord::Migration[4.2]
  def change
    add_index :eby_defs, :status
    add_index :eby_defs, :defhead
    add_index :eby_defs, :proof_round_passed
  end
end
