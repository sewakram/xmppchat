<?php use Phalcon\Tag;
?>
<div>
         <ul class="collection sms_conversion">
         </ul>
             <div class="block-compose hide">
                  <div class="row bottom-position-flex" style="margin-bottom:0;">
                  <div class="col s10">
                    <textarea id="inbox-text" class="textarea text-message-row materialize-textarea" placeholder="Type a message"></textarea>
                  </div>
                  <div class="col s1">
                  <!-- <a id="inbox-reply-btn" href="#!" class="smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">send</i></a> -->
                  <button id="inbox-reply-btn" type="button" class="smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">send</i></button>
                  </div>
                  </div>
            </div>
</div>
<!-- INBOX Page Specific JS Code -->
<script type="text/javascript">
/*INBOX*//*********************************************************************/
/*Function to send reply from chatBox*/
function reply(mobile){
  var default_msg_priority=0;
    var message = $('#inbox-text').val().trim();
    if (message=='') {
      Materialize.toast('Please enter message', 3000); // 4000 is the duration of the toast
        return false;
    };
    $.ajax({
            type: "POST",
            url: "/message/verify",
            data:{ mobile_count:1, option:"Multimedia", multimedia:message },
            dataType: "json",
            success: function(response){               
                if(response['status']!='success'){
                    Materialize.toast(response['message'], 3000);
                    return false;
                }else{   
                    var d = new Date();
                    var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                    var sms_elem=$('#INBOX .sms_conversion');
                    sms_elem.append('<li class="collection-item right-align"><div class="box-shadow inbox-content"><p class="msg-text-wrap">'+message+'</p><p class="date-time">'+datetime+'</p></div></li>');
                    $('#INBOX #inbox-text').val('').removeAttr("style");
                    sms_elem.animate({ scrollTop:sms_elem[0].scrollHeight}, 600);              
        dataString="mobile_no="+mobile+"&sender_id=&option=Multimedia&msg_field_type=text&message_type=text&text="+message+"&priority="+default_msg_priority+"&route=Reply";
                    $.ajax({
                        type: "POST",
                        url: "/message/send",
                        data: dataString,
                        success: function(response){
                            //$('#loader').hide();
                            console.log(response);
                            return false;
                        }
                    });
                }//end else
            }
    });
 }
function sendDelivery(){
  //console.log('Executing send Delivery function'+ids.length);
   $.ajax({
      type: "POST",
      url: "/inbox/updateStatus",
      dataType: "json",
      success:  function(response){
        console.log('sendDelivery: ',response);
        var data_id='';
        // console.log('data_id: ',data_id);
        var datetime=new Date().toISOString().slice(0,10);
        console.log(datetime);
       var len=response.length;
    //    var jid=(decode_me(jid));
       console.log('jid: ',decoded_jid);
       console.log('xmpp_con',xmpp_con.jid);

            for(var i=0;i<len;i++){

                console.log(response[i].sender_id);
             
                var delivery_reply = $msg({to:response[i].sender_id+'@sancharapp.com',from: decoded_jid,id:response[i].msg_id,datetime: datetime,type: 'chat'}).c('body').t('Read');
                          var message_extra={submit_datetime:datetime,type: 'delivery',status:'read'};
                      delivery_reply.up().c("message_extra").t(JSON.stringify(message_extra));
                          xmpp_con.send(delivery_reply);
            }
    
      }
    });
}//end send delivery function

function sendappDelivery(from,to,id){
  //console.log('Executing send Delivery function'+ids.length);
   // $.ajax({
      // type: "POST",
      // url: "/inbox/updateStatus",
      // dataType: "json",
      // success:  function(response){
        // console.log('sendDelivery: ',response);
        // var data_id='';
        // console.log('data_id: ',data_id);
        var datetime=new Date().toISOString().slice(0,10);
        // console.log(datetime);
       // var len=response.length;
    //    var jid=(decode_me(jid));
       console.log('jid: ',decoded_jid);
       console.log('xmpp_con',xmpp_con.jid);
       console.log('frrrom',from);
       // console.log('len',len);
            // for(var i=0;i<len;i++){

                // console.log(response[i].sender_id);
             
                var delivery_reply = $msg({to:from,from:decoded_jid ,id:id,datetime: datetime,type: 'status'}).c('body').t('Delivered');
                          var message_extra={submit_datetime:datetime,type: 'delivery',status:'delivery'};
                      delivery_reply.up().c("message_extra").t(JSON.stringify(message_extra));
                          xmpp_con.send(delivery_reply);
            // }
    
      // }
    // });
}//end send delivery function

/*Function to show right chatbox*/
$(document).on("click", "#INBOX ul#inbox-recent-message li", function (event) {
    $("#INBOX ul#inbox-recent-message li").removeClass("selected");
    $(this).addClass("selected");
    var sender_id=$(this).attr("id");
    var sender_name=$(this).attr("data_val");

    var selecter=$('#INBOX .sms_conversion');
    selecter.html(loader);
       $.ajax({
          type: "POST",
          url: "/inbox/report",
          data:"senderid="+sender_id,   
          dataType: "json",
          success:  function(response){
            $("#INBOX .block-compose").removeClass("hide");
            selecter.html('');
            selecter.attr("id",sender_id);
            var title='<div class="inbox-chat-title"><img class="circle" alt="" src="../images/1new-connect-logo-3-plain.png"><span class="title font-size16 ellipsify">'+sender_name+'</span></div>';
            $('.page_title_wrapp #inbox_title').html(title);
            $('#inbox-reply-btn').attr("onclick","reply("+sender_id+")");  
            $.each( response, function( key, value ) {
              if(value['route']){
                selecter.append('<li class="collection-item right-align"><div class="box-shadow inbox-content"><p class="msg-text-wrap">'+value['message']+'</p><p class="date-time">'+value['datetime']+'</p></div></li>');
              }else{
                selecter.append('<li class="collection-item left-align"><div class="box-shadow inbox-content"><p class="msg-text-wrap">'+value['message']+'</p><p class="date-time">'+value['datetime']+'</p></div></li>');
              }
             });
            var scoll_elem=$('.sms_conversion');
            scoll_elem.scrollTop(scoll_elem.prop("scrollHeight"));    
          }
      });
  });
$(document).on("keyup", "#INBOX #inbox-text", function (event) {
        if (event.keyCode == 13) {
          var content = this.value;  
          var caret = getCaret(this);          
          if(event.shiftKey){
              this.value = content.substring(0, caret - 1) + "\n" + content.substring(caret, content.length);
              event.stopPropagation();
          }else{
              this.value = content.substring(0, caret - 1) + content.substring(caret, content.length);
              $("#INBOX #inbox-reply-btn").trigger("click");
          }
        }
    });
/*END INBOX*//*********************************************************************/
</script>
<!-- END INBOX Page Specific JS Code -->