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
Const constPageScriptName = "dataview.asp"
Dim strPageTitle
strPageTitle = "DataTable View"

' Init Variables
'=======================
Dim nItemID, strMode, nCount, nIndex, dvFields, dvActionsInline, dvActionsToolbar

' Open DB Connection
'=======================
adoConnCrudeStr = adoConStr
SET adoConnCrude = adoConn
adoConnCrude.Open
%><!--#include file="dist/asp/inc_crudeconstants.asp" --><%
    
Dim blnFound, blnRequiredFieldsFilled, strViewIDString, strViewQueryString
Dim blnShowCustomActions, blnShowForm, blnShowList, blnShowCharts, blnAllowUpdate, blnAllowInsert, blnAllowDelete, blnAllowClone, blnAllowSearch, strOrderBy, strSearchFilter, strCurrFilter
Dim blnDtInfo, blnDtColumnFooter, blnDtQuickSearch, blnDtSort, blnDtPagination, blnDtPageSizeSelection, blnDtStateSave
Dim nDtModBtnStyle, nDtFlags, nDtDefaultPageSize, strDtPagingStyle
Dim strLastOptGroup, blnOptGroupStarted, strCSSTable
Dim blnAllowColumnsToggle, blnAllowRowDetails, blnAllowRowSelection, blnFixedHeaders
Dim blnExportClipboard, blnExportCSV, blnExportExcel, blnExportPDF, blnExportPrint, blnAllowExport, blnAllowExportAll
Set rsItems = Server.CreateObject("ADODB.Recordset")

Dim myRegEx
SET myRegEx = New RegExp
myRegEx.IgnoreCase = True
myRegEx.Global = True


'[ConfigVars]
' Init Form Variables from DB. This will be deleted when generated as a seperate file.
DIM adoConnCrudeSrc, adoConnCrudeSource, nViewID, blnPublished, rsFields, arrViewFields
DIM nFieldsNum, nViewFlags, strPrimaryKey, strDataSource, strMainTableName, strDataViewDescription, strFilterBackLink, strRowReorderCol, strRowReorderColMasked
Dim strFilterField, blnFilterRequired, cmdStoredProc, strViewProcedure, strModificationProcedure, strDeleteProcedure, varCurrFieldValue
Dim paramPK, paramMode, paramFilter, paramOrderBy, blnRequired, blnReadOnly, nDtModBtnStyleIndex, blnShowRowActions

strDataSource = "Default"
strError = ""
strSearchFilter = ""
strRowReorderColMasked = ""

nItemID = Request("ItemID")
IF NOT IsNumeric(nItemID) THEN nItemID = ""
strMode = Request("mode")
IF strMode = "" THEN strMode = "none"

nViewID = Request("ViewID")

