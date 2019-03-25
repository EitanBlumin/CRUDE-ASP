<%@ LANGUAGE="VBSCRIPT" CODEPAGE="65001" %>
<!--#include file="dist/asp/inc_config.asp" -->
<%' use this meta tag instead of adovbs.inc%>
<!--METADATA TYPE="typelib" uuid="00000205-0000-0010-8000-00AA006D2EA4" -->
<%
Response.CodePage = 65001
Session.CodePage = 65001
Response.CharSet = "UTF-8"

' Local Constants
'=======================
Const constPageScriptName = "admin_dataviews.asp"
Dim strPageTitle
strPageTitle = "Manage Data Views"

' Init Variables
'=======================
Dim nItemID, strMode, nCount, nIndex

' Open DB Connection
'=======================
adoConnCrude.Open
%><!--#include file="dist/asp/inc_crudeconstants.asp" --><%
Dim adoConnCrudeSource, adoConnCrudeSrc, strTitle, strDataSource, strMainTable, strPrimaryKey, strModificationProcedure, strViewProcedure, strDeleteProcedure
Dim strDescription, strOrderBy, nFlags, blnPublished, strRowReorderCol
Dim nDtModBtnStyle, nDtFlags, nDtDefaultPageSize, strDtPagingStyle
    
strMode = Request("mode")
nItemID = Request("ItemID")
IF NOT IsNumeric(nItemID) THEN nItemID = ""
strTitle = Request("Title")
strDataSource = Request("DataSource")
IF strDataSource = "" THEN strDataSource = "Default"
blnPublished = Request("Published")
IF blnPublished = "" THEN blnPublished = False ELSE blnPublished = CBool(blnPublished)
strMainTable = Request("MainTable")
strPrimaryKey = Request("PrimaryKey")
strModificationProcedure = Request("ModificationProcedure")
strViewProcedure = Request("ViewProcedure")
strDeleteProcedure = Request("DeleteProcedure")
strDescription = Request("ViewDescription")
strOrderBy = Request("OrderBy")
strRowReorderCol = Request("RowReorderCol")
IF strRowReorderCol = "" THEN strRowReorderCol = Null
nDtModBtnStyle = Request("DataTableModificationButtonStyle")
nDtDefaultPageSize = Request("DataTableDefaultPageSize")
strDtPagingStyle = Request("DataTablePagingStyle")
nDtFlags = 0
nFlags = 0

For nIndex = 1 TO Request.Form("Flags").Count
    nFlags= nFlags + CLng(Request.Form("Flags")(nIndex))
Next
For nIndex = 1 TO Request.Form("DataTableFlags").Count
    nDtFlags= nDtFlags + CLng(Request.Form("DataTableFlags")(nIndex))
Next

