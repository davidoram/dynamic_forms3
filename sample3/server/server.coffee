# Nano - provides a minimal interface to couchdb
nano = require('nano')('http://localhost:5984')
db_name = 'sample3'
db = nano.use(db_name)

app = require('zappa') ->
	
	# HTML output will use the default coffekup layout
	@enable 'default layout'
	
	# Server static files in 'public' dir
	# eg http://localhost:3000/test_static.html 
	@use @app.router, static: __dirname + '/public'

	# Ping the server, & return its status regarding connectivity
	# to couchdb etc
	@get '/': ->
		
		@response.write "<html><body>Zappa #{app.zappa.version} - ok<br>"
		db.get '', (error, body, headers) =>
			if error
				@response.write "Couch db #{db_name} - error.<br>"
				@response.write "Execute ./bin/migrate to create db and views etc<br>"
			else
				@response.write "Couch db #{db_name} - ok<br>"
				@response.write "<a href='/documents'>Documents</a><br>"
			@response.end "Done</body></html>"

	# Return a collection of Documents
	#
	# Query parameters:
	# - pageSize - max number of rows to return
	# - pageStartIndex - 0 based index of 1st row to return
	#
	# Request Headers
	# - Accept - the acceptable values are 'application/json', or 'text/html'
	# 
	# Response Headers
	# - Accept is 'application/json' or 'text/html'
	# - Last-Modified will contain a Timestamp indicating the last time when this resource changed ie:"now"
	# - ETag will contain an opaque string that identifies the version of the response entity
	#
	#
	# Response Body
	#	{
	#		"search-results": [
	#			"name":		"Application to fund medical research"
	#			{
	#				"href"	:	"http://api.host.com/documents/87",
	#				"rel"	:	"edit"	
	#			},
	#			{
	#				"href"	:	"http://api.host.com/documents/1887",
	#				"rel"	:	"edit"	
	#			},
	#		] 
	#		"links" : {
	#			"self" :  { 
	#				"href" :	"http://api.host.com/documents?pageSize=10&pageStartIndex=3"
	#				"rel"  :	"self" 
	#			}, 
	#			"next" :  { 
	#				"href" :	"http://api.host.com/documents?pageSize=10&pageStartIndex=4"
	#				"rel"  :	"next" 
	#			}, 
	#			"prev" :  { 
	#				"href" :	"http://api.host.com/documents?pageSize=10&pageStartIndex=2"
	#				"rel"  :	"prev" 
	#			},
	#		}
	#	}
	# For rel values see http://www.iana.org/assignments/link-relations/link-relations.xml#link-relations-2
	# To test: 
	#   curl --header "Accept:application/json" http://localhost:3000/documents to see JSON
	#   or run from broswer to see HTML
	#
	@get '/documents': ->
		# TODO - Add appropriate user rights etc here to the query
		db.view 'documents', 'all', (error, body, headers) =>
			if error
				@response.send { error: 'Error retrieving documents ' + error}, 504 
			else
				if @request.accepts('html')
					@render documents: { data: body, scripts: [ 'jquery-1.6.2'] }
				else if @request.accepts('json')
					@response.send body
				else
					@response.send "Unable to generate content to match the 'Accept' header: '#{@request.header('Accept', '')}', try 'application/json', or 'text/html'", 
			               406
		
	# Create a new Document, that has the appropriate default fields etc 
	# but is not yet saved to the database
	#
	# Query parameters:
	# - n/a
	#
	# Request Headers
	# - Accept - the acceptable values are 'application/json', or 'text/html'
	# 
	# Response Headers
	# - Accept is 'application/json' or 'text/html'
	# - Last-Modified will contain a Timestamp indicating the last time when this resource changed ie:"now"
	# - ETag will contain an opaque string that identifies the version of the response entity
	#
	# To test: 
	#   curl --header "Accept:application/json" http://localhost:3000/documents to see JSON
	#   or run from broswer to see HTML
	#
	@get '/documents/generate': '''
		TODO - create new doc, Return document id
		'''
		
	# Read an existing Document
	@get '/documents/:id': '''
		TODO - get document 
		'''
	# Update an existing Document
	@put '/documents/:id': '''
		TODO - Update Return document
		'''
		
	# Execute the documents controller & direct it to delete all documents 
	@post '/documents/delete-all': '''
		TODO - Delete all documents
		'''
