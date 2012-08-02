Dynamic_forms3
==============
David Oram
v1.0, 2011-09
:doctype: book

:toc:

[preface]
Preface
-------
The design of dynamic_forms3 (df3)  has been preceded by the authors thought into the attendant problems of
designing, implementing maintaining and enhancing procurement systems.
Blah Blah

Part 1 - Business Case
======================

Introduction
------------

DF3 is a system that allows users to create forms that populate document instances

Documents are grouped into Collections representing different entities.

Users can design business rules to be checked.

A Workflow module provides moving documents through a business process.

Documents can be linked - for example to support a procurement system. There will be Documents that
represent application forms, and separate Documents that capture the assessment of the applications, 
and the two will be linked.


Part 2 - Overview
=================

URL space
---------

We divide the URL space into the following:

. Root
. Collections
. Documents
. Store
. Controller

Summary of Actions
------------------

[width="60%",options="header"]
|==============================================================
| HTTP Verb | Root | Collection | Document | Store | Controller
| GET       | X | X | X | X | -
| PUT       | - | - | X | X | -
| POST      | - | X | - | - | X
| DELETE    | - | - | X | X | -
|==============================================================



Root  
~~~~

The root is the default entry page for the system, and provides links to the other parts of the system.
This page is hand-coded HTML.

URL:
 
 /

HTTP Actions:

. GET - Retrieves the entry page. Query parameters provide a unified search over all Collections

Collections
~~~~~~~~~~~

Collections represent the different 'buckets' of information that the system holds. The buckets are defined 
in a configuration step. All collections are presented using templated pages built on the fly.

Examples:

 /applications
 /assessments
 /users
 /roles

HTTP Actions:

. GET - Returns a list of Documents in the collection. All collections supports the following query parameters:
.. title=moo  This is a generic query parameter that will filter the results 
.. pageSize=10  Pagination page size
.. pageStartIndex=4  Pagination page start index
. POST - Create a new Document in the Collection


Documents
~~~~~~~~~

Documents represent the information that the user will be entering, and editing etc.

Examples:

 /applications/\{applicationId\}     
 /applications/\{applicationId\}/phases
 /assessments/\{assessmentId\}
 /users/\{userId\}

HTTP Actions:

. GET - Returns a Document instance
. DELETE - Delete a Document instance
. PUT - Update an existing Document instance

Store
~~~~~

Store values are controlled fully by clients 

Examples:

 /users/\{userId\}/bookmarks

HTTP Actions:

. GET - Retrieve a resource
. DELETE - Remove a resource
. PUT - Insert or Update a resource



Controllers
~~~~~~~~~~~

Function oriented controller resources

Examples:

 /jobs/\{jobId\}/pause
 

HTTP Actions:

. GET - 
. DELETE -
. POST - Used to invoke a controller
. PUT -


Return codes
~~~~~~~~~~~~

Standard HTTP return codes are used:

Success codes

. 200 - generic success
. 201 - resource created
. 202 - accepted: start of async action
. 204 - no content
. 301 - Moved permanatly. New URL in 'Location' header
. 304 - Not modified. But there is state

Error codes

. 400 - generic error
. 401 - Unauthorized. Problem with client credentials ie: No username/pasword or mismatch
. 403 - Forbidden. Client has insufficient access
. 404 - not found
. 405 - Method not allowed
. 415 - Unsupported Media-Type. Content-Type unsupported
. 500 - Generic error code (When an exception occurs)

Database design
---------------

The system uses Riak http://bashio.com/products/riak as its backend data store.

Riak features
~~~~~~~~~~~~~

. Key/Value store.
. Links
. Full text search
. Distributed
. Horizontally scaleable
. Fault tolerant
. Highly available
. Web standards compilant
. Map/Reduce


Riak data model
~~~~~~~~~~~~~~~

. All data is referenced by key
. Keys grouped into buckets
. Operations get,put,delete
. Data is composed of
.. Metadata
.. Links are composed as HTTP Headers:
 Link: </riak/bucket/key>; riaktag="tag"
 Link: </riak/users/fred>; riaktag="owner"
.. Thereafter can link walk to retrieve
 GET /riak/documents/my-doc/_,owner,1
.. Value
. Lucene/Full text search is enabled for a bucket
.. data encoded with header 'Content-type: application/json' can be parsed & automatically indexed on save



