class AddLoginTimesToEbyUser < ActiveRecord::Migration
  def change
    add_column :eby_users, :last_login, :datetime
    add_column :eby_users, :login_count, :integer
  end
end