IF strError = "" AND nViewID <> "" AND IsNumeric(nViewID) THEN
    SET rsItems = Server.CreateObject("ADODB.Command")
    rsItems.ActiveConnection = adoConnCrude
    rsItems.CommandText = "SELECT * FROM portal.DataView WHERE ViewID = ?"
	SET rsItems = rsItems.Execute (,nViewID,adOptionUnspecified)
	IF NOT rsItems.EOF THEN
        strDataSource = rsItems("DataSource")
        IF strDataSource = "" OR IsNull(strDataSource) THEN strDataSource = "Default"
		strPageTitle = rsItems("Title")
        blnPublished = rsItems("Published")
        strDataViewDescription = rsItems("ViewDescription")
        strViewProcedure = rsItems("ViewProcedure")
        strModificationProcedure = rsItems("ModificationProcedure")
        strDeleteProcedure = rsItems("DeleteProcedure")
        strMainTableName = rsItems("MainTable")
        strOrderBy = rsItems("OrderBy")
        strRowReorderCol = rsItems("RowReorderColumn")
        strPrimaryKey = rsItems("PrimaryKey")
        nViewFlags = rsItems("Flags")
        nDtModBtnStyle = rsItems("DataTableModifierButtonStyle")
        nDtDefaultPageSize = rsItems("DataTableDefaultPageSize")
        nDtFlags = rsItems("DataTableFlags")
        strDtPagingStyle = rsItems("DataTablePagingStyle")
        strCSSTable = rsItems("CSSTable")
    
        blnAllowUpdate = CBool((nViewFlags AND 1) > 0)
        blnAllowInsert = CBool((nViewFlags AND 2) > 0)
        blnAllowDelete = CBool((nViewFlags AND 4) > 0)
        blnAllowClone = CBool((nViewFlags AND 8) > 0)

        blnShowRowActions = CBool(blnAllowUpdate OR blnAllowDelete OR blnAllowClone)

        blnShowForm = CBool((nViewFlags AND 16) > 0)
        blnShowList = CBool((nViewFlags AND 32) > 0)
        blnShowCharts = CBool((nViewFlags AND 64) > 0)
        blnShowCustomActions = CBool((nViewFlags AND 128) > 0)

        blnDtInfo = CBool((nDtFlags AND 1) > 0)
        blnDtColumnFooter = CBool((nDtFlags AND 2) > 0)
        blnDtQuickSearch = CBool((nDtFlags AND 4) > 0)
        blnDtSort = CBool((nDtFlags AND 8) > 0)
        blnDtPagination = CBool((nDtFlags AND 16) > 0)
        blnDtPageSizeSelection = CBool((nDtFlags AND 32) > 0)
        blnDtStateSave = CBool((nDtFlags AND 64) > 0)
        blnAllowSearch = CBool((nDtFlags AND 128) > 0)
        blnAllowColumnsToggle = CBool((nDtFlags AND 256) > 0)
        blnAllowRowDetails = CBool((nDtFlags AND 512) > 0)
        blnAllowRowSelection = CBool((nDtFlags AND 1024) > 0)
        blnExportClipboard = CBool((nDtFlags AND 2048) > 0)
        blnExportCSV = CBool((nDtFlags AND 4096) > 0)
        blnExportExcel = CBool((nDtFlags AND 8192) > 0)
        blnExportPDF = CBool((nDtFlags AND 16384) > 0)
        blnExportPrint = CBool((nDtFlags AND 32768) > 0)

        blnAllowExport = CBool(blnExportClipboard OR blnExportCSV OR blnExportExcel OR blnExportPDF OR blnExportPrint)
        blnAllowExportAll = CBool(blnExportClipboard AND blnExportCSV AND blnExportExcel AND blnExportPDF AND blnExportPrint)

        blnFixedHeaders = CBool((nDtFlags AND 65536) > 0)

        FOR nIndex = 0 TO UBound(arrDataTableModifierButtonStyles, 2)
            IF nDtModBtnStyle = arrDataTableModifierButtonStyles(dtbsValue, nIndex) THEN
                nDtModBtnStyleIndex = nIndex
            END IF
        NEXT
		SET dvFields = InitDataViewFields(nViewID, adoConnCrude)
        SET dvActionsInline = InitDataViewActions(nViewID, True, adoConnCrude)
        SET dvActionsToolbar = InitDataViewActions(nViewID, False, adoConnCrude)
	ELSE
		strError = GetWord("ViewID Not Found!")
		nViewID = ""
	END IF
	rsItems.Close
ELSE
	strError = GetWord("ViewID Invalid!")
END IF

IF NOT blnPublished OR strError <> "" THEN Response.Redirect "404.asp"

Dim strFilteredValue : strFilteredValue = Request(strFilterField & nViewID)
strViewQueryString = "&ViewID=" & nViewID
IF strFilteredValue <> "" THEN strViewQueryString = strViewQueryString & "&seek_" & Sanitizer.Querystring(strFilterField) & "=" & Sanitizer.Querystring(strFilteredValue)
IF strDataSource <> "" THEN adoConnCrudeSource = GetConfigValue("connectionStrings", "name", "connectionString", strDataSource, adoConStr)

Set adoConnCrudeSrc = Server.CreateObject("ADODB.Connection")
adoConnCrudeSrc.ConnectionString = adoConnCrudeSource
adoConnCrudeSrc.CommandTimeout = 0

ON ERROR RESUME NEXT

