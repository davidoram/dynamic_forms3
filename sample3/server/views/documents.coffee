h1 'Documents'

table ->
	tr ->
		td 'Identifier'
		td 'Name'
		td ->
			button onclick: 
	for row in @data.rows
		tr ->
			td row.id
			td row.name 
			td ''

p "Total rows #{@data.total_rows}"