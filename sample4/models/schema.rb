require_relative 'database_configuration'

class Schema < ActiveRecord::Base
  has_many :documents
  serialize :df_fields
  
  def form_for(user)
    # todo - get form for teh users role
    forms[0]
  end
  
end