IF Request.Form("Title") <> "" THEN
	
    ' Check if Primary Key needs to be automatically discovered
    IF strPrimaryKey = "" THEN
        IF strDataSource <> "" THEN adoConnCrudeSource = GetConfigValue("connectionStrings", "name", "connectionString", strDataSource, adoConStr)
    
        Set adoConnCrudeSrc = Server.CreateObject("ADODB.Connection")
        adoConnCrudeSrc.ConnectionString = adoConnCrudeSource
        adoConnCrudeSrc.CommandTimeout = 0
        adoConnCrudeSrc.Open

        SET rsItems = Server.CreateObject("ADODB.Command")
        rsItems.ActiveConnection= adoConnCrudeSrc
        rsItems.CommandType = adCmdText
        rsItems.CommandText = "DECLARE @ObjId INT; " & vbCrLf & _
                              " SET @ObjId = OBJECT_ID(?); " & vbCrLf & _
                              " SELECT ObjId = @ObjId, q.* " & vbCrLf & _
                              " FROM (SELECT c.name AS PKCol, MAX(ic.key_ordinal) OVER () AS PKComposite FROM sys.indexes AS ix JOIN sys.index_columns AS ic " & vbCrLf & _
                              " ON ix.object_id = ic.object_id AND ix.index_id = ic.index_id " & vbCrLf & _
                              " JOIN sys.columns AS c ON ix.object_id = c.object_id AND ic.column_id = c.column_id" & vbCrLf & _
                              " WHERE ix.object_id = @ObjId AND ix.is_primary_key = 1) AS q"
    
        rsItems.Parameters.Append rsItems.CreateParameter("@TableName", adVarChar, adParamInput, 255, strMainTable)
    
        SET rsItems = rsItems.Execute

        IF NOT rsItems.EOF THEN
            IF IsNull(rsItems("ObjId")) THEN
                strError = GetWord("Specified table not found! Please make sure you're using the correct data source.")
            ELSEIF rsItems("PKComposite") > 1 THEN
                strError = GetWord("Tables with more than one primary key column are unsupported. Please specify PK column manually.")
            END IF
            strPrimaryKey = rsItems("PKCol")
        END IF

        IF strError = "" AND (strPrimaryKey = "" OR IsNull(strPrimaryKey)) THEN strError = GetWord("Primary Key must be specified for this table!")

        rsItems.Close
        adoConnCrudeSrc.Close
        SET adoConnCrudeSrc = Nothing

    END IF

    strSQL = "SELECT * FROM portal.DataView WHERE "
    
    IF strMode = "add" THEN
        strSQL = strSQL & "1=2"
    ELSEIF strMode ="edit" AND nItemID <> "" AND IsNumeric(nItemID) THEN
        strSQL = strSQL & "ViewID = " & nItemID
    ELSE
        strError = "Invalid input!"
        strSQL = ""
    END IF
    
	IF strError = "" AND strSQL <> "" THEN
        SET rsItems = Server.CreateObject("ADODB.Recordset")
        rsItems.CursorLocation = adUseClient
        rsItems.CursorType = adOpenKeyset
        rsItems.LockType = adLockOptimistic
        rsItems.Open strSQL, adoConnCrude
    
        IF strMode = "add" THEN
            rsItems.AddNew
        END IF

        IF strMode = "edit" AND rsItems.EOF THEN
            strError = "Item Not Found<br/>"
            rsItems.Close    
        ELSE
            rsItems("Title") = strTitle
            rsItems("Published") = blnPublished
            rsItems("DataSource") = strDataSource
            rsItems("MainTable") = strMainTable
            rsItems("Primarykey") = strPrimaryKey
            rsItems("ModificationProcedure") = strModificationProcedure
            rsItems("ViewProcedure") = strViewProcedure
            rsItems("DeleteProcedure") = strDeleteProcedure
            rsItems("ViewDescription") = strDescription
            rsItems("OrderBy") = strOrderBy
            rsItems("RowReorderColumn") = strRowReorderCol
            rsItems("Flags") = CLng(nFlags)
            rsItems("DataTableModifierButtonStyle") = CInt(nDtModBtnStyle)
            rsItems("DataTableDefaultPageSize") = CInt(nDtDefaultPageSize)
            rsItems("DataTableFlags") = CLng(nDtFlags)
            rsItems("DataTablePagingStyle") = strDtPagingStyle
    
            ON ERROR RESUME NEXT
    
            rsItems.Update

            IF strMode = "add" THEN
                nItemID = rsItems("ViewID")
            END IF

            rsItems.Close   
            
            ON ERROR GOTO 0
        END IF

        ' check for errors
        If adoConnCrude.Errors.Count > 0 Then
            DIM CurrErr
            strError = strError & " Error(s) while performing &quot;" & strMode & "&quot;:<br/>" 
            For Each CurrErr In adoConnCrude.Errors
			    strError = strError & "[" & CurrErr.Source & "] Error " & CurrErr.Number & ": " & CurrErr.Description & " | Native Error: " & CurrErr.NativeError & "<br/>"
            Next
            IF globalIsAdmin THEN strError = strError & "While trying to run:<br/><b>" & strSQL & "</b>"
        End If
	
	    IF strError = "" THEN 
            adoConnCrude.Close
            IF strMode = "add" THEN
                IF nItemID = "" OR NOT IsNumeric(nItemID) THEN nItemID = "latest"
	            Response.Redirect("admin_dataviewfields.asp?mode=autoinit&ViewID=" & nItemID)
            ELSE
	            Response.Redirect(constPageScriptName & "?MSG=" & strMode)
            END IF
        END IF
	END IF

