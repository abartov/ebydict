class CreateEbyMarkers < ActiveRecord::Migration
  def change
    create_table :eby_markers do |t|
      t.integer :user_id
      t.integer :def_id
      t.integer :partnum
      t.integer :marker_y

      t.timestamps
    end
  end
end
