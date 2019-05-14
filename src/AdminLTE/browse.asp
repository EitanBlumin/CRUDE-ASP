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
Const constPageScriptName = "browse.asp"
Dim strPageTitle
strPageTitle = "Browse"

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
    
        blnShowRowActions = CBool(blnAllowUpdate OR blnAllowDelete OR blnAllowClone OR strRowReorderCol <> "" OR blnAllowRowDetails)

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

IF NOT blnPublished OR strError <> "" THEN Response.Redirect "404.asp?msg=viewnotfound"

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
    Dim currErr
    For Each currErr In adoConnCrudeSrc.Errors
		strError = strError & "[" & currErr.Source & "] Error " & currErr.Number & ": " & currErr.Description & " | Native Error: " & currErr.NativeError & "<br/>"
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
<!-- JQuery Form -->
<script src="http://malsup.github.com/jquery.form.js"></script> 

<!-- Codemirror (codemirror.css, codemirror.js, xml.js, formatting.js) -->
<link rel="stylesheet" type="text/css" href="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/codemirror.css">
<link rel="stylesheet" type="text/css" href="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/theme/monokai.css">
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/codemirror.js"></script>
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/codemirror/3.20.0/mode/xml/xml.js"></script>
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/codemirror/2.36.0/formatting.js"></script>
</head>
<body class="<%= globalBodyClass %>">
<div class="wrapper">
<!--#include file="dist/asp/inc_header.asp" -->
      
<%
IF strError <> "" THEN
%>
    <div class="callout callout-danger alert-danger">
    <h4><%= GetWord("Critical Error!") %></h4>

    <p><%= strError %></p>
    </div>
  
<% ELSE %>

<div class="card">
    <div class="card-header">
        <div class="grid-buttons-container"></div>
    </div>
    <div class="card-body" id="contents">
        <h3 class="text-center"><i class="fas fa-circle-notch fa-spin"></i></h3>
    </div>
</div>

<!-- respite_crud -->
<script type="text/javascript" src="datatable_respite_crud.js"></script>
<!-- page scripts -->

<script type="text/javascript">
    // Init default options
    respite_crud.site_root = "<%= SITE_ROOT %>";
    respite_crud.setEditorOptions();

    // Init DataView Properties as Placeholders
    respite_crud.placeholderReplacements.push( {
        "key": "dataview",
        "values": {
            "id": <%= nViewID %>,
            "title": "<%= Sanitizer.JSON(strPageTitle) %>"
        }});

    // Override some options
    respite_crud.respite_editor_options.dt_Options.dt_AjaxGet = "<%= SITE_ROOT %>ajax_dataview.asp?mode=datatable&browse=true&columns[0][searchable]=true&columns[0][name]=DT_RowID&columns[0][data]=DT_RowID&columns[0][search][regex]=false&search[value]=&ViewID=<%= nViewID %>&columns[0][search][value]=<%= nItemID %>";
    respite_crud.respite_editor_options.modal_Options.modal_delete.modal_form_target = "<%= SITE_ROOT %>ajax_dataview.asp?ViewID=<%= nViewID %>";
    respite_crud.respite_editor_options.dt_Options.dt_BrowseMode = true;

    // DataView Fields:
    respite_crud
        <% IF strError = "" THEN
            InitDataViewFieldsJS dvFields
        END IF %>
   // Inline buttons
<%
IF strMode <> "add" AND strMode <> "clone" THEN

    IF blnAllowClone THEN %>
        .addCloneButton("<%= GetWord("Clone") %>", "<%= GetWord("Clone") %>")<% 
    END IF
    IF blnAllowUpdate THEN %>
        .addEditButton("<%= GetWord("Edit") %>", "<%= GetWord("Edit") %>")<% 
    END IF
    IF blnAllowDelete THEN %>
        .addDeleteButton("<%= GetWord("Delete") %>", "<%= GetWord("Delete") %>")<% 
    END IF
    IF blnShowCustomActions THEN
        InitDataViewInlineActionButtonsJS dvActionsInline
    END IF

END IF
%>;

// function for handling error
function handleError(errorThrown, textStatus) {
    console.log('returned ' + textStatus + ': ' + errorThrown);
    toastr.error(errorThrown, textStatus);
    $('#contents').html('<div class="callout callout-danger alert-danger"><h4>' + textStatus + '</h4><p>' + errorThrown + '</p></div>');
}
function loadPageContent() {
    // init toolbar
    var backBtn = $('<a class="btn btn-sm btn-primary" data-toggle="tooltip" title="<%= GetWord("Return to List") %>"><i class="fas fa-arrow-left"></i> <%= GetWord("Back") %></a>');
    var backUrl = respite_crud.getUrlParam("prev_link");
    var urlLink = window.location.href;

    if (backUrl == "undefined" || backUrl == undefined || backUrl == "")
        backUrl = "dataview.asp?ViewID=<%= nViewID %>";

    backBtn.attr('href', backUrl);

    $('.grid-buttons-container').empty().append(backBtn).append($('<span>&nbsp;</span>'));
    $('.grid-buttons-container').append($('<a href="javascript:void(0)" class="btn btn-sm btn-primary" data-toggle="tooltip" title="<%= GetWord("Refresh") %>"><i class="fas fa-sync"></i> <%= GetWord("Refresh") %></a>')
        .on('click', function() {loadPageContent();}));

    ($('.grid-buttons-container').parent())
            .append(
                $('<div class="card-tools"></div>')
                    .append($('<a class="btn btn-sm btn-light text-muted" role="button" data-toggle="tooltip" title="Get URL for this page"><i class="fas fa-link"></i></a>').attr('href', urlLink))
                );

    // request page contents
    $.ajax(respite_crud.respite_editor_options.dt_Options.dt_AjaxGet
        , {
            method: 'GET',
            dataType: 'json',
            error: function (jqXHR, textStatus, errorThrown) {
                handleError(errorThrown, textStatus);
            },
            success: function( response, textStatus, jqXHR ) {
                console.log('returned ' + textStatus);
                console.log(response);

                if (response['error']) {
                    handleError(response['error'], textStatus);
                } else if (response.recordsFiltered <= 0) {
                    handleError("<%= GetWord("Requested record not found") %>", "<%= GetWord("Not Found") %>");
                } else {
                    var d = response.data[0];
                    respite_crud.row = d;
                    var content = respite_crud.respite_editor_options.dt_Options.dt_DetailRowRender(d);
                    $('#contents').html(content);

                    $('.grid-buttons-container')
                        .append(respite_crud.renderInlineActionButtons());
                }
            }
        }
    );
}

loadPageContent();
</script>
<!-- /scripts -->
<% END IF %>
<!--#include file="dist/asp/inc_footer.asp" -->
</div>
<!-- ./wrapper -->

<!-- REQUIRED JS SCRIPTS -->
<!--#include file="dist/asp/inc_footer_jscripts.asp" -->
</body>
</html>