<?php use Phalcon\Tag;
echo $this->getContent();
//$siteurl = $application['base_url'];
?>
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }}
{{ stylesheet_link('css/custom.css') }}
{{ stylesheet_link('DateTimePicker/jquery.datetimepicker.css') }}
{{ javascript_include('DateTimePicker/jquery.datetimepicker.js')}}
<script type="text/javascript">
  $(document).ready(function() {

   $('#dob').datetimepicker({
        timepicker:false,
        scrollInput: false,
        format:'Y-m-d',
    });
    
  });
</script>
<div id="register">
<div class="col-md-12">
<div class="col-md-6 page-header">
    <h2>Create Manager</h2>
</div>
<div class="col-md-6 page-header">
<ul class="pager">
    <li class="previous pull-right">
        <a href="index">← Go Back</a>    </li>

 </ul>
 </div>
 </div>
<div class="form_wrapper" id="formdiv">

 {{ form('manager/new', 'id': 'registerForm', 'name': 'registerForm','class':'form-horizontal','role':'form') }}

    <fieldset class="col-md-12">
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
         <div class="form-group">
            {{ form.label('mobile', ['class': 'control-label']) }}
            <div class="input-outer">
                {{ form.render('mobile', ['class': 'form-control','placeholder':'required','required':'required','maxlength':'10']) }}
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
        </div>
        <div class="col-md-2"></div>
        <div class="col-md-5">
               <!--  <div class="form-group">
                    {{ form.label('dob', ['class': 'control-label']) }}
                    <div class="input-outer">
                        {{ form.render('dob', ['class': 'form-control','id': 'dob']) }} 
                    </div>
                </div> -->

                <div class="form-group">
                    {{ form.label('pincode', ['class': 'control-label']) }}
                    <div class="input-outer">
                        {{ form.render('pincode', ['class': 'form-control']) }} 
                    </div>
                </div>

                 <div class="form-group">
                    <label class="control-label" for="status" class="control-label">Status</label>
                      <div class="input-outer">
                          <select class="form-control" name="status" id="status">
                            <option value="Active">Active</option>
                            <option value="Inactive" selected="selected">Inactive</option>
                            <option value="Pending"  >Pending</option>
                            <option value="Blocked">Blocked</option>
                          </select>        
                      </div>  
                 </div>
                <div class="form-group">
                    {{ form.label('address', ['class': 'control-label']) }}
                    <div class="textarea-outer">
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
                </div> 
               <!--  <div class="form-group">
                   <div class="pull-left checkbox">
                      <label>
                        <input onclick="$('#third_party_sms_api').toggleClass('hide');" name="configure_status" type="checkbox" id="blankCheckbox" >
                        Configure SMS API
                      </label>
                    </div>
                </div> --> 
       </div>
