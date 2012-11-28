class AddRejectCountToEbyDef < ActiveRecord::Migration
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
