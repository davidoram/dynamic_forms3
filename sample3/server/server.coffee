# Nano - provides a minimal interface to couchdb
nano = require('nano')('http://localhost:5984')
db_name = 'sample3'
db = nano.use(db_name)

app = require('zappa') ->

	@get '/test': ->
		db.get '', (error, body, headers) =>
			if error
				console.log 'couch - error'
				console.log body
				@response.local 'couchStatus', 'error'
			else
				console.log 'couch - ok'
				@response.local 'couchStatus', 'ok'
			@response.send "Zappa version #{app.zappa.version}<br>Couch #{@response.local 'couchStatus'}"

	# Ping the server, & return its status regarding connectivity
	# to couchdb etc
	@get '/': '''
		Sample3 server ok
		'''

	# Return a collection of Documents
	#
	# Query parameters:
	# - pageSize - max number of rows to return
	# - pageStartIndex - 0 based index of 1st row to return
	#
	# Request Headers
	# - Content-Type - the only acceptable value is 'application/json'
	# 
	# Response Headers
	# - Content-Type is 'application/json'
	# - Last-Modified will contain a Timestamp indicating the last time when this resource changed ie:"now"
	# - ETag will contain an opaque string that identifies the version of the response entity
	@get '/documents': '''
		TODO - Return a list of documents
		'''
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
