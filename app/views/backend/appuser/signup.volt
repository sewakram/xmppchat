<?php use Phalcon\Tag;
echo $this->getContent();
?>
{{ stylesheet_link('css/custom.css') }}
<!-- always add for responsive menu outer page-->
{{ stylesheet_link('css/menu_responsive_outer.css') }}
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }}
{{ javascript_include('js/bootbox.min.js')}}
<div id="register">
<div class="col-md-12">
<div class="col-md-6 page-header">
    <h2>User Signup</h2>
</div>
<div class="col-md-6 page-header">
<ul class="pager">
    <li class="previous pull-right">
        <a href="/index/index">← Go Back</a>    </li>

 </ul>
 </div>
 </div>
<div class="form_wrapper" id="formdiv">

 <!-- {{ form("user/signup/echo $url_param;", 'id': 'registerForm', 'name': 'registerForm','class':'form-horizontal','role':'form') }} -->
<form method="POST" action="/user/signup/<?php echo $url_param;?>" id= 'registerForm' name= 'registerForm' class='form-horizontal'>
    <fieldset id="step1" class="col-md-12">
    <div class="col-md-5">
        <div class="form-group">
            {{ form.label('first_name', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('first_name', ['class': 'form-control','placeholder':'required','required':'required']) }}
            </div>
        </div>
        <div class="form-group">
            {{ form.label('last_name', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('last_name', ['class': 'form-control','placeholder':'required','required':'required']) }}
            </div>
        </div>
        <div class="form-group">
            {{ form.label('email', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('email', ['class': 'form-control','placeholder':'required','required':'required']) }}
            </div>
        </div>
        </div>
        <div class="col-md-2"></div>
        <div class="col-md-5">
        <div class="form-group">
            {{ form.label('mobile', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('mobile', ['id':'mobile','class': 'form-control','placeholder':'required','required':'required','maxlength':'10']) }}
            </div>
        </div>
        <div class="form-group">
            {{ form.label('password', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('password', ['class': 'form-control','placeholder':'required','required':'required']) }}
            </div>
        </div>

        <div class="form-group">
            <label class="control-label" for="repeatPassword">Repeat Password</label>
            <div class="input-outer">
                {{ password_field('repeatPassword', 'class': 'input-xlarge form-control','placeholder':'required','required':'required','size':'32') }}
               
            </div>
        </div>
        <!-- <div class="form-group">
            {{ form.label('organization', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('organization', ['class': 'form-control']) }} 
            </div>
        </div>
        <div class="form-group">
            {{ form.label('address', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('address', ['class': 'form-control']) }}
            </div>
        </div>

          <div class="form-group">
            {{ form.label('state', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('state', ['class': 'form-control']) }}
            </div>
        </div>

        <div class="form-group">
            {{ form.label('city', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('city', ['class': 'form-control']) }}              
            </div>
        </div>

        <div class="form-group">
            {{ form.label('phone', ['class': 'control-label']) }}
            <div class="input-outer">
               {{ form.render('phone', ['class': 'form-control']) }} 
            </div>
        </div> -->
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
      </div>

    <div class="row">
    <div class="col-sm-12 ">
        <ul id="plan_pills" class="nav nav-pills nav-justified">
        <?php echo $pill_content;?>
        </ul>
  
        <div class="tab-content">
        <?php echo $tab_content;?>
         <div class="plan_btn pull-right"><a href="#plans" class="btn btn-primary" data-toggle="modal"><span class="glyphicon glyphicon-info-sign"></span> View Plans</a></div>
        </div>
    </div>
    </div>
    <div class="col-sm-12 margin">
    <div class="checkbox">
        <label>
        <input data-placement="left" name="terms" id="terms" type="checkbox"> 
        <strong>I agree to the sancharapp <a href="/index/terms" target="_blank">Terms of Service</a></strong>
        </label>
    </div><br>
     <a id="signup" class="btn btn-success btn-lg blue"><span class="glyphicon glyphicon-ok"></span> Signup</a>
     <button type="reset" class='btn btn-primary btn-lg red' ><span class='glyphicon glyphicon-remove-sign'></span>  Cancel</button>
  </div>
    </fieldset>
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


<?php $this->partial("modal/plans") ?>


<script type="text/javascript">
function update_slab(slab_id){
    $("input#slab_id").val(slab_id);
    $("form#registerForm").attr('action','/user/signup/'+slab_id);
}
$(document).ready(function(){
    jQuery.validator.addMethod("lettersonly", function(value, element) {
      return this.optional(element) || /^[a-z-_\s]+$/i.test(value);
    }, "Letters only please"); 
    $("#registerForm").validate({
        rules: { 
           first_name: {lettersonly: true}, 
           last_name: {lettersonly: true},     
           email: {email:true},
           mobile:{minlength:10,maxlength:10},
           phone:{ digits: true},
           pincode:{ digits: true},
           password:{minlength:8},
           terms:{required:true},
           repeatPassword:{equalTo: "input[name='password']"},
        },
        messages: {
            mobile: "Enter Valid Mobile Number",
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