DF3 data model
~~~~~~~~~~~~~~

The DF3 data model is layered on the top of Riak data model.

. Buckets
.. schemas. Schema documents
.. documents. Data documents
.. users. Users and roles
.. jobs. Workflow entities
. Secondary indexes
.. document : df_type_bin: document
.. schema : df_type_bin: schema
.. user : df_type_bin: user
. Links
.. documents
... schema -> points to the schemas/xx
... creator -> points to users/yy
. Search
.. schemas identify specific fields as being those that are for default searches
.. any field can be searched using a field:{search term} syntax

 
Approach
--------

df3 takes the approach of separating the tasks of designing a form processing system, which provides forms
that provide a means to capture data into documents.  Documents can be pushed through a workflow
which supports a business process.

The initial design does not concern itself with anything beyond these requirements, but that having been said,
the system has been created with the aim of solving problems in the 'procurement' business domain. 

Architecture
------------

The system provides the means for end users to design, test and publish Forms.  Then users fill out the Forms which result in
Document instances that conform to the layout and structure dictated in the Form.

The system stores all of its data in JSON format.

Permanent Data is stored in CouchDB.

Clients run JavaScript enabled browsers.

  +---------+               +-----------+               +-------------+
  | Browser |    <------>   | Webserver |    <------>   | Document DB |
  +---------+               +-----------+               +-------------+
                                 |
                                 |
                                 v
                               Static files, generated files
                                     

Documents
~~~~~~~~~
Each Document instance is represented by a JSON document, which in turn is stored in a document db (CouchDB). 
The process of editing a Document 
involves retrieving the Document, and Form from CouchDB, then rendering the Document through the Form and updating changes
to the Document instance on the browser, and finally sending the edited Document back to stored in CouchDB.

Forms
~~~~~
Each Form is split into Sections. A Sections generally fits on a page, has a heading and the various form elements such 
as text boxes, date pickers and so forth. 

One way to think of the Forms is this diagram, which shows Sections layed out in 2D physical space:

    +---------------------+
    | Section 1           |
    |                     |
    |                     |
    |                     |
    |                     |
    |                     |
    |                     |
    +---------------------+----------------------+
    | Section 2           | Section 3 - Child <n>|
    |                     |                      |
    | Children            |                      |
    | o Child 1           |                      |
    | o Child 2           |                      |
    |                     |                      |
    |                     |                      |
    +---------------------+----------------------+
    | Section 4           |
    |                     |
    |                     |
    |                     |
    |                     |
    |                     |
    |                     |
    +---------------------+


The user sees one Section at a time, and can navigate up or down to the next/prev Section.

When navigating between the Sections the system animates the movements so as to give the
user a real sense of the physical structure of what they are editing.

In this example Section 2 renders a list of child entities.  When clicking on an element in the list, the system
will display Section 3, with the data for the particular Child being edited.

That list might have an 'Add' button which would dynamically add another child to the list, and also a mechanism for
deleting a child from the list.

When viewing a child in Section 3, the user can navigate left to return to the list of Children.  


Modules
~~~~~~~
The system is modular with independent modules being responsible for different parts of the system

.Modules
[width="60%",options="header"]
|==============================================
| Module          | Description
| schema          | Schema design
| form            | Form design
| compiler        | Compiles the form design, into a static representation that uses the runtime
| runtime         | Renders forms with their data, retrieving and saving data back to the datastore
| workflow        | Defines the steps that the information moves through
| comms           | Interface for external communications with users
|==============================================




[[schema_builder_module]]
Schema Designer Module
----------------------
The Schema design captures the type data that will be stored. The result is a <<df_schema>>  data structure.

Schemas capture the data elements, including the hierarchical structure. 

Data elements on the schema can be Lists or Basic data types.

Basic data types include:

. Integer
. Money
. Date
. Time
. String
. Text 

Lists are ordered collections of other data elements

Schemas are versioned. 

Forms are built based on a specific schema. 

See <<df_schema>

[[form_builder_module]]
Form Builder Module
-------------------

The builder provides the components to build forms interactively or using an API.

The result of building forms is a  <<df_form>> data structure


[[compiler_module]]
Compiler Module
---------------
Takes the <<df_form>> data as built in the <<form_builder_module>>, & turns it into a different 
representation such as HTML and javascript or static PDF 

