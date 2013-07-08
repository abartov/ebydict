class AddOrdinalToEbyDef < ActiveRecord::Migration
  def change
    add_column :eby_defs, :ordinal, :integer
  end
end
