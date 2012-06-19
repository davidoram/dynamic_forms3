require 'json'
require 'pp'
require 'erubis'

module DF3
  
    class SchemaCompiler
      
      def SchemaCompiler.render(style, schema_str, path = '')
        template = File.read("#{File.dirname(__FILE__)}/templates/#{style}.eruby")
        
        schema = JSON.parse(schema_str)
        
        erb = Erubis::EscapedEruby.new(template)
        erb.result(:fields => navigate_to(schema['fields'], path))
      end
    
      private
      
      def SchemaCompiler.navigate_to(schema, path)
        path.split('/').each do |path_el|
          schema = schema[path_el]
        end
        schema
      end
    
    end
end