require 'json'
require 'pp'
require 'erubis'

module DF3
  
    class DataCompiler
      
      def DataCompiler.render(template, data_str, path = [])
        data = JSON.parse(data_str)
        erb = Erubis::Eruby.new(template, :pattern => '<-% %->')
        erb.result(:data => navigate_to(data, path))
      end
    
      private
      
      def DataCompiler.navigate_to(data, path)
        path.each do |path_el|
          schema = data[path_el]
        end
        data
      end
    
    end
end