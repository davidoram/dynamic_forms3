require 'json'
require 'pp'
require 'erubis'

module DF3
  
    # Formats output as a Ruby data structure 
    class RubyFormatter
      
      DEBUG = false
      
      def initialize
        # Stack of pointers to the current place where data is to be added
        @data = []
        @root = nil
      end
      
      # render 
      def render
        @root
      end
      
      def on_object_start(field, data)
        pp "on_object_start" if DEBUG
        
        obj = {}
        # Pull in index if we are part of an array
        obj['df_index'] = data['df_index'] if data.has_key? 'df_index'
        
        @root = obj if @data.empty?
        @data.last << obj if @data.last
        @data.push(obj)
      end
      
      def on_object_end
        pp "on_object_start" if DEBUG
        @data.pop
      end

      def on_primitive(field, data)
        pp "on_primitive field: #{field['id']}, data: #{data}" if DEBUG
        @data.last[field['id']] = data
      end
      
      def on_array_start(field, data)
        arr = []
        @data.last[field['id']] = arr if @data.last
        @data.push(arr)
      end
      
      def on_array_end(field, data)
        @data.pop
      end
      
      def on_array_header_start(field, data)
      end
      
      def on_column(field, data)
      end
      
      def on_array_header_end(field, data)
      end
    end
        
    
end