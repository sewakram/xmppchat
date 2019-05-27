<?php use Phalcon\Tag;
?>
<div class="compose_wrapper">
     <div class="row">
        <div id="que" class="input-field col s12">
           <textarea rows="1" id="question" name="question" class="materialize-textarea"></textarea>
          <label for="question">Question</label>
        </div>
      </div>
      <div id="ans" class="row">
        <div class="input-field col s12">
          <input type="answers" id="answers" type="text">
          <label for="answers">Options:</label>(Min 2 and Max 10 option allow)
          <p class="grey-text">Type and Press Enter to add Your option</p>
        </div>
      </div>
      <div class="send-immediately row">
    <p>
    
     <button id="submit_btn" type="button" class="smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">send</i></button>
      <button onclick="reset_value();" class="smart_btn_red smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">clear</i></button></p>
<!-- 
    <div id="datetime_wrapper" class="hide">
          <div class="input-field">
          <span>Datetime</span>
           <input class="flatpickr" type="text" name="datetime" id="timedatepicker" data-enabletime=true data-time_24hr=true>
        </div>
   </div>  -->
   </div>
    <!--<div class="row action-btn-row">
      <button id="submit_btn" type="button" class="smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">send</i></button>
      <button onclick="reset_value();" class="smart_btn_red smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">clear</i></button>  </div>  -->
</div>
<div id="send_option_modal" class="modal">
        <div class="modal-content">
            <h4 class="modal-title">Sending Options</h4>
            <div class="row">  
              <div class="col s12">
              <form name="feedbackForm" id="feedbackForm" method="post" autocomplete="off" action="" role="form">
                <input type='hidden' name='question' class='form-control'>
                <input type='hidden' name='answers' class='form-control'>

                <div class="form-group">
                  <label class="col-md-4 control-label text-primary" id="temp_quest" for="optionsRadios"></label>
                  <div id="temp_ans"></div>
                </div>
                <a href="#!" class=" modal-action modal-close waves-effect waves-green btn-flat">Edit Feedback</a>
                <div class="row send-options-message">
                  <ul id="follow-to-type-tab" class="tabs">
                    <?php if($user_permission['contact_groups'] == 'Yes'){?>
                    
                    <li class="tab col s2"><a class="<?php if($user_permission['contact_groups'] == 'Yes'){echo "active";}?>" href="#follow_group_id"><input class="with-gap" data-rel="group_id" id="follow_group_type_msg" type="radio" value="group" name="to_type_msg" <?php if($user_permission['contact_groups'] == 'Yes'){echo "checked";}?> />Group</a></li>
                    <?php } ?>

                    <li class="tab col s2"><a class="<?php if($user_permission['contact_groups'] == 'No'){echo "active";}?>" href="#follow_single"><input class="with-gap" data-rel="single" id="follow_single_type_msg" type="radio" value="single" name="to_type_msg" <?php if($user_permission['contact_groups'] == 'No'){echo "checked";}?> /> Numbers</a></li>

                    <?php if($user_permission['excel_message_upload'] == 'Yes'){?>
                    <li class="tab col s2"><a href="#follow_excelfile"><input class="with-gap" data-rel="excelfile" id="excelfile_type_msg" type="radio" value="excelfile" name="to_type_msg"/>File Upload</a></li>
                    <?php } ?>

                    <?php if($user_permission['joint'] == 'Yes'){?>
                    <li class="tab col s2"><a href="#"><input class="with-gap" data-rel="joint" id="follow_joint_type_msg" type="radio" value="joint" name="to_type_msg"/>Followers</a></li>
                    <?php } ?>

                    <?php if($user_permission['pincode_message'] == 'Yes'){?>
                    <li class="tab col s2"><a href="#follow_pincode"><input class="with-gap" data-rel="pincode" id="public_type_msg_feedback" type="radio" value="pincode" name="to_type_msg"/>Public Service</a></li>
                     <?php } ?>
                   
                  </ul>
                </div>
                <div id="to_div">
              <?php 
                     if($user_permission['excel_message_upload'] == 'Yes'){
                       echo '<div id="follow_excelfile" class="row select_Wrapper"><div class="file-field input-field">
      <div class="btn"><span>File</span><input type="file" name="excelfile" id="excelfile" /></div><div class="file-path-wrapper"><input class="file-path validate" type="text"></div></div><p class="grey-text">Allowed File Types are .TXT or .XLS or .XLSX <a href="/sample.xls" download>Download sample file</a></p></div>';
                    }
                    $class_temp='';
                    if($user_permission['contact_groups'] == 'Yes'){$class_temp='';}
                    echo "<div id='follow_single' class='row select_Wrapper ".$class_temp."'><textarea  name='mobile_no' id='mobile_no' class='materialize-textarea'></textarea><p class='help-block'>Type mobile no's in each line or with commas in between</p></div>";  
                    if($user_permission['contact_groups'] == 'Yes'){
                    ?>
                      <div id="follow_group_id" class="row <?php if($user_permission['contact_groups'] == 'No'){echo '';}?> select_Wrapper">
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
                    <?php 
            if($user_permission['pincode_message'] == 'Yes'){?>
                    <div id="follow_pincode" class="row  select_Wrapper">
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
                        echo'<div class="input-outer"><p><input type="radio" name="public_service_radio" value="pincode" id="feedback_pincode_radio" class="with-gap" checked /><label for="feedback_pincode_radio">Pincode</label><input class="with-gap" type="radio" name="public_service_radio" value="pincode_range" id="feedback_pincode_range" /><label for="feedback_pincode_range">Pincode Range</label></p><select name="pincode[]" id="pincode" data-placeholder="Select pincode..." class="browser-default feedback_chosen" multiple="true"></select><div style="display:none;" id="pincode_range">Start <input type="text" size="6" name="pincode_range_min">- End <input size="6" type="text" name="pincode_range_max"></div></div>';
                    }
                }
                     ?>   
                       <span id="showMembers_pincode"></span>
                   </div>
                    <?php } ?>
  </div>
    <input class="with-gap"  id="schedular_status1" type="radio" value="Now" name="schedularstatus" checked="" />
        <label for="schedular_status1">Now</label>
    <input class="with-gap"  id="schedular_status2" type="radio" value="Later" name="schedularstatus" />
        <label for="schedular_status2">Later</label>
        
      <span style="display:inline-block;" id="datetime_wrapper" class="hide"><input Placeholder="Datetime" class="flatpickr" type="text" id="timedatepicker" /><input id="input_starttime" class="timepicker" type="hidden">
        <input id="hidden_timedatepicker" name="datetime" type="hidden" /></span>
                </form>
                </div>
              </div>
        <div class="modal-footer">

          <a onClick="formConfirmation();" class="waves-effect waves-light btn btn_blue">Confirm & Send</a>
          <a href="#!" class=" modal-action modal-close waves-effect waves-light btn red">Cancel</a>
        </div>
    </div>
