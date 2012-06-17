#!/bin/bash
#
# Run the server
#
# Use rvm to select the appropriate ruby version 1st
#
THIS_DIR=`dirname $0`

# For development mode - use shotgun to reload with each request
rackup -Ilib ${THIS_DIR}/../config.ru
