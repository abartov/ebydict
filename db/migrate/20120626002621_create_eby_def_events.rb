class CreateEbyDefEvents < ActiveRecord::Migration
  def change
    create_table :eby_def_events do |t|
      t.integer :who
      t.integer :thedef
      t.string :old_status
      t.string :new_status

      t.timestamps
    end
  end
end
