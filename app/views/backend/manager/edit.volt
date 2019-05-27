<?php use Phalcon\Tag;
echo $this->getContent();
$auth = $this->session->get('auth');
$login_type=$auth["login_type"];
// echo $user->id;exit;
// $users = new User();
// $user_permission = $users->getPermissions($user->id); 

?>
{{ stylesheet_link('css/custom.css') }}
{{ stylesheet_link('bootstrap/css/bootstrap-switch.min.css') }} 
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }}
{{ javascript_include('bootstrap/js/bootstrap-switch.min.js') }}
{{ stylesheet_link('DateTimePicker/jquery.datetimepicker.css') }}
{{ javascript_include('DateTimePicker/jquery.datetimepicker.js')}}
{{ javascript_include('js/common.js') }}
{{ javascript_include('chosen_v1.5.1/chosen.jquery.min.js') }}
{{ stylesheet_link('chosen_v1.5.1/chosen.min.css') }}
<script type="text/javascript">
  $(document).ready(function() {

   $('#dob').datetimepicker({
        timepicker:false,
        scrollInput: false,
        format:'Y-m-d',
    });
    
  });

</script>
<div id="useredit">
<div class="col-md-12">
    <div class="col-md-6 page-header">
    <h2>Edit User</h2>
    </div>
<div class="col-md-6 page-header">
<ul class="pager">
    <li class="previous pull-right">
        <a href="/manager/index">← Go Back</a>    </li>
