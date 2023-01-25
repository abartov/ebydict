class AddIndexToEbyScanImage < ActiveRecord::Migration[6.1]
  def change
    add_index :eby_scan_images, :assignedto
  end
end
