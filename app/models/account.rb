require 'date'
class Account < ActiveRecord::Base
  belongs_to :user
  def password_expires
    todays_date = DateTime.now
    binding.pry
    expiry_date = self.password_changed_date
    return (expiry_date - todays_date).to_i
  end
end
