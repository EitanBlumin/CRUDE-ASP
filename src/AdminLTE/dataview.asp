<%@ LANGUAGE="VBSCRIPT" CODEPAGE="1255" %>
<!--#include file="dist/asp/inc_config.asp" -->
<%' use this meta tag instead of adovbs.inc%>
<!--METADATA TYPE="typelib" uuid="00000205-0000-0010-8000-00AA006D2EA4" -->
<%
Response.CodePage = 1255
Session.CodePage = 1255

' Local Constants
'=======================
Const constPageScriptName = "dataview.asp"

' Init Variables
'=======================
Dim strSQL, rsItems, nItemID, strMode, nCount, nIndex

' Open DB Connection
'=======================
adoConn.Open
%><!--#include file="dist/asp/inc_crudeconstants.asp" --><%
    
Dim blnFound, blnRequiredFieldsFilled, strViewIDString
Dim blnRTEEnabled, blnShowForm, blnShowList, blnAllowUpdate, blnAllowInsert, blnAllowDelete, blnAllowClone, blnAllowSearch, strOrderBy, strSearchFilter, strCurrFilter
Dim strLastOptGroup, blnOptGroupStarted
Set rsItems = Server.CreateObject("ADODB.Recordset")

Dim myRegEx
SET myRegEx = New RegExp
myRegEx.IgnoreCase = True
myRegEx.Global = True


'[ConfigVars]
' Init Form Variables from DB. This will be deleted when generated as a seperate file.
DIM nViewID, rsFields, arrViewFields, nColSpan
DIM nFieldsNum, nViewFlags, strPageTitle, strPrimaryKey, strMainTableName, strScriptName, strDataViewDescription, strFilterBackLink
Dim strFilterField, blnFilterRequired, cmdStoredProc, strViewProcedure, strModificationProcedure, strDeleteProcedure, varCurrFieldValue
Dim paramPK, paramMode, paramFilter, paramOrderBy

strError = ""
strSearchFilter = ""
strPageTitle = "Data View"

strMode = Request("mode")
IF strMode = "" THEN strMode = "none"

nViewID = Request("ViewID")
strScriptName = "dataview.asp"

IF nViewID <> "" AND IsNumeric(nViewID) THEN
	strSQL = "SELECT * FROM portal.DataView WHERE ViewID = " & nViewID
	rsItems.Open strSQL, adoConn
	IF NOT rsItems.EOF THEN
		strPageTitle = rsItems("Title")
        strDataViewDescription = rsItems("ViewDescription")

		SET rsFields = Server.CreateObject("ADODB.Recordset")
		rsFields.Open "SELECT * FROM portal.DataViewField WHERE ViewID = " & nViewID & " ORDER BY FieldOrder ASC", adoConStr
		IF NOT rsFields.EOF THEN
			arrViewFields = rsFields.GetRows()
		END IF
		rsFields.Close
		SET rsFields = Nothing
		
	ELSE
		strError = "ViewID Not Found!"
		nViewID = ""
	END IF
	rsItems.Close
ELSE
	strError = "ViewID Invalid!"
END IF

Dim strFilteredValue : strFilteredValue = Request(strFilterField & nViewID)


'***************
' Page Contents
'***************
%>
<!DOCTYPE html>
<html>
<head>
  <title><%= constPortalTitle %></title>
<!--#include file="dist/asp/inc_meta.asp" -->
</head>
<body class="hold-transition skin-blue sidebar-mini fixed" ng-app="CrudeApp" ng-controller="CrudeCtrl">
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
        <li><a href="default.asp"><i class="fas fa-tachometer-alt"></i> Home</a></li>
        <li class="active"><%= strPageTitle %></li>
      </ol>

    </section>

    <!-- Main content -->
    <section class="content container-fluid">

<div class="row">
    <div class="col col-sm-12">
        <a class="btn btn-primary" role="button" href="#"><i class="fas fa-arrow-left"></i> Back</a>
    </div>
</div>
<div class="row">
    <div class="col col-sm-12"><br />
        <small><%= strDataViewDescription %><//small>
    </div>
</div>
        <!-- Items List -->

<div class="box">
<div class="box-body">
<table datatable="ng" id="DataViewMainTable" class="table table-hover table-bordered table-striped">
<thead>
<tr><th>ID</th><%
    nColSpan = 1

    FOR nIndex = 0 TO UBound(arrViewFields, 2)
        nColSpan = nColSpan + 1 %>
    <th><%= arrViewFields(2, nIndex) %></th><%
     NEXT %><th>Actions</th>
