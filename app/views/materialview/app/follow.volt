<?php use Phalcon\Tag;
?>
<div class="compose_wrapper">
  <form name="followForm" id="followForm" method="post" autocomplete="off" action="" class="form-horizontal" role="form">
  <div class="row">
    <div class="col s12">
      <ul id="follow-message-tab" class="tabs">
        <li class="tab col s3"><a class="active" href="#follow-text-option"><input name="msg_field_type" type="radio" value="text" checked>Message</a></li>
        <li class="tab col s3"><a href="#follow-image-option"><input name="msg_field_type" type="radio" value="multimedia">Image</a></li>
      </ul>
    </div>
    <div id="follow-text-option" class="col s12">
        <p>
          <input class="with-gap" id="follow-opt_text" type="radio"  value="text" name="message_type" checked="checked" />
          <label for="follow-opt_text">Text</label>
          <input class="with-gap" <?php if($user_permission['unicode_message'] == 'No' && $user_permission['http_sms_forwarding_(3rd_party)'] == 'No'){echo "disabled";}?> id="follow-opt_uni" type="radio" value="unicode" name="message_type" />
          <label for="follow-opt_uni">Unicode</label>
        </p>
          <div id="translControl2_Wrap"><div <?php if($user_permission['unicode_message'] == 'No' && $user_permission['http_sms_forwarding_(3rd_party)'] == 'No'){echo "style='pointer-events: none;'";}?> id='translControl2'> </div></div>
        <textarea name="text" onKeyUp="countChar(this)" onFocus="countChar(this)" id="follow-text" class="textarea text-message-row materialize-textarea" placeholder="Type a message"></textarea><div id="charNum" align="left" style="color:#000000;"></div>
      <div id="msg_error" align="left" style="color:#F00;display:none"><strong>Please enter message</strong></div>
    </div>
    <div id="follow-image-option" class="col s12">
        <img style="display:none;width:30%;"class="img-responsive img-thumbnail" id="xFileImage" src="">
        <input id="multimedia" name="multimedia" type="hidden"/>
       <!--  <a onClick="BrowseServer();" href="#!" class="waves-effect waves-light btn"><i class="right material-icons">add_to_photos</i> Browse Image..</a> -->
        <a onClick="BrowseServer();" href="#!" class="add_photos compose_common text_lightgrey-color relative"><i class="large material-icons">file_upload</i></a>
    </div>
  </div>
   
   <div class="send-immediately row">
    <p>
        <input class="with-gap schedularstatuss"  id="schedularstatus_1" type="radio" value="Now" name="schedularstatus" checked="" />
        <label for="schedularstatus_1">Now</label>
        <input class="with-gap schedularstatuss"  id="schedularstatus_2" type="radio" value="Later" name="schedularstatus" />
        <label for="schedularstatus_2">Later</label>
        
        <span style="display:inline-block;" id="datetime_wrapper" class="hide"><input Placeholder="datetime" class="flatpickr" type="text" id="timedatepicker" /><input id="input_starttime" class="timepicker" type="hidden">
        
        <input id="hidden_timedatepicker" name="datetime" type="hidden" /></span>
        <button id="submitbtn" type="submit" class="smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">send</i></button>
    </p>
   
   </div>
  </form>
</div>
<!-- Follow Page Specific JS Code -->
<script type="text/javascript">

