h1 'Documents'

table ->
	tr ->
		td 'Identifier'
		td 'Name'
	for row in @data.rows
		tr ->
			td row.id
			td row.name 

p "Total rows #{@data.total_rows}"