<!DOCTYPE html>
<html lang="en">
<head>
   {{ get_title() }}
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.0"/>
  <!-- CSS  -->
  {{ stylesheet_link('https://fonts.googleapis.com/icon?family=Material+Icons') }}
  {{ stylesheet_link('materialize/css/materialize.min.css') }}
  {{ stylesheet_link('materialize/css/style.css') }}
  {{ stylesheet_link('materialize/css/poll.css') }}
  {{ javascript_include('js/jquery.min.js') }}
  {{ javascript_include('js/utils.js') }}
   {{ javascript_include('materialize/js/materialize.js') }}
   <!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.100.2/js/materialize.min.js"></script> -->
        {{ javascript_include('js/XMPP/strophe.min.js') }}
  <meta name="description" content="Sancharapp">
  <meta name="author" content="Sancharapp">
</head>
<body>
        {{ content() }}
        {{ javascript_include('materialize/js/init.js') }}

       
        <?php
        $login_status="false";
        $auth=$this->session->get('auth');
        if($auth['login_type']=="Group Admin" ||$auth['login_type']=="Super Admin"||$auth['login_type']=="Manager"){
            $login_status="true";
        }
        ?>
        <script type="text/javascript">
         var BOSH_SERVICE = 'http://sancharapp.com:5280/http-bind';
         var status="<?php echo $login_status?>";
         if(status=="true"){
            var jid="<?php if(isset($auth['jid'])){echo base64_encode($auth['jid']);}?>";
            var j_pass="<?php if(isset($auth['j_pass'])){echo base64_encode($auth['j_pass']);}?>";
            xmpp_con = new Strophe.Connection(BOSH_SERVICE,{'keepalive': true});
            var decoded_jid=decode_me(jid);
            console.log(' materializeviw index jid: ',decode_me(jid));
            console.log(' materializeviw index  j_pass: ',decode_me(j_pass));
            console.log(' materializeviw index  j_pass without decode: ',j_pass);
            //xmpp_con.connect(decode_me(jid),decode_me(j_pass),onConnect); 
            setTimeout(function(){ xmpp_con.connect(decode_me(jid),decode_me(j_pass),onConnect); }, 5000);
            //register event before page unload disconnect xmpp connection to stop any incomming message loss
            $(window).bind('beforeunload', function(){
                xmpp_con.flush();
                //xmpp_con.options.sync = true;    
                xmpp_con.disconnect();   
            });

         }
         function reConnectXMPP(){
            $("#xmpp-con-div").addClass("rotation");
            //alert("caller is " + arguments.callee.caller.name);
            console.log('reConnectXMPP')
             try {
                xmpp_con.restore(decode_me(jid), onConnect);
             } catch(e) {
                console.log(e);
                xmpp_con = new Strophe.Connection(BOSH_SERVICE, {'keepalive': true});
                xmpp_con.connect(decode_me(jid),decode_me(j_pass),onConnect);
             }
          }
         function onConnect(status)
         {
          if(status == Strophe.Status.DISCONNECTED) {
            console.log('disconnected.');
            $("#xmpp-con-div").removeClass("hide");
          }else if (status == Strophe.Status.CONNECTED ||status == Strophe.Status.ATTACHED) {
            console.log('Connected.');
            $("#xmpp-con-div").addClass("hide");
            console.log(xmpp_con.jid);
            /*$(window).bind('beforeunload', function(){
              xmpp_con.disconnect();
              return;
            }); */
            xmpp_con.addHandler(onXmppMessage, null, 'message', null, null,  null);
            xmpp_con.send($pres().tree());
            // var priority=parseInt(localStorage.getItem("priority"));
            // if(priority===null||priority>=127)
            //   priority=0;
            // else
            //   priority++;
            // xmpp_con.send($pres().c("priority").t(""+priority+""));
            // localStorage.setItem("priority",priority); 
            // if($('div#inbox').length>0)
            //   sendDelivery();
          }
          setTimeout(function(){ $("#xmpp-con-div").removeClass("rotation");},500);
         }

         function decodeEntities(s){
         return $("<div/>").html(s).text();
        }
        
        function onXmppMessage(msg){
          console.log("sewak",msg);
          var id = msg.getAttribute('id');
          // console.log('sewakkkk',id);
          var to = msg.getAttribute('to');
          var appto = msg.getAttribute('from');
          var from =msg.getAttribute('from').split("/");
          var datetimerply=new Date().toISOString().slice(0,10);
          from=from[0].split("@");
          if(msg=="sancharapp.com"){
            // firstTimeWelcome(msg);
            return true;
          }
          var type = msg.getAttribute('type');
          var elems = msg.getElementsByTagName('body');
          var ele_message_extra = msg.getElementsByTagName('message_extra');
          try {
            var  message_extra=$.trim(decodeEntities(Strophe.getText(ele_message_extra[0])));
console.log('message_extra : ',message_extra);
var datetime;
if(message_extra)
{
  var attributes =JSON.parse(message_extra);
console.log('attributes: ',attributes);
var datetime=attributes['submit_datetime'];
}
          } catch (error) {
            console.log('error22: ',error);
          }

  //   //////////////
  var len=elems.length
  // console.log("length=",len);
  // for(var i=0;i<len;i++){
  // try{
  // var delivery_reply = $msg({to:from,from: decoded_jid,id:id,datetime: datetimerply,type: 'chat'}).c('body').t('delivery');
  // var message_extra={submit_datetime:datetimerply,type: 'delivery',status:'delivary'};
  // delivery_reply.up().c("message_extra").t(JSON.stringify(message_extra));
  // console.log("delivery_reply",delivery_reply);
  // xmpp_con.send(delivery_reply);
  // } catch (error) {
  // console.log('error22: ',error);
  // }
  // }
  //   //////////////////////
 
if(typeof (datetime) == 'undefined' ||datetime==null )
          {
            datetime= new Date().toISOString().slice(0, 10);
          }
          console.log('datetime: ',datetime);
          console.log('type: ',type);
          
          if( type == "chat" && elems.length > 0) {
              var body = elems[0];
              var message=$.trim(decodeEntities(Strophe.getText(body)));
               sendappDelivery(appto,to,id);
              $.ajax({
                      type: "POST",
                      url: "/inbox/save",
                      data:"sender_id="+from[0]+"&datetime="+datetime+"&message="+message+"&msg_id="+id,
                      dataType: "json",
                      error:function(response){
                     console.log('error: ',response);
                      },
                      success:  function(response){

                          
                     console.log(response);
                        if($("#INBOX").length){
                          /*update status in db function*/
                            if($("#INBOX").is(":visible")){
                              //console.log('ala');
                              sendDelivery();
                            }
                          /*END*/
                            var left_list_elem=$("#INBOX ul#inbox-recent-message");
                            var right_list_elem=$("#INBOX ul.sms_conversion");

                            var item = '<li class="collection-item avatar" id="'+from[0]+'"><img class="circle" alt="" src="../images/1new-connect-logo-3-plain.png"><span class="title font-size16 ellipsify">'+from[0]+'</span><span class="emojitext ellipsify ellipsis multiline font-size14">'+message+'</span><span class="date-time font-size12">'+response['data']['datetime']+'</span><a data-activates="dropdown3" class="dropdown-button secondary-content" href="#!"><i class="material-icons">keyboard_arrow_down</i></a></li>';
                            left_list_elem.find("li#"+from[0]+"").remove();
                            left_list_elem.prepend(item);
                            // right_list_elem.animate({ scrollTop:0}, 600);
                            /*check chat box is open */
                            if(right_list_elem.is("#"+from[0]+"")){
                              var d = new Date();
                              var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                              right_list_elem.append('<li class="collection-item left-align"><div class="box-shadow inbox-content"><p class="msg-text-wrap">'+message+'</p><p class="date-time">'+datetime+'</p></div></li>');
                              // right_list_elem.animate({ scrollTop:right_list_elem[0].scrollHeight}, 600);
                            }
                            /*End*/
                         //}else{
                            var elem=$("ul.tabs span#inbox-count");
                            var count =parseInt(elem.text().replace(/[^0-9]/gi, ''),10);
                            if(isNaN(count))
                              count=1;
                            else
                              count=count+1;
                            /*console.log(count);*/
                            elem.text('('+count+')');
                            $("ul.tabs i#inbox-bell").addClass('red-text');
                         }
                      }//end success
                  });
          }
          return true;
        }

        function firstTimeWelcome(from){
          if($("#INBOX").length){
                          /*update status in db function*/
                            if($("#INBOX").is(":visible")){
                              sendDelivery();
                            }
                          /*END*/
                            var left_list_elem=$("#INBOX ul#inbox-recent-message");
                            var right_list_elem=$("#INBOX ul.sms_conversion");
                            var today = new Date();
                            var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
var dateTime = date+' '+time;
                            var item = '<li class="collection-item avatar" id="'+from+'"><img class="circle" alt="" src="../images/1new-connect-logo-3-plain.png"><span class="title font-size16 ellipsify">'+from+'</span><span class="emojitext ellipsify ellipsis multiline font-size14">Welcome To '+from+'</span><span class="date-time font-size12">'+date+'</span><a data-activates="dropdown3" class="dropdown-button secondary-content" href="#!"><i class="material-icons">keyboard_arrow_down</i></a></li>';
                            left_list_elem.find("li#"+from+"").remove();
                            left_list_elem.prepend(item);
                            right_list_elem.animate({ scrollTop:0}, 600);
                            /*check chat box is open */
                            if(right_list_elem.is("#"+from+"")){
                              var d = new Date();
                              var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                              right_list_elem.append('<li class="collection-item left-align"><div class="box-shadow inbox-content"><p class="msg-text-wrap">Welcome To '+from+'</p><p class="date-time">'+datetime+'</p></div></li>');
                              right_list_elem.animate({ scrollTop:right_list_elem[0].scrollHeight}, 600);
                            }
                            /*End*/
                         //}else{
                            var elem=$("ul.tabs span#inbox-count");
                            var count =parseInt(elem.text().replace(/[^0-9]/gi, ''),10);
                            if(isNaN(count))
                              count=1;
                            else
                              count=count+1;
                            /*console.log(count);*/
                            elem.text('('+count+')');
                            $("ul.tabs i#inbox-bell").addClass('red-text');
                         }
        }
        </script>
    </body>
</html>