#!/bin/bash
#
# Load up schema docs 
#
SCRIPT_DIR=`dirname $0`

curl -X PUT \
	-H "Content-type:application/json" \
	-d @${SCRIPT_DIR}/sample-1.json \
	${1}/riak/schemas/sample-1
