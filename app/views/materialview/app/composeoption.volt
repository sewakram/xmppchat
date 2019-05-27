<?php use Phalcon\Tag;
?>
<style type="text/css">
  .clrleft{
    clear: left;
  }
</style>
<!-- <script src="https://surveyjs.azureedge.net/1.0.35/survey.jquery.js"></script> -->
<!-- <link href="https://surveyjs.azureedge.net/1.0.35/survey.css" type="text/css" rel="stylesheet"/> -->
<div class="compose_wrapper">
  <form name="composeForm" id="composeForm" method="post" autocomplete="off" action="" class="form-horizontal" role="form">
      <div class="row send-options-message">
      <ul id="compose-to-type-tab" class="tabs">
        <?php if($user_permission['contact_groups'] == 'Yes'){?>
        <li class="tab col s3"><a class="<?php if($user_permission['contact_groups'] == 'Yes'){echo "active";}?>" href="#group_id"><input class="with-gap" data-rel="group_id" id="group_type_msg" type="radio" value="group" name="to_type_msg" <?php if($user_permission['contact_groups'] == 'Yes'){echo "checked";}?> />Group</a></li>
        <?php } ?>
        <?php if($user_permission['pincode_message'] == 'Yes'){?>
        <li class="tab col s3"><a href="#pincode"><input class="with-gap" data-rel="pincode" id="public_type_msg" type="radio" value="pincode" name="to_type_msg"/>Public Service</a></li>
         <?php } ?>
        <li class="tab col s3"><a class="<?php if($user_permission['contact_groups'] == 'No'){echo "active";}?>" href="#single"><input class="with-gap" data-rel="single" id="single_type_msg" type="radio" value="single" name="to_type_msg" <?php if($user_permission['contact_groups'] == 'No'){echo "checked";}?> /> Numbers</a></li>
        <?php if($user_permission['excel_message_upload'] == 'Yes'){?>
        <li class="tab col s3"><a href="#excelfile"><input class="with-gap" data-rel="excelfile" id="excelfile_type_msg" type="radio" value="excelfile" name="to_type_msg"/>File Upload</a></li>
        <?php } ?>
        <li class="tab col s3"><a class="with-gap modal-trigger"  href="#poll">Create Poll</a></li>
      </ul>
      </div>
            <div id="to_div">
        <?php 
            if($user_permission['pincode_message'] == 'Yes'){?>
                    <div id="pincode" name="pincode"  class="row select_Wrapper">
                      <?php
                    $pincode=array();
                    $public_service= PublicService::findFirst("user_id=".$auth['id']."");
                    if($public_service){
                      $pincode=explode("=",$public_service->pincode);
                      if(isset($pincode[1]) && $pincode[1]!="null"){
                      $pincode_ids=implode(",", json_decode($pincode[1]));

                     switch ($pincode[0]) {
                                case 'district':
                                    $pincode_src ="SELECT p.pin,p.id FROM pincode p,taluka t,district d WHERE d.id=t.dist_id AND t.id=p.tq_id AND d.id IN (".$pincode_ids.")";
                                    break;
                                case 'taluka':
                                    $pincode_src = "SELECT p.pin,p.id FROM pincode p,taluka t WHERE t.id=p.tq_id AND t.id IN (".$pincode_ids.")";
                                    break;
                                case 'pincode':
                                    $pincode_src = "SELECT pin,id FROM pincode WHERE id IN (".$pincode_ids.")";
                                    break;
                                default:
                                    //state
                                    $pincode_src = "SELECT p.pin,p.id FROM pincode p,taluka t,district d,state s WHERE s.id=d.state_id AND d.id=t.dist_id AND t.id=p.tq_id AND s.id IN (".$pincode_ids.")";
                                    break;
                    }
                    $this->session->set("pincode_sql", $pincode_src);
                        echo'<div class="input-outer"><p><input type="radio" name="public_service_radio" value="pincode" id="pincode_radio" class="with-gap" checked /><label for="pincode_radio">Pincode</label><input class="with-gap" type="radio" name="public_service_radio" value="pincode_range" id="pincode_range" /><label for="pincode_range">Pincode Range</label></p><select name="pincode[]" id="pincode" data-placeholder="Select pincode..." class="chosen" multiple="true" class="browser-default"></select><div style="display:none;" id="pincode_range">Start <input type="text" size="6" name="pincode_range_min">- End <input size="6" type="text" name="pincode_range_max"></div></div>';
                    }
                }
                     ?>   
                       <span id="showMembers_pincode"></span>
                   </div>
                    <?php }
                     if($user_permission['excel_message_upload'] == 'Yes'){
                      /* echo '<div id="excelfile" class="row select_Wrapper"><div class="file-field input-field">
      <div class="btn"><span>File</span><input type="file" name="excelfile" id="excelfile" /></div><div class="file-path-wrapper"><input class="file-path validate" type="text"></div></div><p class="grey-text">Allowed File Types are .TXT or .XLS or .XLSX <a href="/sample.xls" download>Download sample file</a></p></div>';*/
               $alphabet = range('A', 'Z');
                       echo '<div id="excelfile" class="row select_Wrapper"><div class="file-field input-field">
      <div class="btn"><span>File</span><input type="file" name="excelfile" id="excelfile" /></div><div class="file-path-wrapper"><input class="file-path validate" type="text"></div></div><p class="grey-text">Allowed File Types are .TXT or .XLS or .XLSX <a id="sample_file" href="/sample.xls" download>Download sample file</a></p><div class="row" width="100%"><input  class="with-gap" name="msgtypes" type="radio"  id="simple" value="simple" checked /><label for="simple">Simple</label><input  class="with-gap"  name="msgtypes" type="radio"  id="dynamic" value="dynamic"/><label for="dynamic">Dynamic</label></div><div class="col s6" style="padding-left:0;display:none;"><div id="Mobile_Column"><h6 class="black-text">Mobile Column:</h6><div class="input-field"><select  class="option browser-default"  id="mob_select" name="mob_select">';  
            foreach($alphabet as $key => $val){ ?>
                  <option value=<?php echo $val ?>><?php echo $val ?></option><?php
                  }
            echo '</select></div></div></div><p class="help-block">Column (A) is for Mobile Numbers.</p><div class="col s12" ><div id="Message_Column"><h6 class="black-text">Add Column in Message :</h6><div class="input-field"><select id="col_select"  class="option browser-default"  name="col_select" onchange="call_textareamsg();" disabled="true">'; 
                    $p=0;
                      foreach($alphabet as $key => $val){
                          if($p==0){
                            $p++;continue;
                          } ?>
                            <option value=<?php echo $val ?>><?php echo $val ?></option><?php } 
                    echo '</select></div></div></div></div>';
                    
                    }
                    $class_temp='';
                    if($user_permission['contact_groups'] == 'Yes'){$class_temp='';}
                    echo "<div id='single' class='row select_Wrapper ".$class_temp."'><textarea  name='mobile_no' id='mobile_no' class='materialize-textarea'></textarea><p class='help-block'>Type mobile no's in each line or with commas in between</p></div>";  
                    if($user_permission['contact_groups'] == 'Yes'){
                    ?>
                      <div id="group_id" class="row <?php if($user_permission['contact_groups'] == 'No'){echo '';}?> select_Wrapper">
                      <select class="browser-default" name="group_id" id="group_id" onchange='getMembers(this.value)'>
                           <option selected="" disabled="" value="">Select group</option>
                          <?php 
                              $groups = Group::find(array("user_id = $user_id ",'order'=>'id' ));
                              foreach ($groups as $group) { 
                                echo" <option value=$group->id>$group->name</option>";   
                              } ?>             
                      </select>
                      <span id="showMembers"></span>
                      </div>
                     
                    <?php }?>
  </div>
  <div id="route_block" class="row">
                   <h6 class="black-text">Send to</h6>
                    <div class="input-field">
                      <select  class="option browser-default" name="option" id="option" <?php if($user_permission['http_sms_forwarding_(3rd_party)']=="No"||$api_status==false){ echo "disabled"; } ?> >
                            <option value="Multimedia" selected>Sancharapp Only</option>
                            <option value="SMS">SMS Only</option>
                            <option value="Default">All (Sancharapp + SMS)</option>

                      </select>
                      <?php if($user_permission['http_sms_forwarding_(3rd_party)']=="No" || $api_status==false){ ?>
                        <input type="hidden" name="option" value="Multimedia" class='option' />
                      <?php } ?>
                    </div>
                    <p class="help-block grey-text">
                      <span id="help_Multimedia">Non Sancharapp users will not receive any message</span>
                      <span style="display:none;" id="help_Default">SMS will be sent to all selected contacts as per waiting period</span>
                      <span style="display:none;" id="help_SMS">Sancharapp users will not receive any message</span>
                    </p>
 </div>
  <?php                  
  if($user_permission['http_sms_forwarding_(3rd_party)']=="No"||$user_permission['time_bound_delivery'] == 'No'){
        $err_priority='You don\'t have permission to this feature.To enable this feature please upgrade your plan.';
    }else if ($api_status==false) {
        $err_priority='You don\'t have configure/enable Third party SMS Api .To configure/enable it go to <a href="/account/api">My account</a>';
    }else{
        $err_priority='This option is available with Sancharapp+SMS only (Default waiting period can be set in my profile)';
  }
  ?>
     <div id="priority" class="row">
      <h6 class="black-text">SMS waiting period <a class="tooltipped" data-position="right" data-delay="50" data-tooltip="If a Sancharapp user is not in data network for any reason the message will be delivered to the user via SMS after the selected waiting period. Non Sancharapp users will receive SMS without any waiting."><i class="material-icons black-text">info</i></a></h6>               
                      <div class="input-field">
                      <select class="browser-default priority" name="priority" id="priority" <?php if($user_permission['time_bound_delivery'] == 'No'||$user_permission['http_sms_forwarding_(3rd_party)']=="No"||$api_status==false){echo "disabled"; } ?> >
                          <option selected="" value="0">Never</option>
                            <?php
                              $time_intervals = explode(",",$user_permission['time_bound_delivery']);
                              foreach ($time_intervals as $time_interval) { 
                                $tmp='';
                                if($user->default_msg_priority==$time_interval){
                                    $tmp='selected';
                                }
                                if($time_interval>59)
                                  $time_interval_val=($time_interval/60).' hr';
                                else
                                  $time_interval_val=$time_interval.' min';
                                echo"<option value=$time_interval $tmp>$time_interval_val</option>";   
                            } ?>    
                      </select>
                    </div>
                      <p class="grey-text help-block"><?php echo $err_priority;?></p>
    </div>
  <div class="row message-inbox-tab">
    <div class="col s12">
      <ul id="compose-message-tab" class="tabs">
        <li class="tab col s3"><a class="active" href="#compose-text-option"><input style="margin-top: 1px;" name="msg_field_type" type="radio" value="text" checked>Message</a></li>
        <li class="tab col s3"><a href="#compose-image-option"><input style="margin-top: 1px;" name="msg_field_type" type="radio" value="multimedia">Image</a></li>
        <li class="tab col s3"><a href="#compose-audio-option"><input style="margin-top: 1px;" name="msg_field_type" type="radio" value="multimedia">Audio</a></li>
        <li class="tab col s3"><a href="#compose-video-option"><input style="margin-top: 1px;" name="msg_field_type" type="radio" value="multimedia">Video</a></li>
      </ul>
    </div>
    <div id="compose-text-option" class="col s12">
        <p>
          <input class="with-gap" id="opt_text" type="radio"  value="text" name="message_type" checked="checked" />
          <label for="opt_text">Text</label>
          <input class="with-gap" <?php if($user_permission['unicode_message'] == 'No' && $user_permission['http_sms_forwarding_(3rd_party)'] == 'No'){echo "disabled";}?> id="opt_uni" type="radio" value="unicode" name="message_type" />
          <label for="opt_uni">Unicode</label>
        </p>
          <div <?php if($user_permission['unicode_message'] == 'No' && $user_permission['http_sms_forwarding_(3rd_party)'] == 'No'){echo "style='pointer-events: none;'";}?> id='translControl'> </div>
        <textarea name="text"  onKeyUp="countChar(this)" onFocus="countChar(this)" id="text" class="textarea text-message-row materialize-textarea" placeholder="Type a message"></textarea><div id="charNum" align="left" style="color:#000000;"></div>
      <div id="msg_error" align="left" style="color:#F00;display:none"><strong>Please enter message</strong></div>
    </div>
    <div id="compose-image-option" class="col s12">
        <img style="display:none;width:30%;"class="img-responsive img-thumbnail" id="xFileImage" src="">
        <input id="multimedia" name="multimedia" type="hidden"/>
        <a onClick="BrowseServer();" href="#!" class="add_photos compose_common text_lightgrey-color relative"><i class="large material-icons">file_upload</i></a>
    </div>
    <div id="compose-audio-option" class="col s12">
        <img style="display:none;width:30%;"class="img-responsive img-thumbnail" id="xFileAudio" src="">
        <input id="multimedia" name="multimedia" type="hidden"/>
        <a onClick="BrowseServer();" href="#!" class="add_photos compose_common text_lightgrey-color relative"><i class="large material-icons">file_upload</i></a>
    </div>
    <div id="compose-video-option" class="col s12">
        <img style="display:none;width:30%;"class="img-responsive img-thumbnail" id="xFileVideo" src="">
        <input id="multimedia" name="multimedia" type="hidden"/>
        <a onClick="BrowseServer();" href="#!" class="add_photos compose_common text_lightgrey-color relative"><i class="large material-icons">file_upload</i></a>
    </div>
  </div>
  <div class="send-immediately row">
    <p>
        <input class="with-gap"  id="schedular_status_1" type="radio" value="Now" name="schedular_status" checked="" />
        <label for="schedular_status_1">Now</label>
    <input class="with-gap"  id="schedular_status_2" type="radio" value="Later" name="schedular_status" />
        <label for="schedular_status_2">Later</label>
        
      <span style="display:inline-block;" id="datetime_wrapper" class="hide"><input Placeholder="Datetime" class="flatpickr" type="text" id="timedatepicker" /><input id="input_starttime" class="timepicker" type="hidden">
        <input id="hidden_timedatepicker" name="datetime" type="hidden" /></span>
      <button id="submitbtn" type="submit" class="smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">send</i></button>
    </p>
