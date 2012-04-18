require 'fileutils'
require 'json'
require 'uuidtools'

#---------------------------------------------------
#
# Interface with this class is ruby objects (Hashses, Arrays, and primitive values)
# All convesion to json done inside this class
#
class TestDatabase
  
  def initialize(base_dir)
    pp "initialize"
    @base_dir = base_dir
    if ! File.exist? base_dir
      pp "mkdir #{base_dir}"
      FileUtils.mkdir_p base_dir
    end
  end

  def get(df_id)
    pp "get #{df_id}"
    if !File.file?("#{@base_dir}/#{df_id}")
      raise "Missing '#{@base_dir}/#{df_id}'"
    end
    # Convert from JSON -> Ruby obj
    str = IO.readlines("#{@base_dir}/#{df_id}").join('')
    JSON.parse(str)    
  end
  
  def delete(df_id)
    pp "delete #{df_id}"
    doc = get(df_id)
    index = get_index(doc['df_type'])
    to_del = ["#{@base_dir}/#{df_id}", "#{index}/#{df_id}"]
    pp "deleteing files : #{to_del}"
    FileUtils.rm_f(to_del)
  end
  
  # Create or update document (Ruby object representation of JSON doc), returns df_id
  def create_or_update(document)
    pp "create_or_update"
    df_id = document['df_id']
    df_type = document['df_type']
    raise 'Error missing "df_type"' if df_type.nil?
    pp "df_type : #{df_type}"
    if df_id.nil? || df_id == ''
      df_id = create_id_and_update_index(df_type)
      document['df_id'] = df_id
    end
    File.open("#{@base_dir}/#{df_id}", 'w') do |file|
      file.puts JSON.pretty_generate(document)
    end
    df_id
  end

  def get_index(df_type)
    index = "#{@base_dir}/#{df_type}"
    if ! File.exist? index
      FileUtils.mkdir index
    end
    index
  end
  
  def create_id_and_update_index(df_type)
    df_id = UUIDTools::UUID.random_create
    pp "create_id_and_update_index #{df_type}/#{df_id}"
    FileUtils.touch get_index(df_type) + "/#{df_id}"
    df_id
  end
  
  def list(df_type)
    pp "list #{df_type}"
    list = []
    dir = Dir.new(get_index(df_type)) 
    pp "has #{list.length} length"
    dir.each do |file|
      list << file unless File.directory?(file)
    end
    list
  end

end