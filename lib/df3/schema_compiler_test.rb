require 'test/unit'
require 'pp'
require 'set'
require_relative 'templating'
require_relative 'formatter'

class TestSchemaCompiler < Test::Unit::TestCase 
  
  def test_render_simple
    template = 
    {
      "id" => 123,
      "fields" => [ 
         	{ 
         	  "id" =>    "name",
         	  "type" =>  "string"
         	},
         	{ 
         	  "id" =>    "dob",
         	  "type" =>  "date"
         	},
         	{ 
         	  "id" =>    "pets",
         	  "type" =>  "array",
         	  "fields" => [
             	{ 
             	  "id" =>    "name",
             	  "type" =>  "string"
             	}
         	  ]
         	}
       ]
    }

    data =
    {
      "id" => 456,
      "name" => "bob",
      "dob" => "2012-01-03",
      "pets"=> [
          {
            "name" => "snuffles"
          },
          {
            "name"=> "molly" 
          }
      ]
    }

    formatter = DF3::RubyFormatter.new
    output = DF3::Render.render(template, data, formatter)
    #pp '----- Output ----'
    #pp formatter.render
    assert_equal("2012-01-03", output['dob'])
    assert_equal("bob", output['name'])
    assert_equal(Set.new([{ 'name' => "molly", 'df_index' => 1}, { 'name' => "snuffles", 'df_index' => 0}]), 
                 Set.new(output['pets']))
  end 

end