</ul>
</div>
</div>
<div align="center">
<form name="form1" id="form1" method="post" autocomplete="off" action="" class="form-horizontal" role="form">
<div class="container">
<div class="form_wrapper">
<div class="col-md-5">
     <div class="form-group">
        <label class="control-label" for="firstname">First Name</label><div class="input-outer">
        <input class="form-control" type="text" size="24" name="firstname" id="firstname" value="<?php echo $user->firstname?>" required/> </div>   </div>

     <div class="form-group">
        <label class="control-label" for="lastname">Last Name</label><div class="input-outer">
        <input class="form-control" type="text" size="24" name="lastname" id="lastname" value="<?php echo $user->lastname;?>" required/>    </div>   </div>


     <div class="form-group">
            <label class="control-label" for="email" class="control-label">Email Address</label><div class="input-outer">
                <input class="form-control" size="24" type="email" class="input-xlarge" value="<?php echo $user->email;?>" name="email" id="email" required/>               
     </div>  </div>

      <div class="form-group">
        <label class="control-label" for="mobile">Mobile</label><div class="input-outer">
        <input class="form-control" type="text" maxlenght="10" size="24" name="mobile" id="mobile" value="<?php echo $user->mobile;?>" required/></div>  </div>
       
     <div class="form-group">
            <label class="control-label" for="status" class="control-label">Status</label><div class="input-outer">
            
            <select class="form-control" name="status" id="status">
              <option data-id="Active"  value="Active" <?php if($user->status=="Active"){ echo "selected"; } ?> >Active</option>
              <option data-id="Inactive" value="Inactive" <?php if($user->status=="Inactive"){ echo "selected"; } ?> >Inactive</option>
              <option data-id="Pending" value="Pending" <?php if($user->status=="Pending"){ echo "selected"; } ?> >Pending</option>
              <option data-id="Blocked" value="Blocked" <?php if($user->status=="Blocked"){ echo "selected"; } ?> >Blocked</option>
            </select>        
                                         
     </div>  </div>
    <!--  <div class="form-group">
            <label class="control-label" for="organization">Date Of Birth</label><div class="input-outer">
            <input type="text" class="form-control" name="dob" id="dob" value="<?php //echo $user->dob;?>"> 
    </div>  </div> -->
     <div class="form-group">
            <label class="control-label" for="address">Address</label>
            <div class="input-outer">
            <textarea class="form-control" name="address" id="address"><?php echo $user->address;?></textarea>       
            </div> 
     </div>

     </div>
     <div class="col-md-2"></div>
     <div class="col-md-5">
     <div class="form-group">
            <label class="control-label" for="state">State</label><div class="input-outer">
            <input type="text" class="form-control" name="state" id="state" value="<?php echo $user->state;?>">   
            
    </div>  </div>

    <div id="show_city" class="form-group">
            <label for="city" class="control-label">City</label><div class="input-outer">
            <input type="text" class="form-control" name="city" id="city" value="<?php echo $user->city;?>"> 
    </div>  </div>

    <div class="form-group">
            <label class="control-label" for="pincode">Pincode</label><div class="input-outer">
            <input type="text" class="form-control" name="pincode" id="pincode" value="<?php echo $user->pincode;?>">              
    </div>  </div>
    <div class="form-group">
            <label class="control-label" for="phone">Phone</label>   <div class="input-outer">        
            <input type="text" class="form-control" name="phone" id="phone" value="<?php if($user->phone!=0) echo $user->phone;?>"> 
           
    </div>   </div>
    <div class="form-group">
            <label class="control-label col-sm-3" for="senderid" class="control-label">Sender Id</label>
        <div class="input-outer">
              <input class="form-control" size="24" type="senderid" class="input-xlarge" 
              value="<?php $senderid = SenderID::findFirst("user_id=".$user->id);
                    if($senderid)
                      echo $senderid->text;
                  ?>" name="senderid" id="senderid" placeholder="(maxlength: 20 character)"/>             
         </div> 
   </div> 
     <!-- <div class="form-group">
        <div class="checkbox text-left">
        <label>
          <input value="1" type="checkbox" id="http_api_whitelist_status" name="http_api_whitelist_status" <?php //if($user->http_api_whitelist_status==1){ echo "checked";} ?>> HTTP API Whitelist
        </label>
      </div>
    </div> -->
      <div class="form-group">
          <div class="btn-group change_outer" data-toggle="buttons" id="pass_check">
            <label class="btn btn-primary">
            <input type="checkbox" value="true" name="pass_status" id="pass_check">  Change Password</label>     
          </div>
     </div>
     <div id="pass_wrapper" style="display:none;">
     <div class="form-group">
            <label class="control-label" for="password" class="control-label">Password</label><div class="input-outer">
            <input class="form-control" size="24" type="password" class="input-xlarge" name="password" id="password" required/>             
        </div>  </div>
     <div class="form-group">
            <label class="control-label" for="confirm_password" class="control-label">Confirm Password</label><div class="input-outer">
            <input class="form-control" size="24" type="password" class="input-xlarge"  name="confirm_password" id="confirm_password"/>               
     </div>  </div>
     </div>
     </div>
      <?php 
        // if($user_permission['pincode_message'] == 'Yes'){
        //    $public_service= PublicService::findFirst("user_id=".$user->id."");
        ?>
       <!--  <div id="public_service" class="col-sm-12"> 
        <div class="panel panel-default">
          <div class="panel-heading">Public Service Account Setting</div>
          <div class="panel-body">
            <div class="form-group">
                <label class="control-label col-sm-3" for="service_pincode">Service Pincode <a style="cursor:pointer;font-size: 15px;" onClick="getState();"><span class="glyphicon glyphicon-refresh"></span>GetState</a></label>
                <input type="hidden" name="service_pincode_val" id="service_pincode_val"/> -->
                    <?php
                    // $pincode=array();
                   // $district_html='<div class="hide col-sm-3 input-outer text-left"><div class="radio"><label><input type="radio" name="public_service_radio" value="district" id="district_radio" >District</label></div><select id="district" data-placeholder="Select district..." class="chosen" multiple="true"></select><p><a onclick="getTaluka();" class="pull-right btn btn-primary btn-sm">Get City</a></p></div>';

                   // $taluka_html='<div class="hide col-sm-3 input-outer text-left"><div class="radio"><label><input type="radio" name="public_service_radio" value="taluka" id="taluka_radio" >City</label></div><select id="taluka" data-placeholder="Select city..." class="chosen" multiple="true"></select><p><a onclick="getPincode();" class="pull-right btn btn-primary btn-sm">Get Pincode</a></p></div>';

                   // $pincode_html='<div class="hide col-sm-3 input-outer text-left"><div class="radio"><label><input type="radio" name="public_service_radio" value="pincode" id="pincode_radio" >Pincode</label></div><select id="pincode" data-placeholder="Select pincode..." class="chosen" multiple="true"></select></div>';

                   // $state_html='<div class="hide col-sm-3 input-outer text-left"><div class="radio"><label><input type="radio" name="public_service_radio" value="state" id="state_radio" >State</label></div><select id="state" data-placeholder="Select state..." class="chosen" multiple="true"></select><p><a onclick="getDistrict();" class="pull-right btn btn-primary btn-sm">Get District</a></p></div>';
                   // if($public_service){$pincode=explode("=",$public_service->pincode);}else{$pincode[0]='';}
                   // switch ($pincode[0]) {
                    //    case 'district':
                     //       echo $state_html;
                      //      if(isset($pincode[1]) && $pincode[1]!="null"){
                               // $state_ids=implode(",", json_decode($pincode[1]));
                               // $result = $this->db->fetchAll("SELECT * FROM district WHERE id IN (".$state_ids.")", Phalcon\Db::FETCH_ASSOC);
                                //echo '<div class="col-sm-3 input-outer text-left"><div class="radio"><label><input type="radio" name="public_service_radio" value="district" id="district_radio" checked>District</label></div><select id="district" data-placeholder="Select district..." class="chosen" multiple="true">';
                        //         foreach ($result as $key => $value) {
                        //              echo '<option value='.$value['id'].' selected>'.$value['name'].'</option>';
                        //         }
                        //         echo '</select><p><a onclick="getTaluka();" class="pull-right btn btn-primary btn-sm">Get City</a></p></div>';
                        //     }
                        //     echo $taluka_html;
                        //     echo $pincode_html;
                        //     break;
                        // case 'taluka':
                        //     echo $state_html;
                        //     echo $district_html;
                        //     if(isset($pincode[1]) && $pincode[1]!="null"){
                        //         $taluka_ids=implode(",", json_decode($pincode[1]));
                        //         $result = $this->db->fetchAll("SELECT * FROM taluka WHERE id IN (".$taluka_ids.")", Phalcon\Db::FETCH_ASSOC);
                        //         echo'<div class="col-sm-3 input-outer text-left"><div class="radio"><label><input type="radio" name="public_service_radio" value="taluka" id="taluka_radio" checked>City</label></div><select id="taluka" data-placeholder="Select city..." class="chosen" multiple="true">';
                        //         foreach ($result as $key => $value) {
                        //              echo '<option value='.$value['id'].' selected>'.$value['name'].'</option>';
                        //         }
                        //         echo '</select><p><a onclick="getPincode();" class="pull-right btn btn-primary btn-sm">Get Pincode</a></p></div>';
                        //     }
                        //     echo $pincode_html;
                        //     break;
                        // case 'pincode':
                        //     echo $state_html;
                        //     echo $district_html;
                        //     echo $taluka_html;
                        //     if(isset($pincode[1]) && $pincode[1]!="null"){
                        //         $tapincode_ids=implode(",", json_decode($pincode[1]));
                        //         $result = $this->db->fetchAll("SELECT * FROM pincode WHERE id IN (".$tapincode_ids.")", Phalcon\Db::FETCH_ASSOC);
                        //         echo'<div class="col-sm-3 input-outer text-left"><div class="radio"><label><input type="radio" name="public_service_radio" value="pincode" id="pincode_radio" checked>Pincode</label></div><select id="pincode" data-placeholder="Select pincode..." class="chosen" multiple="true">';
                        //         foreach ($result as $key => $value) {
                        //              echo '<option value='.$value['id'].' selected>'.$value['pin'].'</option>';
                        //         }
                        //         echo '</select></div>';
                        //     }
                        //     break;
                        // default:
                        //    $state=State::find();
                        //    $state_ids=array();
                        //    if(isset($pincode[1]) && $pincode[1]!="null"){
                        //     $state_ids=json_decode($pincode[1]);
                        //    }
                        //     echo'<div class="col-sm-3 input-outer text-left"><div class="radio"><label><input type="radio" name="public_service_radio" value="state" id="state_radio" checked>State</label></div><select id="state" data-placeholder="Select state..." class="chosen" multiple="true">';
                        //    foreach ($state as $key => $value) {
                        //     $temp_attr='';
                        //         if (in_array($value->id, $state_ids)) 
                        //             $temp_attr='selected';
                        //        echo '<option value='.$value->id.' '.$temp_attr.'>'.$value->name.'</option>';
                        //    }
                        //     echo '</select><p><a onclick="getDistrict();" class="pull-right btn btn-primary btn-sm">Get District</a></p></div>';
                        //     //District
                        //     echo $district_html;

                        //     //Taluka
                        //     echo $taluka_html;

                        //       //Pincode
                        //     echo $pincode_html;
                        //     break;
                    //}
                     ?>   
    </div>
         <!-- <p class="pull-left help-block">(Note: You can either select multiple State OR District OR Taluka OR Pincode)</p> -->
          </div>
        </div>
        </div>
        <?php //}?>
      <div class="col-sm-12 margin" align="center">
         <a onclick="submitForm();" class="btn btn-lg btn-success blue" <?php if($auth['login_type']=="Franchisee"){ echo "disabled";}?> >Update
         </a>
         <button type="reset" class='btn btn-primary btn-lg red'><span class='glyphicon glyphicon-remove-sign'></span>  Reset</button></div>
