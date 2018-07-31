

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
    $('.textarea').wysihtml5()
  })
</script>
<script type="text/javascript">
$(document).ready(function(){
    loadSideNav();
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