<!-- 
    <div id="datetime_wrapper" class="hide">
          <div class="input-field">
          <span>Datetime</span>
           <input class="flatpickr" type="text" name="datetime" id="timedatepicker" data-enabletime=true data-time_24hr=true>
        </div>
   </div>  -->
   </div>

   
<!--   <div class="send-cancel-wrap row">
      <button id="submitbtn" type="submit" class="send_text compose_common text_lightgrey-color relative"><i class="left material-icons">send</i></button>
  </div>      -->
  </form>
  <!-- app poll start -->
   <!-- <div class="row"> -->
    
      <!-- <div class="col s12"> 
        <h4 class="header">who will win?</h4>
      </div>
      
      <div class="col s12">
    <form action="#" id="voting_form" method="post">
      <div class="col S8">
      <input class="with-gap" name="group2" type="radio" id="test1"/>
      <label for="test1">BJP</label>
      </div>

      <div class="col S8 clrleft"> -->
      <!-- <input name="group2" type="radio" id="test1" /> -->
      <!-- <label for="test2">APP</label> -->
      <!-- <input class="with-gap" name="group2" type="radio" id="test2"/>
      <label for="test2">APP</label>
      </div>
      
      <div class="col S8 clrleft">
      <input class="with-gap" name="group2" type="radio" id="test3" />
      <label for="test3">UPA</label>
      </div>
      <div class="col S8 clrleft">
      <button id="submitvote" type="button" class="class="waves-effect waves-light btn"">Vote</button>
      </div>
    </form>
  </div> -->
  
    <!-- <div id="surveyElement"></div> -->
     <!-- <div id="surveyResult"></div> -->
      <!-- <script type="text/javascript" src="./index.js"></script> -->
      <!-- {{ javascript_include('js/index.js') }} -->
   <!-- </div> -->
   <!-- app poll end -->
