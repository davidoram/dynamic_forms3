require 'json'
require 'pp'

@df_form = JSON.parse(IO.read("/Users/davidoram/Dropbox/dynamic_forms3/sample2/form_data/df_form1.json"))

# Map from types -> html tag
@element_for = {
  'string' => 'input',
  'integer' => 'input',
  'date' => 'input',
  'text' => 'textarea',
}


# Map from types -> html input tag types
@input_type_for = {
  'string' => 'text',
  'integer' => 'number',
  'date' => 'date',
}

# Cant put these in the template directly because rbtenjin things they are ruby code to be evaluated
@js = '#{'
@jse = '}'
@js2 = '${'

