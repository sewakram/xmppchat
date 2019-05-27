{{ content() }}
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }}
{{ stylesheet_link('css/custom.css') }}
<div class="container" style="padding-right: 45px;">
<div class="row ">
<div class="center">
	{{ form('id':'forgotForm','class': 'well form-search') }}

	<div class="page-header">
		<h2>Forgot Password?</h2>
	</div>

		{{ form.render('mobile') }}
		{{ form.render('Send') }}
        <a href="/connect/signin" class="btn btn-primary">← Go Back</a> 
		<hr>
      
	</form>


</div>
</div>
</div>
<script>
$(document).ready(function(){
    $("#forgotForm").validate({
        rules: { 
           mobile:{minlength:10,maxlength:10},
        },
        messages: {
            mobile: "Enter Valid Mobile Number",
        },
        tooltip_options: {
          // first_name: { placement: 'right' }
        }
    });
});
</script>