adoConnCrudeSrc.Open

IF adoConnCrudeSrc.Errors.Count > 0 THEN
	strError = "ERROR while tring to open data source " & strDataSource & ":<br>"
    For Each Err In adoConnCrudeSrc.Errors
		strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
    Next
'ELSE
'        Response.Write "<!-- Opened ConnString (" & strDataSource & ") " & adoConnCrudeSource & " -->" 
END IF

ON ERROR GOTO 0

'***************
' Page Contents
'***************
%>
<!DOCTYPE html>
<html>
<head>
  <title><%= GetPageTitle() %></title>
<!--#include file="dist/asp/inc_meta.asp" -->
<!-- DataTables styles -->
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.18/css/dataTables.bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/autofill/2.3.3/css/autoFill.bootstrap.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/buttons/1.5.6/css/buttons.bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.4/css/fixedHeader.bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/keytable/2.5.0/css/keyTable.bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/responsive/2.2.2/css/responsive.bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/scroller/2.0.0/css/scroller.bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/select/1.3.0/css/select.bootstrap.min.css"/>
<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/rowreorder/1.2.5/css/rowReorder.bootstrap.min.css"/>
 
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jszip/2.5.0/jszip.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/pdfmake.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.36/vfs_fonts.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/1.10.18/js/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/1.10.18/js/dataTables.bootstrap.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/autofill/2.3.3/js/dataTables.autoFill.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/autofill/2.3.3/js/autoFill.bootstrap.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.5.6/js/dataTables.buttons.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.5.6/js/buttons.bootstrap.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.5.6/js/buttons.colVis.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.5.6/js/buttons.flash.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.5.6/js/buttons.html5.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/buttons/1.5.6/js/buttons.print.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/fixedheader/3.1.4/js/dataTables.fixedHeader.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/keytable/2.5.0/js/dataTables.keyTable.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/responsive/2.2.2/js/dataTables.responsive.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/responsive/2.2.2/js/responsive.bootstrap.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/scroller/2.0.0/js/dataTables.scroller.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/select/1.3.0/js/dataTables.select.min.js"></script>
<script type="text/javascript" src="https://cdn.datatables.net/rowreorder/1.2.5/js/dataTables.rowReorder.min.js"></script>
<!-- JQuery Form -->
<script src="http://malsup.github.com/jquery.form.js"></script> 

<!-- Codemirror (codemirror.css, codemirror.js, xml.js, formatting.js) -->
<link rel="stylesheet" type="text/css" href="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/codemirror.css">
<link rel="stylesheet" type="text/css" href="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/theme/monokai.css">
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/codemirror.js"></script>
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/mode/xml/xml.js"></script>
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/codemirror/2.36.0/formatting.js"></script>
<style>
/* Detail Control Styles */
td.details-control {
    background: url('images/details_open.png') no-repeat left center;
    cursor: pointer;
}
tr.details td.details-control {
    background: url('images/details_close.png') no-repeat left center;
}
/* Actions Control Styles */
td.actions-control {
    background: none;
}
</style>
</head>
<body class="<%= globalBodyClass %>">
<div class="wrapper">
<!--#include file="dist/asp/inc_header.asp" -->

  <!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        <%= Sanitizer.HTMLDisplay(strPageTitle) %>
      </h1>

      <ol class="breadcrumb">
        <li><a href="default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li class="active"><%= Sanitizer.HTMLDisplay(strPageTitle) %></li>
      </ol>

    </section>

    <!-- Main content -->
    <section class="content container-fluid">

<!--<div class="row">
    <div class="col col-sm-12">
        <a class="btn btn-primary" role="button" href="#"><i class="fas fa-arrow-left"></i> Back</a>
    </div>
</div>-->
      
<%
IF strError <> "" THEN
%>
    <div class="callout callout-danger">
    <h4><%= GetWord("Critical Error!") %></h4>

    <p><%= strError %></p>
    </div>
  
<% ELSE %>

<!-- Hidden Form for Row Reordering -->
<form name="row_reorder_form" action="ajax_dataview.asp?ViewID=<%= nViewID %>" method="post">
    <div id="row_reorder_body"></div>
    <input type="hidden" name="postback" value="true" />
    <input type="hidden" name="mode" value="reorder" />
