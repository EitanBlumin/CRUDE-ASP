<!-- Main Sidebar Container -->
<aside class="main-sidebar sidebar-dark-primary elevation-4">
    <!-- Brand Logo -->
    <a href="<%= SITE_ROOT %>default.asp" class="brand-link">
        <!-- mini logo for sidebar mini 50x50 pixels -->
        <span class="brand-image img-circle elevation-3">
            <span class="fa-stack fa-1x">
            <i class="far fa-circle fa-stack-2x"></i>
            <i class="fas fa-tint fa-stack-1x"></i>
            </span>
        </span>
        <!-- logo for regular state and mobile devices -->
        <span class="brand-text font-weight-light">Crude<b>ASP</b></span>
    </a>
    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">
      <!-- Sidebar Menu -->
      <nav class="mt-2">
        <ul class="nav nav-sidebar flex-column" data-widget="treeview" role="menu" data-accordion="false" id="sideNavMenu">
            <!-- Add icons to the links using the .nav-icon class
                    with font-awesome or any other icon font library -->
        <li class="nav-header">Menu</li>
        <!-- Optionally, you can add icons to the links -->
        <li class="nav-item"><a class="nav-link" href="#"><i class="fas fa-spinner fa-pulse"></i> Loading...</a></li>
      </ul>
      </nav>
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
    txt += '<li class="nav-item';
    if (navLink.ChildItems == undefined || navLink.ChildItems.length > 0)
        txt += ' has-treeview';
    if (isNavLinkActive(navLink))
        txt += ' active';
    if (navLink["ViewID"] != null && navLink["ViewID"] != undefined && navLink["ViewID"] != "")
        txt += '" view-id="' + navLink.ViewID;
    if (navLink["OpenUriInIFRAME"])
        txt += '" nav-id="' + navLink.NavId;

    txt += '"><a class="nav-link" href="';

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

    txt += '><i class="nav-icon ' + navLink.NavGlyph + '"></i> <p>' + navLink.NavLabel;
    
    if (navLink.ChildItems != undefined && navLink.ChildItems.length > 0)
    {
        txt += '<i class="fas fa-angle-left pull-right"></i></p><ul class="nav nav-treeview">';
        for (y in navLink.ChildItems) {
            txt += displayNavLink(navLink.ChildItems[y]);
        }
        txt += '</ul>'
    } else {
        txt += '</p></a>';
    }

    txt += '</li>'
    return txt;
}
</script>
      <!-- /.sidebar-menu -->
    </section>
    <!-- /.sidebar -->
      
  </aside>
