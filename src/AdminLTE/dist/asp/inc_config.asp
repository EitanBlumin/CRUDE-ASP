<%
Option Explicit
' Enforce Local access only
' ============================
IF Right(Request.ServerVariables("SCRIPT_NAME"), Len("/restricted.asp")) <> "/restricted.asp" THEN
    IF Request.ServerVariables("SERVER_NAME") <> "127.0.0.1" AND LCase(Request.ServerVariables("SERVER_NAME")) <> "localhost" THEN 
        Response.Redirect "restricted.asp"
    END IF
END IF

' Connection string
' =====================
Dim adoConStr, adoConn, strError
adoConStr = "Provider=SQLOLEDB;Data Source=127.0.0.1;User ID=CrudeLogin;Password=CrudePassword;Initial Catalog=CrudePortalDB;Application Name=" & Request.ServerVariables("SCRIPT_NAME")

' Define global connection object
' ================================
Set adoConn = Server.CreateObject("ADODB.Connection")
adoConn.ConnectionString = adoConStr
adoConn.CommandTimeout = 0

' Global Variables
' ============================
Dim globalIsAdmin, constPortalTitle, globalToastrOptions

constPortalTitle = "CrudeASP"
globalIsAdmin = True
globalToastrOptions = "" & VbCrLf & _
"   'closeButton': true," & VbCrLf & _
"   'debug': false," & VbCrLf & _
"   'newestOnTop': true," & VbCrLf & _
"   'progressBar': true," & VbCrLf & _
"   'positionClass': 'toast-bottom-left'," & VbCrLf & _
"   'preventDuplicates': false," & VbCrLf & _
"   'onclick': null," & VbCrLf & _
"   'showDuration': '300'," & VbCrLf & _
"   'hideDuration': '1000'," & VbCrLf & _
"   'timeOut': '5000'," & VbCrLf & _
"   'extendedTimeOut': '1000'," & VbCrLf & _
"   'showEasing': 'swing'," & VbCrLf & _
"   'hideEasing': 'linear'," & VbCrLf & _
"   'showMethod': 'slideDown'," & VbCrLf & _
"   'hideMethod': 'fadeOut'" & VbCrLf
%>
<!--#include file="inc_functions.asp" -->