</form>
<!-- /row reorder -->
        
        <div class="row">
            <div class="col col-sm-12">
                <%= strDataViewDescription %>
            </div>
        </div>
<!-- grid -->
<div class="box">
    <div class="grid-buttons-container"></div>
    <div class="box-body container-fluid">

        <div class="table-responsive">
            <table datatable="" id="mainGrid" class="<%= strCSSTable %>">
        <thead>
        <tr class="bg-primary">
        <% IF strRowReorderCol <> "" AND Not IsNull(strRowReorderCol) THEN %>
            <th></th>
        <% END IF %>
            <% IF blnShowRowActions THEN %><th><%= GetWord("Actions") %></th><% END IF 
    FOR nIndex = 0 TO dvFields.UBound
        IF strRowReorderCol = dvFields(nIndex)("FieldSource") AND strRowReorderColMasked = "" THEN strRowReorderColMasked = dvFields(nIndex)("FieldIdentifier")
        IF (dvFields(nIndex)("FieldFlags") AND 9) > 0 THEN %>
            <th class="dt-exportable dt-toggleable<%
                ' if search is enabled for this field
                IF (dvFields(nIndex)("FieldFlags") AND 16) > 0 THEN
                    ' if field type is dropdown, multi-selection, or boolean, apply dropdown filter, otherwise textual filter
                    IF dvFields(nIndex)("FieldType") = 5 OR dvFields(nIndex)("FieldType") = 6 OR dvFields(nIndex)("FieldType") = 9 OR (dvFields(nIndex)("FieldType") >= 17 AND dvFields(nIndex)("FieldType") <= 23) THEN Response.Write " dt-searchable-dropdown" ELSE Response.Write " dt-searchable-text"
                END IF
                 %>"><%= Sanitizer.HTMLDisplay(dvFields(nIndex)("FieldLabel")) %></th><%
        END IF
     NEXT %>
        </tr>
        </thead>
        <tbody></tbody><% IF blnDtColumnFooter OR blnAllowSearch THEN %>
        <tfoot<% IF blnDtColumnFooter THEN Response.Write " class=""dt-keep-footer""" %>>
        <tr>
        <% IF strRowReorderCol <> "" AND Not IsNull(strRowReorderCol) THEN %>
            <th class="dt-non-searchable"></th>
        <% END IF %>
    <% IF blnShowRowActions THEN %><th class="dt-non-searchable"><%= GetWord("Actions") %></th><% END IF 
            FOR nIndex = 0 TO dvFields.UBound
                IF (dvFields(nIndex)("FieldFlags") AND 9) > 0 THEN %>
            <th class="dt-exportable dt-toggleable<%
                ' if search is enabled for this field
                IF (dvFields(nIndex)("FieldFlags") AND 16) > 0 THEN
                    ' if field type is dropdown, multi-selection, or boolean, apply dropdown filter, otherwise textual filter
                    IF dvFields(nIndex)("FieldType") = 5 OR dvFields(nIndex)("FieldType") = 6 OR dvFields(nIndex)("FieldType") = 9 OR (dvFields(nIndex)("FieldType") >= 17 AND dvFields(nIndex)("FieldType") <= 23) THEN Response.Write " dt-searchable-dropdown" ELSE Response.Write " dt-searchable-text"
                ELSE
                    Response.Write " dt-non-searchable"
                END IF
                 %>"><%= Sanitizer.HTMLDisplay(dvFields(nIndex)("FieldLabel")) %></th><%
                END IF
             NEXT %>
        </tr>
        </tfoot><% END IF %>
        </table>
        </div>
    </div>
</div>
<!-- /grid -->

