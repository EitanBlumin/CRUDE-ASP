// To make Pace works on Ajax calls
$(document).ajaxStart(function () { Pace.restart(); });
$('.ajax').click(function () {
    $.ajax({
        url: '#', success: function (result) {
            $('.ajax-content').html('<hr>Ajax Request Completed !')
        }
    })
});
// Navbar functions
function isNavLinkActive(navLink) {
    console.log('isNavLinkActive is not implemented. use loadSideNav and setActiveAndBubbleUp instead');
    return false;
}
function displayNavLink(navLink, siteRoot) {
    var navitem = $('<li class="nav-item"></li>');
    siteRoot = siteRoot || "";

    if (navLink.ChildItems == undefined || navLink.ChildItems.length > 0)
        navitem.addClass('has-treeview');
    //    if (isNavLinkActive(navLink))
    //        navitem.addClass('active');
    if (navLink["ViewID"] != null && navLink["ViewID"] != undefined && navLink["ViewID"] != "")
        navitem.attr('view-id', navLink.ViewID);
    if (navLink["OpenUriInIFRAME"])
        navitem.attr('nav-id', navLink.NavId);

    var navlink = $('<a class="nav-link"></a>');

    if (navLink.ChildItems == undefined || navLink.ChildItems.length > 0)
        navlink.attr("href", "javascript:void(0)");
    else if (navLink["OpenUriInIFRAME"])
        navlink.attr("href", siteRoot + "view.asp?NavID=" + navLink.NavId);
    else if (navLink["NavUri"])
        navlink.attr("href", navLink.NavUri);
    else if (navLink["ViewID"] != null && navLink["ViewID"] != undefined && navLink["ViewID"] != "")
        navlink.attr("href", siteRoot + "dataview.asp?ViewID=" + navLink.ViewID);
    else
        navlink.attr("href", "#");

    if (navLink["NavTooltip"]) {
        navlink.attr("title", navLink.NavTooltip);

        if (navLink.ChildItems == undefined || navLink.ChildItems.length == 0) {
            navlink.attr("data-toggle", "tooltip");
            navlink.attr("data-placement", "right");
        }
    }

    navlink.append('<i class="nav-icon ' + navLink.NavGlyph + '"></i>');

    var navInner = $('<p><span>' + navLink.NavLabel + '</span></p>');

    if (navLink.ChildItems != undefined && navLink.ChildItems.length > 0) {
        navInner.append($('<i class="fas fa-angle-left pull-right"></i>'));
        var navInnerChild = $('<ul class="nav nav-treeview"></ul>');
        for (y in navLink.ChildItems) {
            navInnerChild.append(displayNavLink(navLink.ChildItems[y], siteRoot));
        }
        navInner.append(navInnerChild);
    }

    navlink.append(navInner);
    navitem.append(navlink);
    return navitem;
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
        if ($(element).parent().get(0).tagName == "LI" && $(element).parent().hasClass("nav-item")) {
            $(element).parent().addClass('active');
            setActiveAndBubbleUp($(element).parent());
        }
        else if ($(element).parent().get(0).tagName == "UL" && $(element).parent().hasClass("nav-treeview")) {
            $(element).parent().addClass('active');
            setActiveAndBubbleUp($(element).parent());
        }
    }
}

function loadSideNav(sideNavId, ajaxUri, navHeader, siteRoot, appendExisting) {
    sideNavId = sideNavId || "sideNavMenu";
    siteRoot = siteRoot || "";
    ajaxUri = ajaxUri || (siteRoot + 'ajax_dataview.asp?mode=getSiteNav');
    var nav = "[]";
    var sideNavMenu = $('#' + sideNavId);

    // make sure nav menu exists
    if (document.getElementById(sideNavId) == undefined) {
        throw "side nav element not found: " + sideNavId;
        return;
    }

    $.get(ajaxUri, "", function (response) {
        //console.log(response);
        nav = response;

        if (!appendExisting)
            sideNavMenu.empty();

        if (navHeader)
            sideNavMenu.append($('<li class="nav-header">' + navHeader + '</li>'));

        for (x in nav) {
            sideNavMenu.append(displayNavLink(nav[x], siteRoot));
        }

        $('li.nav-item a').each(function () {
            //console.log("examining link: " + getPageName($(this).attr('href')));
            if (getPageName($(this).attr('href')) == currFileName) {

                if (currFileName == "dataview.asp") {
                    if ($(this).parent().attr("view-id") == currViewID) {
                        //console.log("found match (ViewID)");
                        //console.log($(this).parent());
                        $(this).addClass('active');
                        setActiveAndBubbleUp(this);
                    }
                }
                else if (currFileName == "view.asp") {
                    if ($(this).parent().attr("nav-id") == currNavID) {
                        console.log("found match (NavID)");
                        //console.log($(this).parent());
                        setActiveAndBubbleUp(this);
                    }
                }
                else {
                    //console.log("found match (URI)");
                    //console.log($(this).parent());
                    setActiveAndBubbleUp(this);
                }

            }
        });
    });
}
// Tooltip and Summernote
$(document).ready(function () {
    $('body').tooltip({
        selector: '[data-toggle="tooltip"]'
    });
    if (currFileName != "dataview.asp") {
        $('.summernote textarea').summernote({
            placeholder: 'You can enter rich text here.',
            tabsize: 2,
            height: 100
        });
    }
});