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
Const constPageScriptName = "404.asp"
Dim strPageTitle
strPageTitle = "404 Page Not Found"

Dim query_string : query_string = request.ServerVariables("QUERY_STRING")
if query_string <> "" then
	query_string = "?" & query_string
end if
Dim ServerProtocol, ServerPort
IF Request.ServerVariables("HTTPS") = "off" THEN ServerProtocol = "http://" ELSE ServerProtocol = "https://"
IF Request.ServerVariables("SERVER_PORT") <> "80" THEN ServerPort = ":" & Request.ServerVariables("SERVER_PORT") ELSE ServerPort = ""
Dim BasePath : BasePath = "404;" & ServerProtocol & request.ServerVariables("SERVER_NAME") & ServerPort
Dim RequestedPath : RequestedPath = Replace(LCase(Request.ServerVariables("QUERY_STRING")), LCase(BasePath & SITE_ROOT), "")

Dim pathStack : pathStack = Split(RequestedPath, "/")
IF UBound(pathStack) > 0 THEN
    Dim newURL
    SELECT CASE pathStack(0)
        case "dataview"
            newURL = SITE_ROOT & "dataview.asp?viewid=" & pathStack(1)
            IF UBound(pathStack) > 1 THEN
                IF UBound(pathStack) > 2 THEN
                    newURL = newURL & "&mode=" & pathStack(2) & "&DT_ItemId=" & pathStack(3)
                ELSE
                    newURL = newURL & "&mode=edit&DT_ItemId=" & pathStack(2)
                END IF
            END IF
            Response.Redirect(newURL)
    END SELECT
END IF

' Open DB Connection
'=======================
adoConn.Open
%><!--#include file="dist/asp/inc_crudeconstants.asp" -->
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
        <li><a href="<%= SITE_ROOT %>default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li class="active"><%= strPageTitle %></li>
      </ol>

    </section>

    <!-- Main content -->
    <section class="content container-fluid">
        
      <div class="error-page">
        <h2 class="headline text-yellow"> 404</h2>

        <div class="error-content">
          <h3><i class="fas fa-exclamation-triangle text-yellow"></i> Oops! Page not found.</h3>

          <div>
            We could not find the page you were looking for.
            <br />
            Meanwhile, you may <a href="<%= SITE_ROOT %>"default.asp">return to dashboard</a> or try using the search form.
          </div>

          <form class="search-form">
            <div class="input-group">
              <input type="text" name="search" class="form-control" placeholder="Search">

              <div class="input-group-btn">
                <button type="submit" name="submit" class="btn btn-warning btn-flat"><i class="fas fa-search"></i>
                </button>
              </div>
            </div>
            <!-- /.input-group -->
          </form>
        </div>
        <!-- /.error-content -->
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
<script src="<%= SITE_ROOT %>dist/js/adminlte.min.js"></script>

<!-- Optionally, you can add Slimscroll and FastClick plugins.
     Both of these plugins are recommended to enhance the
     user experience. -->

<script type="text/javascript">
    var pathStack = window.location.pathname.split('/');
    if (false && pathStack.length > 3) {
        var newURL;
        switch (pathStack[2]) {
            case "dataview":
                newURL = "<%= SITE_ROOT %>dataview.asp?viewid=" + pathStack[3];
                if (pathStack.length > 4) {
                    if (pathStack.length > 5) {
                        newURL += '&mode=' + pathStack[4] + '&DT_ItemId=' + pathStack[5];
                    } else {
                        newURL += '&mode=edit&DT_ItemId=' + pathStack[4];
                    }
                }
                window.location.replace(newURL);
                break;
            default:
        };
    }
</script>
</body>
</html>