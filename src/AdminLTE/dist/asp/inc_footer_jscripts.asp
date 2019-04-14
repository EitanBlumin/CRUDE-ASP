
<!-- page script -->
<script type="text/javascript">
  // To make Pace works on Ajax calls
  $(document).ajaxStart(function () { Pace.restart(); });
  $('.ajax').click(function () {
      $.ajax({
          url: '#', success: function (result) {
              $('.ajax-content').html('<hr>Ajax Request Completed !')
          }
      })
  });
  $(document).ready(function () {
      $('body').tooltip({
          selector: '[data-toggle="tooltip"]'
      });<% IF constPageScriptName <> "dataview.asp" THEN %>
      $('.summernote textarea').summernote({
          placeholder: 'You can enter rich text here.',
          tabsize: 2,
          height: 100
      });<% END IF %>
  });
  toastr.options = {<%= globalToastrOptions %>}
      <% SELECT CASE Request("MSG")
          CASE "edit" %>
              toastr.success('<%= GetWord("Item was successfully updated.") %>', '<h3><%= GetWord("Success!") %></h3>');
       <% CASE "add" %>
            toastr.success('<%= GetWord("Item was successfully added.") %>', '<h3><%= GetWord("Success!") %></h3>');
       <% CASE "delete" %>
            toastr.warning('<%= GetWord("Item was successfully deleted.") %>', '<h3><%= GetWord("Success!") %></h3>');
       <% CASE "autoinit" %>
            toastr.success('<%= GetWord("Items have been initialized.") %>', '<h3><%= GetWord("Success!") %></h3>');
       <% CASE "sorted" %>
            toastr.success('<%= GetWord("Sorting has been updated.") %>', '<h3><%= GetWord("Success!") %></h3>');
       <% CASE "actiondone" %>
            toastr.success('<%= GetWord("Action Completed Successfully") %>', '<h3><%= GetWord("Success!") %></h3>');
       <% CASE "notfound" %>
            toastr.error('<%= GetWord("Provided item ID was not found.") %>', '<h3><%= GetWord("Error!") %></h3>');
    <% END SELECT
    IF strError <> "" THEN %>
            toastr.error("<%= Sanitizer.HTMLFormControl(strError) %>", '<h3><%= GetWord("Error!") %></h3>');
    <% END IF %>

</script>

<script>
function isNavLinkActive(navLink) {
    // not implemented. use loadSideNav and setActiveAndBubbleUp instead
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
function getPageName(path) {
    if (!path) path = window.location.href;
    var segments = path.split('?')[0].split('/');
    var toDelete = [];
    for (var i = 0; i < segments.length; i++) {
        if (segments[i].length < 1) {
            toDelete.push(i);
        }
    }
    for (var i = 0; i < toDelete.length; i++) {
        segments.splice(i, 1);
    }
    return segments[segments.length - 1];
}
function getParameterByName(name, url) {
     if (!url) url = window.location.href;
     name = name.replace(/[\[\]]/g, "\\$&");
     var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
         results = regex.exec(url);
     if (!results) return null;
     if (!results[2]) return '';
     return decodeURIComponent(results[2].replace(/\+/g, " "));
}
    
var currFileName = getPageName();
var currViewID = getParameterByName("ViewID");
var currNavID = getParameterByName("NavID");

function setActiveAndBubbleUp(element) {
    //console.log($(element).parent().get(0).tagName);
    if (!$(element).parent().hasClass("active")) {
        if ($(element).parent().get(0).tagName == "LI" && $(element).parent().hasClass("nav-item"))
        {
            $(element).parent().addClass('active');
            setActiveAndBubbleUp($(element).parent());
        }
        else if ($(element).parent().get(0).tagName == "UL" && $(element).parent().hasClass("nav-treeview"))
        {
            $(element).parent().addClass('active');
            setActiveAndBubbleUp($(element).parent());
        }
    }
}

function loadSideNav()
{
    var nav = "[]";

    // make sure nav menu exists
    if (document.getElementById("sideNavMenu") == undefined)
        return;

    $.get('<%= SITE_ROOT %>ajax_dataview.asp?mode=getSiteNav', "", function(response) {
     //console.log(response);
     nav = response;
    
    var navTxt = '<li class="nav-header">Menu</li>';

    for (x in nav) {
        navTxt += displayNavLink(nav[x]);
    }

    document.getElementById("sideNavMenu").innerHTML = navTxt;
    
    $('li.nav-item a').each(function() {
        //console.log("examining link: " + getPageName($(this).attr('href')));
        if (getPageName($(this).attr('href')) == currFileName){

            if (currFileName == "dataview.asp")
            {
                if ($(this).parent().attr("view-id") == currViewID)
                {
                    //console.log("found match (ViewID)");
                    //console.log($(this).parent());
                    $(this).addClass('active');
                    setActiveAndBubbleUp(this);
                }
            }
            else if (currFileName == "view.asp")
            {
                if ($(this).parent().attr("nav-id") == currNavID)
                {
                    console.log("found match (NavID)");
                    //console.log($(this).parent());
                    setActiveAndBubbleUp(this);
                }
            }
            else
            { 
                //console.log("found match (URI)");
                //console.log($(this).parent());
                setActiveAndBubbleUp(this);
            }

        }
    });
});
}

loadSideNav();

</script>