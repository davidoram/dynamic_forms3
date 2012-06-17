require 'test/unit'
require_relative 'schema_compiler'

class TestSchemaCompiler < Test::Unit::TestCase 
  def test_context_create
    compiler = DF3::SchemaCompiler.new(DF3::SchemaCompiler::UNIT_TEST)
    schema =<<JSON 
    {
      "id": 123,
      "fields": [ 
         	{ 
         	  "id":    "name",
         	  "label": "Name",
         	  "type":  "string"
         	}
       ]
    }
JSON
    x = compiler.compile(schema)
  end 
end