</div>

<div id="addgroupmodal" class="modal" style="display:none;"><div class="modal-content"><div id="msg"></div><p id="text-mod"></p><form class="col s12 well" id="importForm"  action=""  method="post"><div class="row" width="100%"><input  class="with-gap" name="import_type" type="radio"  id="impgroup1" checked /><label for="impgroup1">Add numbers to group</label><input  class="with-gap"  name="import_type" type="radio"  id="impgroup2" value="import_group_name"/><label for="impgroup2">Create whole new group</label></div><div id="fform"></div></div><div class="modal-footer"><a href="#" class="modal-action modal-close waves-effect waves-green btn-flat">Cancel</a><button id="submitbtn1" type="submit" class="btn btn-primary">Add</button><a id="finalmsg" onclick="send_message();" class="btn btn-primary">Continue without adding</a></div></form></div>

<div id="summarymodal" class="modal">
                <h3 class="boot_dialog">Message Summary</h3><hr>
                 <div class="msg_sent_wrapp"><b id='total_msg_sent'></b> Message sent<br><b id='linkapp_user_count'></b> Sancharapp user</div>
                <div class='modal-footer'>
                      <a href='#' class='modal-action modal-close waves-effect waves-green btn-flat'>Cancel</a>
                      <a href='#' class='modal-action modal-close waves-effect waves-green btn-flat'>Ok</a>
                </div>