ELSEIF strMode = "delete" AND nItemID <> "" AND IsNumeric(nItemID) THEN
		
	adoConnCrude.Execute "DELETE FROM portal.DataViewField WHERE ViewID = " & nItemID & "; DELETE FROM portal.DataView WHERE ViewID = " & nItemID
	adoConnCrude.Close
	
	Response.Redirect(constPageScriptName & "?MSG=delete")
END IF
%>
<!DOCTYPE html>
<html>
<head>
  <title><%= GetPageTitle() %></title>
<!--#include file="dist/asp/inc_meta.asp" -->
</head>
<body class="<%= globalBodyClass %>">
<div class="wrapper">
<!--#include file="dist/asp/inc_header.asp" -->
    
  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <%= strPageTitle %>
      </h1>

      <ol class="breadcrumb">
        <li><a href="default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li class="active"><%= Sanitizer.HTMLDisplay(strPageTitle) %></li>
      </ol>

    </section>

    <!-- Main content -->
    <section class="content container-fluid">

<%

IF (strMode = "edit" AND nItemID <> "" AND IsNumeric(nItemID)) OR strMode = "add" Then

IF strMode = "edit" AND nItemID <> "" AND IsNumeric(nItemID) Then
	strSQL = "SELECT * FROM portal.DataView WHERE ViewID = " & nItemID
	rsItems.Open strSQL, adoConnCrude
	IF NOT rsItems.EOF THEN
		strTitle = rsItems("Title")
        strDataSource = rsItems("DataSource")
		strMainTable = rsItems("MainTable")
        blnPublished = rsItems("Published")
		strPrimaryKey = rsItems("PrimaryKey")
		strOrderBy = rsItems("OrderBy")
        strRowReorderCol = rsItems("RowReorderColumn")
		strDescription = rsItems("ViewDescription")
        strModificationProcedure = rsItems("ModificationProcedure")
        strViewProcedure = rsItems("ViewProcedure")
        strDeleteProcedure = rsItems("DeleteProcedure")
		nFlags = rsItems("Flags")
        nDtModBtnStyle = rsItems("DataTableModifierButtonStyle")
        nDtDefaultPageSize = rsItems("DataTableDefaultPageSize")
        nDtFlags = rsItems("DataTableFlags")
        strDtPagingStyle = rsItems("DataTablePagingStyle")
	END IF
	rsItems.Close
ELSE
    Dim objFlag
    nFlags = 0
    For Each objFlag In luDataViewFlags.Items
        IF CBool(objFlag.DefaultValue) THEN nFlags = nFlags + CLng(objFlag.Value)
    Next
    nDtFlags = 0
    For Each objFlag In luDataTableFlags.Items
        IF CBool(objFlag.DefaultValue) THEN nDtFlags = nDtFlags + CLng(objFlag.Value)
    Next
	strMode = "add"
END IF
%>
<!-- Update/Insert Form -->
<div class="container-fluid">
<div class="panel panel-primary">
<div class="box-header with-border">
    <!-- tools box -->
    <div class="box-tools pull-right">
        <% IF strMode = "edit" AND nItemID <> "" THEN %>
        <a role="button" href="admin_dataviewfields.asp?ViewID=<%= nItemID %>" class="btn btn-primary btn-sm"><i class="fas fa-bars"></i> Manage Fields</a>
        <a role="button" href="dataview.asp?ViewID=<%= nItemID %>" class="btn btn-primary btn-sm"><i class="fas fa-eye"></i> Open Data View</a>
        <% END IF %>
        <a role="button" class="btn btn-default btn-sm" title="Cancel" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>"><i class="fas fa-times"></i></a>
    </div>
    <!-- /. tools -->

    <h3 class="box-title pull-left">
        <% IF strMode = "edit" AND nItemID <> "" THEN Response.Write "Edit" ELSE Response.Write "Add" %> Data View
    </h3>
