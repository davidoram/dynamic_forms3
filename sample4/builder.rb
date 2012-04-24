#---------------------------------------------------
#
# Interface to build templates on the fly, by combining
# schema + form + data
#
class Builder
  
  def render(df_schema, df_section, df_path, df_document)
    form_template = get_form(df_section)
  end
  
end
