/*
 * Navigate.js
*/

// Declare the data document
var df_document = {
  name: 'Dave',
  dob: '1969-12-20',
  children: 5,
  comment: 'Blah blah',
  employees: [
	{ name: 'Sue', dob: '1970-01-01' },
	{ name: 'Bob', dob: '1972-11-03' }
  ]
};

/* Pointer into the df_document providing the context for rendering */
var df_document_ptr = [ ];

/* The section navigation data structure */
var section_navigation =  [
	{ id: 'section_1', up: null, down: 'section_2', left: null },  
	{ id: 'section_2', up: 'section_1', down: null, left: null }, 
	{ id: 'section_3', up: null, down: null, left: 'section_2'  }
]

/* The 'current' section that has focus */
var current_section_id = 'section_1';


/* Precompiled template cache */
var template_cache = { };

function get_template(id) {
	var start = new Date().getTime();
	var cached = true;
	if (!template_cache.hasOwnProperty(id)) {
		cached = false;
		var template_str =  $('#' + id).html();
		template_cache.id = new Shotenjin.Template();
		template_cache.id.convert(template_str);
	}
	var end = new Date().getTime();
	log("get_template cached:" + cached + ", took " + ( end - start ) + " millisec" )
	return template_cache.id;
}
 
function render_and_replace(template, context, id) {
	var start = new Date().getTime();
	var output = template.render(context);
	var render = new Date().getTime();
	$(id).html(output);
	var end = new Date().getTime();
	log("render_and_replace. render phase took " + ( render - start ) + " millisec, replace output phase took " + (end - render) + ' millisec' );
}
 

function log(msg) {
	console.log(new Date() + ':' + msg);
}

function get_section_nav() {
	log('get_section_nav ' + section_navigation.length);
	for (var i = 0; i < section_navigation.length; i = i + 1) {
		log('checking: ' + section_navigation[i].id);
		if (section_navigation[i].id == current_section_id) {
			return section_navigation[i];
		}
	}
	throw "Unknown section_id '" + current_section_id + "'";
}

function dump() {
	log('>>> dump');
	log('>>> dump df_document: ' + JSON.stringify(df_document));
	log('>>> dump df_document_ptr: ' + JSON.stringify(df_document_ptr));
	log('>>> dump current_section_id: ' + JSON.stringify(current_section_id));
	log('>>> dump section_navigation: ' + JSON.stringify(section_navigation));
	log('>>> dump');
}

function push_doc_ptr(json_path_element) {
	if (typeof json_path_element != 'string') {
		throw "json_path_element must be a string";
	}
	log('push_doc_ptr: ' + json_path_element);
	df_document_ptr.push( json_path_element );
}

function pop_doc_ptr() {
	df_document_ptr.pop();
}

function get_eval_path() {
	var eval_path = 'df_document' ;
	if (df_document_ptr.length > 0) {
		eval_path = eval_path + '.' + df_document_ptr.join('.') 
	}
	return eval_path;
}

function peek_doc_ptr() {
	var eval_path = get_eval_path();
	log('peek_doc_ptr. path "'+ eval_path + '"');
	return eval(eval_path);
}


function set_value(path, value) {
	var expression = get_eval_path() + "." + path + " = '" + value + "'";
	log('set_value. "'+ expression + '"');
	eval(expression);
}

function get_value(path) {
	var expression = get_eval_path() + "." + path;
	log('get_value.  "'+ expression + '"');
	return eval(expression);
}

function value_changed(event) {
	set_value(event.data, event.target.value);
}

function render_current_section() {
    log('render_current_section');

	// Remove all existing bindings in the form
	$('#content').unbind
	
	// Render template into 'content' div
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
}

function navigate_to(new_section_id) {
	current_section_id = new_section_id;
	render_current_section();
	log('navigate_to ' + current_section_id);
}
