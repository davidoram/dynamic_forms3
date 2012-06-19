require 'test/unit'
require 'pp'
require 'json'
require_relative 'schema_compiler'

class TestSchemaCompiler < Test::Unit::TestCase 
  
  def test_compile_simple
    schema =<<JSON 
    {
      "id": 123,
      "fields": [ 
         	{ 
         	  "id":    "name",
         	  "label": "Name",
         	  "type":  "string"
         	},
         	{ 
         	  "id":    "dob",
         	  "label": "Date of birth",
         	  "type":  "date"
         	}
       ]
    }
JSON
    output = DF3::SchemaCompiler.render('UnitTest', schema, '')
    json = JSON.parse(output)
    assert_equal(%w{ dob name }, json.keys.sort)
    pp json
  end 

end