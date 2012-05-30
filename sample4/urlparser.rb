class String  
  def is_integer?    
    true if Integer(self) rescue false  
  end 
  
  def is_json?
    true if JSON.parse(self) rescue false
  end
  
  def to_json
    JSON.parse(self)
  end
  
end


#---------------------------------------------------
#
# Class to parse URLs
#
class UrlParser
  
  # Types
  PRIMITIVE = 1
  ARRAY_ELEMENT = 2

  def UrlParser.parseUrl(url)
    entity = url.split('/')[1]
    return parseDocumentUrl(url) if entity == 'documents'
    raise "Unknown url '#{url}"
  end

  # Parse the Document URL path, so we turn from '/documents/16/employees/5/children/section/section-1'
  # into:
  # { 
  #   :id => 16,
  #   :path => [ 
  #     {
  #       :name => 'employees', 
  #       :index => 5,
  #       :type => UrlParser::ARRAY_ELEMENT,
  #     },
  #     {
  #       :name => 'children', 
  #       :type => UrlParser::PRIMITIVE
  #     },`
  #   :data_path = ['employees', '$employee_index', 'children'],
  #   :section_path = ['section-1']
  #   ],
  #   :url => '/documents/16/employees/5/children/section/section-1'
  #   :data_url => '/documents/16/employees/5/children'
  #   :section_url => 'section/section-1'
  # } 
  def UrlParser.parseDocumentUrl(url)
    root = 'documents'
    raise "Not a document url '#{url}'" unless url.split('/')[1] == root  
    # Path starts after '/documents'
    path = url.split('/').compact.slice(2..-1)
    raise "Error at #{path[idx]}, document id not an identifier" unless path[0].is_integer? 
    idx = 1
    path_array = []
    data_path = []
    section_array = []
    
    section_idx = path.index('section')
    section_url = ''
    data_url = url
    if section_idx
      data_url = path[0..(section_idx - 1)].join('/')
      data_url = "#{root}/data_url"
      section_array = path[section_idx + 1..-1]
      section_url = path[section_idx..-1].join('/')
    end
    
    while idx < path.length && path[idx] != 'section'
      element = {} 
      element[:type] = UrlParser::PRIMITIVE
      raise "Error at #{path[idx]}, expected a path identifier not a number" if path[idx].is_integer? 
      element[:name] = path[idx]
      idx = idx + 1
      if idx < path.length
        raise "Error at #{path[idx]}, expected a path index not an identifier" unless path[idx].is_integer? 
        element[:index] = Integer(path[idx])
        element[:type] = UrlParser::ARRAY_ELEMENT
        idx = idx + 1
      end
      path_array << element
      data_path << element[:name]
      data_path << "$#{element[:name]}" if element.has_key?(:index)
    end
    
    return {
      :id           => Integer(path[0]),
      :path         => path_array,
      :data_path    => data_path,
      :section_path => section_array,
      :url          => url,
      :data_url     => data_url,
      :section_url  => section_url,
    }
  end
  
end