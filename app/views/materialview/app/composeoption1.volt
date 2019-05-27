<?php use Phalcon\Tag;
?>
<!--added code webgile start-->

<div class="compose_wrapper">
<!--<div id="successmsg" style="display:none;"></div>-->
  <form name="composeForm1" id="composeForm1" method="post" autocomplete="off" action="" class="form-horizontal" role="form">
<div class="col s12">
                  <div style="display:none;" class="form-group">
                    <label class="control-label" for="sender_id">Sender Id</label>
                    <div class="input-outer">
                      <input type="text" name="sender_id2" id="sender_id2" value="poonam" class="form-control" readonly />
                    </div>
                  </div>

                  <div id="route_block1" class="row">
                  <h6 class="black-text"  for="option1">Route Type</h6>
                     <div class="input-field">
                      <select onchange='change_option(this.value)' class="option browser-default" name="option1" id="option1" <?php if($user_permission['http_sms_forwarding_(3rd_party)']=="No"||$api_status==false){ echo "disabled"; } ?> >
                            <option value="Multimedia" selected>Sancharapp Only</option>
                            <option value="SMS">SMS Only</option>
                            <option value="Default">All (Sancharapp + SMS)</option>

                      </select>
                      <?php if($user_permission['http_sms_forwarding_(3rd_party)']=="No" || $api_status==false){ ?>
                        <input type="hidden" name="option" value="Multimedia" class='option' />
                      <?php } ?>
                    </div>
                            <input type="hidden" name="to_type_msg" value="excelfile" class='option' />
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
                  <div id="priority1" class="form-group">
                       <h6 class="black-text">SMS waiting period <a class="tooltipped" data-position="right" data-delay="50" data-tooltip="If a Sancharapp user is not in data network for any reason the message will be delivered to the user via SMS after the selected waiting period. Non Sancharapp users will receive SMS without any waiting."><i class="material-icons black-text">info</i></a></h6>        
                       <!--start-->                       
                           <div class="input-field">
                      <select class="browser-default priority" name="priority2" id="priority2" <?php if($user_permission['time_bound_delivery'] == 'No'||$user_permission['http_sms_forwarding_(3rd_party)']=="No"||$api_status==false){echo "disabled"; } ?> >
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
                       <!--end-->
                      <p class="help-block"><?php echo $err_priority;?></p>
                  </div>
                  </div>
                  <div class="col-sm-1"></div>
                   <div class="col s12">
                  <div class="form-group">
                 
                
                    <h6 class="black-text"  for="excel message">Upload Excel Message</h6>
                    <div class="input-outer_right">
                      <!--<input type="file" name="csvimport" id="csvimport" class="form-control" />-->
                        <div id="excelfile" class="row select_Wrapper">
                          <div class="file-field input-field">
                              <div class="btn">
                                  <span>File</span>
                                  <input type="file" name="excelfile" id="excelfile" />
                              </div>
                              <div class="file-path-wrapper">
                                  <input class="file-path validate" type="text">
                              </div>
                          </div>
                           <p class="help-block">Allowed File Types are .XLSX or .XLS <a href="/excel_msg_upload.xls" download>Download sample file</a></p>
                        </div>
                    </div>
                   
                  </div>
                 </div>
                   <div class="col s12 message_upload_bottom">

   
  
  <?php  

$alphabet = array('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z');

?>
<!--start-->
 <div class="col s6" style="padding-left:0;">
     <div id="Mobile_Column">
                  <h6 class="black-text">Mobile Column:</h6>
                     <div class="input-field">
                      <select  class="option browser-default"  id="mob_select" name="mob_select">
                        <?php foreach($alphabet as $key => $val){ ?>
                        <option value="<?php echo $val?>"><?php echo $val?></option>
                        <?php }?>
                      </select>
                  </div>
</div>
</div>
<!--end-->
 <div class="col s6"  style="padding-right:0;">
 <div id="Message_Column">
<h6 class="black-text">Add Column in Message :</h6>
  <div class="input-field">