[[runtime_module]]
Runtime Module
--------------
HTML as created by the <<compiler>> module uses the JavaScript runtime to maintain the data being edited on the HTML pages.
It knows how to update the HTML correctly as per the users intentions and save the data back to the server.

Process
~~~~~~~
The steps required to allow users to enter data on forms is as follows:

. Design the schema
. Build a Form
. Publish the Form
. Create a Document instance using the Form

If we break the steps down as follows:

[[design_the_schema]]
The user decides on the data elements to be captured, along with their
data types and so forth. The result is a <<df_schema>> document.

[[build_a_form]]
The user creates a form, from the data elements on a <<df_schema>> document. 
The result is a <<df_form>> document.

[[publish_the_form]]
Publish the form
At this stage the <<df_form>> is passed through the <<compiler>> module, and the compiled HTML pages 
stored.  Any errors during compilation will result in further form design being necessary.

[[create_doc_using_form]]
Create a Document instance using the Form.
The user selects from a list of published forms, choosing the one which fulfills their needs closest,
and is presented with an (initially) empty <<df_document>> which they edit through the HTML pages
created when the form was published.  


Part 3 - Detailed Design
========================

[[data_structures]]
Data Structures
---------------


[[df_document]]
df_document
~~~~~~~~~~~

df_document stores the document instance data, in JSON format. 
It is persisted to and from the permanent document store.

  {
    "_id": "1",
    "df_type": "document",
    "name": "Dave",
    "kids": "3",
    "comment": "Developer",
    "employees": [
      { "name": "Sue", "dob": "1970-01-01" },
      { "name": "Bob", "dob": "1972-12-24" },
    ]
  }

[[df_schema]]
df_schema
~~~~~~~~~

df_schema stores the data representation:

 {
  "_id": "schema1",
  "df_type", "schema"
  "version": "1",
	"fields": [ 
    	{ 
    	  "label": "Name",
    	  "id": "name",
    	  "type": "string"
    	},
    	{ 
    	  "label": "Num kids",
    	  "id": "kids",
    	  "type": "integer"
    	},
    	{ 
    	  "label": "Comment",
    	  "id": "comment",
    	  "type": "text"
    	},
    	{ 
    	  "label": "Employee List",
    	  "id": "employee_list",
    	  "type": "list",
    	  "fields": [
    	    {
    	      "label": "Name",
    	      "id": "name",
    	      "type": "string"
    	    },
    	    {
    	      "label": "Date of Birth",
    	      "id": "dob",
    	      "type": "date"
    	    }
    	  ]
    	}
    ]	
  }

It is persisted to and from the document store, and is used both in the process of designing forms
and also in reporting across the entire set of df_documents.  

When reporting, common data elements can be
identified across multiple schemas and then incorporated into reports. This provides flexibility when
designing the schemas for example two schemas could both have a field with id 'classification-code', in
schema 1 it might be at the root level of the schema and thus captured at 0..1 times, however in schema 2
it might be inside a 'list' of repeating fields, and therefore might be captured 0..N times. A report
over 'classification-code' wouldn't care if where it was stored, but would extract it in the appropriate way
for each document instance. 


[[df_form]]
df_form
~~~~~~~

df_form stores the presentation layout of the forms:

  {
  	"id": "form1",
    "df_type", "form"
  	"sections": [ 
  		{
  			"id": "section_1",
  			"heading": "Personal details",
  			"type": "form",
  			"fields":  [
  				{ "label": "Name", "json_path": "$.name", "type": "string" },
  		        { "label": "Num kids", "json_path": "$.kids",  "type": "integer" },				 		
  		        { "label": "Comment", "json_path": "$.comment",  "type": "text" }				 		
  			],
  			"section_navigation": { "down": "section_2" }
  		},
  		{
  			"id": "section_2",
  			"heading": "Employee List",
  			"type": "list",
  			"index":"employees_index",
  			"json_path": "$.employees",
  			"child_section_id": "section_3",
  			"columns":  [
  				{ "label": "Name", "json_path": "name", "type": "string" },
  		        { "label": "Date of birth", "json_path": "dob",  "type": "date" }
  			],
  			"section_navigation": { "up" : "section_1" }
  		},
  		{
  			"id": "section_3",
  			"heading": "Employee",
  			"type": "form",
  			"fields":  [
  		    	{ "json_path": "$.employees[employees_index].name", "type": "string" },
  		        { "json_path": "$.employees[employees_index].dob", "type": "date" }
  			],
  			"section_navigation": { "left": "section_2" }
  		}
  	] 
  }

