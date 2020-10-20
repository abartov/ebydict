class AddSessionFieldsToEbyUser < ActiveRecord::Migration[4.2]
  def change
    add_column :eby_users, :google_token, :string
    add_column :eby_users, :google_refresh_token, :string
    add_column :eby_users, :provider, :string
    add_column :eby_users, :uid, :string
    add_column :eby_users, :oauth_token, :string
    add_column :eby_users, :oauth_expires_at, :datetime 
  end
end