<select id="col_select"  class="option browser-default"  name="col_select" onchange="call_msg();">
<?php foreach($alphabet as $key => $val){ ?>
<option value="<?php echo $val?>"><?php echo $val?></option>
<?php }?>
</select>
</div>
</div>
</div>
<div class="message_unicode_wrapper">
<h6 class="black-text">Message:</h6>
<!-- start  -->
<div class="row message-tab">

      <ul id="dynamic-message-tab" class="tabs">
        <li class="tab col s3"><a class="active" href="#text-option1"><input style="margin-top: 1px;" name="msg_field_type" type="radio" value="text" checked>Message</a></li>
      </ul>
  
    <div id="text-option1" class="col s12">
        <p>
      <input type="radio" checked="checked" name="message_types" value="text" id="option_text" class="with-gap">
      <label for="option_text">Text</label>
      <input type="radio" name="message_types" value="unicode" id="option_uni" class="with-gap" <?php if($user_permission['unicode_message'] == 'No' && $user_permission['http_sms_forwarding_(3rd_party)'] == 'No'){echo "disabled";} ?>>
      <label for="option_uni">Unicode</label> 
        </p>
          <div <?php if($user_permission['unicode_message'] == 'No' && $user_permission['http_sms_forwarding_(3rd_party)'] == 'No'){echo "style='pointer-events: none;'";}?> id='translControl3'> </div>
        <textarea name="message_val"   id="message_val" class="textarea text-message-row materialize-textarea" placeholder="Type a message"></textarea><div id="charNum" align="left" style="color:#000000;"></div>
      <div id="msg_error" align="left" style="color:#F00;display:none"><strong>Please enter message</strong></div>

    </div>
  </div>
    </div>

</div>                
<!-- end -->
<!--<textarea id="message_val"  class="textarea text-message-row materialize-textarea" name="message_val"></textarea>-->
<div  class="col s12">
<p>
<button id="submitbtn" type="submit" class="smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">send</i></button>
</p>
 </div>
 </form>
 </div>
 <!--modal start-->
   
                <div id="addgroupmod" class="modal">
                  <div class='modal-content'>
                                <div id="msg"></div>
                                <p id='textmod'></p>
                                 <form class="col s12 well" id="fimportForm"  action=""  method="post">
                                        <div class='row' width='100%'>
                                                  <input  class="with-gap" name='import_type' type='radio'  id='importgroup1' checked />
                                                  <label for='importgroup1'>Add numbers to group</label>
                                                
                                                  <input  class="with-gap"  name='import_type' type='radio'  id='importgroup2' value="import_group_name"/>
                                                  <label for='importgroup2'>Create whole new group</label>
                                                </div> 
                                                <div id="ffform"></div>
                                      </div>
                                                                  
                                     <div class='modal-footer'>
                                                   <a href='#' class='modal-action modal-close waves-effect waves-green btn-flat'>Cancel</a>
                                                  <button id="submitbtn1" type="submit" class="btn btn-primary">Add</button>
                                                   <a id='finalmsg' onclick="send_msg();" class='btn btn-primary'>Continue without adding</a>
                                      </div>
                                      </form>

                </div>
                 <div id="summarymodal" class="modal">
                <h3 class="boot_dialog">Message Summary</h3><hr>
                 <h4><b id='total_msg_sent1'></b> Message sent<br><b id='linkapp_user_count1'></b> Sancharapp user</h4>
                <div class='modal-footer'>
                      <a href='#' class='modal-action modal-close waves-effect waves-green btn-flat'>Cancel</a>
                      <a href='#' class='modal-action modal-close waves-effect waves-green btn-flat'>Ok</a>
                </div>
                 </div>
<!--modal end-->
  <!--added code webgile end-->
