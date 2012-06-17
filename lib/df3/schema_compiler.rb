require 'json'
require 'json-schema'
require 'pp'
require_relative 'renderer'

module DF3
  
    class SchemaCompiler
      
      # Styles
      UNIT_TEST = 'UnitTest'
      
      # Field types
      FIELD_TYPES = {
        "string"  => { :is_primitive => true },
        "integer"  => { :is_primitive => true },
        "array"  => { :is_primitive => false },
      }
    
      def initialize(style)
        @renderer = eval("DF3::Render#{style}.new")
      end
    
      # Compile json schema, returning an hash 
      # containing 'identifier' => 'HTML template'
      # where identifier is {schema_id}-[{data_path}]
      # and HTML template is a template that can be interpreted using the
      # appropriate templating engine chosen
      def compile(schema_str, h = {})
        schema = JSON.parse(schema_str)
        h[schema['id']] = compile_at_path(schema['fields'], '/', h)
      end
      
      private
       
      def compile_at_path(fields, path, h)
        body = {}
        fields.each do |field|
          body[field['id']] = render_field(field)
        end
        body    
      end
      
      def render_field(field)
        if is_primitive? field
          @renderer.primitive field
        elsif is_array? field
          @renderer.array field
        else
          raise "Unknown field type: #{field.type}"
        end
      end

      def is_primitive?(field)
        FIELD_TYPES[field['type']][:is_primitive]
      end
      
      def is_array?(field)
        field['type'] == 'array'
      end
      
    end
end