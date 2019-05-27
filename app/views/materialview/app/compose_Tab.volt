<?php use Phalcon\Tag;
?>
<div class="compose_wrapper">
  <form name="composeForm" id="composeForm" method="post" autocomplete="off" action="" class="form-horizontal" role="form">

  <div class="row">
    <div class="col s12">
      <ul id="compose-to-type-tab" class="tabs">
        <?php if($user_permission['contact_groups'] == 'Yes'){?>
        <li class="tab col s3"><a class="active" href="#compose-group_id">  <input id="group_type_msg" type="radio" value="group" name="to_type_msg"  <?php if($user_permission['contact_groups'] == 'Yes'){echo "checked";}?> />Group</a></li>
        <?php } ?>
        <?php if($user_permission['pincode_message'] == 'Yes'){?>
        <li class="tab col s3"><a href="#compose-pincode"><input class="with-gap" onclick="handleClick('pincode');" id="public_type_msg" type="radio" value="pincode" name="to_type_msg"/> Public Service</a></li>
         <?php } ?>
        <li class="tab col s3"><a href="#compose-single"><input class="with-gap" onclick="handleClick('single');" id="single_type_msg" type="radio" value="single" name="to_type_msg" <?php if($user_permission['contact_groups'] == 'No'){echo "checked";}?> /> Numbers</a></li>
        <?php if($user_permission['excel_message_upload'] == 'Yes'){?>
        <li class="tab col s3"><a href="#compose-excelfile">File Upload</a></li>
        <?php } ?>
      </ul>
    </div>
  <div id="to_div">
        <?php 
            if($user_permission['pincode_message'] == 'Yes'){?>
                    <div id="compose-pincode" class="row select_Wrapper">
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

                                echo'<div class="input-outer text-left"><div class="radio"><label><input type="radio" name="public_service_radio" value="pincode" id="pincode_radio" checked>Pincode</label><label><input type="radio" name="public_service_radio" value="pincode_range" id="pincode_range">Pincode Range</label></div><select name="pincode[]" id="pincode" data-placeholder="Select pincode..." class="chosen" multiple="true" class="browser-default"></select><div style="margin-top: 14px;display:none;" id="pincode_range">Start <input type="text" size="6" name="pincode_range_min">- End <input size="6" type="text" name="pincode_range_max"></div></div>';

                    }
                }
                     ?>   
                       <span id="showMembers_pincode"></span>
                   </div>
                    <?php }
                     if($user_permission['excel_message_upload'] == 'Yes'){
                       echo '<div id="compose-excelfile" class="row select_Wrapper"><div class="file-field input-field">
      <div class="btn"><span>File</span><input type="file" name="excelfile" id="excelfile" /></div><div class="file-path-wrapper"><input class="file-path validate" type="text"></div></div><p class="grey-text">Allowed File Types are .TXT or .XLS or .XLSX <a href="/sample.xls" download>Download sample file</a></p></div>';
                    }

                    echo "<div id='compose-single' class='row select_Wrapper'><textarea  name='mobile_no' id='mobile_no' class='materialize-textarea'></textarea><p class='help-block'>Type mobile no's in each line or with commas in between</p></div>";  
                    if($user_permission['contact_groups'] == 'Yes'){
                    ?>
                      <div id="compose-group_id" class="row <?php if($user_permission['contact_groups'] == 'No'){echo 'hide';}?> select_Wrapper">
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
  </div>
  <div id="route_block" class="row">
                   <h6 class="black-text">Route Type</h6>
                    <div class="input-field">
                      <select onchange='change_option(this.value)' class="option browser-default" name="option" id="option" <?php if($user_permission['http_sms_forwarding_(3rd_party)']=="No"||$api_status==false){ echo "disabled"; } ?> >
                            <option value="Multimedia" selected>Sancharapp message only</option>
                            <option value="Default">Sancharapp + SMS</option>
                            <option value="SMS">SMS only</option>
                      </select>
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
                                if($user_data->default_msg_priority==$time_interval){
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
  <div class="row">
    <div class="col s12">
      <ul id="compose-message-tab" class="tabs">
        <li class="tab col s3"><a class="active" href="#compose-text-option"><input style="margin-top: 1px;" name="msg_field_type" type="radio" value="text" checked>Message</a></li>
        <li class="tab col s3"><a href="#compose-image-option"><input style="margin-top: 1px;" name="msg_field_type" type="radio" value="multimedia">Image</a></li>
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
        <textarea name="text" onKeyUp="countChar(this)" onFocus="countChar(this)" id="text" class="textarea text-message-row materialize-textarea" placeholder="Type a message"></textarea><div id="charNum" align="left" style="color:#000000;"></div>
      <div id="msg_error" align="left" style="color:#F00;display:none"><strong>Please enter message</strong></div>
    </div>
    <div id="compose-image-option" class="col s12">
        <img style="display:none;width:30%;"class="img-responsive img-thumbnail" id="xFileImage" src="">
        <input id="multimedia" name="multimedia" type="hidden"/>
        <a onClick="BrowseServer();" href="#!" class="add_photos compose_common text_lightgrey-color relative"><i class="right material-icons">add_to_photos</i></a>
    </div>
  </div>
  <div class="row">
    <p>
     <input class="with-gap"  checked="" type="radio" name="schedular_status" id="schedular_status_1" onclick="$('#datetime_wrapper').addClass('hide');"/>
      <label for="schedular_status_1">Send immediately</label>
      <input class="with-gap"  <?php if($user_permission['contact_groups'] == 'No'){echo 'disabled';}?> type="radio" name="schedular_status" id="schedular_status_2" onclick="$('#datetime_wrapper').removeClass('hide');"/>
      <label for="schedular_status_2">Schedule</label>
    </p>

    <div id="datetime_wrapper" class="hide">
          <div class="input-field">
          <span>Datetime</span>
           <input class="flatpickr" type="text" name="datepicker" id="timedatepicker" data-enabletime=true data-time_24hr=true>
           <!-- <label for="timedatepicker">Datetime</label> -->
        </div>
   </div> 
   </div>
  <div class="row">
      <button id="submitbtn" type="submit" class="waves-effect waves-green btn btn_blue">SEND</button>
      <button class="modal-action modal-close red waves-effect waves-green btn btn_red">CANCEL</button>
  </div>     
  </form>
</div>