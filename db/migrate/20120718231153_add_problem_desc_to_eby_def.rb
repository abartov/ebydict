class AddProblemDescToEbyDef < ActiveRecord::Migration[4.2]
  def change
    add_column :eby_defs, :prob_desc, :string
  end
end
