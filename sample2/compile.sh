#!/bin/bash
#
# Pass in the path to the form_data.json file to be processed
#
# Will output to 'output' dir
# Put rbhtml templates in 'templates' dir
# Put json form definitions in 'form_data' dir
# Merges static files from 'static_content' dir into 'output' dir
#
# Need rubyb tenjin installed 
# 		sudo gem install tenjin
# See www.kuwata-lab.com
#

THIS_DIR=`dirname $0`

# Delete & recreate output dir
rm -rf ${THIS_DIR}/output
mkdir ${THIS_DIR}/output
if [[ $? != 0 ]]; then 
	echo "ERROR! Unable to recreate output dir"
	exit 1	
fi

rbtenjin -C -f ${THIS_DIR}/form_data/df_form1.rb --path=${THIS_DIR}/templates layout.rbhtml > ${THIS_DIR}/output/df_form1.html
if [[ $? != 0 ]]; then 
	echo "ERROR! reported by rbtenjin"
	cat ${THIS_DIR}/output/df_form1.html
	exit 1	
fi
cp -r ${THIS_DIR}/static_content/* ${THIS_DIR}/output

coffee --compile --bare --output ${THIS_DIR}/output ${THIS_DIR}/coffee/df_core.coffee
if [[ $? != 0 ]]; then 
	echo "ERROR! reported by coffee"
	exit 1	
fi
