
<!-- page script -->
<script type="text/javascript" src="<%= SITE_ROOT %>dist/js/crudePortal.js"></script>
<script type="text/javascript">
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
loadSideNav(
    "sideNavMenu", 
    '<%= SITE_ROOT %>ajax_dataview.asp?mode=getSiteNav',
    "Menu", 
    "<%= SITE_ROOT %>", 
    false
    );
</script>