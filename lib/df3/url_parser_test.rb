require 'test/unit'
require 'pp'
require 'set'
require_relative 'url_parser'

class TestURLParser < Test::Unit::TestCase 
  
  def test_parse_empty
    parser = DF3::URLParser.new('')
    assert_equal(0, parser.size)
  end 

  def test_parse_empty2
    parser = DF3::URLParser.new('/')
    assert_equal(0, parser.size)
  end 

  def test_parse_list
    parser = DF3::URLParser.new('/documents')
    assert_equal(1, parser.size)
    assert_equal({:type => :array, :name => 'documents'}, parser[0])
  end 

  def test_parse_list_element
    parser = DF3::URLParser.new('/documents/3674')
    assert_equal(1, parser.size)
    assert_equal({:type => :array_element, :name => 'documents', :index => 3674}, parser[0])
  end 

  def test_parse_list_element_list
    parser = DF3::URLParser.new('/documents/3674/children')
    assert_equal(2, parser.size)
    assert_equal({:type => :array_element, :name => 'documents', :index => 3674}, parser[0])
    assert_equal({:type => :array, :name => 'children'}, parser[1])
  end 

  def test_parse_list_element_list_element
    parser = DF3::URLParser.new('/documents/3674/children/65')
    assert_equal(2, parser.size)
    assert_equal({:type => :array_element, :name => 'documents', :index => 3674}, parser[0])
    assert_equal({:type => :array_element, :name => 'children', :index => 65}, parser[1])
  end 

end