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
Const constPageScriptName = "modal_test.asp"
Dim strPageTitle
strPageTitle = "New Page"

' Open DB Connection
'=======================
adoConn.Open
%>
<!DOCTYPE html>
<!--
This is a starter template page. Use this page to start your new project from
scratch. This page gets rid of all links and provides the needed markup only.
-->
<html>
<head>
  <title><%= constPageScriptName %></title>
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
      <h1><%= strPageTitle %></h1>

      <ol class="breadcrumb">
        <li><a href="default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li class="active"><%= strPageTitle %></li>
      </ol>

    </section>

    <!-- Main content -->
    <section class="content container-fluid">
        Hello, World! Put your content here.<br />
        <button type="button" class="btn btn-primary btn-test">Test me</button>
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->
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
    respite_crud.respite_editor_options.dt_Options.dt_AjaxGet = "ajax_dataview.asp?mode=datatable&ViewID=12";
    respite_crud.respite_editor_options.modal_Options.ajax_forms_selector = "form.ajax-form";

    $('.btn-test')[0].addEventListener("click", function (e) {
        var body = respite_crud.renderDMFormFields({
            "DT_RowId": 101,
            "Field_1": "Field 1 Value"
        }, [{
            "name": "Field_1",
            "data": "Field_1",
            "render": respite_crud.renderAutomatic,
            "editor_data": {
                "label": "Field 1 Label",
                "type": "text",
                "tooltip": "Field 1 Tooltip",
                "default_value": "",
                "attributes": { "placeholder": "Field 1 Placeholder", "maxlength": 15 }
            }
        }]);

        new BstrapModal("my tile", body).Show();
    });

</script>
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