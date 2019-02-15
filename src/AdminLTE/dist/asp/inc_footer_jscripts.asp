

<!-- jQuery 3 -->
<script src="bower_components/jquery/dist/jquery.min.js"></script>
<!-- Bootstrap 3.3.7 -->
<script src="bower_components/bootstrap/dist/js/bootstrap.min.js"></script>
<!-- PACE -->
<script src="bower_components/PACE/pace.min.js"></script>
<!-- Bootstrap WYSIHTML5 -->
<script src="plugins/bootstrap-wysihtml5/bootstrap3-wysihtml5.all.min.js"></script>
<!-- CodeSeven toastr notifications -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>
<!-- DataTables -->
<script src="bower_components/datatables.net/js/jquery.dataTables.min.js"></script>
<script src="bower_components/datatables.net-bs/js/dataTables.bootstrap.min.js"></script>

<!-- page script -->
<script type="text/javascript">
  // To make Pace works on Ajax calls
  $(document).ajaxStart(function () {
    Pace.restart()
  })
  $('.ajax').click(function () {
    $.ajax({
      url: '#', success: function (result) {
        $('.ajax-content').html('<hr>Ajax Request Completed !')
      }
    })
  })
</script>
<script>
  $(function () {
    //bootstrap WYSIHTML5 - text editor
    $editor = $('.textarea').wysihtml5();
//    console.log($editor.val());
//    $('.textarea').each(function () {
//        var disabled = this.textareaElement.disabled;
//        var readonly = !!this.textareaElement.getAttribute('readonly');

//        if (readonly) {
//            this.composer.element.setAttribute('contenteditable', false);
//            this.toolbar.commandsDisabled = true;
//        }

//        if (disabled) {
//            this.composer.disable();
//            this.toolbar.commandsDisabled = true;
//        }
//    })
  })
</script>
<script type="text/javascript">
$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});
</script>
<script>
toastr.options = {<%= globalToastrOptions %>}
    <% SELECT CASE Request("MSG")
        CASE "edit" %>
            toastr.success('Item was successfully updated.', '<h3>Success!</h3>')
       <% CASE "add" %>
            toastr.success('Item was successfully added.', '<h3>Success!</h3>')
       <% CASE "delete" %>
            toastr.warning('Item was successfully deleted.', '<h3>Success!</h3>')
       <% CASE "autoinit" %>
            toastr.success('Items have been initialized.', '<h3>Success!</h3>')
       <% CASE "sorted" %>
            toastr.success('Sorting has been updated.', '<h3>Success!</h3>')
       <% CASE "notfound" %>
            toastr.error('Provided item ID was not found.', '<h3>Error!</h3>')
    <% END SELECT
    IF strError <> "" THEN %>
            toastr.error("<%= Sanitizer.HTMLFormControl(strError) %>", '<h3>Error!</h3>')
    <% END IF %>
</script>

<script>
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
    
function loadSideNav()
{
    var nav = "[]";
    $.get('ajax_dataview.asp?mode=getSiteNav', "", function(response) {
     //console.log(response);
     nav = response;
    
    var navTxt = '<li class="header">Menu</li>';

    for (x in nav) {
        navTxt += displayNavLink(nav[x]);
    }

    document.getElementById("sideNavMenu").innerHTML = navTxt;
    
    $('li.nav-link a').each(function() {
        //console.log("examining link: " + getPageName($(this).attr('href')));
        if (getPageName($(this).attr('href')) == currFileName){

            if (currFileName == "dataview.asp" || currFileName == "view.asp")
            {
                if ($(this).parent().attr("view-id") == currViewID)
                {
                    //console.log("found match (ViewID)");
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

var currFileName = getPageName();
var currViewID = getParameterByName("ViewID");

function setActiveAndBubbleUp(element) {
    //console.log($(element).parent().get(0).tagName);
    if (!$(element).parent().hasClass("active")) {
        if ($(element).parent().get(0).tagName == "LI" && $(element).parent().hasClass("nav-link"))
        {
            $(element).parent().addClass('active');
            setActiveAndBubbleUp($(element).parent());
        }
        else if ($(element).parent().get(0).tagName == "UL" && $(element).parent().hasClass("treeview-menu"))
        {
            $(element).parent().addClass('active');
            setActiveAndBubbleUp($(element).parent());
        }
    }
}
</script>