class AddIndexToEbyDefPartImages < ActiveRecord::Migration
  def change
    add_index(:eby_def_part_images, :thedef)
  end
end