<script type="text/javascript">
  function call_msg(){
  
    
   var value=$('#col_select').val();
    var dest_value=$("textarea#message_val").val();
      //alert(value);

  if($("textarea#message_val").val()!='')
  {
    $("textarea#message_val").val(dest_value+' ~'+value+'~');
  }
else{
$("textarea#message_val").val('~'+value+'~');  
  }
}
change_option('Multimedia');
  function change_option(option){ 

if(option=="Default"){  
$('select#priority2').prop('disabled', false);
//$('select#priority').style.display='block';
//document.getElementById('priority1.priority').removeAttribute("disabled");   
}else{
  $('#priority1 #priority2').prop('disabled', 'disabled');
}
$("#route_block1 .help-block span").hide();
$("#route_block1 .help-block #help_"+option+"").show();
}
 ///////////////////start
 var multimedia_image,msg_field_type,control;
var char_limit = "<?php echo $char_limit ?>";

$(document).ready(function() {

   $('.modal-trigger').leanModal({
      dismissible: true, // Modal can be dismissed by clicking outside of the modal
      opacity: .5, // Opacity of modal background
      in_duration: 300, // Transition in duration
      out_duration: 200, // Transition out duration
      starting_top: '4%', // Starting top style attribute
      ending_top: '10%', // Ending top style attribute
      ready: function() { alert('Ready'); }, // Callback for Modal open
      complete: function() { alert('Closed'); } // Callback for Modal close
    }
  );
  $("#composeForm1").validate({
   //     ignore: [],
      //  debug: false,
        rules: {
           sender_id:{required:true},
           option1:{required:true},
           col_select:{required:true},
           mob_select:{required:true},
           excelfile:{required:true},
           message_val:{required:true},
        },
        tooltip_options: {
           sender_id:{ placement: 'right' },
        },        
        submitHandler: function (form) {

            var option = $('#option1').val();
            var priority = $('#priority2').val();
            var col_select =$('#col_select').val();
            var mob_select = $('#mob_select').val();
            var message_val = $('#message_val').val();
            var excelfile = $('#excelfile').val();
            var datestring2 = $("#composeForm1").serializefiles();

      $.ajax({
                  cache: false,
                  type: "POST",
                  url: "/message/verify",
                  data:{option:option},
                  dataType: "json",
                  success: function(response){
                    $("html, body").animate({ scrollTop: 0 }, "slow");                     
                    if(response['status']!='success'){
                    var $toastContent = $('<span>'+response['message']+'</span>');
                       Materialize.toast($toastContent, 3000);
                      //$("#successmsg").html(response['message']).show();
                      return false;
                    }else{ 
                      $.ajax({
                            cache: false,
                            type: "POST",
                            url: "/message/verify_contacts",
                            data:datestring2,
                            contentType: false,
                            processData: false,
                            success: function(response){
                                console.log(response);
                                response=JSON.parse(response);

                                if (response['status']!="success") {
                                var $toastContent = $('<span>'+'<div class="alert alert-danger">'+response['message']+'</div>'+'</span>');
                                Materialize.toast($toastContent, 3000);
                            //    $("#successmsg").html('<div class="alert alert-danger">'+response['message']+'</div>').show();
                                }else{
                                console.log(response);
                                var total_msg_sent=response['total_msg_sent'];
                                var linkapp_user_count=response['linkapp_user_count'];
                                var not_in_group_array=response['not_in_group_array'];
                                var not_in_group_array_html='';
                                
                            //    if(not_in_group_array){
                                if(not_in_group_array.length>0){
                                              $('#addgroupmod').openModal();
                                              document.getElementById("textmod").innerHTML="<b>"+not_in_group_array.length +"</b> numbers are not in contacts please select option and press add or Continue without adding"; 
                                              not_in_group_array_html='<br><input type="hidden" name="import_contacts" value='+not_in_group_array.join()+'><div class="form-group"><div class="row"><div class="col-md-6"><select class="input-md form-control" name="import_group_id" id="import_group_id" >'+$("select#group_id").html()+'</select></div><div class="col-md-6"><input id="import_group_name" type="text" length="10"  name="import_group_name" placeholder="New Group name"></div></div></div>';
                                              
                                                document.getElementById('ffform').innerHTML=not_in_group_array_html;
                                             
                                                 $("#import_group_name").hide();
                                             $(document).on("click", "#importgroup1", function(){ 
                                         //   document.getElementById('fform').innerHTML=not_in_group_array_html;
                                             $("select#import_group_id").show();
                                              $("#import_group_name").hide();
                                          });
                                             $(document).on("click", "#importgroup2", function(){ 
                                        //    document.getElementById('fform').innerHTML=not_in_group_array_html;
                                        $("#import_group_name").show();
                                            $("select#import_group_id").hide();
                                          });
                                               
                                }else{
                                  send_msg();
                                }
                              //}    
                               }
                               return false;
                            }
                      });
                    }
                  }
            });
        }
    }); 
});
 function send_msg()  {
      $('#addgroupmod').closeModal();

  var datestring2 = $("#composeForm1").serializefiles();
    /////////////////strat
                                               $.ajax({
                            cache: false,
                            type: "POST",
                            url: "/test/send_excelmsg",
                            data:datestring2,
                            contentType: false,
                            processData: false,
                            success: function(response){
                               console.log(response);
                                 response=JSON.parse(response);
                                if (response['status']!="success") {
                                   var $toastContent = $('<span>'+'<div class="alert alert-danger">'+response['message']+'</div>'+'</span>');
                                Materialize.toast($toastContent, 3000);
                            //    $("#successmsg").html('<div class="alert alert-danger">'+response['message']+'</div>').show();

                                }else{
                                   var $toastContent = $('<span>'+'Message sent'+'</span>');
                                Materialize.toast($toastContent, 3000);
                                 //$("#successmsg").html('<div class="alert alert-success">Message sent</div>').show();
                               $("html, body").animate({ scrollTop: 0 }, "slow");
                                var total_msg_sent=response['total_msg_sent'];
                                var linkapp_user_count=response['linkapp_user_count'];
                                var not_in_group_array=response['not_in_group_array'];
                                var not_in_group_array_html='';
                                document.getElementById("total_msg_sent1").innerHTML = total_msg_sent;
                                
                               if(linkapp_user_count==""){
                                linkapp_user_count=0;
                               }
                                document.getElementById("linkapp_user_count1").innerHTML = linkapp_user_count;
                              // $('#summarymodal').openModal();
                               }
                               return false;
                            }
                      });
                                                 ///////////////////end
 }
 (function($) {
$.fn.serializefiles = function() {
    var obj = $(this);
    /* ADD FILE TO PARAM AJAX */
    var formData = new FormData();
    $.each($(obj).find("input[type='file']"), function(i, tag) {
        $.each($(tag)[0].files, function(i, file) {
            formData.append(tag.name, file);
        });
    });

    var params = $(obj).serializeArray();
    $.each(params, function (i, val) {
        formData.append(val.name, val.value);
    });
    return formData;
};
})(jQuery);
$("#fimportForm").validate({        
        rules: {
            import_group_id:{ required: {
                 depends: function(element) {
                                if($("#importgroup1:checked").length){
                                     return true;
                                }
                            }
                }
          },
            import_group_name:{ required: {
                      depends: function(element) {
                                if($("#importgroup2:checked").length){
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
                var dataval = $("#fimportForm").serialize();
                 console.log(dataval);
                  $.ajax({
                  cache: false,
                  type: "POST",
                  url: "/app/updatestatus",
                  data:dataval,
                  dataType: "json",
                  success: function(response){
                    $('#addgroupmod').closeModal();                    
                    var $toastContent = $('<span>'+response['message']+'</span>');
                    Materialize.toast($toastContent, 3000);
                     //document.getElementById("msg").innerHTML=response['message'];
                       if (response['status']=="success") {
                        send_msg();
                       }
                   }
         });
      }
  });
 /////////////////end

</script>
<style type="text/css">
/*.form-control[disabled], fieldset[disabled] .form-control {
    cursor: not-allowed;
}
.form-control[disabled], .form-control[readonly], fieldset[disabled] .form-control {
    background-color: #eee;
    opacity: 1;
}*/
</style>