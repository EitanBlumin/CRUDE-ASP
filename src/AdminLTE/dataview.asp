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
Dim strLastOptGroup, blnOptGroupStarted
Dim blnAllowColumnsToggle, blnAllowRowDetails, blnAllowRowSelection, blnFixedHeaders
Dim blnExportClipboard, blnExportCSV, blnExportExcel, blnExportPDF, blnExportPrint, blnAllowExport, blnAllowExportAll
Set rsItems = Server.CreateObject("ADODB.Recordset")

Dim myRegEx
SET myRegEx = New RegExp
myRegEx.IgnoreCase = True
myRegEx.Global = True


'[ConfigVars]
' Init Form Variables from DB. This will be deleted when generated as a seperate file.
DIM adoConnCrudeSrc, adoConnCrudeSource, nViewID, rsFields, arrViewFields
DIM nFieldsNum, nViewFlags, strPrimaryKey, strDataSource, strMainTableName, strDataViewDescription, strFilterBackLink
Dim strFilterField, blnFilterRequired, cmdStoredProc, strViewProcedure, strModificationProcedure, strDeleteProcedure, varCurrFieldValue
Dim paramPK, paramMode, paramFilter, paramOrderBy, blnRequired, blnReadOnly, nDtModBtnStyleIndex, blnShowRowActions

strDataSource = "Default"
strError = ""
strSearchFilter = ""

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
        IF strDataSource = "" OR strDataSource = Null THEN strDataSource = "Default"
		strPageTitle = rsItems("Title")
        strDataViewDescription = rsItems("ViewDescription")
        strViewProcedure = rsItems("ViewProcedure")
        strModificationProcedure = rsItems("ModificationProcedure")
        strDeleteProcedure = rsItems("DeleteProcedure")
        strMainTableName = rsItems("MainTable")
        strOrderBy = rsItems("OrderBy")
        strPrimaryKey = rsItems("PrimaryKey")
        nViewFlags = rsItems("Flags")
        nDtModBtnStyle = rsItems("DataTableModifierButtonStyle")
        nDtDefaultPageSize = rsItems("DataTableDefaultPageSize")
        nDtFlags = rsItems("DataTableFlags")
        strDtPagingStyle = rsItems("DataTablePagingStyle")
    
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

