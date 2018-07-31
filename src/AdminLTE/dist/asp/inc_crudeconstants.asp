<%
SET rsItems = Server.CreateObject("ADODB.Recordset")
    
'==============================
' Data View Flags
'==============================

Dim arrDataViewFlags
Const dvfValue = 0
Const dvfLabel = 1
Const dvfGlyph = 2
Const dvfDefault = 3

strSQL = "SELECT * FROM portal.DataViewFlags ORDER BY FlagValue ASC"
rsItems.Open strSQL, adoConn

arrDataViewFlags = rsItems.GetRows()

rsItems.Close

'==============================
' Data Table Flags
'==============================

Dim arrDataTableFlags
Const dtfValue = 0
Const dtfLabel = 1
Const dtfTooltip = 2
Const dtfGlyph = 3
Const dtfDefault = 4

strSQL = "SELECT * FROM portal.DataViewDataTableFlags ORDER BY FlagValue ASC"
rsItems.Open strSQL, adoConn

arrDataTableFlags = rsItems.GetRows()

rsItems.Close
    
'==============================
' Data Table Button Styles
'==============================

Dim arrDataTableModifierButtonStyles
Const dtbsValue = 0
Const dtbsLabel = 1
Const dtbsClass = 2
Const dtbsShowText = 3
Const dtbsShowGlyph = 4
Const dtbsDefault = 5

strSQL = "SELECT * FROM portal.DataViewModifierButtonStyles ORDER BY StyleValue ASC"
rsItems.Open strSQL, adoConn

arrDataTableModifierButtonStyles = rsItems.GetRows()

rsItems.Close

'==============================
' Data View Field Flags
'==============================

Dim arrDataViewFieldFlags
Const dvffValue = 0
Const dvffLabel = 1
Const dvffGlyph = 2
Const dvffDefault = 3

strSQL = "SELECT * FROM portal.DataViewFieldFlags ORDER BY FlagValue ASC"
rsItems.Open strSQL, adoConn

arrDataViewFieldFlags = rsItems.GetRows()

rsItems.Close

'==============================
' Data View Field Types
'==============================

Dim arrDataViewFieldTypes
Const dvftValue = 0
Const dvftLabel = 1
Const dvftWrappers = 2

strSQL = "SELECT * FROM portal.DataViewFieldTypes ORDER BY TypeValue ASC"
rsItems.Open strSQL, adoConn

arrDataViewFieldTypes = rsItems.GetRows()

rsItems.Close
    
'==============================
' Uri Link Styles
'==============================

Dim arrDataViewUriStyles
Const dvusValue = 0
Const dvusLabel = 1
Const dvusGlyph = 2
Const dvusDefault = 3

strSQL = "SELECT * FROM portal.DataViewUriStyles ORDER BY StyleValue ASC"
rsItems.Open strSQL, adoConn

arrDataViewUriStyles = rsItems.GetRows()

rsItems.Close
    
'==============================
' Data View Field Columns
'==============================

Const dvfcViewID = 0
Const dvfcFieldID = 1
Const dvfcFieldLabel = 2
Const dvfcFieldSource = 3
Const dvfcFieldType = 4
Const dvfcFieldFlags = 5
Const dvfcFieldOrder = 6
Const dvfcDefaultValue = 7
Const dvfcMaxLength = 8
Const dvfcUriPath = 9
Const dvfcUriStyle = 10
Const dvfcLinkedTable = 11
Const dvfcLinkedTableGroupField = 12
Const dvfcLinkedTableTitleField = 13
Const dvfcLinkedTableValueField = 14
Const dvfcLinkedTableAddition = 15
Const dvfcWidth = 16
Const dvfcHeight = 17
Const dvfcFieldDescription = 18
%>