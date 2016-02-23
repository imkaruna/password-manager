class CreateUserAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :accountname
      t.string :accountpassword
    end
  end
end
