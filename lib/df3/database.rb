require 'pp'
require 'riak'

module DF3
  
  class Database
    
    def initialize
      @client = Riak::Client.new
    end
    
    # Query all documents in the 'schema' bucket for columns marked as indexed
    # Then construct a lenene search for documents in the bucket with those columns    
    def find_in_collection(collection, pageSize, pageStartIndex)
  
      GET the list of all fields of all schemas in the bucket that are included in the default serach
      COnvert mydoc.collection.field -> mydoc_collection_field
      Create a search term that looks for the value in all fields
      Return and format
  
      
      TODO - Find out how Riak Search works - Lunene?
      Query all documents in the schema buck
      Search here - returning results as indexes with pk field
      
      matches = @client.bucket(collection).get_index('pk')
    end
  end
end