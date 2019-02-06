
  <!-- Left side column. contains the logo and sidebar -->
  <aside class="main-sidebar">
    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">

        <% IF False THEN %>
      <!-- Sidebar user panel (optional) -->
      <div class="user-panel">
        <div class="pull-left image">
          <img src="dist/img/user2-160x160.jpg" class="img-circle" alt="User Image">
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
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}
function isNavLinkActive(navLink) {
    // not yet implemented
    return false;
}
function displayNavLink(navLink) {
    var txt = "";
    txt += '<li class="nav-link';
    if (navLink.ChildItems.length > 0)
        txt += ' treeview';
    if (isNavLinkActive(navLink))
        txt += ' active';
    if (navLink["ViewID"])
        txt += '" view-id="' + navLink.ViewID;

    txt += '"><a href="';

    if (navLink.ChildItems.length > 0)
        txt += "javascript:"
    else if (navLink["OpenUriInIFRAME"])
        txt += "view.asp?NavID=" + navLink.NavId;
    else if (navLink["NavUri"])
        txt += navLink.NavUri;
    else if (navLink["ViewID"])
        txt += "dataview.asp?ViewID=" + navLink.ViewID;
    else
        txt += "#"

    txt += '" title="' + navLink.NavTooltip + '"';
    if (navLink["NavTooltip"] && navLink.ChildItems.length == 0)
        txt += ' data-toggle="tooltip"';

    txt += '><i class="' + navLink.NavGlyph + '"></i> <span>' + navLink.NavLabel + '</span>'
    
    if (navLink.ChildItems.length > 0)
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
function loadSideNav()
{
    var nav = getCookie('SiteNav').replace(/\\n/g, "\\n")  
               .replace(/\\'/g, "\\'")
               .replace(/\\"/g, '\\"')
               .replace(/\\&/g, "\\&")
               .replace(/\\r/g, "\\r")
               .replace(/\\t/g, "\\t")
               .replace(/\+/g, " ")
               .replace(/\\b/g, "\\b")
               .replace(/\\f/g, "\\f");
    nav = nav.replace(/[\u0000-\u0019]+/g,"");
    nav = JSON.parse(nav);
    //console.log(nav);
    
    var navTxt = '<li class="header">Menu</li>';

    for (x in nav) {
        navTxt += displayNavLink(nav[x]);
    }

    document.getElementById("sideNavMenu").innerHTML = navTxt;
}

loadSideNav();
</script>
      <!-- /.sidebar-menu -->
    </section>
    <!-- /.sidebar -->
      
  </aside>
