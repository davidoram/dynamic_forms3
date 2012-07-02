require 'test/unit'
require 'pp'
require 'set'
require_relative 'url_parser'

class TestURL < Test::Unit::TestCase 
  
  def test_parse_static_empty_url
    parser = DF3::URL.new('', get_routes)
    assert_equal(0, parser.size)
    assert(parser.is_static?)
  end 

  def test_parse_static
    parser = DF3::URL.new('/', get_routes)
    assert_equal(0, parser.size)
    assert(parser.is_static?)
  end 

  def test_parse_list
    parser = DF3::URL.new('/documents', get_routes)
    assert_equal(1, parser.size)
    assert_equal({:type => :collection, :name => 'documents'}, parser[0])
    assert(parser.is_collection?, "Got #{parser.type}")
  end 

  def test_parse_list_element
    parser = DF3::URL.new('/documents/3674', get_routes)
    assert_equal(1, parser.size)
    assert_equal({:type => :document, :name => 'documents', :index => 3674}, parser[0])
    assert(parser.is_collection?)
  end 

  def test_parse_list_element_list
    parser = DF3::URL.new('/documents/3674/children', get_routes)
    assert_equal(2, parser.size)
    assert_equal({:type => :document, :name => 'documents', :index => 3674}, parser[0])
    assert_equal({:type => :collection, :name => 'children'}, parser[1])
    assert(parser.is_collection?)
  end 

  def test_parse_list_element_list_element
    parser = DF3::URL.new('/documents/3674/children/65', get_routes)
    assert_equal(2, parser.size)
    assert_equal({:type => :document, :name => 'documents', :index => 3674}, parser[0])
    assert_equal({:type => :document, :name => 'children', :index => 65}, parser[1])
    assert(parser.is_collection?)
  end 

private
  def get_routes
    [
      { :route_regex => '/documents', :type => :collection },
      { :route_regex => '/?', :type => :static },
    ]
  end
end