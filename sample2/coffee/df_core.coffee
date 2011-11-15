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

	log: (message) ->
		console.log "#{new Date} #{message}"
		
	# Set the index for a particular value
	index_for: (key, value) ->
		@index_hash[key] = value
		
	# Given a JSONPath string replace any instances of indexes with
	# the appropriate values eg: 
	resolve_index_for = (json_path) ->
		str = json_path
		for own index_key, index_value of @index_hash 
			str.replace(index_key, index_value)
		str
		
	
	# render the current section
	render: ->

		this.log ">render. Current section #{@current_section}, to #{@html_dest_id}"
		
		# Remove all existing bindings in the form
		# TODO - content id should be a parameter
		$(@html_dest_id).unbind

		# Get template str ...
		template =  $('#' + @current_section).html()
		this.log "template: #{template}"

		# ... convert template
		@template_engine.convert(template)

		# ... render it
		output = @template_engine.render(@context)
		this.log "output: #{output}"
		
		# ... put rendering on the page
		$(@html_dest_id).html(output);
		
		# .. bind each element which has custom attribute 'df_jsonpath'
		$('#content [df_bindto]').each =>
			# get the JSONPath....
			json_path = @attr('df_bindto')
			# .. replace any indexes
			json_path = resolve_index_for(json_path)
			# .. put the data value at json_path into the html form
			@val = jsonPath(@document, json_path)[0]
			

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