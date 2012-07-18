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

      search_keys = searchkeys(collection)
      
      # TODO construct a query from the search parameters
      Riak::Bucket.new(@client,collection).get_index('df_type_bin', 'application')
    end
  
    # Each schema document has an optional 'searchkeys' array which lists the
    # keys that form the default set to be searched, get the list for all
    # schemas & return
    def searchkeys(collection)
      result = []
      if collection == 'applications'
        map = "function(value, keyData, arg){ 
               		var data = Riak.mapValuesJson(value)[0]; 
               		if(data.searchkeys) 
                 			return [data.searchkeys]; 
               		else 
                 			return []; 
              }"
            
        reduce = "function(valueList, arg){ 
                    return _.unique(_.flatten(valueList));
                  }"
                
        result = Riak::MapReduce.new(@client).index('schemas', 'df_type_bin', 'schema')
            .map(map)
            .reduce(reduce, :keep => true)
            .run
      end
      result
    end
  end
end