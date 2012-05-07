require 'mustache'

#---------------------------------------------------
#
# Interface to build templates on the fly, by combining
# schema + form + data
#
class Builder
  
  def Builder.render(document, schema, form, url_parsed)
    # Find the section that matches the path
    schema_ptr = schema.df_fields
    document_ptr = document.df_data
    section = form.section_for_path([]);
    path_stack = url_parsed[:path].reverse
    while path_element = path_stack.pop
      pp "evaluate path_element #{path_element}"
      # Is this part of the stack a 
    end 
    
    # Add any missing data elements at this part of the schema to the document?
    
    # Create/retrieve a template representing this section
    template = Builder.template_for(section, url_parsed)
    
    # combine the template and document
    Mustache.render(template, {:document    => document,
                               :url_parsed  => url_parsed,
                               :errors      => [] })
  end
  
private
  def Builder.template_for(section, url_parsed)
    # Template will take the following context:
    # doc => the document being edited
    # url_parsed => as returned by UrlParser.parseDocumentUrl
    # errors => array of errors 
    template = <<-END_OF_STRING
    <html>
    <body>
    <h1>Document {{url_parsed.id}}</h1>


    {{# errors}}
    <p style="color: red;">{{.}}</p>
    {{/ errors}}

    <form method="post" action="/documents{{url_parsed.url}}">
    <p>TODO</p>
      <button type="submit">Save</button>
    </form>
    <a href="/">Cancel</a>

    </body>
    </html>
    END_OF_STRING
    template
  end
  
end