</div>
     <?php  $chk="user_id=".$auth['id'];
     $sender = SenderID::findFirst($chk);
     $sender_text=0;
if(count($sender)>0)
{
    if(isset($sender->text)){
        $sender_text=1;
     }
}
//echo "val=".$sender_text;
 
       ?>
<script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.100.2/js/materialize.min.js"></script>
<script type="text/javascript">

    function pollresult(id){
      // alert('sewak');exit;
      var strv = $( "#voting_form" ).serialize();
      $.ajax({
      type: "POST",
      url: "/poll/rating",
      data:{formdata:strv,poll_id:id},
      dataType: "json",
      error:function(response){
      console.log('error: ',response);
      },
      success:  function(response){
      console.log('success:',response);
      }
      });

      }
      
  // A $( document ).ready() block.
$( document ).ready(function() {
  /////////voting begain
    // $("#submitvote" ).on('click', function() {
    // console.log('sewak');
    // });
    // pollresult function start
    
      // pollresult function end
    $("#subpoll" ).on('click', function() {
    ///////
          var str = $( "#poll_form" ).serialize();
        // alert(str); 
         $.ajax({
                      type: "POST",
                      url: "/poll/save",
                      data:str,
                      dataType: "json",
                      error:function(response){
                     alert('error: ',response);
                      },
                      success:  function(response){
                        console.log(response.data.id);
                        var str = $( "#poll_form" ).serializeArray();
                        // $.each(str, function( i, val ) {
                        html='<div class="row">\
                        <div class="col s12"> \
                        <h4 class="header">'+str['0'].value+'</h4>\
                        </div>\
                        <div class="col s12">\
                        <form action="#" id="voting_form" method="post">\
                        <div class="col S8">\
                        <input class="with-gap active" name="group2" type="radio" id="test1">\
                        <label for="test1">'+str['1'].value+'</label>\
                        </div>\
                        <div class="col S8 clrleft">\
                        <input class="with-gap" name="group2" type="radio" id="test2">\
                        <label for="test2">'+str['2'].value+'</label>\
                        </div>\
                        <div class="col S8 clrleft">\
                        <input class="with-gap" name="group2" type="radio" id="test3">\
                        <label for="test3">'+str['3'].value+'</label>\
                        </div>\
                        <div class="col S8 clrleft">\
                        <button onclick="pollresult('+response.data.id+');" id="submitvote" type="button" class="waves-effect waves-light btn">Vote</button>\
                        </div>\
                        </form>\
                        </div>\
                        </div>';
                        // });

                        $('#message-recent').prepend(html);
                        console.log('form val: ',str);


                      }


            });
        ///////
    });
    

  //////////////voting end
  $( "#poll_form" )
   $('.modal').modal({
      dismissible: true, // Modal can be dismissed by clicking outside of the modal
      opacity: .5, // Opacity of modal background
      inDuration: 300, // Transition in duration
      outDuration: 200, // Transition out duration
      startingTop: '4%', // Starting top style attribute
      endingTop: '10%', // Ending top style attribute
      ready: function(modal, trigger) { // Callback for Modal open. Modal and trigger parameters available.
        // alert("Ready");
        console.log(modal, trigger);
      },
      complete: function() { 
      // alert('Closed');
        
        
      } // Callback for Modal close
    }
  );
});
</script>
<!-- Message Page Specific JS Code -->
<script type="text/javascript">
var agree_terms_of_service="<?php echo $user->agree_terms_of_service ?>";
var sender_text=<?php echo $sender_text ?>;
//alert(sender_text);
var multimedia ;
$(document).ready(function() {
    $("#composeForm #route_block select#option").on("change",function(){
    var option=$(this).val();
    console.log(option);
    if(option=="Default"){
      $('select#priority').prop('disabled', false);
    }else{
      $('select#priority').prop('disabled', 'disabled');
    }
    $("#composeForm #route_block .help-block span").hide();
    $("#composeForm #route_block .help-block #help_"+option+"").show();
  }).change();

  /*Compose Message*//*********************************************************************/
 $('.chosen').ajaxChosen({
                   dataType: 'json',
                   type: 'POST',
                   url:'/user/getAjaxPincode/'
 },{
                   loadingImg: 'http://sancharapp.com/public/images/loading.gif'
 });
if(agree_terms_of_service==0){
  $('#myModal').openModal();   
}else{
  if(sender_text==false){
      $('#getsenderModal').openModal();
    }
}
$('.feedback_chosen').ajaxChosen({
                   dataType: 'json',
                   type: 'POST',
                   url:'/user/getAjaxPincode/'
 },{
                   loadingImg: 'http://sancharapp.com/public/images/loading.gif'
 });

   $('input[type=radio][name=public_service_radio]').change(function() {
        if (this.value == 'pincode') {
        $("div#pincode_range").hide();
        $("div#pincode_chosen").show();
        }
        else{
        $("div#pincode_range").show();
        $("div#pincode_chosen").hide();
        }
    });
  var d = new Date();
  var hours = d.getHours();
  var minutes = d.getMinutes();
  $('#MESSAGE #timedatepicker').pickadate({closeOnSelect:true,format: 'yyyy/mm/dd',min:d,onClose: function() {
        $(document.activeElement).blur();
        var value=$('#MESSAGE #timedatepicker').val();
        if(value)
          $('#MESSAGE #input_starttime').trigger('click');
    }, onSet: function( arg ){
        if ( 'select' in arg ){ //prevent closing on selecting month/year
            this.close();
        }}
  });
  $('#MESSAGE #input_starttime').on("input change",function(){
      var time=$(this).val();
      var old=$('#MESSAGE #timedatepicker').val();
      $('#MESSAGE #timedatepicker').val(old+' '+time);
      $('#MESSAGE #hidden_timedatepicker').val(old+' '+time12To24(time));
    })
  $('#MESSAGE #input_starttime').clockpicker({
      placement: 'bottom',
      align: 'left',
      twelvehour: true,
      //default: ''+hours+':'+minutes+'',
      default:'now',
      autoclose: true
    });
  $('ul.tabs#compose-message-tab li a,ul.tabs#follow-message-tab li a,ul.tabs#compose-to-type-tab li a,ul.tabs#follow-to-type-tab li a').on('click', function(e) {
    $(this).find("input[type=radio]").prop( "checked", true );
  });
$('#MESSAGE input[name=schedular_status]').on("change",function(){
    if($(this).attr("id")=="schedular_status_1"){
      $('#MESSAGE #datetime_wrapper').addClass('hide');
    }else{
      $('#MESSAGE #datetime_wrapper').removeClass('hide');
      $('#MESSAGE #timedatepicker').trigger('click');
    }
});

$("#composeForm").validate({
      ignore: [],
        debug: false,
        rules: {
           to_type_msg:{required:true},
           group_id: {
             required: {
                 depends: function(element) {
                 if($("#group_type_msg:checked").length){
                      return true;
                 }
               }
             }
            },
            excelfile: {
             required: {
                 depends: function(element) {
                    if($("#excelfile_type_msg:checked").length){
                      return true;
                    }
                 }
             }
            },
            datetime: {
             required: {
                 depends: function(element) {
                    if($("#schedular_status_2:checked").length){
                      return true;
                    }
                 }
             }
            },
            mobile_no: {
             required: {
                 depends: function(element) {
                    if($("#single_type_msg:checked").length){
                      return true;
                    }
                 }
             }
            },
            text: {
             required: {
                 depends: function(element) {
                  console.log($("input[name=msg_field_type]:checked").val());
                    if($("input[name=msg_field_type]:checked").val()=="text"){
                      return true;
                    }
                 }
             }
            }
        },
        messages: {
          multimedia:{ required:"Please enter message" }
        },
        tooltip_options: {
           to_type_msg:{ placement: 'right' },
           pincode:{ placement: 'right' },
           group_id:{ placement: 'right' },
           excelfile:{ placement: 'right' },
           text:{ placement: 'right' },
           datetime:{ placement: 'right' },
        },        
          submitHandler: function (form) {
            var dataString = $("#composeForm").serialize();
            datavalue = $("#composeForm").serializefiles();

            if($('#public_type_msg:checked').val()){
              var pin = document.forms["composeForm"]["pincode"].value;
            
              if(pin=="" ||typeof(pin)  === "undefined"){
                 Materialize.toast("Please enter pincode", 3000);
                $("html, body").animate({ scrollTop: 0 }, "slow");
                return false;
              } 
            }
            if(!$("#composeForm #group_type_msg:checked").length)    
              mobile_count = ($("#composeForm #mobile_no").val().split("\n")).length;
            //other wise mobile count will set from common.js file
            //var option = $('.option').val();
              var option = $('#option').val();
            msg_field_type=$('#composeForm input[name=msg_field_type]:checked').val();
            
            if(msg_field_type=="multimedia")
              multimedia = $("#composeForm input#multimedia").val();//multimedia_image;
            else
              multimedia = $("#composeForm #text").val();//text message

            if(multimedia=="" ||typeof(multimedia)  === "undefined"){
               Materialize.toast('Please enter message', 3000);
               return false;
            }
          
            //$("select#option").val('Default');
            $("#composeForm #text,#composeForm #timedatepicker,#composeForm #mobile_no,#composeForm #group_id,#composeForm #multimedia").val('');
            $("#composeForm #showMembers,#composeForm #showMembers_pincode").empty();
            $("#composeForm img#xFileImage").removeAttr("src").hide();
             $.ajax({
                  cache: false,
                  type: "POST",
                  url: "/message/verify",
                  data:{ mobile_count:mobile_count, option:option, multimedia:multimedia },
                  dataType: "json",
                  success: function(response){
                   
                    if(response['status']!='success'){
                      Materialize.toast(response['message'], 3000);
                      return false;
                    }else{ 
          
                           $.ajax({
                            cache: false,
                            type: "POST",
                            url: "/message/verify_contacts",
                            data:datavalue,
                            contentType: false,
                            processData: false,
                            success: function(response){
                                  console.log(response);
                                // response=JSON.parse(response);
 
                                if (response['status']!="success") {
                                var $toastContent = $('<span>'+'<div class="alert alert-danger">'+response['message']+'</div>'+'</span>');
                                Materialize.toast($toastContent, 3000);
                             }else{

                               console.log(response);
                                var total_msg_sent=response['total_msg_sent'];
                                var not_in_group_array=response['not_in_group_array'];
                
                                var not_in_group_array_html='';
                                
                               if(not_in_group_array.length>0)
                               {
                                  document.getElementById("text-mod").innerHTML="<b>"+not_in_group_array.length +"</b> numbers are not in contacts please select option and press add or Continue without adding"; 
                                      $('#addgroupmodal').openModal();
                                      
                                      not_in_group_array_html='<br><input type="hidden" name="import_contacts" value='+not_in_group_array.join()+'><div class="form-group"><div class="row"><div class="col-md-6"><select class="input-md form-control" name="import_group_id" id="import_group_id" >'+$("select#group_id").html()+'</select></div><div class="col-md-6"><input id="import_group_name" type="text" length="10"  name="import_group_name" placeholder="New Group name"></div></div></div>';
                                      document.getElementById('fform').innerHTML=not_in_group_array_html;
                                      $("#import_group_name").hide();
                                       $("select#import_group_id").show();

                                      $(document).on("click", "#impgroup1", function(){ 
                                              //   document.getElementById('fform').innerHTML=not_in_group_array_html;
                                              $("select#import_group_id").show();
                                              $("#import_group_name").hide();
                                      });
                                      
                                      $(document).on("click", "#impgroup2", function(){ 
                                              //    document.getElementById('fform').innerHTML=not_in_group_array_html;
                                              $("#import_group_name").show();
                                              $("select#import_group_id").hide();
                                      });

                                    }else{
                                      
                                         if($("#composeForm #schedular_status_2:checked").length)
                                                    {
                                                        Materialize.toast('Message Schedule', 3000);

                                                        $.ajax({
                                                                cache: false,type: "POST",
                                                                url: "/schedular/ajaxnew",
                                                                data: datavalue,    
                                                                contentType: false,
                                                                processData: false,
                                                                success: function(response){
                                                                              //$('#loader').hide();
                                                                              console.log(response);
                                                                              return false;
                                                                }
                                                          });
                                                          return false;
                                                       }  
                                                      
                                                         //end check schedule -----------------------------------
                                                        //$('#loader').show();

                                                    /*    var d = new Date();
                                                        var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9); 
                                                        var item = '<li class="collection-item avatar"><img class="circle" alt="" src="../images/1new-connect-logo-3-plain.png"><span class="title font-size16 ellipsify"></span><span class="emojitext ellipsify ellipsis multiline font-size14">'+multimedia+'</span><span class="date-time font-size12">'+datetime+'</span></li>';
                                                        $("#MESSAGE ul#message-recent").prepend(item);*/

                                                        //Materialize.toast('Message sent ', 3000);
                                                      //  $(".compose_wrapper").animate({ scrollTop: 0 }, "slow");
                                                        //schedular end
                                                    
                                                        send_message();
                                    }
                             }
                            }
                          });
                    }
                  }
                });
          }
  });
//#importForm").validate() strat
$("#importForm").validate({        
        rules: {
            import_group_id:{ required: {
                 depends: function(element) {
                                if($("#impgroup1:checked").length){
                                     return true;
                                }
                            }
                }
          },
            import_group_name:{ required: {
                      depends: function(element) {
                                if($("#impgroup2:checked").length){
                                     return true;
                                }
                            }
                      }
            },
            },
            tooltip_options: {
                   '_all_': { placement: 'bottom' }
            },
        submitHandler: function (form) {
           dataval = $("#importForm").serialize();
                 console.log(dataval);
                  $.ajax({
                  cache: false,
                  type: "POST",
                  url: "/app/updatestatus",
                  data:dataval,                   
                  dataType: "json",
                  success: function(response){
                    $('#addgroupmodal').closeModal();                    
                    var $toastContent = $('<span>'+response['message']+'</span>');
                    Materialize.toast($toastContent, 3000);
                     console.log(response);
                       if (response['status']=="success") {
//schedular start
     //check schedule for later or send  now----------------
                      if($("#composeForm #schedular_status_2:checked").length){
                          Materialize.toast('Message Schedule', 3000);
                          $.ajax({cache: false,type: "POST",url: "/schedular/ajaxnew",data: datavalue,    contentType: false,
                            processData: false,
                            success: function(response){
                                //$('#loader').hide();
                                console.log(response);
                                return false;
                            }
                      });
                        return false;
                      }  
                      //end check schedule -----------------------------------

                      //$('#loader').show();
                      var d = new Date();
                      var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9); 
                      var item = '<li class="collection-item avatar"><img class="circle" alt="" src="../images/1new-connect-logo-3-plain.png"><span class="title font-size16 ellipsify"></span><span class="emojitext ellipsify ellipsis multiline font-size14">'+multimedia+'</span><span class="date-time font-size12">'+datetime+'</span></li>';
                      $("#MESSAGE ul#message-recent").prepend(item);
                    //  Materialize.toast('Message sent ', 3000);
                   //   $(".compose_wrapper").animate({ scrollTop: 0 }, "slow");
//schedular end


                        send_message();
                       }else{
                            return;
                       }
                       return false;
                   }
                   });
      }
  });                     
//#importForm").validate() end             
$(document).on("click", "#MESSAGE ul#message-recent li", function (event) {
  window.location.href = "/reports";
}); 
/*END Compose Message*//*********************************************************************/


});
function send_message()  {

     $('#addgroupmodal').closeModal();
    /////////////////strat
    
   if($("#composeForm #schedular_status_2:checked").length){
                                                        Materialize.toast('Message Schedule', 3000);
                                                        $.ajax({
                                                                cache: false,type: "POST",
                                                               url: "/schedular/ajaxnew",
                                                                data: datavalue,    
                                                                contentType: false,
                                                                processData: false,
                                                                success: function(response){
                                                                              //$('#loader').hide();
                                                                              console.log(response);
                                                                              return false;
                                                                }
                                                          });
                                                          return false;
                                                       }  
                                                       else{

///////////////////////////////end    
      var mytab = $('input[name=to_type_msg]');
      var checkedtab = mytab.filter(':checked').attr('id');
        var myRadio = $('input[name=msgtypes]');
      var checkedValue = myRadio.filter(':checked').attr('id');

 if(checkedtab=="excelfile_type_msg" && checkedValue=='dynamic'){   
  /////////////////strat
                 $.ajax({
                            cache: false,
                            type: "POST",
                            url: "/message/send_xlmsg",
                            data:datavalue,
                            contentType: false,
                            processData: false,
                            success: function(response){
                               console.log(response);
                                 response=JSON.parse(response);
                                if (response['status']!="success") {
                                   var $toastContent = $('<span>'+'<div class="alert alert-danger">'+response['message']+'</div>'+'</span>');
                                Materialize.toast($toastContent, 3000);
                               // $("#successmsg").html('<div class="alert alert-danger">'+response['message']+'</div>').show();

                                }else{
                                   var $toastContent = $('<span>'+'Message sent'+'</span>');
                                Materialize.toast($toastContent, 3000);
                           //      $("#successmsg").html('<div class="alert alert-success">Message sent</div>').show();
                               $("html, body").animate({ scrollTop: 0 }, "slow");
                                var total_msg_sent=response['total_msg_sent'];
                                var linkapp_user_count=response['linkapp_user_count'];
                                var not_in_group_array=response['not_in_group_array'];
                                var not_in_group_array_html='';
                                document.getElementById("total_msg_sent").innerHTML = total_msg_sent;
                               
                               if(linkapp_user_count==""){
                                linkapp_user_count=0;
                               }
                                document.getElementById("linkapp_user_count").innerHTML = linkapp_user_count;
                               $('#summarymodal').openModal();
                               }
                               return false;
                            }
                      });
////////////////1

      }
        else{

 $.ajax({
                            cache: false,
                            type: "POST",
                            url: "/message/send",
                            data:datavalue,
                            contentType: false,
                            processData: false,
                            success: function(response){
                                //$('#loader').hide();
                                console.log(response);
                                response=JSON.parse(response);
                                if (response['status']!="success") {
                                  Materialize.toast(response['message'], 3000);
                                }else{
                                console.log(response);
                                //start
                                var total_msg_sent=response['total_msg_sent'];
                                var linkapp_user_count=response['linkapp_user_count'];
                                var not_in_group_array=response['not_in_group_array'];
                                var not_in_group_array_html='';
                                document.getElementById("total_msg_sent").innerHTML = total_msg_sent;
                                
                               if(linkapp_user_count==null){
                                linkapp_user_count=0;
                               }
                                document.getElementById("linkapp_user_count").innerHTML = linkapp_user_count;
                                  Materialize.toast('Message sent ', 3000);
                               $('#summarymodal').openModal();
                                //end
                               }
                               return false;
                            }
                      });
        }
      }
} 
$('#MESSAGE input[name=msgtypes]').on("change",function(){
    if($(this).attr("id")=="dynamic"){
      $('#MESSAGE #col_select').removeAttr('disabled');
      $('#sample_file').prop("href", "/dynamic_msg_upload.xls");
      $("#MESSAGE .message-inbox-tab ul li:eq(1)").removeClass('disabled');
    }else{
      $("#MESSAGE #col_select").attr('disabled','disabled');
      $('#sample_file').prop("href", "/sample.xls");
      $("#MESSAGE .message-inbox-tab ul li:eq(1)").addClass('disabled'); 
    }
   
});
function call_textareamsg(){
    
   var value=$('#col_select').val();
    var dest_value=$("textarea#text").val();
      //alert(value);

  if($("textarea#text").val()!='')
  {
    $("textarea#text").val(dest_value+' <'+value+'>');
  }
else{
$("textarea#text").val('<'+value+'>');  
  }
}
$('#MESSAGE ul#compose-to-type-tab li a').on('click', function(e) {
  var hash = $(this).attr("href");
 if(hash=="#pincode"){
    $('.send-immediately label').addClass("hide");
  $('.send-immediately #schedular_status_1').addClass("hide");
  $('.send-immediately #schedular_status_2').addClass("hide");
 }else{
  $('.send-immediately label').removeClass("hide");
  $('.send-immediately #schedular_status_1').removeClass("hide");
  $('.send-immediately #schedular_status_2').removeClass("hide");
 }
  });
</script>
<!-- END Message Page Specific JS Code -->