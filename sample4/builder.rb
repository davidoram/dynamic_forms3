#---------------------------------------------------
#
# Interface to build templates on the fly, by combining
# schema + form + data
#
class Builder
  
  def Builder.render(document, schema, form, path)
    # Find the section that matches the path
    schema_ptr = schema.df_fields
    document_ptr = document.df_data
    path_stack = path.reverse
    while path_element = path_stack.pop
      pp "evaluate path_element #{path_element}"
      # Is this part of the stack a 
    end 
  end
  
end
