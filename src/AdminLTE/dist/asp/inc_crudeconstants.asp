<%
class DataViewLookupClassExtendable
    private dictProperties
    public Count
    
    public property Get UBound
        UBound = Count - 1
    end property
    
    public property Get Items
        SET Items = dictProperties.Items
    end property

    private sub Class_Initialize
        Count = 0
        Set dictProperties = Server.CreateObject("Scripting.Dictionary")
    end sub

    public default function GetProp(pKey)
	    IF NOT dictProperties.Exists(pKey) THEN
		    GetProp = Null
	    Else
		    GetProp = dictProperties.Item(pKey)
	    END IF	
    end function

    public sub SetProp(pKey, pItem)
	    IF NOT dictProperties.Exists(pKey) THEN
		    dictProperties.Add pKey, pItem
            Count = Count + 1
	    Else
		    SET dictProperties.Item(pKey) = pItem
	    END IF
    end sub

end class

class DataViewLookupClass
    public Value
    public Label
    public Glyph
    public DefaultValue
    public Tooltip
    public CSSClass
    public ShowText
    public ShowGlyph
    public Wrappers
    public Identifier
    
    public default function Init(pValue, pLabel)
        Value = pValue
        Label = pLabel
        SET Init = me
    end function

end class
    
class DataViewLookupCollectionClass
    private dictObj
    public Count
    
    public property Get UBound
        UBound = Count - 1
    end property
    
    public property Get Items
        Items = dictObj.Items
    end property
    
    public property Get Keys
        SET Keys = dictObj.Keys
    end property

    private sub Class_Initialize
        Count = 0
        Set dictObj = Server.CreateObject("Scripting.Dictionary")
    end sub

    public default function GetItem(pKey)

	    IF NOT dictObj.Exists(CStr(pKey)) THEN
		    SET GetItem = Nothing
	    Else
		    SET GetItem = dictObj.Item(CStr(pKey))
	    END IF	
    end function

    public sub AddItem(pKey, pItem)
	    IF NOT dictObj.Exists(CStr(pKey)) THEN
		    dictObj.Add CStr(pKey), pItem
            Count = Count + 1
	    Else
		    SET dictObj.Item(CStr(pKey)) = pItem
	    END IF
    end sub

end class

Dim luTmpObject, luTmpIndex

SET rsItems = Server.CreateObject("ADODB.Recordset")

'==============================
' Data View Flags
'==============================

Dim arrDataViewFlags
Const dvfValue = 0
Const dvfLabel = 1
Const dvfGlyph = 2
Const dvfDefault = 3

strSQL = "SELECT * FROM portal.DataViewFlags ORDER BY FlagValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewDataTableFlags ORDER BY FlagValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewModifierButtonStyles ORDER BY StyleValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewPagingTypes ORDER BY StyleValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewFieldFlags ORDER BY FlagValue ASC; " & vbCrLf & _
         "SELECT * FROM portal.DataViewFieldTypes ORDER BY TypeValue ASC;" & vbCrLf & _
         "SELECT * FROM portal.DataViewUriStyles ORDER BY StyleValue ASC; "
rsItems.Open strSQL, adoConnCrudeStr

arrDataViewFlags = rsItems.GetRows()

SET rsItems = rsItems.NextRecordset()