'***************************
' Data Manipulation Section
'***************************
IF strError = "" AND ((strMode = "add" AND blnAllowInsert) OR (strMode = "edit" AND blnAllowUpdate AND nItemID <> "")) AND Request.Form("postback") = "true" THEN
    Response.Write "<!-- Data Manipulation Start -->" & vbCrLf
	' If stored procedure
    IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
        strSQL = strModificationProcedure

	    SET cmdStoredProc = Server.CreateObject("ADODB.Command")
	    cmdStoredProc.ActiveConnection = adoConnCrudeSrc
	    cmdStoredProc.CommandText = strSQL
	    cmdStoredProc.CommandType = adCmdStoredProc
    
        cmdStoredProc.Parameters.Refresh
        ' Parameter 0 is the return value
        ' Parameter 1 should be @Mode.
        cmdStoredProc.Parameters(1).Value = strMode
        
        ' Parameter 2 should be the PK.
        IF nItemID = "" THEN nItemID = Null
        cmdStoredProc.Parameters(2).Value = nItemID

    Else
	    strSQL = "SELECT * FROM " & strMainTableName

        IF strMode = "edit" AND nItemID <> "" AND IsNumeric(nItemID) THEN
		    strSQL = strSQL & " WHERE " & strPrimaryKey & " = " & nItemID
        ELSE
		    strSQL = strSQL & " WHERE 1=2"
        END IF
        
        rsItems.CursorLocation = adUseClient
        rsItems.CursorType = adOpenKeyset
        rsItems.LockType = adLockOptimistic
        rsItems.Open strSQL, adoConnCrudeSrc

        IF strMode = "add" THEN
            rsItems.AddNew
        END IF

        IF strMode = "edit" AND rsItems.EOF THEN
            strError = "Item Not Found<br/>"
        END IF
    END IF

    IF strError = "" THEN
	Dim nParamID
    nParamID = 2
    ON ERROR RESUME NEXT

		FOR nIndex = 0 TO UBound(arrViewFields, 2) 'AND False
			IF arrViewFields(dvfcFieldType, nIndex) <> 10 AND (arrViewFields(dvfcFieldFlags, nIndex) AND 4) = 0 THEN ' not "link" or read-only
                
                IF Request("inputField_" & nIndex) = "" AND (arrViewFields(dvfcFieldFlags, nIndex) AND 2) > 0 THEN
                    strError = strError & "<b>" & Sanitizer.HTMLDisplay(arrViewFields(dvfcFieldLabel, nIndex)) & "</b> is required but has not been filled.<br/>"
                ELSE
                    Select Case arrViewFields(dvfcFieldType, nIndex)
                        Case 12, 1, 2, 6, 14 '"password", "text", "textarea", "multicombo", "rte"
                            varCurrFieldValue = Request("inputField_" & nIndex)
                        Case 13 '"time"
                            IF Len(Request("inputField_" & nIndex)) = 0 AND (arrViewFields(dvfcFieldFlags, nIndex) AND 2) = 0 THEN ' if empty and not required, enter NULL
                                varCurrFieldValue = NULL
                                Response.Write "<!-- setting [time] field " & arrViewFields(dvfcFieldSource, nIndex) & " = NULL -->" & vbCrLf
                            ELSE
				                varCurrFieldValue = Mid(Request("inputField_" & nIndex), 1, 8)
                                Response.Write "<!-- [time] field " & arrViewFields(dvfcFieldSource, nIndex) & " is NOT NULL (" & Len(Request("inputField_" & nIndex)) & ", " & (arrViewFields(dvfcFieldFlags, nIndex) AND 2) & ") = " & varCurrFieldValue & " -->" & vbCrLf
                            END IF
                        Case Else
                            IF Len(Request("inputField_" & nIndex)) = 0 AND (arrViewFields(dvfcFieldFlags, nIndex) AND 2) = 0 THEN ' if empty and not required, enter NULL
                                varCurrFieldValue = NULL
                                Response.Write "<!-- setting " & arrViewFields(dvfcFieldSource, nIndex) & " = NULL -->" & vbCrLf
                            ELSE
				                varCurrFieldValue = Request("inputField_" & nIndex)
                                Response.Write "<!-- " & arrViewFields(dvfcFieldSource, nIndex) & " is NOT NULL (" & Len(Request("inputField_" & nIndex)) & ", " & (arrViewFields(dvfcFieldFlags, nIndex) AND 2) & ") = " & varCurrFieldValue & " -->" & vbCrLf
                            END IF
                    End Select

                    IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
                        nParamID = nParamID + 1
                        Response.Write "<!-- Setting parameter " & nParamID & " = " & varCurrFieldValue & "-->" & vbCrlf
                        cmdStoredProc.Parameters(nParamID).Value = varCurrFieldValue
                    ELSE
                        Response.Write "<!-- setting " & arrViewFields(dvfcFieldSource, nIndex) & " = """ & varCurrFieldValue & """ (isnull: " & IsNull(varCurrFieldValue) & ") ErrCount: " & adoConnCrude.Errors.Count & " -->" & vbCrLf
                        rsItems(arrViewFields(dvfcFieldSource, nIndex)) = varCurrFieldValue
                    END IF
                END IF
			END IF
		NEXT
        
        IF strError = "" THEN
            IF NOT IsNull(strModificationProcedure) AND strModificationProcedure <> "" THEN
	            cmdStoredProc.Execute

	            IF adoConnCrudeSrc.Errors.Count > 0 THEN
		            strError = strError & " Executed Stored Procedure " & strModificationProcedure & " With Errors</br>"
    		    END IF

	            SET cmdStoredProc = Nothing
            ELSE
                'strError = strError & "Attempting rs.Update<br/>"
                'Response.Write "<!-- ErrCount before Update: " & adoConnCrudeSrc.Errors.Count & " -->" & vbCrLf
                rsItems.Update
                'Response.Write "<!-- ErrCount after Update: " & adoConnCrudeSrc.Errors.Count & " -->" & vbCrLf
                rsItems.Close    
                'Response.Write "<!-- ErrCount after Close: " & adoConnCrudeSrc.Errors.Count & " -->" & vbCrLf
            END IF
        ELSE
            rsItems.Close    
        END IF

	END IF

    ON ERROR GOTO 0

    ' check for errors
    If adoConnCrudeSrc.Errors.Count > 0 Then
        DIM Err
        strError = strError & " Error(s) while performing """ & strMode & """:<br/>" 
        For Each Err In adoConnCrudeSrc.Errors
			strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
        Next
        IF globalIsAdmin THEN strError = strError & "While trying to run:<br/><b>" & strSQL & "</b>"
    End If
	
	IF strError = "" THEN 
        adoConnCrudeSrc.Close
        adoConnCrude.Close
	    Response.Redirect(constPageScriptName & "?MSG=" & strMode & strViewQueryString)
    END IF

ELSEIF strError = "" AND strMode = "delete" AND nItemID <> "" AND IsNumeric(nItemID) AND blnAllowDelete THEN
	
	' If stored procedure
    IF NOT IsNull(strDeleteProcedure) AND strDeleteProcedure <> "" THEN
        strSQL = strDeleteProcedure

	    SET cmdStoredProc = Server.CreateObject("ADODB.Command")
	    cmdStoredProc.ActiveConnection = adoConnCrudeSrc
	    cmdStoredProc.CommandText = strSQL
	    cmdStoredProc.CommandType = adCmdStoredProc
    
        cmdStoredProc.Parameters.Refresh
        ' Parameter 0 is the return value
        ' Parameter 1 should be the PK.
        IF nItemID = "" THEN nItemID = Null
        cmdStoredProc.Parameters(1).Value = nItemID
    
        ON ERROR RESUME NEXT

	    cmdStoredProc.Execute
    
        IF Err.Number <> 0 THEN
		    strError = Err.Description
	    ELSEIF adoConnCrudeSrc.Errors.Count > 0 THEN
	        strError = "ERROR while tring to open data source " & strDataSource & ":<br/>"
            For Each Err In adoConnCrudeSrc.Errors
		        strError = strError & "[" & Err.Source & "] Error " & Err.Number & ": " & Err.Description & " | Native Error: " & Err.NativeError & "<br/>"
            Next
        END IF
	
	    SET cmdStoredProc = Nothing

        ON ERROR GOTO 0
    Else
        strSQL = "DELETE FROM " & strMainTableName & " WHERE " & strPrimaryKey & " = " & nItemID
	    adoConnCrudeSrc.Execute strSQL
    End If

	IF strError = "" Then
    	adoConnCrudeSrc.Close
        adoConnCrude.Close
        Response.Redirect(constPageScriptName & "?MSG=delete" & strViewQueryString)
    End If
END IF


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

<!-- Data Manipulation Modals -->
<!-- Edit/Update/Clone Modal -->
<div class="modal fade" id="modal_edit" role="dialog">
    <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
        <div class="modal-header bg-primary">
            <span class="box-tools pull-right">
                <button type="button" class="btn btn-danger btn-sm" id="modal_btn_delete" role="button" href="javascript:void(0)" onclick="respite_crud.showDelete(respite_crud.row)" aria-label="Delete" title="Delete" data-toggle="modal" data-target="#modal_delete"><i class="far fa-trash-alt"></i> Delete</button>
                &nbsp;
                <button type="button" role="button" class="btn btn-secondary btn-sm" data-dismiss="modal" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></button>
            </span>
            <h4 class="modal-title float-left" id="modal_edit_title">Add Item</h4>
        </div>
        <form class="ajax-form" name="modal_edit_form" action="ajax_dataview.asp?ViewID=<%= nViewID %>" method="post" form-modal="#modal_edit">
            <div class="modal-body" id="modal_edit_body"></div>
            <div class="modal-footer bg-primary">
                <input type="hidden" name="postback" value="true" />
                <input type="hidden" name="DT_RowId" value="" />
                <input type="hidden" name="mode" value="add" />
                <button type="button" class="btn btn-secondary pull-left" data-dismiss="modal">Close</button>
                <button type="submit" class="btn btn-success"><i class="fas fa-save"></i> Save changes</button>
            </div>
        </form>
    </div>
    <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
</div>
<!-- /.modal -->

<!-- Deletion Modal -->
<div class="modal fade" id="modal_delete" role="dialog">
    <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content">
        <div class="modal-header bg-danger">
            <span class="box-tools pull-right">
            <button type="button" role="button" class="btn btn-secondary btn-sm" data-dismiss="modal" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></button>
            </span>
            <h4 class="modal-title float-left">Are you sure you want to delete?</h4>
        </div>
        <form class="ajax-form" name="modal_delete_form" action="ajax_dataview.asp?ViewID=<%= nViewID %>" method="post" form-modal="#modal_delete">
            <div class="modal-body" id="modal_delete_body"></div>
            <div class="modal-footer bg-danger">
                <input type="hidden" name="postback" value="true" />
                <input type="hidden" name="DT_RowId" value="-1" />
                <input type="hidden" name="mode" value="delete" />
                <button type="button" class="btn btn-secondary pull-left" data-dismiss="modal">Cancel</button>
                <button type="submit" class="btn btn-danger" onclick="respite_crud.hideModal('#modal_edit')">Delete</button>
            </div>
        </form>
    </div>
    </div>
</div>
<!-- /.modal -->

<!-- Response Modal -->
<div class="modal fade" id="modal_response" role="dialog">
    <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
        <div class="modal-header bg-primary">
            <span class="box-tools pull-right">
            <button type="button" role="button" class="btn btn-secondary btn-sm" data-dismiss="modal" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></button>
            </span>
            <h4 class="modal-title float-left" id="modal_response_title">Processing</h4>
        </div>
            <div class="modal-body container-fluid" id="modal_response_body"><h2><i class="fas fa-spinner fa-pulse"></i></h2></div>
            <div class="modal-footer bg-primary">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
            </div>
    </div>
    </div>
</div>
<!-- /.modal -->
        
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
            <table datatable="" id="mainGrid" class="table table-hover table-bordered table-striped">
        <thead>
        <tr class="bg-primary">
            <% IF blnShowRowActions THEN %><th><%= GetWord("Actions") %></th><% END IF 
    FOR nIndex = 0 TO dvFields.UBound
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
    // pre-submit callback 
    function preRequest(formData, jqForm, options) {
        // jqForm is a jQuery object encapsulating the form element.  To access the 
        // DOM element for the form do this: 
        var formElement = jqForm[0];

        $(formElement.getAttribute('form-modal')).modal('hide');
        //respite_crud.dt.buttons.info('Processing...', '<h3 class="text-center"><i class="fas fa-spinner fa-pulse"></i></h3>');
        $('#modal_response_body').html('<h2 class="text-center"><i class="fas fa-spinner fa-pulse"></i></h2>');
        $('#modal_response_title').text('<%= GetWord("Processing...") %>');
        $('#modal_response .modal-header').removeClass().addClass("modal-header bg-primary");
        $('#modal_response .modal-footer').removeClass().addClass("modal-footer bg-primary");
        $('#modal_response').modal('show');

        // returning anything other than false will allow the form submit to continue 
        return true;
    }

    // post-submit callback 
    function showResponse(response, statusType, xhr, $form) {
        // for normal html responses, the first argument to the success callback 
        // is the XMLHttpRequest object's responseText property 

        // if the ajaxForm method was passed an Options Object with the dataType 
        // property set to 'xml' then the first argument to the success callback 
        // is the XMLHttpRequest object's responseXML property 

        // if the ajaxForm method was passed an Options Object with the dataType 
        // property set to 'json' then the first argument to the success callback 
        // is the json data object returned by the server 
        //var btnsm = '<div class="ml-auto float-right"><button type="button" role="button" class="btn btn-secondary btn-sm" onclick="respite_crud.dt.buttons.info(false)" aria-label="Close" title="Close"><span aria-hidden="true">&times;</span></button></div>';
        //var btn = '<br/><br/><button type="" class="btn btn-secondary" onclick="respite_crud.dt.buttons.info(false)">Close</button>';
        if (statusType == 'error') {
            //respite_crud.dt.buttons.info('<i class="fas fa-exclamation-triangle"></i> ' + response.status + ' ' + response.statusText + btnsm, 'Response Body:<br/><div class="alert alert-danger">' + respite_crud.escapeHtml(response.responseText) + '</div>' + btn);
            $('#modal_response .modal-header').removeClass().addClass("modal-header bg-danger");
            $('#modal_response .modal-footer').removeClass().addClass("modal-footer bg-danger");
            $('#modal_response_title').html('<i class="fas fa-exclamation-triangle"></i> ' + response.status + ' ' + response.statusText);
            $('#modal_response_body').html(response.responseText);
        }
        else {
            //respite_crud.dt.buttons.info('<i class="fas fa-check-circle"></i> ' + xhr.statusText + btnsm, response['data'] + btn, 10000);
            $('#modal_response .modal-header').removeClass().addClass("modal-header bg-success");
            $('#modal_response .modal-footer').removeClass().addClass("modal-footer bg-success");
            $('#modal_response_title').html('<i class="fas fa-check-circle"></i> ' + xhr.statusText);
            $('#modal_response_body').html(response['data']);
        }
        // refresh datatable:
        respite_crud.dt.ajax.reload();

        //alert('status: ' + statusType + '\n\nresponse: \n' + response['data'] + 
        //    '\n\nThe output div should have already been updated with the responseText.'); 
    }

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

    // Override some options
    respite_crud.respite_editor_options.dt_Options.dt_AjaxGet = "ajax_dataview.asp?mode=datatable&ViewID=<%= nViewID %>";
    respite_crud.respite_editor_options.modal_Options.pre_submit_callback = preRequest;
    respite_crud.respite_editor_options.modal_Options.response_success_callback = showResponse;
    respite_crud.respite_editor_options.modal_Options.response_error_callback = showResponse;
    respite_crud.respite_editor_options.modal_Options.ajax_forms_selector = "form.ajax-form";

    // DataTable Columns:
    // TODO: Simplify the addColumn() function interface
    respite_crud
        .addInlineActionButtonsColumn()
        <% IF strError = "" THEN
        FOR nIndex = 0 TO dvFields.UBound
        IF (dvFields(nIndex)("FieldFlags") AND 9) > 0 THEN
    %>.addColumn({
        "name": "Field_<%= dvFields(nIndex)("FieldID") %>",
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
                "type": "<%
                Select Case dvFields(nIndex)("FieldType")
            Case 1
            Response.Write "text"
            Case 2
            Response.Write "textarea"
            Case 3
            Response.Write "numeric"
            Case 4
            Response.Write "decimal"
            Case 5
            Response.Write "select"
            Case 6
            Response.Write "csv"
            Case 7
            Response.Write "date"
            Case 8
            Response.Write "datetime"
            Case 9
            Response.Write "boolean"
            Case 10
            Response.Write "link"
            Case 11
            Response.Write "image"
            Case 12
            Response.Write "password"
            Case 13
            Response.Write "time"
            Case 14
            Response.Write "rte"
            Case 15
            Response.Write "email"
            Case 16
            Response.Write "phone"
        Case Else
            Response.Write "text"
        End Select                
                %>",       // field type
                "default_value": "<%= Sanitizer.JSON(dvFields(nIndex)("DefaultValue")) %>",   // default value
                <%
                IF (dvFields(nIndex)("FieldFlags") AND 16) > 0 THEN %>"searchable": false,<%
                END IF %>
                // collection of custom attributes to apply to the input field element: { attrName: attrValue, ... }
                "attributes": { "placeholder": "<%= Sanitizer.JSON(dvFields(nIndex)("FieldLabel")) %>"<%
                    IF dvFields(nIndex)("MaxLength") <> "" AND dvFields(nIndex)("MaxLength") <> Null THEN
                    %>, "maxlength": <%= dvFields(nIndex)("MaxLength") %><%
                    END IF
                    IF (dvFields(nIndex)("FieldFlags") AND 2) > 0 THEN
                    %>, "required": true<%
                    END IF
                    IF (dvFields(nIndex)("FieldFlags") AND 4) > 0 THEN 
                    %>, "readonly": true<%
                    END IF %>}
                <% IF dvFields(nIndex)("FieldType") = 5 OR dvFields(nIndex)("FieldType") = 6 THEN
                Response.Write ", ""options"": [ "
                Dim rsOptions
                SET rsOptions = Server.CreateObject("ADODB.Recordset")
                strSQL = "SELECT " & dvFields(nIndex)("LinkedTableValueField") & " AS [value], " & dvFields(nIndex)("LinkedTableTitleField") & " AS [title], "
                IF dvFields(nIndex)("LinkedTableGroupField") <> "" THEN
                strSQL = strSQL & dvFields(nIndex)("LinkedTableGroupField")
                ELSE
                    strSQL = strSQL & "''"
                END IF
                strSQL = strSQL & " AS [group] FROM " & dvFields(nIndex)("LinkedTable") '& dvFields(nIndex)("LinkedTableAddition")

                rsOptions.Open strSQL, adoConnCrudeSrc
                WHILE NOT rsOptions.EOF
            %>{ "group": "<%= Sanitizer.JSON(rsOptions("group")) %>", "value": "<%= Sanitizer.JSON(rsOptions("value")) %>", "label": "<%= Sanitizer.JSON(rsOptions("title")) %>" }<%
                rsOptions.MoveNext
                IF NOT rsOptions.EOF THEN Response.Write ", "
                WEND
                rsOptions.Close
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
            className: "btn btn-primary btn-sm",
            action: function (e, dt, node, config) {
                <%= dvActionsToolbar(nIndex)("NgClickJSCode") %>
            }
        })<%
    NEXT
    END IF
    %>
        /*
        // Custom toolbar buttons example
        .addToolbarActionButton(
        {
            text: '<i class="fas fa-exclamation-triangle"></i> Select Reds',
            className: "btn btn-danger btn-sm",
            action: function (e, dt, node, config) {
                dt.rows('.bg-danger').select();
            }
        })
        .addToolbarActionButton({
            text: '<i class="fas fa-info-circle"></i> Inspect Selected',
            className: "btn btn-info btn-sm",
            action: function (e, dt, node, config) {
                var r = dt.rows({ selected: true }).data();
                alert("Inspecting " + r.length + " rows (check the console)");
                console.log(r);
            }
        })*/
        // Inline buttons
<% IF blnAllowRowDetails THEN %>
        .addDetailsButton() //formatDetails)<% END IF
            IF blnAllowClone THEN %>
        .addCloneButton("<%= GetWord("Clone") %>")<% END IF
            IF blnAllowUpdate THEN %>
        .addEditButton("<%= GetWord("Edit") %>")<% END IF
            IF blnAllowDelete THEN %>
        .addDeleteButton("<%= GetWord("Delete") %>")<% END IF %>
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

        // Bind Data Manipulation Forms to Ajax
        respite_crud.initAjaxForm({
            beforeSubmit: preRequest,
            success: showResponse,
            error: showResponse,
            dataType: 'json'
        });

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
            scroller: { loadingIndicator: true },<% END IF %><% IF blnDtStateSave THEN %>
            stateSave: true,<% END IF %>
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