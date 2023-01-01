class AddFootMarkersToEbyMarker < ActiveRecord::Migration[6.1]
  def change
    add_column :eby_markers, :footpart, :integer
    add_column :eby_markers, :footmarker, :integer
  end
end
