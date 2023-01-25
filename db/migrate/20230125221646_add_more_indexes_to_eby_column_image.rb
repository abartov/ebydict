class AddMoreIndexesToEbyColumnImage < ActiveRecord::Migration[6.1]
  def change
    add_index :eby_column_images, [:status, :assignedto]
  end
end
