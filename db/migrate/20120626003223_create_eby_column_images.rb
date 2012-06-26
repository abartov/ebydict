class CreateEbyColumnImages < ActiveRecord::Migration
  def change
    create_table :eby_column_images do |t|
      t.integer :eby_scan_image_id
      t.integer :colnum
      t.string :coljpeg
      t.string :coldefjpeg
      t.string :colfootjpeg
      t.integer :volume
      t.integer :pagenum
      t.string :status
      t.integer :assignedto
      t.integer :partitioned_by
      t.string :smalljpeg
      t.integer :defpartitioner_id

      t.timestamps
    end
  end
end
