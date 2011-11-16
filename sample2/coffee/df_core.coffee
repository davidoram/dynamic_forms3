class DFCore
	constructor: (@sections, @document) ->
		this.log ">constructor"

		# Shotenjin template class to generate content on the fly
		@template_engine = new Shotenjin.Template
		
		# Context which is passed through when invoking the template engine
		@context =  { }
		
		# html id of page element to recieve rendered template
		@html_dest_id = '#content'
		
		# Index hash, contains mapping from each index in JSONPath
		# variables, to the actual index selected
		# TODO - Set the initial values from URL?
		@index_hash = { }
		
		# Current section
		# TODO - Parse from URL?
		@current_section = @sections[0]

		this.log "<constructor"

	# Print a timestamped message to the console
	log: (message) ->
		console.log "#{new Date} #{message}"

	# Log key state to the console
	dump: ->
		this.log '>>> dump --------------------------------------'
		this.log '>>> dump document: ' + JSON.stringify(@document)
		this.log '>>> dump sections: ' + JSON.stringify(@sections)
		this.log '>>> dump current_section: ' + JSON.stringify(@current_section)
		this.log '>>> dump index_hash: ' + JSON.stringify(@index_hash)
		this.log '>>> dump --------------------------------------'
		
	# Set the index for a particular value
	index_for: (key, value) ->
		@index_hash[key] = value
		
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
		
	# render the current section
	render: ->

		this.log ">render. Current section #{@current_section}, to #{@html_dest_id}"
		
		# Remove all existing bindings in the form
		# TODO - content id should be a parameter
		$(@html_dest_id).unbind

		# Get template str ...
		template =  $('#' + @current_section).html()
		#this.log "template: #{template}"

		# ... convert template
		@template_engine.convert(template)

		# ... render it
		output = @template_engine.render(@context)
		#this.log "output: #{output}"
		
		# ... put rendering on the page
		$(@html_dest_id).html(output);
		
		# .. bind each element which has custom attribute 'df_jsonpath'
		$('#content [df_jsonpath]').each (index, element)  =>
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

		this.log "<render"
		
###		
		# replace indexes in JSONPaths
		output = getTemplate.render(context)
		
		
		render_and_replace(get_template(current_section_id),
		                   peek_doc_ptr(),
		                   '#content');

		// Bind changes on the form fields to specific values on the data object
		$('#content [df_bindto]').each(function() {
			var bindTo = $(this).attr('df_bindto');
			log('Apply binding from id:' + this.id + ' to path:' + bindTo);
			$(this).val(get_value(bindTo));
			$(this).bind('change', bindTo , value_changed);

		});

		// Render the navigation controls
		render_and_replace(get_template('df_navigation'),
		                   { },
		                   '#footer');

	    log('render_current_section ' + current_section_id);
###	    