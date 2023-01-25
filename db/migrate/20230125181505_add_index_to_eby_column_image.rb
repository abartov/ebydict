class AddIndexToEbyColumnImage < ActiveRecord::Migration[6.1]
  def change
    add_index :eby_column_images, [:eby_scan_image_id, :colnum]
  end
end
