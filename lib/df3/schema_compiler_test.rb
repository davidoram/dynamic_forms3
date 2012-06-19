require 'test/unit'
require 'pp'
require 'json'
require_relative 'schema_compiler'
require_relative 'data_compiler'

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
    path = ''
    template_str = DF3::SchemaCompiler.render('UnitTest', schema, path)
    template = JSON.parse(template_str)
    assert_equal(%w{ dob name }, template.keys.sort)
    
    data =<<JSON 
    {
      "id": 456,
      "name": "bob",
      "dob": "2012-01-03" 
    }
JSON
    output_str = DF3::DataCompiler.render(template_str, data, path)
    output = JSON.parse(output_str)
    assert_equal(%w{ 2012-01-03 bob }, output.values.sort)
    
    
    
  end 

end