</tr>
</thead>
<tbody>
    <tr ng-repeat="row in dataviewContents.data">
        <td ng-bind="row._ItemID"></td><%
    nColSpan = 1

    FOR nIndex = 0 TO UBound(arrViewFields, 2)
        nColSpan = nColSpan + 1 %>
    <td ng-bind="row['<%= arrViewFields(2, nIndex) %>']"></td><%
     NEXT %>
        <td ng-bind-html="row._Actions | trust"></td>
    </tr>
</tbody>
</table>
</div>
<!-- /.box-body -->
</div>
<!-- /.box -->

    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

<!--#include file="dist/asp/inc_footer.asp" -->
</div>
<!-- ./wrapper -->

<!-- REQUIRED JS SCRIPTS -->
<!--#include file="dist/asp/inc_footer_jscripts.asp" -->
    <!-- Angular -->
    <script src="bower_components/angular/angular.min.js"></script>
    <script src="bower_components/angular-datatables/dist/angular-datatables.min.js"></script>

<!-- AdminLTE App -->
<script src="dist/js/adminlte.min.js"></script>

<!-- Optionally, you can add Slimscroll and FastClick plugins.
     Both of these plugins are recommended to enhance the
     user experience. -->
<!-- page script -->
<script>
var app = angular.module("CrudeApp", ['datatables']);
app.filter("trust", ['$sce', function($sce) {
  return function(htmlCode){
    return $sce.trustAsHtml(htmlCode);
  }
}]);
app.controller("CrudeCtrl", function($scope, $http, $interval, $window) {   
    $scope.getAjaxData = function () {

      $http.get("ajax_dataview.asp?mode=dataviewcontents&ViewID=<%= nViewID %>")
      .then(function(response) {
            $scope.dataviewContents = response.data;
            console.log("loaded ajax data. num of rows: " + $scope.dataviewContents.data.length);
      }, function(response) {
            alert("Something went wrong: " + response.status + " " + response.statusText);
        });
    }
     
    $scope.openedItems = {};
    $scope.touchedItems = {};

    $scope.secondsInterval = 3;

    $scope.sortType     = 'Severity'; // set the default sort type
    $scope.sortReverse  = true;  // set the default sort order
    $scope.searchTerm   = '';     // set the default search/filter term

    $scope.setSort = function(newSort) {
        if ($scope.sortType == newSort) {
            $scope.sortReverse = !$scope.sortReverse;
        } else {
            $scope.sortType = newSort;
        }
    }
    
    $scope.setTitle = function(newTitle) {
        $window.document.title = newTitle;
    }

    $scope.startAutoRefresh = function () {
      $scope.doAutoRefresh = true;
        $scope.stop = $interval($scope.getAjaxData, $scope.secondsInterval * 1000);
    }

    $scope.stopAutoRefresh = function () {
      $scope.doAutoRefresh = false;
      $scope.stopInterval();
    }

    $scope.changeInterval = function () {
      if ($scope.doAutoRefresh && $scope.secondsInterval > 0 && $scope.secondsInterval <= 99)
        {
            $scope.stopAutoRefresh();
            $scope.startAutoRefresh();
        }
    }

    $scope.toggleAutoRefresh = function () {
      $scope.doAutoRefresh = !$scope.doAutoRefresh;
        if ($scope.doAutoRefresh)
        {
           $scope.startAutoRefresh(); 
        }
    }
    
    $scope.stopInterval = function () {
        if (angular.isDefined($scope.stop)) {
            $interval.cancel($scope.stop);
            $scope.stop = undefined;
        }
    };

    $scope.$on('$destroy', function () {
        // Make sure that the interval is destroyed too
        $scope.stopInterval();
    });
    
    $scope.doAutoRefresh = false;

    $scope.toggleItem = function (obj) {
        if ($scope.openedItems[obj]) {
            $scope.openedItems[obj] = false
        } else {
            $scope.openedItems[obj] = true;
        }
        $scope.touchedItems[obj] = true;
    }

    $scope.initItemVisibility = function (obj, ishidden) {
        if (!$scope.touchedItems[obj]) {
            $scope.openedItems[obj] = !$scope.touchedItems[obj] && !ishidden && !$scope.openedItems[obj];
        }
    }

    $scope.collapseAll = function () {
        angular.forEach($scope.openedItems, function (value, key) {
            $scope.openedItems[key] = false;
            $scope.touchedItems[key] = true;
        });
    }
    $scope.expandAll = function () {
        angular.forEach($scope.openedItems, function (value, key) {
            $scope.openedItems[key] = true;
            $scope.touchedItems[key] = true;
        });
    }

    $scope.getAjaxData();
});
</script>
</body>
</html>