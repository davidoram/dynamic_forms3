require_relative 'database_configuration'

class User < ActiveRecord::Base
  serialize :roles

  # Return the user if find a matching username & correct password otherwise return nil
  def User.authenticate(username, password)
    user = User.find_by_username(username)
    if user && user.password != password
      user = nil
    end
    user
  end
  
end