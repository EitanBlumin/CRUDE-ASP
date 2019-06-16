
    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

  <!-- Main Footer -->
    <footer class="main-footer">
        <strong>Copyright &copy; 2018 <a href="https://git.eitanblumin.com/CRUDE-ASP/" target="_blank">Eitan Blumin</a>.</strong>
        All rights reserved.
        <div class="float-right d-none d-sm-inline-block">
            <b>Version</b> 0.8-alpha
             | <b>Powered by</b> <a href="https://adminlte.io/" target="_blank">AdminLTE</a>
        </div>
    </footer>

    <!-- Control Sidebar -->
    <aside class="control-sidebar control-sidebar-dark">
        <!-- Control sidebar content goes here -->
<% IF globalIsAdmin THEN %>
      <!-- Settings tab content -->
      <div class="p-3" id="control-sidebar-settings-tab">
        <section class="sidebar">
            <h5>Administration</h5>
            <hr class="mb-2">
            <h6>Manage</h6>
            <ul class="nav nav-sidebar flex-column">
                <li class="nav-item"><a class="nav-link" href="<%= SITE_ROOT %>dataview.asp?ViewID=-1"><i class="fas fa-cogs"></i> Manage Data Views</a></li>
                <li class="nav-item"><a class="nav-link" href="<%= SITE_ROOT %>dataview.asp?ViewID=-4"><i class="fas fa-link"></i> Manage Navigation</a></li>
            </ul>
<% IF Right(Request.ServerVariables("SCRIPT_NAME"), Len("/dataview.asp")) = "/dataview.asp" THEN %>
            <hr class="mb-2">
            <h6>Manage This DataView</h6>
            <ul class="nav nav-sidebar flex-column">
                <li class="nav-item"><a class="nav-link" href="<%= SITE_ROOT %>dataview.asp?ViewID=-1&mode=edit&DT_ItemId=<%= nViewID %>"><i class="fas fa-edit"></i> <%= GetWord("Edit DataView") %></a></li>
                <li class="nav-item"><a class="nav-link" href="<%= SITE_ROOT %>dataview.asp?ViewID=-2&dataview[search]=<%= nViewID %>"><i class="fas fa-bars"></i> <%= GetWord("Edit Fields") %></a><//li>
                <li class="nav-item"><a class="nav-link" href="<%= SITE_ROOT %>dataview.asp?ViewID=-3&dataview[search]=<%= nViewID %>"><i class="fas fa-bolt"></i> <%= GetWord("Edit Actions") %></a><//li>
            </ul>
<% END IF %>
        </section>
      </div>
      <!-- /.tab-pane -->
<% END IF %>
    </aside>
    <!-- /control-sidebar -->