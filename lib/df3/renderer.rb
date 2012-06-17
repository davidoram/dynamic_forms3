require 'erubis'

module DF3
  
    class RenderUnitTest
      def primitive(field)
        erb = Erubis::Eruby.new("<% field['id'] %>:<%= field['type'] %>")
        erb.result(:field => field)
      end
      def array(field)
        erb = Erubis::Eruby.new("<% field['id'] %>:<%= field['type'] %>")
        erb.result(:field => field)
      end
    end

end