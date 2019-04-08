
  <!-- Left side column. contains the logo and sidebar -->
  <aside class="main-sidebar">
    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">

        <% IF False THEN %>
      <!-- Sidebar user panel (optional) -->
      <div class="user-panel">
        <div class="pull-left image">
          <img src="<%= SITE_ROOT %>dist/img/user2-160x160.jpg" class="img-circle" alt="User Image">
        </div>
        <div class="pull-left info">
          <p>Alexander Pierce</p>
          <!-- Status -->
          <a href="#"><i class="fas fa-circle text-success"></i> Online</a>
        </div>
      </div>
        <% END IF %>

      <!-- Sidebar Menu -->
        
      <ul class="sidebar-menu" data-widget="tree" id="sideNavMenu">
        <li class="header">Menu</li>
        <!-- Optionally, you can add icons to the links -->
        <li><a href="#"><i class="fas fa-spinner fa-pulse"></i> Loading...</a></li>
      </ul>
<script>
function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    console.log(ca);
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            console.log("cookie: " + name);
            return c.substring(name.length, c.length);
        }
    }
    console.log("cookie not found: " + cname);
    return "";
}
function isNavLinkActive(navLink) {
    // not yet implemented
    return false;
}
function displayNavLink(navLink) {
    var txt = "";
    txt += '<li class="nav-link';
    if (navLink.ChildItems == undefined || navLink.ChildItems.length > 0)
        txt += ' treeview';
    if (isNavLinkActive(navLink))
        txt += ' active';
    if (navLink["ViewID"] != null && navLink["ViewID"] != undefined && navLink["ViewID"] != "")
        txt += '" view-id="' + navLink.ViewID;
    if (navLink["OpenUriInIFRAME"])
        txt += '" nav-id="' + navLink.NavId;

    txt += '"><a href="';

    if (navLink.ChildItems == undefined || navLink.ChildItems.length > 0)
        txt += "javascript:"
    else if (navLink["OpenUriInIFRAME"])
        txt += "<%= SITE_ROOT %>view.asp?NavID=" + navLink.NavId;
    else if (navLink["NavUri"])
        txt += navLink.NavUri;
    else if (navLink["ViewID"] != null && navLink["ViewID"] != undefined && navLink["ViewID"] != "")
        txt += "<%= SITE_ROOT %>dataview.asp?ViewID=" + navLink.ViewID;
    else
        txt += "#"

    txt += '" title="' + navLink.NavTooltip + '"';
    if (navLink["NavTooltip"] && (navLink.ChildItems == undefined || navLink.ChildItems.length == 0))
        txt += ' data-toggle="tooltip" data-placement="right"';

    txt += '><i class="' + navLink.NavGlyph + '"></i> <span>' + navLink.NavLabel + '</span>'
    
    if (navLink.ChildItems != undefined && navLink.ChildItems.length > 0)
    {
        txt += '<span class="pull-right-container"><i class="fas fa-angle-left pull-right"></i></span><ul class="treeview-menu">';
        for (y in navLink.ChildItems) {
            txt += displayNavLink(navLink.ChildItems[y]);
        }
        txt += '</ul>'
    } else {
        txt += '</a>';
    }

    txt += '</li>'
    return txt;
}
</script>
      <!-- /.sidebar-menu -->
    </section>
    <!-- /.sidebar -->
      
  </aside>