</div>
</div>
</form>
</div>

<script type="text/javascript">
/*$('input[name="service_pincode"]').keypress(function() {
    if (this.value.length >= 6) {
        return false;
    }
});*/
function submitForm(){
    var validator = $( "#form1" ).validate();
  //  if($("select.chosen").length){
/*        pincode_list = pillbox[0].getValues();*/
        //var id=$("select.chosen").attr('id');
        var id=$("input[name=public_service_radio]:checked").val();
        pincode_list = $("select#"+id+"").val();
        var json = JSON.stringify(pincode_list);
        console.log(id+'='+json);
        $("input#service_pincode_val").val(id+'='+json);
 //   }
    if(validator.form()){
        $("form").submit();
    }
}
$("[name='delivery_return_sms']").bootstrapSwitch();
$(document).ready(function(){
$(".chosen").chosen({width: "100%"});
/*pillbox = $("input#service_pincode").pillbox();
var values=$("input#service_pincode_val").val();*/
/*if(values){
    if(values.length!="2")
        pillbox[0].setValues(JSON.parse(values));
}*/
 $('#useredit div#pass_check').click(function(){
     $("#pass_wrapper").slideToggle("fast");    
});

jQuery.validator.addMethod("lettersonly", function(value, element) {
      return this.optional(element) || /^[a-z-_\s]+$/i.test(value);
    }, "Letters only please");

$("#form1").validate({
        rules: { 
           /*firstname:{required:true,lettersonly: true},
           lastname: {lettersonly: true}, */
           email:{email:true},
           mobile:{minlength:10},
           phone:{ digits: true},
           pincode:{ digits: true},
/*           service_pincode:{ digits: true,minlength:6,maxlength:6},
*/           password:{minlength:8},         
           confirm_password:{equalTo: "input[name='password']"},
        },
        messages: {
            mobile: "Enter Valid Mobile Number"
        },
        tooltip_options: {
           '_all_': { placement: 'right' }
        }
    });
 });
</script>
<?php //$this->partial("modal/plans") ?>