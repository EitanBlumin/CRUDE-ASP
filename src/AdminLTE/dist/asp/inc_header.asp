
  <!-- Main Header -->
  <header class="main-header">

    <!-- Logo -->
    <a href="default.asp" class="logo">
      <!-- mini logo for sidebar mini 50x50 pixels -->
      <span class="logo-mini">
          <span class="fa-stack fa-1x">
            <i class="far fa-circle fa-stack-2x"></i>
            <i class="fas fa-tint fa-stack-1x"></i>
          </span>
      </span>
      <!-- logo for regular state and mobile devices -->
      <span class="logo-lg">
            <i class="icon-crude-asp"></i>
           Crude<b>ASP</b></span>
    </a>

    <!-- Header Navbar -->
    <nav class="navbar navbar-static-top" role="navigation">
      <!-- Sidebar toggle button-->
      <a href="#" class="sidebar-toggle" data-toggle="push-menu" role="button">
        <i class="fas fa-bars"></i> <span class="sr-only">Toggle navigation</span>
      </a>

      <div class="collapse navbar-collapse navbar-custom-menu" id="navbar-collapse">
        <form class="navbar-form navbar-left" role="search">
        <div class="form-group">
            <input type="text" class="form-control" id="navbar-search-input" placeholder="Search">
        </div>
        <button type="submit" class="btn btn-default"><i class="fas fa-search"></i></button>
        </form>
        <ul class="nav navbar-nav">
          <!-- Messages: style can be found in dropdown.less-->
          <li class="dropdown messages-menu">
            <!-- Menu toggle button -->
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              <i class="far fa-envelope"></i>
              <span class="label label-success">4</span>
            </a>
            <ul class="dropdown-menu">
              <li class="header">You have 4 messages</li>
              <li>
                <!-- inner menu: contains the messages -->
                <ul class="menu">
                  <li><!-- start message -->
                    <a href="#">
                      <div class="pull-left">
                        <!-- User Image -->
                        <img src="dist/img/user2-160x160.jpg" class="img-circle" alt="User Image">
                      </div>
                      <!-- Message title and timestamp -->
                      <h4>
                        Support Team
                        <small><i class="far fa-clock"></i> 5 mins</small>
                      </h4>
                      <!-- The message -->
                      <p>Why not buy a new awesome theme?</p>
                    </a>
                  </li>
                  <!-- end message -->
                </ul>
                <!-- /.menu -->
              </li>
              <li class="footer"><a href="#">See All Messages</a></li>
            </ul>
          </li>
          <!-- /.messages-menu -->

          <!-- Notifications Menu -->
          <li class="dropdown notifications-menu">
            <!-- Menu toggle button -->
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              <i class="far fa-bell"></i>
              <span class="label label-warning">10</span>
            </a>
            <ul class="dropdown-menu">
              <li class="header">You have 10 notifications</li>
              <li>
                <!-- Inner Menu: contains the notifications -->
                <ul class="menu">
                  <li><!-- start notification -->
                    <a href="#">
                      <i class="fas fa-users text-aqua"></i> 5 new members joined today
                    </a>
                  </li>
                  <!-- end notification -->
                </ul>
              </li>
              <li class="footer"><a href="#">View all</a></li>
            </ul>
          </li>
          <!-- Tasks Menu -->
          <li class="dropdown tasks-menu">
            <!-- Menu Toggle Button -->
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              <i class="far fa-flag"></i>
              <span class="label label-danger">9</span>
            </a>
            <ul class="dropdown-menu">
              <li class="header">You have 9 tasks</li>
              <li>
                <!-- Inner menu: contains the tasks -->
                <ul class="menu">
                  <li><!-- Task item -->
                    <a href="#">
                      <!-- Task title and progress text -->
                      <h3>
                        Design some buttons
                        <small class="pull-right">20%</small>
                      </h3>
                      <!-- The progress bar -->
                      <div class="progress xs">
                        <!-- Change the css width attribute to simulate progress -->
                        <div class="progress-bar progress-bar-aqua" style="width: 20%" role="progressbar"
                             aria-valuenow="20" aria-valuemin="0" aria-valuemax="100">
                          <span class="sr-only">20% Complete</span>
                        </div>
                      </div>
                    </a>
                  </li>
                  <!-- end task item -->
                </ul>
              </li>
              <li class="footer">
                <a href="#">View all tasks</a>
              </li>
            </ul>
          </li>
          <!-- User Account Menu -->
          <li class="dropdown user user-menu">
            <!-- Menu Toggle Button -->
            <a href="#" class="dropdown-toggle" data-toggle="dropdown">
              <!-- The user image in the navbar-->
              <img src="dist/img/user2-160x160.jpg" class="user-image" alt="User Image">
              <!-- hidden-xs hides the username on small devices so only the image appears. -->
              <span class="hidden-xs">Alexander Pierce</span>
            </a>
            <ul class="dropdown-menu">
              <!-- The user image in the menu -->
              <li class="user-header">
                <img src="dist/img/user2-160x160.jpg" class="img-circle" alt="User Image">

                <p>
                  Alexander Pierce - Web Developer
                  <small>Member since Nov. 2012</small>
                </p>
              </li>
              <!-- Menu Body -->
              <li class="user-body">
                <div class="row">
                  <div class="col-xs-4 text-center">
                    <a href="#">Followers</a>
                  </div>
                  <div class="col-xs-4 text-center">
                    <a href="#">Sales</a>
                  </div>
                  <div class="col-xs-4 text-center">
                    <a href="#">Friends</a>
                  </div>
                </div>
                <!-- /.row -->
              </li>
              <!-- Menu Footer-->
              <li class="user-footer">
                <div class="pull-left">
                  <a href="#" class="btn btn-default btn-flat">Profile</a>
                </div>
                <div class="pull-right">
                  <a href="#" class="btn btn-default btn-flat">Sign out</a>
                </div>
              </li>
            </ul>
          </li>
<% IF Right(Request.ServerVariables("SCRIPT_NAME"), Len("/dataview.asp")) = "/dataview.asp" THEN %>
          <!-- Control Sidebar Toggle Button -->
          <li>
            <a href="javascript:void(0)" title="Settings" data-toggle="control-sidebar"><i class="fas fa-cogs"></i></a>
          </li>
<% END IF %>
        </ul>
      </div>
    </nav>
  </header>
  <!-- Left side column. contains the logo and sidebar -->
  <aside class="main-sidebar">

    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">

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
    if (navLink.ViewID.length > 0)
        txt += '" view-id="' + navLink.ViewID;

    txt += '"><a href="';

    if (navLink.ChildItems.length > 0)
        txt += "javascript:"
    else if (navLink.NavUri.length > 0)
        txt += navLink.NavUri;
    else if (navLink.ViewID.length > 0)
        txt += "dataview.asp?ViewID=" + navLink.ViewID;
    else
        txt += "#"

    txt += '" title="' + navLink.NavTooltip + '"';
    if (navLink.NavTooltip.length > 0 && navLink.ChildItems.length == 0)
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
