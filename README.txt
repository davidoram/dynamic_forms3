Dynamic_forms3
==============
David Oram
v1.0, 2011-09
:doctype: book


[preface]
Preface
-------
The design of dynamic_forms3 (df3)  has been preceded by the authors thought into the attendant problems of
designing, implementing maintaining and enhancing procurement systems, along with the considerable
influence of colleagues at the MSI.


Approach
--------

df3 takes the approach of separating the tasks of designing a form processing system, which provides forms
that provide a means to capture data into documents.  Documents can be pushed through a workflow
which supports a business process.

The initial design does not concern itself with anything beyond these requirements, but that having been said,
the system has been created with the aim of solving problems in the 'procurement' business domain. 


Modules
~~~~~~~
The system is modular with independent modules being responsible for different parts of the system

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

Data Structures
~~~~~~~~~~~~~~~

df_document stores the document instance data, in JSON format. 
It is persisted to and from the permanent document store.

  df_document = {
    _id: 1,
    name: 'Dave',
    dob: '1969-10-22',
    employees: [
      { name: 'Sue', dob: '1970-01-01' },
      { name: 'Bob', dob: '1972-11-03' }
    ]
  }

df_form stores the presentation layout of the forms:

  df_form {
    sections[
      {
        heading: 'Personal details',
        fields: [
          { field: 'name', type: 'string' },
          { field: 'dob', type: 'date'},
        ]
      },
      {
        heading: 'Employee List',
        fields: [
          { field: 'employees[]', type: 'list' },
        ]
      }
      {
        heading: 'Employee',
        fields: [
          { field: 'employees[].name', type: 'string' },
          { field: 'employees[].dob', type: 'date'},
        ]
      }
    ]
  }


When the page is rendered the user is presented with a rendering of the initial section.
Each section renders data within the document at a specific position, gathering all of its data
from the information at that point.

The df_document stores information in a containment hierarchy, so the 'root' document contains
fields 'name', 'dob' and a list of 'employees'.  Each employee is contained within a specific position
within the employees list, ie: employee[0] is Sue, and employee[1] is Bob.

When rendering any section the system keeps track of where it is within the hierarchy of the df_document
so that the page knows where to get its data from.  A stack of pointers into the df_document is
maintained in the variable df_document_ptr_stack. The df_document_ptr_stack is initialised with a pointer to the
df_document (root), and if the user navigates to a section that represents a child record, then a
pointer to that specific data item eg: employee[1], is pushed on the df_document_ptr_stack.

Whenever a section is rendered, it is passed the top value in the df_document_ptr_stack as its data context, 
that it uses to retrieves its data from.  

The page renderer also evaluates the df_document_ptr stack, and will display a navigation button
( <- ) to return the user from a child record, to the section that displays the list of child records.

The section displaying the list of child records participates, by pushing the correct data context onto
the df_document_ptr_stack when the user navigates to a child record.

  df_document_ptr_stack = [
    
  ]

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
