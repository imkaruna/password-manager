class RenameAccountColumns < ActiveRecord::Migration
  def change
    rename_column :accounts, :accountname, :account_name
    rename_column :accounts, :accountpassword, :account_password
    rename_column :accounts, :accountusername, :account_username
  end
end
