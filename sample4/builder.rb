require 'mustache'

#---------------------------------------------------
#
# Interface to build templates on the fly, by combining
# schema + form + data
#
# Use [[xxx]] to put another level of arguments inside a template 
#
class Builder
  
  # Instances of these delimiters inside your Templates will be replaces with Mustache
  # deliminiters {{ }}, so you can have a Template which generates a Template etc
  VARIABLE_DELIMITERS_REGEXPR = [ '[[', ']]']
  MUSTACHE_DELIMITERS = [ '{{', '}}']

  def Builder.replace_variable_templates(string)
    string = string.gsub(VARIABLE_DELIMITERS_REGEXPR[0], MUSTACHE_DELIMITERS[0])
    string.gsub(VARIABLE_DELIMITERS_REGEXPR[1], MUSTACHE_DELIMITERS[1])
  end
  
  # Render a static file using the context provided,
  # and then replace and [[ ]] pairs with {{ }}
  def Builder.render_file(filename, context = {})
    this_dir = Pathname.new(File.dirname(__FILE__))
    m = Mustache.new
    m.template_file = "#{this_dir}/templates/#{filename}.mustache"
    Builder.replace_variable_templates(m.render(context))
  end

  
  def Builder.render_document(document, schema, form, url_parsed)
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
    <h2>#{section[:heading]}</h1>


    {{# errors}}
    <p style="color: red;">{{.}}</p>
    {{/ errors}}


    <form method="post" action="/documents{{url_parsed.url}}">
    END_OF_STRING

    section['fields'].each do |field|
      template << Builder.render_file("fields/#{field['type']}", field)
    end

    footer = <<-END_OF_STRING
      <button type="submit">Save</button>
    </form>
    <a href="/">Cancel</a>

    </body>
    </html>
    END_OF_STRING
    template << footer
    template
  end
  
end