<!-- respite_crud -->
<script type="text/javascript" src="datatable_respite_crud.js"></script>
<!-- page scripts -->
<script type="text/javascript">
    // Detail Row Formatting
    function formatDetails(d) {
        if (d != undefined) {
            var rv = "";
            console.log(respite_crud.dt.dt_Columns)
            // this will print out all fields and sub-fields and their values
            for (var dKey in d) {

                if (typeof d[dKey] === "object" || typeof d[dKey] === "array") {
                    // recursive:
                    rv += "<b>" + dKey + ':</b><div class="container-fluid">' + formatDetails(d[dKey]) + '</div>';
                } else {
                    // simple string (stop condition):
                    rv += dKey + ": " + d[dKey] + "<br/> ";
                }
            }

            return rv;
        }
        else
            return 'Empty row';
    }

    // Init default options
    respite_crud.setEditorOptions();

    // Init DataView Properties as Placeholders
    respite_crud.placeholderReplacements.push( {
        "key": "dataview",
        "values": {
            "id": <%= nViewID %>,
            "title": "<%= Sanitizer.JSON(strPageTitle) %>"
        }});

    // Override some options
    respite_crud.respite_editor_options.dt_Options.dt_AjaxGet = "ajax_dataview.asp?mode=datatable&ViewID=<%= nViewID %>";
    respite_crud.respite_editor_options.modal_Options.modal_edit.modal_form_target = "ajax_dataview.asp?ViewID=<%= nViewID %>";
    respite_crud.respite_editor_options.modal_Options.modal_delete.modal_form_target = "ajax_dataview.asp?ViewID=<%= nViewID %>";

    // DataTable Columns:
    // TODO: Simplify the addColumn() function interface
    respite_crud
        <% IF strRowReorderCol <> "" AND Not IsNull(strRowReorderCol) THEN
            IF strRowReorderColMasked = "" THEN strRowReorderColMasked = strRowReorderCol
        %>.addRowReorderColumn("<%= Sanitizer.JSON(strRowReorderColMasked) %>")
        <% END IF 
        %>.addInlineActionButtonsColumn()
        <% IF strError = "" THEN
        FOR nIndex = 0 TO dvFields.UBound
        IF (dvFields(nIndex)("FieldFlags") AND 9) > 0 THEN
    %>.addColumn({
        "name": "<%= dvFields(nIndex)("FieldIdentifier") %>",
        "data": "Field_<%= dvFields(nIndex)("FieldID") %>",
            "render": respite_crud.renderAutomatic<%
    IF (dvFields(nIndex)("FieldFlags") AND 8) = 0 THEN  %>,
            "visible": false<%
    END IF
    IF (dvFields(nIndex)("FieldFlags") AND 16) = 0 THEN  %>,
            "searchable": false<%
    END IF %>,
            "editor_data": {<% 
    IF (dvFields(nIndex)("FieldFlags") AND 1) = 0 THEN %>
                "hidden": true,<%
    END IF
    IF dvFields(nIndex)("UriPath") <> "" THEN %>
                "wrap_link": {
                    "href": "<%= Sanitizer.JSON(dvFields(nIndex)("UriPath")) %>",
                    "css": "<%= Sanitizer.JSON(luDataViewUriStyles(dvFields(nIndex)("UriStyle")).CSSClass) %>"
                },<%
    END IF %>
                "label": "<%= Sanitizer.JSON(dvFields(nIndex)("FieldLabel")) %>",
                "type": "<%= luDataViewFieldTypes(dvFields(nIndex)("FieldType")).Identifier %>",       // field type
                "tooltip": "<%= Sanitizer.JSON(dvFields(nIndex)("FieldTooltip")) %>",
                "default_value": "<%= Sanitizer.JSON(dvFields(nIndex)("DefaultValue")) %>",   // default value
                <%
                IF (dvFields(nIndex)("FieldFlags") AND 16) > 0 THEN %>"searchable": false,<%
                END IF
                %>
                // collection of custom attributes to apply to the input field element: { attrName: attrValue, ... }
                "attributes": { "placeholder": "<%= Sanitizer.JSON(dvFields(nIndex)("FieldLabel")) %>"<%
                    IF dvFields(nIndex)("MaxLength") <> "" AND NOT IsNull(dvFields(nIndex)("MaxLength")) THEN
                    %>, "maxlength": <%= dvFields(nIndex)("MaxLength") %><%
                    END IF
                    IF dvFields(nIndex)("Height") <> "" AND NOT IsNull(dvFields(nIndex)("Height")) THEN
                    %>, "<%
                    IF dvFields(nIndex)("FieldType") = 1 OR dvFields(nIndex)("FieldType") = 2 OR dvFields(nIndex)("FieldType") = 14 THEN
                        Response.Write "rows"
                    ELSE
                        Response.Write "height"
                    END IF %>": <%= dvFields(nIndex)("Height") %><%
                    END IF
                    IF dvFields(nIndex)("Width") <> "" AND NOT IsNull(dvFields(nIndex)("Width")) THEN
                    %>, "width": '<%= dvFields(nIndex)("Width") %>%'<%
                    END IF
                    IF dvFields(nIndex)("FormatPattern") <> "" AND NOT IsNull(dvFields(nIndex)("FormatPattern")) THEN
                    %>, "pattern": "<%= Sanitizer.JSON(dvFields(nIndex)("FormatPattern")) %>"<%
                    END IF
                    IF (dvFields(nIndex)("FieldFlags") AND 2) > 0 THEN
                    %>, "required": true<%
                    END IF
                    IF (dvFields(nIndex)("FieldFlags") AND 4) > 0 THEN 
                    %>, "readonly": true<%
                    END IF %>}
                <% 
                IF dvFields(nIndex)("FieldType") = 5 OR dvFields(nIndex)("FieldType") = 6 OR (dvFields(nIndex)("FieldType") >= 17 AND dvFields(nIndex)("FieldType") <= 21) OR (dvFields(nIndex)("FieldType") >= 27 AND dvFields(nIndex)("FieldType") <= 29) THEN
                    Response.Write ", ""options"": [ "

                    IF dvFields(nIndex)("LinkedTableValueField") <> "" AND Not IsNull(dvFields(nIndex)("LinkedTableValueField")) AND dvFields(nIndex)("LinkedTable") <> "" AND NOT IsNull(dvFields(nIndex)("LinkedTable")) THEN
                        Dim rsOptions
                        SET rsOptions = Server.CreateObject("ADODB.Recordset")
                        strSQL = "SELECT * FROM (SELECT " & dvFields(nIndex)("LinkedTableValueField") & " AS [value], "
                    
                        IF dvFields(nIndex)("LinkedTableTitleField") <> "" THEN
                            strSQL = strSQL & dvFields(nIndex)("LinkedTableTitleField")
                        ELSE
                            strSQL = strSQL & dvFields(nIndex)("LinkedTableValueField")
                        END IF
                        strSQL = strSQL & " AS [title], "

                        IF dvFields(nIndex)("LinkedTableGroupField") <> "" THEN
                            strSQL = strSQL & dvFields(nIndex)("LinkedTableGroupField")
                        ELSE
                            strSQL = strSQL & "''"
                        END IF
                        strSQL = strSQL & " AS [group], "
                
                        IF dvFields(nIndex)("LinkedTableGlyphField") <> "" THEN
                        strSQL = strSQL & dvFields(nIndex)("LinkedTableGlyphField")
                        ELSE
                        strSQL = strSQL & "''"
                        END IF
                        strSQL = strSQL & " AS [glyph], "

                        IF dvFields(nIndex)("LinkedTableTooltipField") <> "" THEN
                        strSQL = strSQL & dvFields(nIndex)("LinkedTableTooltipField")
                        ELSE
                        strSQL = strSQL & "''"
                        END IF
                        strSQL = strSQL & " AS [tooltip] "

                        strSQL = strSQL & " FROM " & dvFields(nIndex)("LinkedTable") & " " & dvFields(nIndex)("LinkedTableAddition")
                        strSQL = strSQL & ") AS q ORDER BY [group] ASC, [title] ASC, [value] ASC"
                
                        rsOptions.Open strSQL, adoConnCrudeSrc
                        WHILE NOT rsOptions.EOF
                    %>{ "value": "<%= Sanitizer.JSON(rsOptions("value")) %>", "label": "<%= Sanitizer.JSON(rsOptions("title")) %>", "group": "<%= Sanitizer.JSON(rsOptions("group")) %>", "glyph": "<%= Sanitizer.JSON(rsOptions("glyph")) %>", "tooltip": "<%= Sanitizer.JSON(rsOptions("tooltip")) %>" }<%
                        rsOptions.MoveNext
                        IF NOT rsOptions.EOF THEN Response.Write ", "
                        WEND
                        rsOptions.Close
                    END IF
                    Response.Write "]"
                END IF %>
            }
        })
    <%
        END IF
    NEXT

    END IF %>;
    // DataTable Columns Default Order:
    //respite_crud.setColumnsOrder( [[1, 'asc'], [3, 'desc']] );

    // Toolbar and Inline buttons should be added before init
    respite_crud
        // Toolbar buttons<% IF blnAllowInsert THEN %>
        .addAddButton()<% END IF %>
        .addRefreshButton()<% IF blnAllowRowSelection THEN %>
        .addSelectAllButton()
        .addDeSelectAllButton()<% IF blnAllowDelete THEN %>
        .addDeleteSelectedButton()<% END IF
        END IF
        IF blnAllowColumnsToggle THEN %>
        .addToggleColumnsButton()<% END IF
        IF blnAllowExport THEN %>
        .addExportButton(<%
        IF NOT blnAllowExportAll THEN
            Dim blnFirstItem
            blnFirstItem = True
            %>[<%
                IF blnExportClipboard THEN
                    Response.Write "{ extend: 'copy', exportOptions: { columns: '.dt-exportable' } }"
                    blnFirstItem = False
                END IF
                IF blnExportExcel THEN
                    IF NOT blnFirstItem THEN Response.Write "," & vbCrLf ELSE blnFirstItem = False
                    Response.Write "{ extend: 'excel', exportOptions: { columns: '.dt-exportable' } }"
                END IF
                IF blnExportCSV THEN
                    IF NOT blnFirstItem THEN Response.Write "," & vbCrLf ELSE blnFirstItem = False
                    Response.Write "{ extend: 'csv', exportOptions: { columns: '.dt-exportable' } }"
                END IF
                IF blnExportPDF THEN
                    IF NOT blnFirstItem THEN Response.Write "," & vbCrLf ELSE blnFirstItem = False
                    Response.Write "{ extend: 'pdf', exportOptions: { columns: '.dt-exportable' } }"
                END IF
                IF blnExportPrint THEN
                    IF NOT blnFirstItem THEN Response.Write "," & vbCrLf ELSE blnFirstItem = False
                    Response.Write "{ extend: 'print', exportOptions: { columns: '.dt-exportable' } }"
                END IF
                %>]<%
        END IF
        %>)<% END IF
    IF blnShowCustomActions THEN
    'TODO: Implement DB Command and URL buttons
    FOR nIndex = 0 TO dvActionsToolbar.UBound %>
        .addToolbarActionButton(
        {
            text: '<i class="<%= Sanitizer.JSON(dvActionsToolbar(nIndex)("GlyphIcon")) %>"></i> <%= Sanitizer.JSON(dvActionsToolbar(nIndex)("ActionLabel")) %>',
            className: "<%= Sanitizer.JSON(dvActionsToolbar(nIndex)("CSSButton")) %>",
            title: "<%= Sanitizer.JSON(dvActionsToolbar(nIndex)("ActionTooltip")) %>",
            action: function (e, dt, node, config) {
                <%
                Select Case dvActionsToolbar(nIndex)("ActionType")
                Case "javascript"
                    Response.Write dvActionsToolbar(nIndex)("ActionExpression")
                Case "url"
                    Response.Write "respite_crud.actionUrl(""" & Sanitizer.JSON(dvActionsToolbar(nIndex)("ActionExpression")) & """, " & LCase(dvActionsToolbar(nIndex)("OpenURLInNewWindow")) & ");"
                Case "db_command", "db_procedure"
                    Response.Write "throw 'not yet implemented';"
                Case Else
                    Response.Write "throw 'Action Type " & dvActionsToolbar(nIndex)("ActionType") & " unrecognized';"
                End Select
                %>
            }
        })<%
    NEXT
    END IF
    %>
        // Inline buttons
<% IF blnAllowRowDetails THEN %>
        .addDetailsButton() //formatDetails)
<% END IF
            IF blnAllowClone THEN %>
        .addCloneButton("<%= GetWord("Clone") %>")<% END IF
            IF blnAllowUpdate THEN %>
        .addEditButton("<%= GetWord("Edit") %>")<% END IF
            IF blnAllowDelete THEN %>
        .addDeleteButton("<%= GetWord("Delete") %>")<% END IF
IF blnShowCustomActions THEN
    FOR nIndex = 0 TO dvActionsInline.UBound %>
        .addInlineActionButton(
        {
            href: "javascript:void(0)",
            label: "<%= Sanitizer.JSON(dvActionsInline(nIndex)("ActionLabel")) %>",
            glyph: "<%= Sanitizer.JSON(dvActionsInline(nIndex)("GlyphIcon")) %>",
            "class": "<%= Sanitizer.JSON(dvActionsInline(nIndex)("CSSButton")) %>",
            title: "<%= Sanitizer.JSON(dvActionsInline(nIndex)("ActionTooltip")) %>"
         },
        function (e, tr, r) {
            <%
            Select Case dvActionsInline(nIndex)("ActionType")
            Case "javascript"
            Response.Write dvActionsInline(nIndex)("ActionExpression")
            Case "url"
            Response.Write "respite_crud.actionUrl(""" & Sanitizer.JSON(dvActionsInline(nIndex)("ActionExpression")) & """, " & LCase(dvActionsInline(nIndex)("OpenURLInNewWindow")) & ", undefined, r, undefined);"
            Case "db_command", "db_procedure"
            Response.Write "throw 'not yet implemented';"
            Case Else
            Response.Write "throw 'Action Type " & dvActionsInline(nIndex)("ActionType") & " unrecognized';"
            End Select
            %>}
        )<%
    NEXT
END IF
%>
        /*
        // Custom inline buttons example
        .addInlineActionButton(
        {
            href: "javascript:void(0)",
            class: "btn btn-primary btn-sm",
            title: "Custom Inline Button",
            glyph: "fa fa-magic",
            label: "Custom"
        }, function (e, tr, r) {
            alert("You've activated a custom inline button. Check the console.");
            console.log(tr);
            console.log(r);
        })*/
        ;

        /*// Bind Data Manipulation Forms to Ajax
        respite_crud.initAjaxForm({
            beforeSubmit: preRequest,
            success: showResponse,
            error: showResponse,
            dataType: 'json'
        });*/

        // Init DataTable with default options:
        <% IF strError = "" THEN %>
            respite_crud.initDataTable({
            pagingType: "<%= Sanitizer.JSON(strDtPagingStyle) %>",<% IF NOT blnDtSort THEN %>
            ordering: false,<% END IF %><% IF NOT blnDtQuickSearch THEN %>
            searching: false,<% END IF %><% IF NOT blnDtInfo THEN %>
            info: false,<% END IF %><% IF NOT blnDtPageSizeSelection THEN %>
            lengthChange: false,<% END IF %><% IF NOT blnDtPagination THEN %>
            scrollY: 390,
            scrollX: 460,
            scrollCollapse: true,
            scroller: { loadingIndicator: true },<% END IF %><% IF blnAllowRowSelection THEN %>
            select: "os",<% ELSE %>
            select: false,<% END IF %><% IF blnDtStateSave THEN %>
            stateSave: true,<% END IF %><% IF strRowReorderCol <> "" AND Not IsNull(strRowReorderCol) THEN %>
            rowReorder: { dataSrc: "<%= Sanitizer.JSON(strRowReorderColMasked) %>" },
            columnDefs: [
                { orderable: true, className: 'reorder', targets: 0 },
                { orderable: false, targets: '_all' }
            ],<% END IF %>
            pageLength: <%= nDtDefaultPageSize %>
            });
        <% END IF
        'TODO: blnFixedHeaders
        %>

    </script>
<!-- /scripts -->
<% END IF %>
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