class AddColumnAccountusernameToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :accountusername, :string
  end
end
