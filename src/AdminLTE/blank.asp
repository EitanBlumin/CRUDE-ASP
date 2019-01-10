<%@ LANGUAGE="VBSCRIPT" CODEPAGE="1255" %>
<!--#include file="dist/asp/inc_config.asp" -->
<%' use this meta tag instead of adovbs.inc%>
<!--METADATA TYPE="typelib" uuid="00000205-0000-0010-8000-00AA006D2EA4" -->
<%
Response.CodePage = 1255
Session.CodePage = 1255

' Local Constants
'=======================
Const constPageScriptName = "blank.asp"
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
  <title><%= constPortalTitle %></title>
<!--#include file="dist/asp/inc_meta.asp" -->
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
        <%
        Dim cmdStoredProc, nIndex, param, paramType
        strSQL = "usp_Generate_Merge_For_Table"
        Set cmdStoredProc = Server.CreateObject("ADODB.Command")
	    cmdStoredProc.ActiveConnection = adoConn
	    cmdStoredProc.CommandText = strSQL
	    cmdStoredProc.CommandType = adCmdStoredProc
    
        cmdStoredProc.Parameters.Refresh
        For each param in cmdStoredProc.Parameters
            'Set paramType = param.Type
            Response.Write param.Name & " (ad type " & param.Type & ")<br/>"
        Next
            
             %>
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