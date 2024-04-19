class IncreaseProbDescSize < ActiveRecord::Migration[6.1]
  def change
    change_column :eby_defs, :prob_desc, :string, :limit => 4000 
  end
end
