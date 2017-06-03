class AddIndexToEbyDefEvents < ActiveRecord::Migration
  def change
    add_index(:eby_def_events, [:thedef, :new_status])
  end
end