<div id="third_party_sms_api" class="hide col-sm-12"> 
<div class="panel panel-default">
  <div class="panel-heading">
    <div class="row">
        <div class="col-md-6"><h4>3rd Party SMS Api</h4></div>
        <label class="col-md-3">Select SMS API</label>
        <div class="col-md-3">
            <select name="api_type" id="api_type" class="form-control" onchange="$('#3rdparty').toggleClass('hide');$('#logic').toggleClass('hide');">
              <option value="3rdparty">3rd Party</option>
              <option value="logic" selected>Logic</option>
            </select>
        </div>
    </div>
  </div>
  <div class="panel-body">
    <div id="3rdparty" class="hide">
    <div class="col-sm-5">
     <div class="form-group">
        <label class="control-label" for="url">Url</label><div class="text-area-outer">
        <textarea rows="3" placeholder="http://logic.bizsms.in/SMS_API/sendsms.php?username=XXXX&password=XXXX&sendername=XXXX&routetype=1" class="form-control" type="text" size="30" name="url" id="url" required></textarea></div>
     </div>
        <div class="form-group">
            <label class="control-label" for="max_limit" class="control-label">SMS Batch Limit</label><div class="input-outer">
            <input class="form-control" size="24" type="text" class="input-xlarge" name="max_limit" id="max_limit"/>               
     </div>
     </div>
    </div>
    <div class="col-md-2"></div>
    <div class="col-sm-5">
    <div class="form-group">
        <label class="control-label" for="to">To/Mobile</label><div class="input-outer">
        <input class="form-control" placeholder="enter mobile number field name from API url" type="text" size="24" name="to" id="to" required />    </div>
    </div>
    <div style="margin-top: 45px;" class="form-group">
        <label class="control-label" for="text">Text/Message</label><div class="input-outer">
        <input class="form-control" placeholder="enter message field name from API url" type="text" maxlenght="10" size="24" name="text" id="text" required/></div> </div>
     </div>
  </div>
    <div id="logic" class="">
    <div class="col-sm-5">
     <div class="form-group">
        <label class="control-label" for="username">Username</label><div class="input-outer">
        <input  size="24" class="form-control" type="text" id="username" name="username" alt="username">  </div>
     </div>

     <div class="form-group">
        <label class="control-label" for="api_password">Password</label><div class="input-outer">
        <input size="24" class="form-control"  type="text" id="api_password" name="api_password" alt="api_password"></div> </div>
    </div>
    <div class="col-md-2"></div>
    <div class="col-sm-5">
     <div class="form-group">
        <label class="control-label" for="senderID" class="control-label">SenderID</label><div class="input-outer">
        <input size="24" class="form-control" type="text" id="senderID" name="senderID" alt="senderID">           
     </div>
     </div>
    </div>
    </div>
</div>
</div>
</div>
        <!-- <div class="form-group">
            {{ form.label('details', ['class': 'control-label']) }}
            <div class="input-outer">
               {{ form.render('details', ['class': 'form-control']) }} 
            </div>
        </div> -->  
         
        <div class="col-sm-12 margin">
     <button type="submit" class="btn btn-success btn-lg blue"><span class="glyphicon glyphicon-ok"></span> Save</button>
     <button type="reset" class='btn btn-primary btn-lg red' ><span class='glyphicon glyphicon-remove-sign'></span>  Cancel</button>
  </div>
    </fieldset>
    <input type="hidden" id="is_logic" name="is_logic" value="0">
</form>
</div>
</div>
<script type="text/javascript">
var logic_url="http://logic.bizsms.in/SMS_API/";
$(document).ready(function(){
    jQuery.validator.addMethod("lettersonly", function(value, element) {
      return this.optional(element) || /^[a-z-_\s]+$/i.test(value);
    }, "Letters only please"); 
    $("#registerForm").validate({
        rules: {  
           first_name: {lettersonly: true}, 
           last_name: {lettersonly: true},    
           email: {email:true},
           mobile:{minlength:10},
           phone:{ digits: true},
           pincode:{ digits: true,minlength:6},
           password:{minlength:8},
           repeatPassword:{equalTo: "input[name='password']"},
           username: {
            required: {
                depends: function(element) {
                    if($("select#api_type").val()=="logic"){
                        return true;
                    }
                }
            }
          },
        api_password: {
            required: {
                depends: function(element) {
                    if($("select#api_type").val()=="logic"){
                        return true;
                    }
                }
            }
          },
        senderID: {
            required: {
                depends: function(element) {
                    if($("select#api_type").val()=="logic"){
                        return true;
                    }
                }
            }
          },
        },
        messages: {
            mobile: "Enter Valid Mobile Number"
        },
        tooltip_options: {
           '_all_': { placement: 'right' }
        }
    });

});
 $('#registerForm').submit( function() {
      if($("select#api_type").val()=="logic"){
                var url=logic_url+"sendsms.php?username="+$('#logic input#username').val().trim()+"&password="+$('#logic input#api_password').val().trim()+"&sendername="+$('#logic input#senderID').val().trim()+"&routetype=1";
                $("#url").val(url);
                $("input#to").val("mobile");
                $("input#text").val("message");
                $("input#max_limit").val("100");
                $("input#is_logic").val("1");
      }
      return true;
 });

</script>

<!-- <?php //$this->partial("modal/plans") ?> -->