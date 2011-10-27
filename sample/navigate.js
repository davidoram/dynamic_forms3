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

/* Create an ordering to the sections so we can go to
   the next or prev one */
var ordered_section_ids = [ 'section_1', 'section_2', 'section_3'];

/* Index into ordered_section_ids of the 'current' section that has focus */
var current_section_index = 0;

function dump() {
	console.log('>>> dump');
	console.log('>>> dump df_document: ' + JSON.stringify(df_document));
	console.log('>>> dump df_document_ptr: ' + JSON.stringify(df_document_ptr));
	console.log('>>> dump');
}

function push_doc_ptr(json_path_element) {
	if (typeof json_path_element != 'string') {
		throw "json_path_element must be a string";
	}
	console.log('push_doc_ptr: ' + json_path_element);
	df_document_ptr.push( json_path_element );
}

function pop_doc_ptr() {
	df_document_ptr.pop();
}

function eval_path() {
	var eval_path = 'df_document' ;
	if (df_document_ptr.length > 0) {
		eval_path = eval_path + '.' + df_document_ptr.join('.') 
	}
	return eval_path;
}

function peek_doc_ptr() {
	console.log('peek_doc_ptr. path "'+ eval_path + '"');
	return eval(eval_path());
}


function set_value(path, value) {
	var expression = eval_path() + "." + path + " = " + value;
	console.log('set_value. "'+ expression + '"');
	eval(expression);
}

function get_value(path) {
	var expression = eval_path() + "." + path;
	console.log('get_value.  "'+ expression + '"');
	return eval(expression);
}

function value_changed(event) {
	set_value(event.data, event.target.value);
}

function render_current_section() {
    console.log('render_current_section');

	// Remove all existing bindings in the form
	$('#content').unbind
	
	// Render template into 'content' div
	// retrieve template as a String
	var input = $('#' + ordered_section_ids[current_section_index]).html();
	// context from stack
	var context = peek_doc_ptr(); 
	// render
	var output = Shotenjin.render(input, context);	
	// replace
	$('#content').html(output);
	
	// Bind changes on the form fields to specific values on the data object
	$('#content [df_bindto]').each(function() {
		var bindTo = $(this).attr('df_bindto');
		console.log('Apply binding from id:' + this.id + ' to path:' + bindTo);
		$(this).val(get_value(bindTo));
		$(this).bind('change', bindTo , value_changed);
		
	});
    console.log('render_current_section ' + ordered_section_ids[current_section_index]);
}

function navigate_to(section_id, data) {
	push_doc_ptr(data);
	current_section_index = ordered_section_ids.indexOf(section_id);
	render_current_section();
	console.log('navigate_to ' + current_section_index);
}


function navigate_up() {
	if (current_section_index > 0 ) {
		current_section_index = current_section_index - 1;
		render_current_section();
		console.log('navigate_up. at ' + current_section_index);
	}
}

function navigate_down() {
	if (current_section_index < ordered_section_ids.length ) {
		current_section_index = current_section_index + 1;
		render_current_section();
		console.log('navigate_down. at ' + current_section_index);
	}
}