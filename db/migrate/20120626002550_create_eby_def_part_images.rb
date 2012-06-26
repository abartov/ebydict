class CreateEbyDefPartImages < ActiveRecord::Migration
  def change
    create_table :eby_def_part_images do |t|
      t.integer :thedef
      t.integer :partnum
      t.integer :coldefimg_id
      t.string :filename
      t.integer :defno
      t.boolean :is_last

      t.timestamps
    end
  end
end
