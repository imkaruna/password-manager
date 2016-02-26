require 'date'
class Account < ActiveRecord::Base
  belongs_to :user
  def password_expires
    todays_date = DateTime.now
    #binding.pry
    expiry_date = self.password_changed_date
    num_of_days_to_expiry = self.password_expiry
    return num_of_days_to_expiry - (todays_date - expiry_date).to_i
  end
end
