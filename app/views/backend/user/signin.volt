<?php use Phalcon\Tag;
echo $this->getContent();
?>
{{ stylesheet_link('css/custom.css') }}
<!-- always add for responsive menu outer page-->
{{ stylesheet_link('css/menu_responsive_outer.css') }}
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }}
<div class="row">

    <div class="col-md-4 center">
        <div class="page-header">
            <h2>Sign In</h2>
        </div>
        {{ form('user/signin', 'role': 'form', 'id': 'loginForm') }}

            <fieldset>
             <!-- <div class="btn-group" data-toggle="buttons" id="radio_wrapper">
                
               <label class="btn btn-default active"><input type="radio" name="login_type" value="Group Admin" checked>Group Admin</label>
               <label class="btn btn-default"><input type="radio" name="login_type" value="Franchisee">Franchisee</label>
               <label class="btn btn-default"><input type="radio" name="login_type" value="Super Admin">Super Admin</label>
               
              </div><br><br>-->
                <div class="form-group">
                    <label for="email">Email</label>
                    <div class="controls">
                        {{ text_field('email', 'class': "form-control", 'required':'required') }}
                    </div>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="controls">
                        {{ password_field('password', 'class': "form-control", 'required':'required') }}
                    </div>
                </div>
                <div class="form-group">
                <div class="forgot">
                <a id="forgot_link" href='/admin/forgotPassword/user'>Forgot password</a></div>
                </div>

                    {{ submit_button('Sign In', 'class': 'btn btn-primary btn-large') }}

                <input type="hidden" name="<?php echo $this->security->getTokenKey() ?>"
           value="<?php echo $this->security->getToken() ?>"/>
            </fieldset>
        </form>
    </div>

  
</div>

<script type="text/javascript">
$(document).ready(function(){
/*   $('input:radio').change(function(){
    $('#forgot_link').attr('href','/admin/forgotPassword/'+ this.value +'');
   });*/
    $("#loginForm").validate({
        rules: { 
           email: {email:true},
           /*password:{minlength:8},*/
        },
        tooltip_options: {
           '_all_': { placement: 'right' }
        }
    });
});
</script>