</div>
<!-- Feedback Page Specific JS Code -->
<script type="text/javascript">
/*Feedback Message*//*********************************************************************/
$(document).ready(function() {
var d = new Date();
  var hours = d.getHours();
  var minutes = d.getMinutes();
  $('#FEEDBACK #timedatepicker').pickadate({closeOnSelect:true,format: 'yyyy/mm/dd',min:d,onClose: function() {
        $(document.activeElement).blur();
        var value=$('#FEEDBACK #timedatepicker').val();
        if(value)
          $('#FEEDBACK #input_starttime').trigger('click');
    }, onSet: function( arg ){
        if ( 'select' in arg ){ //prevent closing on selecting month/year
            this.close();
        }}
  });
  $('#FEEDBACK #input_starttime').on("input change",function(){
      var time=$(this).val();
      var old=$('#FEEDBACK #timedatepicker').val();
      $('#FEEDBACK #timedatepicker').val(old+' '+time);
      $('#FEEDBACK #hidden_timedatepicker').val(old+' '+time12To24(time));
    })
  $('#FEEDBACK #input_starttime').clockpicker({
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
$('#FEEDBACK input[name=schedularstatus]').on("change",function(){
    if($(this).attr("id")=="schedular_status1"){
      
      $('#FEEDBACK #datetime_wrapper').addClass('hide');
    }else{
      
      $('#FEEDBACK #datetime_wrapper').removeClass('hide');
      $('#FEEDBACK #timedatepicker').trigger('click');
    }
});

  pillbox = $("#FEEDBACK input#answers").pillbox();
  $("#FEEDBACK #submit_btn").click(function(){
             option_list = pillbox[0].getValues();
 
             var json = JSON.stringify(option_list);
             question =  $("textarea#question").val();
             if(question=='')
             {
                $('div#que textarea').addClass('invalid');
                return false;
             }
          else
             {
               $('div#que textarea').removeClass('invalid');
             }
             if(option_list.length<=1 ||option_list.length>10)
             {
               
                $('div#ans input#answers').addClass('invalid');
                return false;
             }
             else{
                $('div#ans input#answers').removeClass('invalid');
               
             }

             if(question !='' || option_list.length>0){
               //dataString = 'answers='+json+'&question='+question;
               $("input[name=answers]").val(json);
               $("input[name=question]").val(question);
               feedbackSend();
             }//end if
     });
  $("#FEEDBACK input#answers").on("keyup",function (event) {
        if (event.keyCode == 13) {
              if(pillbox[0].getValues().length>10){
                pillbox[0].onBackspace();
                pillbox[0].onBackspace();
              }
        }
  });
function feedbackSend()
{
  var temp_ans='';
  for (var i = 0; i < option_list.length; i++) {
    temp_ans+='<div class="radio disabled"><label><input type="radio" name="optionsRadios" id="optionsRadios'+i+'" disabled>'+option_list[i]+'</label></div>';
  }
  $('#send_option_modal #temp_ans').html(temp_ans);
  $('#send_option_modal #temp_quest').html('Q.'+question);
  $('#send_option_modal').openModal();
  //to fixed invalid tabs indicator issue(refresh indicator)
  $("#send_option_modal ul#follow-to-type-tab li a.active").trigger("click");
}
/*END Feedback Message*//*********************************************************************/
});//end document ready
/*Feedback Start*//*********************************************************************/
function reset_value(){
  $("#ans ul.pillbox-list").empty();
  $("#que textarea#question").val('');
};
function formConfirmation(){
/**************************************************************************/
var form = $( "#feedbackForm" );
var d = new Date();
var temp_id=d.getTime();
form.validate();
if(form.valid()){
  var datestring2 = $("#feedbackForm").serializefiles();  

  $.ajax({
        type: "POST",
        cache: false,
        url: "/feedback/send",
        // url: "/red/sends",
        data: datestring2,
        contentType: false,
        processData: false,
        beforeSend: function() { 
          var que_temp=$("#que textarea#question").val();
          var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9); 
          var item = '<li id="'+temp_id+'"class="collection-item avatar"><img class="circle" alt="" src="../images/1new-connect-logo-3-plain.png"><span class="title font-size16 ellipsify"></span><span class="emojitext ellipsify ellipsis multiline font-size14">'+que_temp+'</span><span class="date-time font-size12">'+datetime+'</span></li>';
          $("#FEEDBACK ul#feedback-recent").prepend(item);
        
          $('#send_option_modal').closeModal();
        },
        complete: function(){
          //$('#loader').hide();
        },
        success: function(response){
          var response=JSON.parse(response);
          console.log(response);
          
          if(response['status']== 'success'){
            if(response['schedularstatus']=='Later'){
                Materialize.toast(response['message'], 3000);
          }else{
              Materialize.toast('Feedback Send', 3000);
            $("#FEEDBACK ul#feedback-recent li#"+temp_id+"").attr("id",response['feedback']['id']);
            $("#ans ul.pillbox-list").empty();
            $("#que textarea#question").val('');
            pillbox[0].clearValues();
          }
          }
          else{
            $("#FEEDBACK ul#feedback-recent li#"+temp_id+"").remove();
            Materialize.toast('Feedback Failed to Send', 3000);
          }
          }
  });
}
}
$(document).on("click", "#FEEDBACK ul#feedback-recent li", function (event) {
  var feed_id=$(this).attr("id");
  if(feed_id)
  window.location.href = "/feedback/results/"+feed_id;
});
/*Feedback END*//*********************************************************************/
</script>
<!-- END Feedback Page Specific JS Code -->