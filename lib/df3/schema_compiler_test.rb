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
         	}
       ]
    }
JSON
    output = DF3::SchemaCompiler.render('UnitTest', schema, '')
    #pp output
    json = JSON.parse(output)
    assert_equal(1, json.keys.length)
    assert_equal("name", json.keys[0])
  end 

end