$(document).ready(function() {
  $('#followForm .schedularstatuss').click(function(){
    idName = $(this).attr('id');
    if ( $(this).is(':checked') ) { 
        if ( idName === 'schedularstatus_1' ) {
            $('#followForm #schedularstatus_1').attr('checked',true);
           
        } else {
            $('#followForm #schedularstatus_2').attr('checked',true);
        }
    }
});
 var d = new Date();
  var hours = d.getHours();
  var minutes = d.getMinutes();
  $('#followForm #timedatepicker').pickadate({closeOnSelect:true,format: 'yyyy/mm/dd',min:d,onClose: function() {
        $(document.activeElement).blur();
        var value=$('#followForm #timedatepicker').val();
        if(value)
          $('#followForm #input_starttime').trigger('click');
    }, onSet: function( arg ){
        if ( 'select' in arg ){ //prevent closing on selecting month/year
            this.close();
        }}
  });
   $('#followForm #input_starttime').on("input change",function(){
      var time=$(this).val();
      var old=$('#followForm #timedatepicker').val();
      $('#followForm #timedatepicker').val(old+' '+time);
      $('#followForm #hidden_timedatepicker').val(old+' '+time12To24(time));
    })
  $('#followForm #input_starttime').clockpicker({
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
$('#followForm input[name=schedularstatus]').on("change",function(){

     if($(this).attr("id")=="schedularstatus_1"){
      $('#followForm #datetime_wrapper').addClass('hide');
    }else{
      $('#followForm  #datetime_wrapper').removeClass('hide');
      $('#followForm  #timedatepicker').trigger('click');
    }
});
   $("#followForm  #timedatepicker").val('');
  /*Follow Message*//*********************************************************************/
    $("#followForm").validate({
        ignore: [],
        debug: false,
        rules: {
          text: {
             required: {
                 depends: function(element) {
                    if($("#followForm input[name=msg_field_type]:checked").val()=="text"){
                      return true;
                    }
                 }
             }
            },
            datetime: {
             required: {
                 depends: function(element) {
                    if($("#schedularstatus_2:checked").length){
                      return true;
                    }else
                    return false;
                 }
             }
            },
        },
        messages: {
          text:{ required:"Please enter message" },
        //   datetime: {required:"Please datetime" },
        },
        tooltip_options: {
           '_all_': { placement: 'right' },
           datetime:{ placement: 'right' },
        },        
        submitHandler: function (form) {
            msg_field_type=$('#followForm input[name=msg_field_type]:checked').val();

            var multimedia ;
            if(msg_field_type=="multimedia")
              multimedia = $("#followForm input#multimedia").val();//multimedia_image;
            else
              multimedia = $("#followForm #follow-text").val();

            if(multimedia=="" ||typeof(multimedia)  === "undefined"){
               Materialize.toast('Please enter message', 3000);
               return false;
            }
            var d = new Date();
            var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);

            var temp_id=d.getTime();
            var dataString = $("#followForm").serialize();
            $("#followForm #follow-text").val('');
            $("#followForm img#xFileImage").removeAttr("src").hide();
            var item = '<li id="'+temp_id+'" class="collection-item avatar"><img class="circle" alt="" src="../images/1new-connect-logo-3-plain.png"><span class="title font-size16 ellipsify"></span><span class="emojitext ellipsify ellipsis multiline font-size14">'+multimedia+'</span><span class="date-time font-size12">'+datetime+'</span></li>';
            
            $("#followForm ul#follow-recent-sent").prepend(item);

            Materialize.toast('Update sent', 3000);
            //  alert(dataString);
            $.ajax({
                  cache: false,
                  type: "POST",
                  url: "/red/send",
                  dataType: "json",
                  data:dataString,
                      success: function(response){
                        
                          if (response['status']!="success") {
                                Materialize.toast(response, 3000);
                                $("#FOLLOW ul#follow-recent-sent li#"+temp_id+"").remove();
                          }else{
                            if(response['schedularstatus']=='later'){
                              Materialize.toast('Message Schedule', 3000);
                            }
                                console.log(response);
                          }
                          return false;
                      }
            });
        }
    });

/*END Follow Message*//*********************************************************************/

});//end document ready
//schedular start
     //check schedule for later or send  now----------------
                      if($("#FOLLOW #schedularstatus_2:checked").length){
                          Materialize.toast('Message Schedule', 3000);
                          $.ajax({cache: false,type: "POST",url: "/schedular/ajaxnew",data: datavalue,    contentType: false,
                            processData: false,
                            success: function(response){
                                //$('#loader').hide();
                                console.log(response);
                                return false;
                            }
                      });
                     //   return false;
                      }  
                      //end check schedule -----------------------------------

</script>
<!-- END Follow Page Specific JS Code -->