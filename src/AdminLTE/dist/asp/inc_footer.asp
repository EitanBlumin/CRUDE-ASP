
  <!-- Main Footer -->
  <footer class="main-footer">
    <!-- To the right -->
    <div class="pull-right hidden-xs">
      <b>Version</b> 0.1 | <b>Powered by</b> <a href="https://adminlte.io/" target="_blank">AdminLTE v2.4.5</a>
    </div>
    <!-- Default to the left -->
    <b>Copyright &copy; 2018 <a href="https://github.com/EitanBlumin/CRUDE-ASP" target="_blank">Eitan Blumin</a>.</b> All rights reserved.
  </footer>

<% IF Right(Request.ServerVariables("SCRIPT_NAME"), Len("/dataview.asp")) = "/dataview.asp" THEN %>
  <!-- Control Sidebar -->
  <aside class="control-sidebar control-sidebar-dark">
    <!-- Create the tabs -->
    <ul class="nav nav-tabs nav-justified control-sidebar-tabs">
      <!-- <li><a href="#control-sidebar-home-tab" data-toggle="tab"><i class="fa fa-home"></i></a></li> -->
      <li><a href="#control-sidebar-settings-tab" data-toggle="tab"><i class="fas fa-cogs"></i></a></li>
    </ul>
    <!-- Tab panes -->
    <div class="tab-content">
      <!-- Settings tab content -->
      <div class="tab-pane active" id="control-sidebar-settings-tab">
          <h3 class="control-sidebar-heading">Data View Settings</h3>

          <p class="row">
              <p>
                <a class="btn btn-primary btn-sm" href="admin_dataviews.asp?mode=edit&ItemID=<%= nViewID %>"><i class="fas fa-edit"></i> Edit Data View</a>
               </p>
              <p>
                <a class="btn btn-primary btn-sm" href="admin_dataviewfields.asp?ViewID=<%= nViewID %>"><i class="fas fa-bars"></i> Manage Data View Fields</a>
              </p>
          <!-- /.form-group -->
      </div>
      <!-- /.tab-pane -->
    </div>
  </aside>
  <!-- /.control-sidebar -->
  <!-- Add the sidebar's background. This div must be placed
       immediately after the control sidebar -->
  <div class="control-sidebar-bg"></div>
<% END IF %>
