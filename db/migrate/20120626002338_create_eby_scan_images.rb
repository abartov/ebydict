class CreateEbyScanImages < ActiveRecord::Migration[4.2]
  def change
    create_table :eby_scan_images do |t|
      t.string :origjpeg
      t.string :smalljpeg
      t.integer :volume
      t.integer :firstpagenum
      t.integer :secondpagenum
      t.string :status
      t.integer :assignedto
      t.integer :partitioned_by

      t.timestamps
    end
  end
end
