class AddPasswordExpiryColumn < ActiveRecord::Migration
  def change
    add_column :accounts, :password_expiry, :integer
  end
end
