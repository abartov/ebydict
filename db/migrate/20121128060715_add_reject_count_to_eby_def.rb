class AddRejectCountToEbyDef < ActiveRecord::Migration[4.2]
  def change
    add_column :eby_defs, :reject_count, :integer
    EbyDef.all.each {|d|
      if d.reject_count.nil?
        d.reject_count = 0
        d.save!
      end
    }
  end
end