When the page is rendered the user is presented with a rendering of the initial section.
Each section renders data within the document at a specific position, gathering all of its data
from the information at that point.

The df_document stores information in a containment hierarchy, so the 'root' document contains
fields 'name', 'kids', 'comment' and a list of 'employees'.  Each employee is contained within a specific position
within the employees list, ie: employee[0] is Sue, and employee[1] is Bob.

Each section knows the 'path' to its data, but in the case of rendering data that can be one of
many from an array (eg: a specific employee), it uses the index_cache.  When navigating into a collection, 
the system records in the index_cache the index that is currently being views for each collection 

  index_cache {
    "employee_index": "2"
  }

Whenever a section is rendered, and the data (or its parents) comes from a collection, the system
recolves the collection indices using the index_cache, thus 'employees[employee_index].name' becomes
'employees[2].name'

Each section knows about its surrounding sections, for displaying navigation controls.

[[workflow_module]]
Workflow Module
---------------
Used to define the steps that the form data travels through, etc 



Part 3 - Samples
================

Introduction
------------

The samples serve to prove the concepts behind df3 will work. They are not a part of the system, but 
serve as background material

[[sample]]
Sample
~~~~~~

This directory contains a hand crafted HTML + Javascript sample that allows the user to edit a df_document
in place.

It validates the use of runtime templates being used to edit a df_document maintained in a single
HTML file.  As the user navigates to different sections, the form is updated to on the fly
with a template that represents that particular section.  The data form the df_document is bound to the 
form & then any changes are reflected back in the df_document instance.

Uses js templating library shotenjin.js from http://kuwata-lab.com/

Work is complete on this sample, and it confirms the approach in <<create_doc_using_form>>

[[sample2]]
Sample2
~~~~~~~
This directory contains an example that seeks to validate the process of generating HTML and javascript
templates for a specific df_form

Executing the shell scripts will generate the equivalent hand crafted portions of <<sample>>, 
using the tenjin templating library from http://kuwata-lab.com/

This proves that the approch used to <<publish_the_form>> will work.

Two stages of templating occur:

. Compiling the <<df_form>> structure to HTML - uses rbtenjin on the server
. At runtime combining the templates generated with df_data - uses jstenjin in the browser 

A new data structure is employed in this prototype.

Each form represents a section, and each field is bound to the underlying data to be displayed
in that field by attaching a JSONPath to that field eg:

  <input df_jsonpath="$.name" type="text">
  
At runtime the df_jsonpath attribute is extracted, and resolved against the df_data document
to retrieve the approriate data value and place that value into the <input>.

Some forms represent lists of values within the df_data document. When the user selects a particular
value from the list, this will set a value in the df_index hash eg: If the user selected was presented
with a list of children:

  Tom
  Jack
  
and the user selected 'Tom' then the df_index hash will be populated as follows:

  df_index {
    "child_index" : 0
  }  
  
When the user navigates to the 'child' form, the form template is constructed as follows:

  <input df_jsonpath="$.children[child_index].name" type="text">

child_index is replaced with the value in the df_index['child_index'], in this case 0, so will resolve
to the correctly selected childs name eg: 'Tom'

This sample also adds the ability to manipulate lists better.  When the section inside a df_form
has a type of "list", then the contents are rendered as an HTML table with a button to "Add" a new
row. When the button is clicked a new row is added to the array of data as identified in the "json_path"
and the user is taken to the child form, bound to the data in the new row. Note that there is no need to 
fill the new row with default data.

No validation occurs in this sample  

Work is complete on this sample and the work appears in the sample2 directory.  To build the samples
run sample2/bin/compile.sh and open the output/df_form1.html files in your browser

[[sample3]]
Sample3
~~~~~~~
The purpose of this sample is to explore the design and implementation of a REST api to be used by clients.

The following API is implemented by the server:

Note that the 'Type' column refers to the concept as described in "The REST API design Book, Mark Masse"

.sample3 URLs
[width="60%",options="header"]
|=================================================================
| URL                             | Type    | Description
| http:/host/documents         |Collection | List of all documents
| http:/host/documents/1       |Document | Access an individual document
| http:/host/documents/delete-all  |Controller | Delete all documents
|=================================================================