Dim luDataViewFlags
SET luDataViewFlags = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataViewFlags, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataViewFlags(dvfValue, luTmpIndex), arrDataViewFlags(dvfLabel, luTmpIndex))
    luTmpObject.Glyph = arrDataViewFlags(dvfGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataViewFlags(dvfDefault, luTmpIndex)

    luDataViewFlags.AddItem arrDataViewFlags(dvfValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing

'==============================
' Data Table Flags
'==============================

Dim arrDataTableFlags
Const dtfValue = 0
Const dtfLabel = 1
Const dtfTooltip = 2
Const dtfGlyph = 3
Const dtfDefault = 4

arrDataTableFlags = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()
    
Dim luDataTableFlags
SET luDataTableFlags = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataTableFlags, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataTableFlags(dtfValue, luTmpIndex), arrDataTableFlags(dtfLabel, luTmpIndex))
    luTmpObject.Tooltip = arrDataTableFlags(dtfTooltip, luTmpIndex)
    luTmpObject.Glyph = arrDataTableFlags(dtfGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataTableFlags(dtfDefault, luTmpIndex)

    luDataTableFlags.AddItem arrDataTableFlags(dtfValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing

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

arrDataTableModifierButtonStyles = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()
    
Dim luDataTableModifierButtonStyles
SET luDataTableModifierButtonStyles = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataTableModifierButtonStyles, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataTableModifierButtonStyles(dtbsValue, luTmpIndex), arrDataTableModifierButtonStyles(dtbsLabel, luTmpIndex))
    luTmpObject.CSSClass = arrDataTableModifierButtonStyles(dtbsClass, luTmpIndex)
    luTmpObject.ShowText = arrDataTableModifierButtonStyles(dtbsShowText, luTmpIndex)
    luTmpObject.ShowGlyph = arrDataTableModifierButtonStyles(dtbsShowGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataTableModifierButtonStyles(dtbsDefault, luTmpIndex)

    luDataTableModifierButtonStyles.AddItem arrDataTableModifierButtonStyles(dtbsValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing
    
'==============================
' Data Table Paging Styles
'==============================

Dim arrDataTablePagingStyles
Const dtpsValue = 0
Const dtpsLabel = 1
Const dtpsDefault = 2

arrDataTablePagingStyles = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()

Dim luDataTablePagingStyles
SET luDataTablePagingStyles = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataTablePagingStyles, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataTablePagingStyles(dtpsValue, luTmpIndex), arrDataTablePagingStyles(dtpsLabel, luTmpIndex))
    luTmpObject.DefaultValue = arrDataTablePagingStyles(dtpsDefault, luTmpIndex)

    luDataTablePagingStyles.AddItem arrDataTablePagingStyles(dtpsValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing
    
'==============================
' Data View Field Flags
'==============================

Dim arrDataViewFieldFlags
Const dvffValue = 0
Const dvffLabel = 1
Const dvffGlyph = 2
Const dvffDefault = 3

arrDataViewFieldFlags = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()

Dim luDataViewFieldFlags
SET luDataViewFieldFlags = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataViewFieldFlags, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataViewFieldFlags(dvffValue, luTmpIndex), arrDataViewFieldFlags(dvffLabel, luTmpIndex))
    luTmpObject.Glyph = arrDataViewFieldFlags(dvffGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataViewFieldFlags(dvffDefault, luTmpIndex)

    luDataViewFieldFlags.AddItem arrDataViewFieldFlags(dvffValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing

'==============================
' Data View Field Types
'==============================

Dim arrDataViewFieldTypes
Const dvftValue = 0
Const dvftLabel = 1
Const dvftWrappers = 2
Const dvftIdentifier = 3

arrDataViewFieldTypes = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()

Dim luDataViewFieldTypes
SET luDataViewFieldTypes = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataViewFieldTypes, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataViewFieldTypes(dvftValue, luTmpIndex), arrDataViewFieldTypes(dvftLabel, luTmpIndex))
    luTmpObject.Wrappers = arrDataViewFieldTypes(dvftWrappers, luTmpIndex)
    luTmpObject.Identifier = arrDataViewFieldTypes(dvftIdentifier, luTmpIndex)
    'Response.Write "DV Field Type: " & arrDataViewFieldTypes(dvftValue, luTmpIndex) & " (" & luTmpObject.Label & ")<br>" & vbCrLf
    luDataViewFieldTypes.AddItem arrDataViewFieldTypes(dvftValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing
    
'==============================
' Uri Link Styles
'==============================

Dim arrDataViewUriStyles
Const dvusValue = 0
Const dvusLabel = 1
Const dvusClass = 2
Const dvusGlyph = 3
Const dvusDefault = 4

arrDataViewUriStyles = rsItems.GetRows()
    
SET rsItems = rsItems.NextRecordset()
    
Dim luDataViewUriStyles
SET luDataViewUriStyles = new DataViewLookupCollectionClass
FOR luTmpIndex = 0 TO UBound(arrDataTableModifierButtonStyles, 2)
    SET luTmpObject = (new DataViewLookupClass)(arrDataViewUriStyles(dvusValue, luTmpIndex), arrDataViewUriStyles(dvusLabel, luTmpIndex))
    luTmpObject.CSSClass = arrDataViewUriStyles(dvusClass, luTmpIndex)
    luTmpObject.Glyph = arrDataViewUriStyles(dvusGlyph, luTmpIndex)
    luTmpObject.DefaultValue = arrDataViewUriStyles(dvusDefault, luTmpIndex)

    luDataViewUriStyles.AddItem arrDataViewUriStyles(dvusValue, luTmpIndex), luTmpObject
NEXT

SET luTmpObject = Nothing
    
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
    
FUNCTION InitDataViewFields (pViewID, pDBConnection)
    Dim tmpCollection, tmpObj, tmpColumn, tmpIndex, tmpRs

    SET tmpCollection = new DataViewLookupCollectionClass

    IF pViewID <> "" AND IsNumeric(pViewID) THEN
        SET tmpRs = Server.CreateObject("ADODB.Command")
        tmpRs.ActiveConnection = pDBConnection
        tmpRs.CommandText = "SELECT * FROM portal.DataViewField WHERE ViewID = ? ORDER BY FieldOrder ASC"
    
        SET tmpRs = tmpRs.Execute (,pViewID,adOptionUnspecified)

        'tmpRs.Open "SELECT * FROM portal.DataViewField WHERE ViewID = " & pViewID & " ORDER BY FieldOrder ASC", pDBConnection
        tmpIndex = 0
        WHILE NOT tmpRs.EOF
            SET tmpObj = new DataViewLookupClassExtendable

            For Each tmpColumn IN tmpRs.Fields
                tmpObj.SetProp tmpColumn.Name, tmpColumn.Value
            Next

            tmpCollection.AddItem tmpIndex, tmpObj
            tmpIndex = tmpIndex + 1

		    tmpRs.MoveNext()
        WEND
        tmpRs.Close
        SET tmpRs = Nothing
    END IF

    SET InitDataViewFields = tmpCollection
END FUNCTION

FUNCTION InitDataViewActions (pViewID, pIsInline, pDBConnection)
    Dim tmpCollection, tmpObj, tmpColumn, tmpIndex, tmpRs, tmpParams(1)
    tmpParams(0) = pViewID
    tmpParams(1) = CBool(pIsInline)
    SET tmpCollection = new DataViewLookupCollectionClass

    IF pViewID <> "" AND IsNumeric(pViewID) THEN
        SET tmpRs = Server.CreateObject("ADODB.Command")
        tmpRs.ActiveConnection = pDBConnection
        tmpRs.CommandText = "SELECT * FROM portal.DataViewAction WHERE ViewID = ? AND IsPerRow = ? ORDER BY ParentActionID ASC, ActionOrder ASC"
        SET tmpRs = tmpRs.Execute (,tmpParams,adOptionUnspecified)

        tmpIndex = 0
        WHILE NOT tmpRs.EOF
            SET tmpObj = new DataViewLookupClassExtendable

            For Each tmpColumn IN tmpRs.Fields
                tmpObj.SetProp tmpColumn.Name, tmpColumn.Value
            Next

            tmpCollection.AddItem tmpIndex, tmpObj
            tmpIndex = tmpIndex + 1

		    tmpRs.MoveNext()
        WEND
        tmpRs.Close
        SET tmpRs = Nothing
    END IF

    SET InitDataViewActions = tmpCollection
END FUNCTION

SET rsItems = Server.CreateObject("ADODB.Recordset")
    

' TODO: Simplify the addColumn() function interface
SUB InitDataViewFieldsJS(ByRef dvFields)
    Dim nIndex, strSQL

    FOR nIndex = 0 TO dvFields.UBound
      IF (dvFields(nIndex)("FieldFlags") AND 9) > 0 THEN
        %>.addColumn({
        "name": "<%= dvFields(nIndex)("FieldIdentifier") %>",
        "data": "<%= dvFields(nIndex)("FieldIdentifier") %>",
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
                        IF dvFields(nIndex)("FieldType") = 1 OR dvFields(nIndex)("FieldType") = 2 THEN
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
END SUB

SUB InitDataViewInlineActionButtonsJS (ByRef dvActionsInline)
    Dim nIndex

    FOR nIndex = 0 TO dvActionsInline.UBound %>
        .addInlineActionButton(
        {
            href: "javascript:void(0)",
            label: "<%= Sanitizer.JSON(dvActionsInline(nIndex)("ActionLabel")) %>",
            glyph: "<%= Sanitizer.JSON(dvActionsInline(nIndex)("GlyphIcon")) %>",
            "class": "<%= Sanitizer.JSON(dvActionsInline(nIndex)("CSSButton")) %>",
            title: "<%= Sanitizer.JSON(dvActionsInline(nIndex)("ActionTooltip")) %>"
         },
        function (e, tr, r, id) {
            var params = {}; // TODO: Add any action parameters to the "params" object + placeholder replacement
            <%
            Select Case dvActionsInline(nIndex)("ActionType")
            Case "javascript"
            Response.Write dvActionsInline(nIndex)("ActionExpression")
            Case "url"
            Response.Write "respite_crud.actionUrl(""" & Sanitizer.JSON(dvActionsInline(nIndex)("ActionExpression")) & """, " & LCase(dvActionsInline(nIndex)("OpenURLInNewWindow")) & ", params, r, undefined);"
            Case "db_command", "db_procedure"
            Response.Write "throw 'not yet implemented';"
            ' TODO: api call action type
            Case Else
            Response.Write "throw 'Action Type " & dvActionsInline(nIndex)("ActionType") & " unrecognized';"
            End Select
            %>}
        )<%
    NEXT
END SUB


Dim BreadCrumbCollection
SET BreadCrumbCollection = new DataViewLookupCollectionClass
                
SUB AddToBreadCrumbCollection (pLabel, pURL)
    Dim tmpObj, tmpColumn, tmpIndex
    
    tmpIndex = BreadCrumbCollection.UBound + 1

    SET tmpObj = new DataViewLookupClassExtendable
    tmpObj.SetProp "Label", pLabel
    tmpObj.SetProp "URL", pURL

    BreadCrumbCollection.AddItem tmpIndex, tmpObj
END SUB
            
SUB RenderBreadCrumbCollection()
    Dim nIndex

    FOR nIndex = 0 TO BreadCrumbCollection.UBound %>
                    <li class="breadcrumb-item"><a href="<%= BreadCrumbCollection(nIndex)("URL") %>"><%= BreadCrumbCollection(nIndex)("Label") %></a></li><%
    NEXT
END SUB
%>