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
  VARIABLE_DELIMITERS_REGEXPR = [ '[^', '^]']
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
    data = document.navigate_to(url_parsed)
    section = form.section_for(url_parsed[:section_path]);

    # Create/retrieve a template representing this section
    template = Builder.template_for(section, url_parsed)
    
    # combine the template and document
    Mustache.render(template, {:data        => data,
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

    # Each field passes in 'label', 'path' and 'type'
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
