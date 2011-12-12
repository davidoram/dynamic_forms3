# Nano - provides a minimal interface to couchdb
nano = require('nano')('http://localhost:5984')
db_name = 'sample3'
db = nano.use(db_name)

app = require('zappa') ->
	
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
	# - Content-Type - the acceptable values are 'application/json', or 'text/html'
	# 
	# Response Headers
	# - Content-Type is 'application/json' or 'text/html'
	# - Last-Modified will contain a Timestamp indicating the last time when this resource changed ie:"now"
	# - ETag will contain an opaque string that identifies the version of the response entity
	#
	# To test: curl --header "Content-Type:application/json" http://localhost:3000/documents
	#
	@get '/documents': ->
		if @request.is('html')
			"html"
		else if @request.is('json')
			"json"
		else
			@response.send "Not Acceptable,'Content-Type' header value: '#{@request.header('Content-Type', '')}' not acceptable, try 'application/json', or 'text/html'", 
			               406
		
	# Create a new Document
	@post '/documents': '''
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
