class DFCore
	constructor: (@form, @document) ->
		this.log ">constructor"

		# Shotenjin template class to generate content on the fly
		@template_engine = new Shotenjin.Template
		
		# html id of page element to recieve rendered template
		@form_content_id = 'content'
		
		# Index hash, contains mapping from each index in JSONPath
		# variables, to the actual index selected
		# TODO - Set the initial values from URL?
		@index_hash = { }
		
		# Current section
		@current_section_id = this.get_starting_section()

		this.log "<constructor"

	# Print a timestamped message to the console
	log: (message) ->
		console.log "#{new Date} #{message}"

	# Log key state to the console
	dump: ->
		this.log '>>> dump --------------------------------------'
		this.log '>>> dump document: ' + JSON.stringify(@document)
		this.log '>>> dump current_section: ' + JSON.stringify(@current_section_id)
		this.log '>>> dump index_hash: ' + JSON.stringify(@index_hash)
		this.log '>>> dump form: ' + JSON.stringify(@form)
		this.log '>>> dump --------------------------------------'

	# Get the section we should start from. 
	# TODO - Could parse the URL?
	get_starting_section: ->
		@form.sections[0].id
	
	# Return the section navigation structure for the current section	
	get_section_navigation: ->
		for section in @form.sections
			if section.id == @current_section_id
				return section.section_navigation

	# Make section_id the current section & render
	navigate_to: (section_id) ->
		this.log ">navigate_to #{section_id}"
		@current_section_id = section_id
		this.render()
		
	# Set the index for a particular value
	index_for: (key, value) ->
		@index_hash[key] = value
	
	# Return the values in the @document at json_path. Assumes that the path is unique &
	# returns the 1st match
	document_data: (json_path) ->
		jsonPath(@document, json_path)[0]
		
		
	# Given a JSONPath string replace any instances of indexes with
	# the appropriate values eg: 
	resolve_index_for: (json_path) ->
		str = json_path
		for own index_key, index_value of @index_hash 
			str.replace index_key, index_value
		this.log "resolve_index_for #{json_path} -> #{str}"
		str
	
	# Update the document at a given json_path to a new value
	update_document: (json_path, new_value) ->
		this.log "update_document at path #{json_path} to #{new_value}"
		expression = json_path.replace /\$/gi, "this.document"	
		eval "#{expression} = '#{new_value}'"
		
	# render a template to the page
	render_template: (template_id, destination_id, context) ->

		this.log ">render_template '#{template_id}' to '#{destination_id}'"
		this.log "context " + JSON.stringify(context)

		# Remove all existing bindings in the form
		$('#' + destination_id).unbind

		# Get template str ...
		template =  $('#' + template_id).html()

		# ... convert template
		@template_engine.convert(template)

		# ... render it
		output = @template_engine.render(context)
		#this.log "output: #{output}"
		
		# ... put rendering on the page
		$('#' + destination_id).html(output);
		
		this.log "<render_template"
			
		
	# render the current section
	render: ->

		this.log ">render. Current section #{@current_section_id}, to #{@form_content_id}"

		# Render the form
		form_context = { }
		this.render_template @current_section_id, @form_content_id, form_context 
		
		# .. bind each element which has custom attribute 'df_jsonpath'
		$('#' + @form_content_id + '  [df_jsonpath]').each (index, element)  =>
			# get the JSONPath....
			json_path = $(element).attr('df_jsonpath')
			# .. replace any indexes
			json_path = this.resolve_index_for(json_path)

			# .. put the data value at json_path into the html form
			value = jsonPath(@document, json_path)[0]
			this.log "#{json_path} resolves to #{value}"
			$(element).val( value )
			
			# finally any changes made to the form field should be immediately reflected back
			# in the json document
			$(element).bind 'change', json_path, (event) =>
				this.update_document event.data, event.target.value

		# Render the navigation
		section_context = { section:  this.get_section_navigation() }
		this.render_template 'df_navigation', 'footer',  section_context

		this.log "<render"