The client from sample 2 is enhanced to interact with the server, initially to get the list of documents,
and then to retrieve a specific document instance, edit it and save.

The server component is built using 'Zappa', the coffescript wrapper around 'Express' for node.js.
The server returns the same data in different formats based on the contents of the HTTP Header
value 'Content-Type'

--------------------------------------------------
Source
 /server                  - server components
    /node_modules         - node modules 
       /connect
       /express
       /jasmine-node
       /underscore
       /zappa
    /public               - static files served form here
--------------------------------------------------

Execution
^^^^^^^^^
The process that occurs is as follows:
Note that 'sample3' is the name of the CouchDB database

|=================================================================
| Browser|Node|CouchDB
| open http://localhost:3000/index.html |Render & return template for document_list page | 
|onDOMReady||
||get /documents|
|||get /sample3/_design/documents/_view/all
|||Returns a list of document <uuids>
|replace contents of <div> with list ||
|||
|click 'add' a new document||
||post /documents (no data)|
||inject an empty document into df_form.html as df_document|
|edit and click save||
||post /documents (with data)|
|||post /sample3/documents
|||returns new document <uuid>
|||get /sample3/<uuid>
||inject document data into df_form1.html as df_document|
|||
|click link to 'edit' a document ||
||get /documents/<uuid>|
|||get /sample3/<uuid>
||inject document data into df_form1.html as df_document|
|edit and click save||
||put /documents/<uuid>|
|||put /sample3/<uuid>
|=================================================================

The work on this sample has been abandoned while a re-think of the fundamental ideas behind the system occurs.


Installation
^^^^^^^^^^^^
- Install coffescript
- Install rbtenjin
- Install node
- Install npm
- cd sample3/server

Execution
^^^^^^^^^
. Start couchdb
  .. as per http://couchdb.apache.org/
. Setup db
  .. bin/migrate
. Run the app server
  .. bin/run-server


[[sample4]]
Sample4
~~~~~~~
The purpose of this sample is to explore the design and implementation of a design that uses the concept
of progressive enhancement. The idea being that making the system with the following layers:

- HTML - content
- CSS - presentation
- JavaScript - client side scripting

But being able to have the site work with just HTML, or HTML and CSS will help to:

- Keep the content, presentation and scripting separate 
- Enable search engine traversal
- Enhance accessibility on a wider range of devices and to screen readers etc
- Ease scripted testing

Approach
^^^^^^^^

Client requests will be page based, so when the user traverses from the a list of items, into
a specific instance, that will require a new request

The information presented to the user is in the form of the following combination of information

  +------+              +-----+           +--------+        +----------+
  | User |              | URL |           | Schema |        | Document |
  +------+              +-----+           +--------+        +----------|


  +------+
  | Role |
  +------+

Class User
++++++++++

* Represents a User that can login to the system
* Responsibilities
** Maintaining the set of Roles for a user
* Collaborations
** Session
** Schema - to expose the data that the user can see via their Roles

Class Role
++++++++++

* Represents a logical role within the system
* Responsibilities
** Each role identifier is unique
** Roles have specific business meanings
* Collaborations
** Users have Roles
** Schemas expose data items to Roles

Class URL
+++++++++

* Represents the URL used to access the system
* Responsibilities
** Specify the document identifier
** Specify the path within the document
* Collaborations
** Schema - define valid paths in Documents
** Documents - exist in DocumentStore, and have Schemas

Class Document
++++++++++++++

* Container for the end user data
* Responsibilities
** Contain the end user data
** Specify the unit of editing/locking
** Have a Schema
* Collaborations
** Schema - define the specification for the Data in a Document

Class Schema
++++++++++++

* Defines the specification for common Documents
* Responsibilities
** Defines data items, collections and heirarcies
** Define access to data items based on Roles
* Collaborations
** Documents - Collections of Documents belong to a Schema



[appendix]
Part 4 - Appendix
=================

[[issues]]
Issues
------
- In the samples, it was obvious that the runtime generation of templates was very slow.
  Can potentially speed up the generation of templates at runtime by pre-compiling them & storing the
  precompiled form either on the browser or server.


[glossary]
Glossary
--------

Workflow::
  TODO



[index]
Index
-----
