<?php use Phalcon\Tag;
echo $this->getContent();
?>
<!-- {{ stylesheet_link('css/custom.css') }} -->
<!-- always add for responsive menu outer page-->
<!-- {{ stylesheet_link('css/menu_responsive_outer.css') }}
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }}
{{ javascript_include('js/bootbox.min.js')}} -->
<!-- coco signup start -->
 <!-- Modal Start -->
          <!-- Modal Task Progress -->  
  <div class="md-modal md-3d-flip-vertical" id="task-progress">
    <div class="md-content">
      <h3><strong>Task Progress</strong> Information</h3>
      <div>
        <p>CLEANING BUGS</p>
        <div class="progress progress-xs for-modal">
          <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style="width: 80%">
          <span class="sr-only">80&#37; Complete</span>
          </div>
        </div>
        <p>POSTING SOME STUFF</p>
        <div class="progress progress-xs for-modal">
          <div class="progress-bar progress-bar-warning" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style="width: 65%">
          <span class="sr-only">65&#37; Complete</span>
          </div>
        </div>
        <p>BACKUP DATA FROM SERVER</p>
        <div class="progress progress-xs for-modal">
          <div class="progress-bar progress-bar-info" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style="width: 95%">
          <span class="sr-only">95&#37; Complete</span>
          </div>
        </div>
        <p>RE-DESIGNING WEB APPLICATION</p>
        <div class="progress progress-xs for-modal">
          <div class="progress-bar progress-bar-primary" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
          <span class="sr-only">100&#37; Complete</span>
          </div>
        </div>
        <p class="text-center">
        <button class="btn btn-danger btn-sm md-close">Close</button>
        </p>
      </div>
    </div>
  </div>
    
  <!-- Modal Logout -->
  <div class="md-modal md-just-me" id="logout-modal">
    <div class="md-content">
      <h3><strong>Logout</strong> Confirmation</h3>
      <div>
        <p class="text-center">Are you sure want to logout from this awesome system?</p>
        <p class="text-center">
        <button class="btn btn-danger md-close">Nope!</button>
        <a href="login.html" class="btn btn-success md-close">Yeah, I'm sure</a>
        </p>
      </div>
    </div>
  </div>        <!-- Modal End -->    
  <!-- Begin page -->
  <div class="container">
    <div class="full-content-center animated fadeInDownBig">
      <p class="text-center"><a href="#"><img src="{{url()}}assets/img/login-logo.png" alt="Logo"></a></p>
      <div class="login-wrap">
        <div class="login-block">
         <form role="form" method="POST" action="/user/signup/<?php echo $url_param;?>" id= 'registerForm' name= 'registerForm' class='form-horizontal'>
            <div class="form-group login-input">
            <i class="fa fa-mobile overlay"></i>
            <!-- <input type="text" class="form-control text-input" placeholder="E-mail"> -->
            {{ form.render('mobile', ['id':'mobile','class': 'form-control text-input','placeholder':'Mobile Number','required':'required','maxlength':'10']) }}
                <p>OTP will be sent to this number.</p>
            </div>
            <div class="form-group login-input">
            <i class="fa fa-key overlay"></i>
            <!-- <input type="password" class="form-control text-input" placeholder="********"> -->
            {{ form.render('password', ['class': 'form-control text-input','placeholder':'Password','required':'required']) }}
            </div>
            <div class="form-group login-input">
            <i class="fa fa-key overlay"></i>
            <!-- <input type="password" class="form-control text-input" placeholder="********"> -->
             {{ password_field('repeatPassword', 'class': 'text-input input-xlarge form-control','placeholder':'Repeat Password','required':'required','size':'32') }}
            </div>
            <div class="form-group login-input">
            
            <!-- <input type="text" class="form-control text-input" placeholder="Username"> -->
            {{ form.render('senderid', ['id':'senderid','class': 'form-control text-input','placeholder':'Sender name','required':'required']) }}
                <p>Sender name cannot be edited later.</p>
            </div>
            <div class="form-group login-input">
            
            <!-- <input type="text" class="form-control text-input" placeholder="Username"> -->
            {{ form.render('joint_handle', ['class': 'form-control text-input','placeholder':'Sancharapp id','aria-describedby':'basic-addon1','required':'required']) }}
            </div>
            <div class="form-group">
            <?php
            echo '<input type="hidden" name="slab_id" id="slab_id" value="'.$url_param.'">';
            $tab_content='';
            $pill_content='';
            $slabs = Slabs::find(array(
            "status='Active' AND display=1",
            "order" => "amount"
            ));
            foreach ($slabs as $slab){
            $class_name='';
            if($slab->id==$url_param)
            $class_name="active";
            $pill_content.='<li class="'.$class_name.'"><a onclick="update_slab('.$slab->id.')" data-toggle="pill" href="#'.$slab->id.'">'.$slab->name.'</a></li>';
            $tab_content.='<div id="'.$slab->id.'" class="tab-pane fade in '.$class_name.' bg-success"><h3>'.$slab->name.'</h3><p><span class="">&#8377; '.$slab->amount.' /month</span></p></div>';
            ?>

            <?php } ?>

            </div>

            <div class="checkbox"><label><input type="checkbox" name="terms" id="terms" class="form-control"> I accept <strong><a target="_blank" href='/terms'>Terms and Conditions</a></strong></label></div>
           
            <div class="row">
              <div class="col-sm-6">
                <a id="signup" class="btn btn-default btn-block"><span class="glyphicon glyphicon-ok"></span> Signup</a>
              <!-- <button type="submit" class="btn btn-default btn-block">Register</button> -->
              </div>
              <div class="col-sm-6">
                <a href="/connect/signin" class="btn btn-primary btn-block">← Go Back</a>
              <!-- <button type="submit" class="btn btn-default btn-block">Register</button> -->
              </div>
            </div>
            <div id="verify" class="hide col-sm-12"> 
            <div class="panel panel-default">
            <div class="panel-heading">
            <div class="row">
            <div class="text-left col-md-6"><h4>Mobile Verification</h4></div>
            </div>
            </div>
            <div class="panel-body">
            <div class="col-sm-5">
            <div class="form-group">
            <label for="OTP" class="control-label">OTP</label>
            <div class="col-sm-7">
            <input style="margin-left: -25px;" type="text" class="form-control" id="OTP" name="OTP" placeholder="Enter OTP">      
            </div>
            <div class="col-sm-3">
            <a class="btn btn-primary" id="resend">Resend</a>    
            </div>
            <div class="col-sm-2">
            <a class="btn btn-primary" onClick='$("div#verify,#step1").toggleClass("hide");' id="changenumber">Change Number</a>    
            </div>
            </div>
            </div>
            </div>
            <div class="text-left panel-footer"><a class="btn btn-primary" id="verify"><span class="glyphicon glyphicon-ok"></span> Verify</a> </div>
            </div>
            </div>
          </form>
        </div>
      </div>
      
    </div>
  </div>
  <!-- the overlay modal element -->
  <div class="md-overlay"></div>
  <!-- End of eoverlay modal -->
