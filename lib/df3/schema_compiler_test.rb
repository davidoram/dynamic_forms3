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
         	  "type":  "string"
         	},
         	{ 
         	  "id":    "dob",
         	  "type":  "date"
         	},
         	{ 
         	  "id":    "pets",
         	  "type":  "array",
         	  "fields": [
             	{ 
             	  "id":    "name",
             	  "type":  "string"
             	}
         	  ]
         	}
       ]
    }
JSON
    path = []
    template_str = DF3::SchemaCompiler.render('UnitTest', schema, path)
    data =<<JSON 
    {
      "id": 456,
      "name": "bob",
      "dob": "2012-01-03",
      "pets": [
          {
            "name": "rover"
          },
          {
            "name": "molly" 
          }
      ]
    }
JSON
    output_str = DF3::DataCompiler.render(template_str, data, path)
    pp '----- Output ----'
    pp output_str
    output = JSON.parse(output_str)
    assert_equal("2012-01-03", output['dob'])
    assert_equal("bob", output['name'])
    assert_equal(["molly", "rover"], output['pets'].sort)
  end 

end