class AddOrdinalToEbyDef < ActiveRecord::Migration[4.2]
  def change
    add_column :eby_defs, :ordinal, :integer
  end
end
