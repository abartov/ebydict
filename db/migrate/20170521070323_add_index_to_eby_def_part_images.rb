class AddIndexToEbyDefPartImages < ActiveRecord::Migration[4.2]
  def change
    add_index(:eby_def_part_images, :thedef)
  end
end
