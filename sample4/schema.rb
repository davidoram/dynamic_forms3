require_relative 'database_configuration'

class Schema < ActiveRecord::Base
  has_and_belongs_to_many :forms
  has_many :documents
  serialize :df_fields
  validate :valid_fields?
  
private
  
  def valid_fields?
    begin
      JSON.parse(df_fields)
    rescue JSON::ParserError => ex
      pp ex
      errors.add(:df_fields, "Invalid JSON : #{ex.message}")
    end
  end
  
end

class Form < ActiveRecord::Base
  has_and_belongs_to_many :schemas
  serialize :df_sections
  validate :valid_sections?

private

  def valid_sections?
    begin
      JSON.parse(df_sections)
    rescue JSON::ParserError => ex
      errors.add(:df_sections, "Invalid JSON : #{ex.message}")
    end
  end

end

class Document < ActiveRecord::Base
  belongs_to :schema
  serialize :df_data
  validate :valid_data?

private

  def valid_data?
    begin
      JSON.parse(df_data)
    rescue JSON::ParserError => ex
      errors.add(:df_data, "Invalid JSON : #{ex.message}")
    end
  end

end