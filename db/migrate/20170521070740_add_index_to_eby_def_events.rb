class AddIndexToEbyDefEvents < ActiveRecord::Migration[4.2]
  def change
    add_index(:eby_def_events, [:thedef, :new_status])
  end
end