</div>
<form class="form-horizontal" action="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>" method="post">
    <div class="box-body">
    <div class="form-group">
        <label for="inputTitle" class="col-sm-2 control-label" data-toggle="tooltip" title="The title will be displayed at the top of the page">Title</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputTitle" placeholder="Title" name="Title" value="<%= Sanitizer.HTMLFormControl(strTitle) %>" required="required">
        </div>
    </div>
    <div class="form-group">
        <label for="inputPublished" class="col-sm-2 control-label" data-toggle="tooltip" title="Sets whether this dataview is visible to end-users">
            Published
        </label>
        <div class="custom-control custom-switch col-sm-10">
        <input type="checkbox" class="custom-control-input" id="inputPublished" name="Published" value="True" <% IF blnPublished THEN Response.Write "checked" %> />
        <label for="inputPublished" class="custom-control-label"></label>
        </div>
    </div>
    <div class="form-group summernote">
        <label for="inputDescription" class="col-sm-2 control-label" data-toggle="tooltip" title="This richly-formatted text will be displayed below the title, before the datatable">Description</label>

        <div class="col-sm-10">
        <textarea name="ViewDescription" placeholder="Rich Text Formatted Description"
                    style="width: 100%; height: 200px; font-size: 14px; line-height: 18px; border: 1px solid #dddddd; padding: 10px;"><%= Sanitizer.HTMLFormControl(strDescription) %></textarea>
        </div>
    </div>
    <div class="form-group">
        <label for="inputDataSource" class="col-sm-2 control-label" data-toggle="tooltip" title="Choose the Connection String to use (from web.config)">Data Source</label>

        <div class="col-sm-10">
            <select class="form-control" id="inputDataSource" name="DataSource">
                <%
                    Dim csoNode, csoChild, csoAttr
                    Set csoNode = CONFIG_FILE_XML.GetElementsByTagName("connectionStrings").Item(0) 
                    Set csoChild = csoNode.GetElementsByTagName("add")
                    For Each csoAttr in csoChild
                    %><option value="<%= csoAttr.getAttribute("name") %>"<%
                        If csoAttr.getAttribute("name") = strDataSource then Response.Write " selected"
                        %>><%= csoAttr.getAttribute("name") %></option>
                    <% Next %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="inputMainTable" class="col-sm-2 control-label" data-toggle="tooltip" title="This is the database table name from which data will be queried and modified in (unless you specified stored procedures below). It can also be a view">Main Table Name</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputMainTable" name="MainTable" placeholder="Main Database Table Name" value="<%= Sanitizer.HTMLFormControl(strMainTable) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputPrimaryKey" class="col-sm-2 control-label" data-toggle="tooltip" title="A column name which serves as a primary key in the aforementioned database table">Primary Key</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputPrimaryKey" placeholder="Primary Key (must be single numerical column)" name="PrimaryKey" value="<%= Sanitizer.HTMLFormControl(strPrimaryKey) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputOrderBy" class="col-sm-2 control-label" data-toggle="tooltip" title="Default sorting expression when querying from the database table">Order By</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputOrderBy" placeholder="Column1 ASC, Column2 DESC" name="OrderBy" value="<%= Sanitizer.HTMLFormControl(strOrderBy) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputRowReorder" class="col-sm-2 control-label" data-toggle="tooltip" title="If specified, this column will be used for sorting and reordering the rows in the datatable">Row Re-order Column</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputRowReorder" placeholder="Column1" name="RowReorderCol" value="<%= Sanitizer.HTMLFormControl(strRowReorderCol) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputViewProcedure" class="col-sm-2 control-label" data-toggle="tooltip" title="Execute this stored procedure instead of querying directly from a table">Source Procedure</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputViewProcedure" placeholder="Procedure for View" name="ViewProcedure" value="<%= Sanitizer.HTMLFormControl(strViewProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputModificationProcedure" class="col-sm-2 control-label" data-toggle="tooltip" title="Execute this stored procedure instead of modifying data directly in a table">Modification Procedure</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputModificationProcedure" placeholder="Procedure for Modification" name="ModificationProcedure" value="<%= Sanitizer.HTMLFormControl(strModificationProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label for="inputDeleteProcedure" class="col-sm-2 control-label" data-toggle="tooltip" title="Execute this stored procedure instead of deleting directly from a table">Deletion Procedure</label>

        <div class="col-sm-10">
        <input type="text" class="form-control" id="inputDeleteProcedure" placeholder="Procedure for Deletion" name="DeleteProcedure" value="<%= Sanitizer.HTMLFormControl(strDeleteProcedure) %>">
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">Properties</label>
        
        <div class="col-sm-10">
        <div class="form-group">
        <% Dim objChild
            For Each objChild IN luDataViewFlags.Items %>
        <div class="input-group">
            <label>
            <input type="checkbox" name="Flags" value="<%= objChild.Value %>" <% IF (objChild.Value AND nFlags) > 0 THEN Response.Write "checked" %> /> 
                <i class="<%= objChild.Glyph %>"></i> <%= objChild.Label %>
            </label>
        </div>
        <% NEXT %>
        </div>
        </div>
    </div>
    <div class="form-group">
        <label for="inputDataTableModificationButtonStyle" class="col-sm-2 control-label" data-toggle="tooltip" title="Choose how the Add/Edit/Clone/Delete buttons would look like">DataTable Row Button Style</label>

        <div class="col-sm-10">
            <select class="form-control" name="DataTableModificationButtonStyle" id="inputDataTableModificationButtonStyle">
            <% For Each objChild IN luDataTableModifierButtonStyles.Items %>
                <option value="<%= objChild.Value %>" <% IF objChild.Value = nDtModBtnStyle THEN Response.Write "selected" %>><%= objChild.Label %></option>
            <% NEXT %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="intpuDataTableDefaultPageSize" class="col-sm-2 control-label" data-toggle="tooltip" title="Choose the default number of rows per page (ignored when pagination is disabled)">DataTable Default Page Size</label>

        <div class="col-sm-10">
            <select class="form-control" name="DataTableDefaultPageSize" id="inputDataTableDefaultPageSize">
                <option value="10" <% IF nDtDefaultPageSize = 10 THEN Response.Write "selected" %>>10</option>
                <option value="25" <% IF nDtDefaultPageSize = 25 THEN Response.Write "selected" %>>25</option>
                <option value="50" <% IF nDtDefaultPageSize = 50 THEN Response.Write "selected" %>>50</option>
                <option value="100" <% IF nDtDefaultPageSize = 100 THEN Response.Write "selected" %>>100</option>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label for="inputDataTablePagingStyle" class="col-sm-2 control-label" data-toggle="tooltip" title="Choose how the pagination buttons would look like (ignored when pagination is disabled)">DataTable Paging Style</label>

        <div class="col-sm-10">
            <select class="form-control" name="DataTablePagingStyle" id="inputDataTablePagingStyle">
            <% For Each objChild IN luDataTablePagingStyles.Items %>
                <option value="<%= objChild.Value %>" <% IF objChild.Value = strDtPagingStyle THEN Response.Write "selected" %>><%= objChild.Label %></option>
            <% NEXT %>
            </select>
        </div>
    </div>
    <div class="form-group">
        <label class="col-sm-2 control-label">DataTable Options</label>
        
        <div class="col-sm-10">
        <div class="form-group">
        <% FOR Each objChild IN luDataTableFlags.Items %>
        <div class="input-group">
            <label data-toggle="tooltip" title="<%= objChild.Tooltip %>">
            <input type="checkbox" name="DataTableFlags" value="<%= objChild.Value %>" <% IF (objChild.Value AND nDtFlags) > 0 THEN Response.Write "checked" %> /> 
                <i class="<%= objChild.Glyph %>"></i> <%= objChild.Label %>
            </label>
        </div>
        <% NEXT %>
        </div>
        </div>
    </div>
    </div>
    <!-- /.panel-body -->
    <div class="panel-footer">
    <input type="hidden" name="ItemID" value="<%= nItemID %>" />
    <input type="hidden" name="mode" value="<%= strMode %>" />

    <a class="btn btn-default" role="button" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>">Cancel</a>

    <button type="submit" class="btn btn-success pull-right">Submit</button>
    </div>
    <!-- /.panel-footer -->
</form>
</div>
</div>
<!-- /.update-insert-form -->
<% END IF %>
        

        <!-- Items List -->
<div class="box">
<div class="box-header">
    <div class="box-title">
        <a class="btn btn-success" role="button" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>?mode=add"><i class="fas fa-plus"></i> Add Data View</a>
    </div>
</div>
<div class="box-body table-responsive">
<table class="table table-border table-hover">
<thead class="bg-primary">
<tr>
    <th>ID</th>
    <th>Title</th>
    <th>Published</th>
    <th>Properties</th>
    <th>DataTable Options</th>
    <th>Actions</th>
</tr>
</thead>
<%
Set rsItems = Server.CreateObject("ADODB.Recordset")
strSQL = "SELECT * FROM portal.DataView ORDER BY Title ASC"
rsItems.Open strSQL, adoConnCrude

WHILE NOT rsItems.EOF

%><tr>
    <td><%= rsItems("ViewID") %></td>
    <td><a href="dataview.asp?ViewID=<%= rsItems("ViewID") %>"><%= Sanitizer.HTMLDisplay(rsItems("Title")) %></a></td>
    <th><i class="fas fa-<% IF rsItems("Published") THEN Response.Write "check-circle text-success" ELSE Response.Write "times-circle text-danger" %>" data-toggle="tooltip" title="<%= rsItems("Published") %>"></i></th>
    <td>
        <% FOR Each objChild In luDataViewFlags.Items
            IF (rsItems("Flags") AND objChild.Value) > 0 THEN %>
        <b data-toggle="tooltip" title="<%= objChild.Label %>"><i class="<%= objChild.Glyph %>"></i></b>
        &nbsp;
        <% END IF
            NEXT %>
    </td>
    <td>
        <% FOR Each objChild In luDataTableFlags.Items
            IF (rsItems("DataTableFlags") AND objChild.Value) > 0 THEN %>
        <b data-toggle="tooltip" title="<%= objChild.Label %>"><i class="<%= objChild.Glyph %>"></i></b>
        &nbsp;
        <% END IF
            NEXT %>
    </td>
    <td>
        <a data-toggle="tooltip" title="Manage Fields" class="btn btn-primary" href="admin_dataviewfields.asp?ViewID=<%= rsItems("ViewID") %>"><i class="fas fa-bars"></i> Manage Fields</a>
        <a data-toggle="tooltip" title="Edit" class="btn btn-success" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>?mode=edit&ItemID=<%= rsItems("ViewID") %>"><i class="fas fa-edit"></i> Edit</a>
        <a data-toggle="tooltip" title="Delete" class="btn btn-danger" href="<%= Sanitizer.HTMLFormControl(constPageScriptName) %>?mode=delete&ItemID=<%= rsItems("ViewID") %>"><i class="far fa-trash-alt"></i> Delete</a>
    </td>
  </tr>
    <% 
    rsItems.MoveNext
WEND %>
</table>
</div>
</div>
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

<!--#include file="dist/asp/inc_footer.asp" -->
</div>
<!-- ./wrapper -->

<!-- REQUIRED JS SCRIPTS -->
<!--#include file="dist/asp/inc_footer_jscripts.asp" -->

<!-- AdminLTE App -->
<script src="dist/js/adminlte.min.js"></script>

<!-- Optionally, you can add Slimscroll and FastClick plugins.
     Both of these plugins are recommended to enhance the
     user experience. -->
</body>
</html>
