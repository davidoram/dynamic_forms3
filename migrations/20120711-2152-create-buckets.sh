#!/bin/bash
#
# Create the bucket to store schemas
#
curl -X PUT \
	-H "content-type:application/json" \
	--data  '{"props":{"precommit":[{"mod":"riak_search_kv_hook","fun":"precommit"}]}}' \
	${1}/riak/schemas 


#
# Create the bucket to store documents
#
curl -X PUT \
	-H "content-type:application/json" \
	--data  '{"props":{"precommit":[{"mod":"riak_search_kv_hook","fun":"precommit"}]}}' \
	${1}/riak/documents 
