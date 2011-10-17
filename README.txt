Dynamic_forms3
==============
David Oram
v1.0, 2011-09
:doctype: book


[preface]
Preface
-------
The design of dynamic_forms3  has been preceeded by 3 years of thought into the attendent problems of
designing, implementing maintaining and enhancing procurement systems.


Approach
--------

DF3 takes the approach of separating the tasks of designing a procurement process from, publishing that process, and 
subsequently allowing users to submit proposals for assessment, decisions being made.

It does not concern itself with anything beyond the decision point, that is; any contracting or further work. 


Modules
~~~~~~~
The system is modular with independent modules being reposnsible for different parts of the system

.Modules
[width="60%",options="header"]
|==============================================
| Module          | Description
| builder         | Form design
| compiler        | Compiles the form design, into a static representation that uses the runtime
| runtime         | Renders forms with their data, retrieving and saving data back to the datastore
| workflow        | Defines the steps that the information moves through
| comms           | Interface for external communications with users
|==============================================


[[builder_module]]
Builder Module
--------------
The builder provides the components to build forms interactively or using an API.

Data Structures
~~~~~~~~~~~~~~~
The data is optimised as to what is required to create pages, and configure the <<runtime_module>>.
The essence is the data structures, data types, and containment relationships.

////////////////////////////////////////////////////////////////
  form {
    id: 1,
    data: [
      { field: 'name', type: 'string'},
      { field: 'dob', type: 'date'},
    ]
  }
////////////////////////////////////////////////////////////////


[[compiler_module]]
Compiler Module
---------------
Takes the form as built in the builder module & turns it into a different representation such as HTML and javascript 
or static PDF 

[[runtime_module]]
Runtime Module
--------------
HTML as created by the <<compiler>> module uses the JavaScript runtime to maintain the data being edited on the HTML pages.
It knows how to update the HTML correctly as per the users intentions and save the data back to the server.

Each procurement round has a number of Forms for capturing the data required at different stages.  Each Form is split 
into Sections. Sections have a heading and the various form elements such as text boxes, date pickers and so forth 
on them. 

The system presents the forms as a 2D layout with a viewport that allows the user to see a Section at a time, and
navigate up or down to previous/next section and also right or left to dive into or out of collections of child data. 

    +---------------------+
    | Section 1           |
    |                     |
    |                     |
    |                     |
    |                     |
    |                     |
    |                     |
    +---------------------+----------------------+
    | Section 2           | Child 1              |
    |                     |                      |
    | Children            |                      |
    | o Child 1           |                      |
    |                     |                      |
    |                     |                      |
    |                     |                      |
    +---------------------+----------------------+
    | Section 3           |
    |                     |
    |                     |
    |                     |
    |                     |
    |                     |
    |                     |
    +---------------------+

What the user sees is a View into this through what we call the ViewPort, which allows them to see 1 of these  
Sections at a time.  When navigating between the Sections the system animates the movements so as to give the
user a real sense of the physical structure of what they are editing.

In this example Child 1 represents a child record that is 'owned' by  the list displayed in Section 2. That list
might have an 'Add' button which would dynamically add Child 2 to the right of Child 1.  Similarly deleting a 
Child would remove it.  



[[workflow_module]]
Workflow Module
---------------
Used to define the steps that the form data travels through, etc 



[glossary]
Glossary
--------

Workflow::
  TODO



[index]
Index
-----
