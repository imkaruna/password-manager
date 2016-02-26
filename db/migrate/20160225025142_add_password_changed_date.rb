class AddPasswordChangedDate < ActiveRecord::Migration
  def change
    add_column :accounts, :password_changed_date, :date
  end
end
