/*
 * Navigate.js
*/

/* Create an ordering to the sections so we can go to
   the next or prev one */
var ordered_section_ids = [ 'section_1', 'section_2', 'section_3'];

/* Index into ordered_section_ids of the 'current' section that has focus */
var current_section_index = 0;

function dump() {
	console.log('>>> dump');
	console.log('>>> dump dataObject: ' + JSON.stringify(dataObject));
	console.log('>>> dump');
}

function set_value(path, value) {
	console.log('set_value. Set path "'+ path + '" to value "' + value + '"');
	dataObject[path] = value;
}

function get_value(path) {
	var value = dataObject[path];
	console.log('get_value. Value at path "'+ path + '" is "' + value + '"');
	return value;
}

function value_changed(event) {
	set_value(event.data, event.target.value);
}

function render_current_section() {
	// Remove all existing bindings in the form
	$('#content').unbind
	
	// Render template into 'content' div
	$('#content').html(tmpl(ordered_section_ids[current_section_index], {}));
	
	// Bind changes on the form fields to specific values on the data object
	$('#content [df_bindto]').each(function() {
		var bindTo = $(this).attr('df_bindto');
		console.log('Apply binding from id:' + this.id + ' to path:' + bindTo);
		$(this).val(get_value(bindTo));
		$(this).bind('change', bindTo , value_changed);
		
	});
    console.log('render_current_section ' + ordered_section_ids[current_section_index]);
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