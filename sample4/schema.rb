require_relative 'database_configuration'

class Schema < ActiveRecord::Base
  has_and_belongs_to_many :forms
  has_many :documents
  serialize :df_fields
  
  def has_default_form?
    ! forms.empty?
  end
  
  def default_form
    forms[0]
  end
  
end

class Form < ActiveRecord::Base
  has_and_belongs_to_many :schemas
  serialize :df_sections

  # Find the appropriate section for a given data path
  def section_for_path(path)
    pp "section_for_path #{path}"
    pp df_sections
    df_sections.each do |section|
      return section if section.path == path
    end
    nil
  end

  # Associate with a schema
  def can_use_for(schema)
    schemas << schema
  end
  
end

class Document < ActiveRecord::Base
  belongs_to :schema
  serialize :df_data

end