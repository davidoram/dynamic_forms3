require 'test/unit'
require 'pp'
require 'set'
require_relative 'templating'
require_relative 'formatter'
require_relative 'url_parser'

class TestSchemaCompiler < Test::Unit::TestCase 
  
  def test_render_simple
    template = get_template_store()[123]
    data = get_data_store()[456]

    formatter = DF3::RubyFormatter.new
    output = DF3::Render.render(template, data, formatter)
    #pp '----- Output ----'
    #pp formatter.render
    assert_equal("2012-01-03", output['dob'])
    assert_equal("bob", output['name'])
    assert_equal(Set.new([{ 'name' => "molly", 'df_index' => 1}, { 'name' => "snuffles", 'df_index' => 0}]), 
                 Set.new(output['pets']))
  end 
  
  def test_navigate_template
    template = get_template_store()[123]
    url = DF3::URL.new('/')
    root = DF3::Render.navigate_template(template, url)
    assert_equal(template, root)
    
    url = DF3::URL.new('/pets/456')
    pets = DF3::Render.navigate_template(template, url)
    assert_equal(template['fields'][2], pets)
  end
  
  def test_navigate_data
    data = get_data_store()[456]
    url = DF3::URL.new('/')
    root = DF3::Render.navigate_data(data, url)
    assert_equal(data, root)
    
    url = DF3::URL.new('/pets')
    pets = DF3::Render.navigate_data(data, url)
    assert_equal(data['pets'], pets)

    url = DF3::URL.new('/pets/0')
    snuffles = DF3::Render.navigate_data(data, url)
    assert_equal('snuffles', snuffles['name'])

    url = DF3::URL.new('/pets/1')
    molly = DF3::Render.navigate_data(data, url)
    assert_equal('molly', molly['name'])
  end
  
  def test_navigate_and_render
    template = get_template_store()[123]
    data = get_data_store()[456]
    url = DF3::URL.new('/')
    formatter = DF3::RubyFormatter.new
    
    output = DF3::Render.navigate_and_render(template, data, formatter, url)
    #pp '----- Output ----'
    #pp formatter.render
    assert_equal("2012-01-03", output['dob'])
    assert_equal("bob", output['name'])
    assert_equal(Set.new([{ 'name' => "molly", 'df_index' => 1}, { 'name' => "snuffles", 'df_index' => 0}]), 
                 Set.new(output['pets']))


    url = DF3::URL.new('/pets/0')
    output = DF3::Render.navigate_and_render(template, data, formatter, url)
    assert_equal("snuffles", output['name'])

    url = DF3::URL.new('/pets/1')
    output = DF3::Render.navigate_and_render(template, data, formatter, url)
    assert_equal("molly", output['name'])

  end 
  

  def get_template_store
    {
      123 =>  {
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
    }
  end
    
  def get_data_store
    {
      456 => {
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
    }
  end

end