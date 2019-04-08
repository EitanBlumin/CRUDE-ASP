
  <!-- Main Footer -->
  <footer class="main-footer">
    <!-- To the right -->
    <div class="pull-right hidden-xs">
      <b>Version</b> 0.7 | <b>Powered by</b> <a href="https://adminlte.io/" target="_blank">AdminLTE v2.4.5</a>
    </div>
    <!-- Default to the left -->
    <b>Copyright &copy; 2018 <a href="https://git.eitanblumin.com/CRUDE-ASP/" target="_blank">Eitan Blumin</a>.</b> All rights reserved.
  </footer>

<% IF globalIsAdmin THEN %>
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
        <section class="sidebar">
        <ul class="sidebar-menu">
            <li class="header">Data View Settings</li>
            <li role="presentation" class="nav-item"><a href="<%= SITE_ROOT %>dataview.asp?ViewID=-1"><i class="fas fa-th-list"></i> Manage Data Views</a></li>
            <li role="presentation" class="nav-item"><a href="<%= SITE_ROOT %>dataview.asp?ViewID=-4"><i class="fas fa-link"></i> Manage Navigation</a></li>
<% IF Right(Request.ServerVariables("SCRIPT_NAME"), Len("/dataview.asp")) = "/dataview.asp" THEN %>
            <li role="presentation" class="nav-item"><a class="nav-link" href="<%= SITE_ROOT %>dataview.asp?ViewID=-1&mode=edit&DT_ItemId=<%= nViewID %>"><i class="fas fa-edit"></i> Edit This Data View</a></li>
            <li role="presentation" class="nav-item"><a class="nav-link" href="<%= SITE_ROOT %>dataview.asp?ViewID=-2&dataview[search]=<%= nViewID %>"><i class="fas fa-bars"></i> Edit This Data View's Fields</a><//li>
<% END IF %>
        </ul>
        </section>
      </div>
      <!-- /.tab-pane -->
    </div>
  </aside>
  <!-- /.control-sidebar -->
  <!-- Add the sidebar's background. This div must be placed
       immediately after the control sidebar -->
  <div class="control-sidebar-bg"></div>
<% END IF %>