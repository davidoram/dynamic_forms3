require_relative 'database_configuration'

class Schema < ActiveRecord::Base
  has_and_belongs_to_many :forms
  has_many :documents
  serialize :df_fields
  validate :valid_fields?
  
private
  
  def valid_fields?
    begin
      if df_fields.empty?
        errors.add(:df_fields, "Invalid JSON : Empty string not allowed")
      else
        JSON.parse(df_fields)
      end
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

  def can_use_for(schema)
    schemas << schema
  end
  
private

  def valid_sections?
    begin
      if df_sections.empty?
        errors.add(:df_sections, "Invalid JSON : Empty string not allowed")
      else
        JSON.parse(df_sections)
      end
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
      if df_data.nil? or df_data.empty?
        errors.add(:df_data, "Invalid JSON : Empty string not allowed")
      else
        JSON.parse(df_data)
      end
    rescue JSON::ParserError => ex
      errors.add(:df_data, "Invalid JSON : #{ex.message}")
    end
  end

end