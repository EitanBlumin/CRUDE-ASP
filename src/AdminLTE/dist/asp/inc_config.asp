<%
Option Explicit
'******************************GetConfigValue*******************************
' Purpose:      Utility function to get value from a configuration file.
' Conditions:   CONFIG_FILE_PATH must be refer to a valid XML file
' Input:        sectionName - a section in the file, eg, appSettings
'               attrName - refers to the "key" attribute of an entry
' Output:       A string containing the value of the appropriate entry
'***************************************************************************
Dim CONFIG_FILE_PATH
CONFIG_FILE_PATH = "web.config" 'if no qualifier, refers to this directory. can point elsewhere.

Dim CONFIG_FILE_XML ' load config file only once    
Set CONFIG_FILE_XML=Server.CreateObject("Microsoft.XMLDOM")
CONFIG_FILE_XML.Async = "false"
CONFIG_FILE_XML.Load(Server.MapPath(CONFIG_FILE_PATH))

Function GetConfigValue(sectionName, keyAttrName, valAttrName, attrName, defaultValue)
    Dim oNode, oChild, oAttr, val
    Set oNode = CONFIG_FILE_XML.GetElementsByTagName(sectionName).Item(0) 
    Set oChild = oNode.GetElementsByTagName("add")
    ' Get the first match
    For Each oAttr in oChild 
        If oAttr.getAttribute(keyAttrName) = attrName then
            val = oAttr.getAttribute(valAttrName)
            GetConfigValue = val
            Exit Function
        End If
    Next

    GetConfigValue = defaultValue
End Function

' Enforce Local access only
' ============================
IF Right(Request.ServerVariables("SCRIPT_NAME"), Len("/restricted.asp")) <> "/restricted.asp" THEN
    IF Request.ServerVariables("SERVER_NAME") <> "127.0.0.1" AND LCase(Request.ServerVariables("SERVER_NAME")) <> "localhost" THEN 
        Response.Redirect "restricted.asp"
    END IF
END IF

' Connection string
' =====================
Dim adoConStr, adoConn, strError, adoConnCrudeStr, adoConnCrude
adoConStr = GetConfigValue("connectionStrings", "name", "connectionString", "Default", "Provider=SQLOLEDB;Data Source=.\DEV2016;User ID=CrudeLogin;Password=CrudePassword;Initial Catalog=CrudePortalDB;Application Name=" & Request.ServerVariables("SCRIPT_NAME"))
adoConnCrudeStr = adoConStr 'compatibility with respite

' Define global connection object
' ================================
Set adoConn = Server.CreateObject("ADODB.Connection")
adoConn.ConnectionString = adoConStr
adoConn.CommandTimeout = 0
SET adoConnCrude = adoConn 'compatibility with respite

' Global Variables
' ============================
Dim rsItems, strSQL, SITE_ROOT
Dim globalIsAdmin, constPortalTitle, globalToastrOptions, globalBodyClass, globalWebPortalAdminEnabled
SITE_ROOT = GetConfigValue("appSettings", "key", "value", "SiteRootPath", "/CrudePortal/")
globalWebPortalAdminEnabled = CBool(GetConfigValue("appSettings", "key", "value", "WebPortalAdminEnabled", "False"))

constPortalTitle = GetConfigValue("appSettings", "key", "value", "PortalTitle", "CrudeASP")
globalIsAdmin = True
globalBodyClass = "hold-transition skin-blue sidebar-fixed sidebar-mini"
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