class AddProblemDescToEbyDef < ActiveRecord::Migration
  def change
    add_column :eby_defs, :prob_desc, :string
  end
end