<!-- coco singup end -->



<?php $this->partial("modal/plans") ?>


<script type="text/javascript">
function update_slab(slab_id){
    $("input#slab_id").val(slab_id);
    $("form#registerForm").attr('action','/user/signup/'+slab_id);
}
$(document).ready(function(){
  $('[data-toggle="tooltip"]').tooltip();

    jQuery.validator.addMethod("lettersonly", function(value, element) {
      return this.optional(element) || /^[a-z-_\s]+$/i.test(value);
    }, "Letters only please");

    jQuery.validator.addMethod("alphanumeric", function(value, element) {
      return this.optional(element) || /^\w+$/i.test(value);
    }, "Letters, numbers, and underscores only please");

    $.validator.addMethod("hasLowercase", function(value, element) {
    if (this.optional(element)) {
      return true;
    }
      return /[a-z]/.test(value);
    }, "Must contain lowercase");

    jQuery.validator.addMethod("mobile", function(value, element) {
      return this.optional(element) || /^[1-9][0-9]*$/i.test(value);
    }, "Invalid mobile");

    $("#registerForm").validate({
        rules: { 
           /*joint_handle: {lettersonly: true}, */
      /*     last_name: {lettersonly: true},     */
/*           email: {email:true,remote: {
                        url: "/user/checkAlreadyExits",
                        type: "get"
                  }},*/
           mobile:{required:true,minlength: 10,maxlength: 10,digits: true,mobile:true,
                  remote: {
                        url: "/user/checkAlreadyExits",
                        type: "get"
                  }
           },
       /*    phone:{ digits: true},*/
   /*        pincode:{ digits: true},*/
           password:{minlength:6},
           terms:{required:true},
           repeatPassword:{equalTo: "input[name='password']"},
           joint_handle:{required:true,alphanumeric: true,hasLowercase:true,
                  remote: {
                        url: "/user/checkAlreadyExits",
                        type: "get"
                  }
           },
        },
        messages: {
            mobile:{
                    minlength:"Invalid number",
                    maxlength:"Invalid number",
                    remote:"you have already registered with this mobile number."
                  },
            joint_handle:{
                    remote:"Joint ID is already exists."
                  },
            email:{
                    remote:"Email is already exists."
                  },
            terms: "In order to use our services, you must agree to sancharapp's Terms of Service."
        },
        tooltip_options: {
          // first_name: { placement: 'right' }
        }
    });

$("a#verify").on("click",function(){
    var validator = $( "#registerForm" ).validate();
    if(validator.form()){
        var OTP=$("#OTP").val();
            $.ajax({
                  cache: false,
                  type: "POST",
                  url:"/user/verifyOTP/",
                  dataType: "json",
                  data:'OTP='+OTP,
                  success:  function(response){
                        if(response['status']=="success"){
                             $("#registerForm").submit();
                        }else{
                           bootbox.alert('<h3 class="boot_dialog text-danger">'+response['message']+'<h3>'); 
                        }
                  }
                });
    }
});
$("a#resend,a#signup").on("click",function(){
    var validator = $( "#registerForm" ).validate();
    var source_id=$(this).attr('id');
    if(validator.form()){
        var mobile=$("#mobile").val();
            $.ajax({
                  cache: false,
                  type: "POST",
                  url:"/user/sendOTP/",
                  dataType: "json",
                  data:'mobile='+mobile,
                  success:  function(response){
                    bootbox.alert('<h3 class="boot_dialog">'+response['message']+'<h3>');
                    console.log();
                    if(source_id=="signup")
                        $("div#verify,#step1").toggleClass("hide");
                  }
                });
    }
});
});
</script>
