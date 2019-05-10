---
title: Database ERD Design
---

# Database ERD Design

> NOTE: this page is work-in-progress and is subject to change frequently

This page contains details about the database tables that would be a part of the CRUDE-NET project.

In this page:

- [True Show of Strength](#true-show-of-strength)
- [crude.Configuration](#crudeconfiguration)
- [crude.DataSource](#crudedatasource)
- [crude.DataView](#crudedataview)
- [crude.DataViewPanel](#crudedataviewpanel)
- [crude.DataViewField](#crudedataviewfield)
- [crude.DataViewQueryGroup](#crudedataviewquerygroup)
- [crude.DataViewQuery](#crudedataviewquery)
- [crude.DataViewAction](#crudedataviewaction)
- [crude.DataViewActionParameter](#crudedataviewactionparameter)
- [crude.DataViewChart](#crudedataviewchart)
- [crude.Comment](#crudecomment)
- [crude.User](#crudeuser)
- [crude.Role](#cruderole)
- [crude.PermissionSegment](#crudepermissionsegment)
- [crude.UserRoles](#crudeuserroles)
- [crude.RolePermissions](#cruderolepermissions)
- [crude.AuthProvider](#crudeauthprovider)
- [crude.CustomPage](#crudecustompage)
- [crude.NavSection](#crudenavsection)
- [crude.Navigation](#crudenavigation)
- [crude.FilterOperator](#crudefilteroperator)
- [crude.FieldType](#crudefieldtype)

## True Show of Strength

The CRUDE-NET platform is very extensive and contains many database tables needed for its implementation and management.
However, a true show of strength of the CRUDE platform, would be to implement the management of these tables using the very platform they're used for implementing.

In other words: Use the CRUD generator platform to manage the CRUD generator platform.

If all functionality needed for the management of these tables can be implemented using the CRUDE platform itself, that would, indeed, be a True Show of Strength of the CRUDE platform, right off the shelf.

/(only exception, possibly, would be the management of the navigation menu items, which would be managed using an editable treeview control)/

Also, leveraging the crud generator abilities for the administrative sections should tremendously reduce development time and effort, since we won't need to hard-code these sections ourselves.

## crude.Configuration

Controls various site settings.

Each setting would have its own column in this table. Please see [Site Settings](Site-Settings) for list of settings.

Exact structure and implementation of this table is TBD

## crude.DataSource

The data source would be the equivalent of a connection string, defining the source server, authentication and default database. However, this table won't contain the connection string itself.
This table could be managed dynamically, but the actual use of it would be by correlating the data from it with a secured configuration file (i.e appSettings.json or web.config or something equivalent). This is so that we won't save secure connection strings inside the database.

In other words, this table would contain identifiers that the controller layer would know to look for in a secure configuration file, to find the actual connection string.

|Column Name|Data Type|Description|
|---|---|----|
| `DataSourceId` |Auto Increment|Primary Key|
| `Label` |String|Textual title or friendly name for the data source|
| `ConnStringName` |String|The connection string identifier as it is written in the secured configuration file.|
| `SourceType` |Enum|Determines what kind of data source this is. Would be used for determining the data layer class library to be used. Possible values:
|||   - Microsoft SQL Server
|||   - Oracle database
|||   - MySQL
|||   - PostgreSQL
|||   - Access database
|||   - More TBD|

More fields are TBD.

## crude.DataView

Equivalent of Evolutility's `form` element.

Each record in this table represents a single data model, with a single underlying database source (either a table/view or a stored procedure).

|Column Name|Data Type|Description|
|---|---|----|
| `ViewId` |Auto Increment|Primary Key|
| `Published` |Boolean|Determines whether this dataview is accessible to end users (otherwise it's only accessible to admins)|
| `PermissionSegmentId` |Foreign Key|References [crude.PermissionSegment](#crudePermissionSegment)|
| `SlugName` |String(100)|A unique name to be used as a route (slug) to this module. Must be small case in English, without spaces or special characters. Will be used in routing, simplifying URLs. For example: "http://myportaladdress/customers" would be a URL for a data view with "customers" as slug name.|
| `Title` |String(100)|Used as page title|
| `Description` |String(max)|Rich free-text displayed on the main component page|
| `Entity` |String(100)|User's object name for the database object. For example: "contact". Default value: "item"|
| `Entities` |String(100)|Plural for entity. Default value: "items"|
| `DataSourceId` |Foreign key|References crude.DataSource. Would be used for getting the connection string identifier name as configured in appSettings.json or web.config's list of connection strings|
| `DBTable` |String(300)|Name of driving table for the component|
| `DBPKColumn` |String(255)|Name of the primary key column used as record identifier|
| `DBUserColumn` |String(255)|In multiple-users environment, specify the column name of the “author column” designating the specific user author of the record. Default is NULL which means the feature is disabled for this component|
| `DBOrderBy` |String(1000)|List of column names to include in the default "order by" SQL clause|
| `DBWhere` |String(4000)|SQL where clause to limit the dataset manipulated, must use the alias "T" for the driving table. Example: "T.Deleted <> 1 AND T.DateAdded > GETDATE()-360" |
| `SPSource` |String(300)|Name of the stored procedure for paging search results. Replaces `DBTable` as source. Expected parameters: @SQLdeclare, @SQLwhere, @SQLorderby, @PageSize, @PageNumber, @UserId|
| `SPGetOne` |String(300)|Name of stored procedure for retrieving details of a single record. Expected parameters: @ItemID, @UserID.
| `SPDelete` |String(300)|Name of the stored procedure for deleting records. Expected parameters: @ItemID, @UserId.|
| `SPModify` |String(300)|Name of the stored procedure for updating or inserting records. Expected parameters: @ItemID (null if inserting), @UserID, @Field1, @Field2, etc... (one parameter per each editable field, ordered).|
| `LOVValueField` |String|If this field is set, it enables this dataview to be used as a list of values. This determines the database column name that should be used as the value.|
| `LOVTitleField` |String|Determines the database column that should be used as the label in a list of values. If not set, the value field will be used instead.|
| `LOVGroupField` |String|Determines the database column that should be used as the group label in a list of values. If not set, items won't be grouped.|
| `LOVGlyphField` |String| Determines the database column that should be used for the glyph icon in a list of values (where supported). If not set, glyph icons won't be used.|
| `LOVIsDefaultField` |String|Determines the database column (must be of a Boolean type), which would be used in a list of values to determine which item(s) should be selected by default. If not set, no default items would be set.|
| `LOVTooltipField` |String|Determines the database column to be used as a tooltip in a list of values. If not specified, no tooltips would be used.|
| `LOVDefaultListType` |Enum|Determines the type of list that would be used, if not overridden explicitly. Possible values:
|||    - Dropdown list (default, normal Dropdown combo box)
|||    - Radio buttons
|||    - Checkboxes
|||    - Buttons
|||    - Select2 control
|||    - Switches
| `DTDefaultPageSize` |Int|Sets the default number of records per page. Ignored if pagination is disabled.|
| `DTPagingStyle` |Enum|Sets how pagination buttons would look like. Ignored if pagination is disabled ([more info](https://datatables.net/reference/option/pagingType)). Possible values:
|||  - First, Previous, Next and Last buttons, plus page numbers
|||  - Previous and Next buttons, plus page numbers
|||  - Previous and Next buttons only
|||  - Page number buttons only
|||  - First, Previous, Next and Last buttons
|||  - First and Last buttons, plus page numbers
| `DTActionButtonStyle` |Enum|Sets how the action buttons of the component would look like. Possible values:
|||  - Icon and Text
|||  - Icon Only
|||  - Text Only
| `Flags` |Int|A bitwise multi-value field for various component toggles. Possible values:
|||  - Allow Edit
|||  - Allow Add
|||  - Allow Delete
|||  - Allow Clone
|||  - Enable Items List (datatable)
| `DTFlags` |Int|A bitwise multi-value field for various toggles for the datatable. Possible values:
|||  - Enable Column Search (advanced search)
|||  - Enable Quick-Search (toggles whether to allow quick free-text search on the table)
|||  - Show Info (toggles an info bar indicating how many rows out of what total are currently being showed) ([more info](https://datatables.net/reference/option/info))
|||  - Column Footers (toggles whether to show column headers at the bottom of the table as well)
|||  - Sortable Columns (toggles whether to allow users to dynamically sort columns) ([more info](https://datatables.net/reference/option/ordering))
|||  - Pagination (toggles whether to split records into pages based on page size) ([more info](https://datatables.net/reference/option/paging)). If this toggle is turned off, datatable scroller will be used instead ([more info](https://datatables.net/extensions/scroller)).
|||  - Page Size Selection	([more info](https://datatables.net/reference/option/lengthChange))
|||  - Client-Side State Save ([more info](https://datatables.net/examples/basic_init/state_save.html))
|||  - Show "Copy to Clipboard" button ([more info](https://datatables.net/reference/button/copy))
|||  - Show "Export to CSV" button ([more info](https://datatables.net/reference/button/csv))
|||  - Show "Export to Excel" button ([more info](https://datatables.net/reference/button/excel))
|||  - Show "Export to PDF" button ([more info](https://datatables.net/reference/button/pdf))
|||  - Show "Print" button ([more info](https://datatables.net/reference/button/print))
|||  - Show "Columns Toggle" button ([more info](https://datatables.net/reference/button/columnsToggle))
|||  - Enable Row Details ([more info](https://datatables.net/examples/server_side/row_details.html))
|||  - Enable Row Selection (allows bulk actions on selected rows) ([more info](https://datatables.net/extensions/select))
|||  - Enable Fixed Headers ([more info](https://datatables.net/extensions/fixedheader/))
| `ViewTemplate` |String|This will determine the HTML template to be used for rendering this dataview. TBD whether this would be a foreign key to another table, or a string path to a template file.|
| `DBDTRowClassColumn` |String (255)|Optional database column (SQL name) containing the CSS class name to be used as DT_RowClass which automatically sets the class of the TR element. Example value: "table-success".|

## crude.DataViewPanel

Equivalent of Evolutility's `panel` , `tab` and `panel-details` elements.

Panels are used to visually group fields on the screen (in edit and view modes).

Panels can also contain sub-groups of panels (for example, a panel can contain tabs, which in turn can contain more panels etc.).

Alternatively, panels can be configured as "Grid Panels" (equivalent of Evolutility's `panel-details` element).

Grid Panels allow for nested sub-entities within the driving entities. In other words, it allows for hierarchical data and adds the feature of master-details. The sub-entity (or detail) can be edited within the page as a grid, or by linking to another page using the sub-entity as its driving entity.

The screenshot below shows an order. The master is composed of 3 panels, one panel-details and another panel for the total.

![](http://www.evolutility.org/doc/pix/ui/panel-details.gif)

Grid Panels cannot contain fields or sub-panels.

|Column Name|Data Type|Description|
|---|---|----|
| `PanelID` |Auto Increment|Primary Key|
| `ParentPanelID` |Foreign Key|Optional recursive parent. References [crude.DataViewPanel](#crudeDataViewPanel)|
| `PanelGroupContainerType` |Enum|Sets the display type of this panel's sub-panels, determining how they would look like ([more info about Bootstrap Navs](https://getbootstrap.com/docs/4.3/components/navs/)). Possible values:
|||  - Panels (i.e. Cards)
|||  - Tabs
|||  - Pills
|||  - Nav Links
|||  - Vertical Tabs
|||  - Vertical Pills
|||  - Vertical Nav Links
|||  - Accordion
|||  - Wizard Steps
| `PermissionSegmentID` |Foreign Key|References [crude.PermissionSegment](#crudePermissionSegment). Default: NULL (inherit from Panel Group).|
| `Label` |String(100)|The panel's title to be displayed to users|
| `Glyph` |String(100)|CSS class name to be used as a glyph icon (optional). Example: "fas fa-address-card".|
| `Logo` |String(255)|An optional image file to be used as the panel's "logo" (similar to Glyph).|
| `Description` |String(max)|A rich-text description to be displayed at the top of the panel|
| `PanelOrder` |Int|A number representing the order in which the panel should be displayed|
| `Width` |Int|A number between 1 and 100, representing in percents how much space the panel would take horizontally|
| `GridViewID` |Foreign Key|If panel is configured as a grid panel: References [crude.DataView](#crudeDataView). Used for configuring the DB table source and fields.|
| `DBFKColumn` |String(255)|If panel is configured as a grid panel: Sets the database column name in the child data view which would serve as a foreign key to the master data view's primary key column. This column would be automatically filtered while displaying the grid, and it would automatically be filled when adding new records in the grid.|
| `Flags` |Int|A bitwise multi-value field for various toggles. Possible options:
|||  - Optional (whether to skip the panel from displaying, if every field contained within it is empty and optional. In View mode only).
|||  - Collapsible (whether to allow users to collapse/expand this panel)
|||  - Closed By Default (if this panel is collapsible, enabling this will make it collapsed by default)
|||  - Grid Panel (whether this panel is to be used as a grid displaying data from another dataview (utilizing the `GridViewID` and `DBFKColumn` fields). *Note: Grid panels cannot contain fields within them*.|
| `CSSPanel` |String|CSS class for the panel element. Default is '' (using base element styling)|

## crude.DataViewField

Equivalent of Evolutility's `field` element.

The data view fields represent fields on the screen, and database columns at once. It is the most used element and the element with the most attributes. Database columns hidden to the user (like the primary key of the driving table) are not declared.

|Column Name|Data Type|Description|
|---|---|----|
| `FieldID` |Auto Increment|Primary Key|
| `PanelID` |Foreign Key|References [crude.DataViewPanel](#crudeDataViewPanel)|
| `FieldLabel` |String(100)|The field title visible to users|
| `FieldIdentifier` |String (100)|Short text to use as a unique identifier for this field within the dataview. This identifier will be used when replacing placeholders in various expressions. For example: If "MyField" is specified as the identifier, then you can use `{{row[MyField]}}` as a placeholder for it in other fields. If not specified, it would default to "Field_x" where x would be the FieldId. For example: "Field_123", and then `{{row[Field_123]}}` would be the placeholder. [more info about expression placeholders](Expression-Placeholders)|
| `Glyph` |String(100)|CSS class name to be used as a glyph icon to prepend to the field (optional). Example: "fas fa-at".|
| `Help` |String(4000)|Help text to be displayed under the field while editing. Can be formatted rich text.|
| `Tooltip` |String(1000)|Tooltip text to be displayed when hovering over the field while viewing|
| `Placeholder` |String(1000)|Expression to be used as placeholder while editing this field|
| `FieldOrder` |Int|Number representing the sort order in which this field will be displayed.|
| `FieldType` |Enum|The type of the field as described in more details in [field types](Field-Types). Possible values:
|||  - boolean (yes/no)
|||  - integer
|||  - decimal
|||  - text
|||  - textarea
|||  - date
|||  - datetime
|||  - time
|||  - email
|||  - phone
|||  - password
|||  - formula (computed SQL formula, must be read-only)
|||  - html (Rich Text Format)
|||  - image (Path to file)
|||  - document (Path to file)
|||  - lookup (single value from a list of values)
|||  - list of values (multi value comma separated)
|||  - url
| `DefaultValue` |String(max)|Default value for the field displayed while creating a new record|
| `Format` |String(100)|Format pattern regular expression.|
| `MaxLength` |Int|Maximum number of characters allowed for the field (relevant to most field types)|
| `Height` |Int|Height property for certain field types: `textarea`, `html`, `image` and multi-selection dropdown|
| `Width` |Int|Width of the field in percentage of the Panel it belongs to.|
| `Flags` |Int|A bitwise multi-value field used for setting various toggles. Possible options:
|||  - Required
|||  - Read Only
|||  - Show in Form
|||  - Show in Items List
|||  - Show in View
|||  - Show in Data Table Details Row (if enabled)
|||  - Allow in Quick Search
|||  - Allow in Advanced Search
|||  - Sortable
| `URLPath` |String(4000)|Expression to be used as URL path. Turns the field text into a clickable link. The expression can contain field placeholders. For example: `{{row[Field_3]}}` or `{{this}}` (the placeholder `{{this}}` is a special placeholder which will be replaced by the data value of the current field, i.e `DBColumn` ).|
| `CSSViewLabel` |String|CSS class for this field's label element while viewing a single item. Default: "" (base styling of text)|
| `CSSEditLabel` |String|CSS class for this field's label element while editing or adding a single item. Default: "" (base styling of label element)|
| `CSSCell` |String|CSS class for how the field would look like in the data table (TBD: using either a span or div tag). Default value: "" which means base text styling, and in case of `url` field types default is: "btn btn-link".|
| `CSSColumnHeader` |String|CSS class for this field's column header element in the data table. Default: "" (base styling of th element)|
| `DBColumn` |String(255)|Database source column (SQL name) for the field|
| `DBColumnImage` |String(255)|Optional database column (SQL name) containing the filename of the image to display for this field.|
| `DBColumnGlyph` |String(255)|Optional database column (SQL name) containing the CSS class name to use as a glyph for this field.|
| `DBDTCellClassColumn` |String (255)|Optional database column (SQL name) containing the CSS class name which sets the class of the cell in the data table. Example values: "alert alert-danger", "text-success", "text-warning".|
| `LOVViewId` |Foreign key|References [crude.DataView](#crudedataview). To be used for displaying values for list of values field types (lookup and multi value)|
| `LOVType` |Enum|The display type of the list of values. Possible options:
|||    - Default (based on dataview default list of values type)
|||    - Dropdown combo box
|||    - Radio buttons
|||    - Checkboxes
|||    - Buttons
|||    - Switches
| `LOVIsMultiple` |Boolean|Determines whether single value or multi value|

## crude.DataViewQueryGroup

Equivalent of Evolutility's `queries` also know as "Selections"

It is possible to add canned queries as a "Selections" button on the toolbar.

Queries are also grouped into Query Groups.

|Column Name|Data Type|Description|
|---|---|----|
| `QueryGroupID` |Auto Increment|Primary Key|
| `ViewID` |Foreign Key|References [crude.DataView](#crudeDataView)|
| `Label` |String(255)|Group title|
| `Glyph` |String(100)|CSS class name to be used as a glyph icon (optional). Example: "fas fa-archive".|
| `Description` |String(max)|Introduction rich-text displayed above the list of queries.|
| `GroupOrder` |Int|Number determining the order in which the query group will be displayed within the list of groups (if there's more than one).|

## crude.DataViewQuery

Equivalent of Evolutility's `query` used within "Selections".

|Column Name|Data Type|Description|
|---|---|----|
| `QueryID` |Auto Increment|Primary Key|
| `QueryGroupID` |Foreign Key|References [crude.DataViewQueryGroup](#crudeDataViewQueryGroup)|
| `Label` |String(255)|Query title|
| `Glyph` |String(100)|CSS class name to be used as a glyph icon (optional). Example: "fas fa-exclamation-circle".|
| `QueryOrder` |Int|Number determining the order in which the query will be displayed within the list.|
| `QueryIdentifier` |String(50)|Key used to identity each query within the list. Each key can be used in links within the page to force the control to display the corresponding query. Example: Assuming "sfo" is a QueryIdentifier you entered for one of the queries, a link to it would look like this: "<a href`"javascript:__doPostBack('evo1','q:sfo')">Restaurants in San Francisco</a>"|
| `DBWhere` |String(4000)|SQL Where clause for the query (will be appended to the regular query of the parent data view)|

## crude.DataViewAction

Each dataview can have, in addition to its data displayed, also a set of customizable "action buttons".

Action buttons could be placed either at the top of the page, and even be formatted as a hierarchical menu, or as contextual buttons per each row in the datatable (right next to the Edit/Clone/Delete buttons).

After activating an action, a modal will be displayed with the text string returned as response (except for http links which would simply open the URL).

|Column Name|Data Type|Description|
|---|---|----|
| `ActionID` |Auto Increment|Primary Key|
| `ViewID` |Foreign Key|References [crude.DataView](#crudeDataView)|
| `PermissionSegmentID` |Foreign Key|References [crude.PermissionSegment](#crudePermissionSegment). Default: NULL (inherit from DataView).|
| `IsPerRow` |Boolean|Determines whether this action button is per each row, or otherwise as a button on the toolbar.|
| `ParentActionID` |Foreign Key|References *crude.DataViewAction* (recursive)|
| `ActionType` |Enum|Determines the type of action. Possible values:
|||  - HTTP link
|||  - DB SQL Command
|||  - DB SQL Procedure
|||  - DataTable Javascript Function
| `Label` |String(100)|Text to be displayed as the button label|
| `Glyph` |String|CSS class name for this button's glyph icon (optional). Example: "fas fa-globe"|
| `Tooltip` |String(200)|Tooltip to be displayed when hovering over this action button|
| `Description` |String(max)|This is a rich-text to be displayed in the pop-up modal (relevant to parameterized)|
| `CSSButton` |String(100)|A CSS class name to be used as the `a` element's `class` attribute. Default: "btn btn-primary btn-sm"|
| `ActionOrder` |Int|Number determining the order in which the action button will be displayed.|
| `Flags` |Int|A bitwise multi-value field used for setting various toggles. Possible values:
|||  - Require Confirmation (determines whether to display confirmation modal before executing the action)
|||  - Open In New Window (relevant to HTTP links, determines whether to open in a new window)
| `ActionExpression` |String(4000)|Determines the behavior of this action.
|||  - If ActionType is HTTP Link, this expression will be used as URL path.
|||  - If ActionType is DB SQL Command, this expression will be used as the command to be executed.
|||  - If ActionType is DB SQL Procedure, this expression will be used as the stored procedure name to be executed.
|||  - If ActionType is DataTable Javascript Function, this expression will be used as the Javascript function body ([more info](https://datatables.net/extensions/buttons/custom))
| `CSSBtn` |String|CSS class name for the button element. Default: "btn btn-primary".|

## crude.DataViewActionParameter

Action parameters can be configured for all action types (HTTP Link, DB SQL Command, DB SQL Procedure, JavaScript function).
A modal dialog will be displayed for setting parameter values before execution, and/or use pre-configured "default" values.

Parameters for http links would be appended to the URL querystring. DB Commands and procedures would receive parameters as SQL parameters, and JavaScript functions would also receive these parameters accordingly.

|Column Name|Data Type|Description|
|---|---|----|
| `ActionParameterID` |Auto Increment|Primary Key|
| `ActionID` |Foreign Key|References [crude.DataViewAction](#crudeDataViewAction)|
| `ParamName` |String(255)|System name of the parameter.|
| `Label` |String(100)|The parameter label visible to users|
| `Glyph` |String(100)|CSS class name to be used as a glyph icon (optional). Example: "fas fa-credit-card".|
| `Help` |String(4000)|Help text to be displayed under the parameter. Can be formatted rich text.|
| `Tooltip` |String(1000)|Tooltip text to be displayed when hovering over the parameter|
| `Placeholder` |String(1000)|Expression to be used as placeholder|
| `ParamOrder` |Int|Number representing the order in which this parameter will be displayed.|
| `ParamType` |Enum|The type of the parameter as described in more details in [field types](Field-Types). Possible values:
|||  - boolean (yes/no)
|||  - integer
|||  - decimal
|||  - text
|||  - textarea
|||  - date
|||  - datetime
|||  - time
|||  - email
|||  - phone
|||  - password
|||  - html (Rich Text Format)
|||  - image (Path to file)
|||  - document (Path to file)
|||  - lookup (single value from a list of values)
|||  - list of values (multi value comma separated)
| `DefaultValue` |String(max)|Default value for the parameter|
| `Format` |String(100)|Format for parameters of type `boolean`, `date`, `datetime`, `time`, `decimal`, or `integer`. Examples: `"$'#,##0.00", "YYYY-MM-DD"`|
| `MaxLength` |Int|Maximum number of characters allowed for the parameter|
| `Height` |Int|Height property for certain parameter types: `textarea`, `html`, `image` and `multi-selection dropdown`|
| `Width` |Int|Width of the parameter, in percent (between 1 and 100)|
| `Flags` |Int|A bitwise multi-value field used for setting various toggles. Possible values:
|||  - Required
|||  - Read Only
|||  - Hidden
| `CSSLabel` |String|CSS class name for this parameter's label. Default: "" (base styling of label element)|
| `LOVViewId` |Foreign key|References [crude.DataView](#crudedataview). To be used for displaying values for list of values field types (lookup and multi value)|
| `LOVType` |Enum|The display type of the list of values. Possible options:
|||    - Default (based on dataview default list of values type)
|||    - Dropdown combo box
|||    - Radio buttons
|||    - Checkboxes
|||    - Buttons
|||    - Select2 control
|||    - Switches
| `LOVIsMultiple` |Boolean|Determines whether single value or multi value|

## crude.DataViewChart

Configures the set of charts that would be available for a data view.

Defines the type of chart (line, area, pie, bubble, bars, etc.) and the various dimensions as needed (x, y, z) mapped to database columns or expressions.

TBA

## crude.Comment

Equivalent of Evolutility's `EVOL_Comment`.

TBA

## crude.User

Used for authentication, registration and profiles.
Equivalent of evolutility's `EVOL_User`. Also comparable to aspnet_Users.

Passwords are saved as one-way hash values, with a salt randomly generated per each user/password.

|Column Name|Data Type|Description|
|---|---|----|
| `UserID` |Auto Increment|Primary Key|
| `Active` |Boolean|Whether the user account is enabled or not|
| `IsAdmin` |Boolean|Whether the user has master admin permissions|
| `Login` |String(50)|The username used during authentication|
| `HashSalt` |String(25)|A random character string uniquely generated per each user password. Used for adding complexity to the password hash|
| `PasswordHash` |Binary|A one-way hash result of the user's password, together with the `HashSalt` . i.e. HASH(Clear Text Password + HashSalt) ` PasswordHash |
| `Email` |String(100)|The user's email address, used for registration and password reset|
| `Phone` |String(20)|The user's phone number, might be used for 2-factor authentication (if implementation allows)|
| `Flags` |Int|A bitwise collection of various toggles for this user. Possible values TBD|
| `ProfileFields` |Json/XML|A dynamic collection of user profile fields, either in JSON or XML format. e.g. Address, City, Country, First and Last Name, Notes, etc.|

I'm not sure yet what's the best way to go about the extendable user's profile fields. Whether to save them in a single document column (JSON or XML), or as regular relational table columns.
Also, there may be more columns TBA.

## crude.Role

Various roles such as user, moderator, admin, and any other custom role.

Comparable to aspnet_Roles.

|Column Name|Data Type|Description|
|---|---|----|
| `RoleID` |Auto Increment|Primary Key|
| `Title` |String|Name for the role|
| `Glyph` |String(100)|CSS class name to be used as a glyph icon (optional). Example: "fas fa-user-cog".|
| `Description` |String|Description for the role|
| `Enabled` |Boolean|Sets whether this role is enabled or not. Can be used for toggling access of entire groups of users, based on their role.|

## crude.PermissionSegment

A logical group of site objects and sections (i.e. data views, navigation menus, etc.) to be used for setting permissions.

|Column Name|Data Type|Description|
|---|---|----|
| `PermissionSegmentID` |Auto Increment|Primary Key|
| `Title` |String|Name for the segment|
| `Description` |String|Description for the segment|
| `Enabled` |Boolean|Sets whether this segment is enabled or not. Can be used for shutting off entire sections of the portal.|

## crude.UserRoles

Mapping between users and roles. A user must be mapped to at least one role in order to have any sort of permissions.

|Column Name|Data Type|Description|
|---|---|----|
| `UserRoleID` |Auto Increment|Primary Key|
| `UserID` |Foreign Key|References [crude.User](#crudeUser)|
| `RoleID` |Foreign Key|References [crude.Role](#crudeRole)|

## crude.RolePermissions

Determines the permissions configured per each role, for each permission segment.

|Column Name|Data Type|Description|
|---|---|----|
| `PermissionID` |Auto increment|Primary key|
| `RoleID` |Foreign key|References [crude.Role](#crudeRole)|
| `SegmentID` |Foreign key|References [crude.PermissionSegment](#crudePermissionSegment)|
| `PublicGrantSet` |Int|A bitwise multi value used for toggling for which operations the role is granted permission *on all records* . Possible values:
|||  - View
|||  - Create
|||  - Read
|||  - Update
|||  - Delete
|||  - Execute
|||  - Charts
|||  - Queries
|||  - More (TBD)
| `PublicDenySet` |Int|A bitwise multi value used for toggling for which operations the role is denied permission *on all records* . Possible values:
|||  - View
|||  - Create
|||  - Read
|||  - Update
|||  - Delete
|||  - Execute
|||  - Charts
|||  - Queries
|||  - More (TBD)
| `PrivateGrantSet` |Int|A bitwise multi value used for toggling for which operations the role is granted permission *for records created by current user* . Possible values:
|||  - View
|||  - Create
|||  - Read
|||  - Update
|||  - Delete
|||  - Execute
|||  - Charts
|||  - Queries
|||  - More (TBD)
| `PrivateDenySet` |Int|A bitwise multi value used for toggling for which operations the role is denied permission *on records created by current user* . Possible values:
|||  - View
|||  - Create
|||  - Read
|||  - Update
|||  - Delete
|||  - Execute
|||  - Charts
|||  - Queries
|||  - More (TBD)

## crude.AuthProvider

A table holding settings of various SSO authentication service providers (i.e. OAuth and OAuth2), such as: Facebook, Google, Twitter, Office365, LinkedIn, Yammer, etc.

|Column Name|Data Type|Description|
|---|---|----|
| `ProviderID` |Auto Increment|Primary Key|
| `ProviderName` |String|Name of the service provider|
| `Enabled` |Boolean|Sets whether to allow users to login using this service provider|
| `LogoImage` |String|Path to service provider's logo image|
| `IconImage` |String|Path to service provider's icon image|
| `ClientID` |String|Site/Authentication Key or Client ID|
| `ClientSecret` |String|Secret Key or Client Secret|
| `RedirectURLSuccess` |String|Redirect URL to return page after successful login (optional, defaults to current page)|
| `RedirectURLFail` |String|Redirect URL to return page after failed login (optional)|
| `ResponseType` |Enum|Sets the "response_type" OAuth2 parameter. Possible values:
|||  - None (if using OAuth instead of OAuth2, for example)
|||  - Code
|||  - Token
| `Scope` |String|Sets the "scope" OAuth2 parameter. One or more scope values indicating which parts of the user's account we wish to access.|
| `Flags` |Int|Bitwise multi-value field for various toggles (possible options TBD, for future use)|

I'm not actually experienced with OAuth implementation so I don't know what other fields may be needed here.

## crude.CustomPage

Custom pages are rich text format pages used as non data bound web pages.

Theoretically, this entity may not be needed, if one was to create a data view without any data binding, instead only using the rich text format description of the data view.

|Column Name|Data Type|Description|
|---|---|----|
| `PageId` |Auto Increment|Primary Key|
| `PermissionSegmentID` |Foreign Key|References [crude.PermissionSegment](#crudePermissionSegment)|
| `Slug` |String|Unique string name to be used for routing. Must be unique across all pages as well as across all dataview controller names.|
| `Title` |String|Main heading to display at top of page|
| `Glyph` |String(100)|CSS class name to be used as a glyph icon (optional). Example: "fas fa-question-circle".|
| `Content` |String(max)|HTML Rich-text format contents for the page|
| `Published` |Boolean|Sets whether this page is visible to visitors, or is hidden as a draft.|
| `SEOTitle` |String|SEO meta title|
| `SEODescription` |String|SEO meta description|
| `SEOTags` |String|SEO meta tags|
| `SEOAuthor` |String|SEO meta author|

## crude.NavSection

A logical "super-group" of navigation items.

Each Navigation Section would be displayed as a top-navbar menu-item.

Clicking on a top-navbar menu item would open a page with the side-navbar menu changing its contents to fit the Navigation items belonging to the selected navigation section.

|Column Name|Data Type|Description|
|---|---|----|
| `SectionId` |Auto Increment|Primary Key|
| `PermissionSegmentId` |Foreign Key|References [crude.PermissionSegment](#crudePermissionSegment)|
| `Label` |String(100)|Label for the menu item to be displayed to visitors|
| `Glyph` |String(100)|CSS class name to be used as a glyph icon (optional). Example: "fas fa-question-circle".|
| `SectionOrder` |Int|Number used for determining this section's sort order in the top-navbar, if there's more than one section.|
| `DefaultPage` |String(200)|A URL to be used for this section, when clicking on the related top-navbar menu item.|

## crude.Navigation

Equivalent of CRUDE-ASP's `Navigation`.

Each navigation item would belong to a specific NavSection.

|Column Name|Data Type|Description|
|---|---|----|
| `NavID` |Auto Increment|Primary Key|
| `SectionID` |Foreign Key|References [crude.NavSection](#crudeNavSection)|
| `ParentNavId` |Foreign Key|References *crude.Navigation* (recursive)|
| `Label` |String(100)|Item text to be displayed to users|
| `NavOrder` |Int|Number determining the sorting order of the menu items|
| `Glyph` |String|CSS class name used as a glyph icon for this menu item. Example: "fa fa-folder"|
| `Tooltip` |String(100)|Text to be shown as tooltip when hovering over this menu item|
| `NavUri` |String(1000)|A specific URL to be opened by clicking this menu item. If points to a local page in the portal, that would be automatically detected and the menu item would be highlighted when its corresponding page is opened.|
| `ViewID` |Foreign Key|References [crude.DataView](#crudeDataView). If set, will open the specific data view.|
| `PageID` |Foreign Key|References [crude.CustomPage](#crudeCustomPage). If set, will open the specific custom page.|
| `OpenUriInIFRAME` |Boolean|Determines whether to open this menu item's target inside an IFRAME element.|

The NavUri, ViewID and PageID fields are all optional, and are mutually exclusive.

If more than one is set anyway, the one chosen will be based on the following priority order: NavUri, ViewID, PageID.

In either case, if this menu item is also the parent of another menu item, no link will be created for this item.
Instead, it will serve exclusively as a parent tree node, clicking which would show or hide its sub-nodes.

## crude.FilterOperator

Based on the [Dynamic Filters](/EitanBlumin/DynamicFilters) solution, to be used for advanced search.

Defines a set of filter operators (equals, not equals, larger than, smaller than, in, contains, starts with...), whether they're a multi value operator or not, and their respective database expression template.

For example, the template for "starts with" is:

```
{Column} LIKE {Parameter} + '%'
```

The template for "in" is:

```
{Column} IN (SELECT [value] FROM {Parameter})
```

|Column Name|Data Type|Description|
|---|---|----|
| `OperatorID` |Auto Increment|Primary Key|
| `Identifier` |String|Unique identifier for this operator to be used inside the code.|
| `Label` |String|Text to show users when selecting operators|
| `Glyph` |String|CSS class name used as a glyph icon for this operator. Example: "fa fa-not-equal"|
| `MultiValue` |Boolean|Sets whether parameters affected by this operator should be treated as multi-valued (i.e. table variable with a single `value` column).|
| `DBTemplate` |String|Defines the database expression template for this operator. {Column} and {Parameter} can be used as palceholders within the template. For example, the template for "starts with" is: "{Column} LIKE {Parameter} + '%'" and the template for "in" (which is a multi-value operator), is: "{Column} IN (SELECT [value] FROM {Parameter})".|

## crude.FieldType

Shared lookup table between [field types](Field-Types) and parameter types.

Will also define which filter operators are valid for which data types, and which types can be used by action parameters.

Depending on whether this is possible in the programming language, this table may also contain information about how the data type may be implemented (various templates for the view layer, validations, etc.). If this is possible, it would allow us to very easily extend the list of data types. An alternative would be to use a standardized file naming convention for loading partial files implementing the functionality of each type.

[More info about custom field types](Field-Types#custom-field-types).

|Column Name|Data Type|Description|
|---|---|----|
| `TypeID` |Auto Increment|Primary Key|
| `Identifier` |String|Unique identifier for this type to be used inside the code.|
| `Label` |String|Text to show users when selecting types|
| `AllowedOperators` |String|A multi-value field (comma-separated) of filter operators supported by this type|

More fields may be added as needed, based on the programming language and implementation.
