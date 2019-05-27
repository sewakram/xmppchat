<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        {{ get_title() }}
       <!--  {{ stylesheet_link('css/bootstrap.min.css') }}
        {{ javascript_include('js/jquery.min.js') }}
        {{ javascript_include('js/utils.js') }} -->

        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="LinkApp">
        <meta name="author" content="LinkApp">
        <link href="https://fonts.googleapis.com/css?family=Fjalla+One|Roboto:300,400,700" rel="stylesheet">
        <!-- new template css start-->
         <!-- Base Css Files -->
        {{ stylesheet_link('assets/libs/jqueryui/ui-lightness/jquery-ui-1.10.4.custom.min.css') }}
        {{ stylesheet_link('assets/libs/bootstrap/css/bootstrap.min.css') }}
        {{ stylesheet_link('assets/libs/font-awesome/css/font-awesome.min.css') }}
        {{ stylesheet_link('assets/libs/fontello/css/fontello.css') }}
        {{ stylesheet_link('assets/libs/animate-css/animate.min.css') }}
        {{ stylesheet_link('assets/libs/nifty-modal/css/component.css') }}
        {{ stylesheet_link('assets/libs/magnific-popup/magnific-popup.css') }} 
        {{ stylesheet_link('assets/libs/ios7-switch/ios7-switch.css') }} 
        {{ stylesheet_link('assets/libs/pace/pace.css') }}
        {{ stylesheet_link('assets/libs/sortable/sortable-theme-bootstrap.css') }}
        {{ stylesheet_link('assets/libs/bootstrap-datepicker/css/datepicker.css') }}
        {{ stylesheet_link('assets/libs/jquery-icheck/skins/all.css') }}
        <!-- Extra CSS Libraries Start -->
        {{ stylesheet_link('assets/css/style.css') }}
        <!-- Extra CSS Libraries End -->
        <link rel="shortcut icon" href="{{url()}}assets/img/favicon.ico">
        <!-- new template css end -->

    </head>
    <body>
       
        {{ content() }}
  <!-- new template js start-->
  <script>
  var resizefunc = [];
  </script>
  <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
  {{ javascript_include('assets/libs/jquery/jquery-1.11.1.min.js') }} 
  {{ javascript_include('assets/libs/bootstrap/js/bootstrap.min.js') }} 
  {{ javascript_include('assets/libs/jqueryui/jquery-ui-1.10.4.custom.min.js') }} 
  {{ javascript_include('assets/libs/jquery-ui-touch/jquery.ui.touch-punch.min.js') }} 
  {{ javascript_include('assets/libs/jquery-detectmobile/detect.js') }} 
  {{ javascript_include('assets/libs/jquery-animate-numbers/jquery.animateNumbers.js') }} 
  {{ javascript_include('assets/libs/ios7-switch/ios7.switch.js') }} 
  {{ javascript_include('assets/libs/fastclick/fastclick.js') }} 
  {{ javascript_include('assets/libs/jquery-blockui/jquery.blockUI.js') }} 
  {{ javascript_include('assets/libs/bootstrap-bootbox/bootbox.min.js') }} 
  {{ javascript_include('assets/libs/jquery-slimscroll/jquery.slimscroll.js') }} 
  {{ javascript_include('assets/libs/jquery-sparkline/jquery-sparkline.js') }} 
  {{ javascript_include('assets/libs/nifty-modal/js/classie.js') }} 
  {{ javascript_include('assets/libs/nifty-modal/js/modalEffects.js') }} 
  {{ javascript_include('assets/libs/sortable/sortable.min.js') }} 
  {{ javascript_include('assets/libs/bootstrap-fileinput/bootstrap.file-input.js') }} 
  {{ javascript_include('assets/libs/bootstrap-select/bootstrap-select.min.js') }} 
  {{ javascript_include('assets/libs/bootstrap-select2/select2.min.js') }} 
  {{ javascript_include('assets/libs/magnific-popup/jquery.magnific-popup.min.js') }}  
  {{ javascript_include('assets/libs/pace/pace.min.js') }} 
  {{ javascript_include('assets/libs/bootstrap-datepicker/js/bootstrap-datepicker.js') }} 
  {{ javascript_include('assets/libs/jquery-icheck/icheck.min.js') }} 
  <!-- {{ javascript_include('assets/js/init.js') }}  -->
  <script type="text/javascript">
  $('input:not(.ios-switch)').iCheck({
  checkboxClass: 'icheckbox_square-aero',
  radioClass: 'iradio_square-aero',
  increaseArea: '20%' // optional
  });
  // IOS7 SWITCH
  $(".ios-switch").each(function(){
  mySwitch = new Switch(this);
  });
  </script>
  <!-- <script src="assets/js/init.js"></script> -->
  <!-- new template js end -->
        <!-- {{ javascript_include('js/bootstrap.min.js') }}        -->
        {{ javascript_include('js/XMPP/strophe.min.js') }}
        <!-- {{ stylesheet_link('css/fontawesome/font-awesome.min.css') }} -->
        <!-- {{ javascript_include('https://www.google.com/recaptcha/api.js')}}  -->
        <?php
        $login_status="false";
        $auth=$this->session->get('auth');
        if($auth['login_type']=="Group Admin" ||$auth['login_type']=="Super Admin"){
            $login_status="true";
        }
        ?>
        <script type="text/javascript">
         var BOSH_SERVICE = 'http://linkapp.in:5280/http-bind';
         var status='false';//<?php echo $login_status?>;
         if(status=="true"){
            var jid="<?php if(isset($auth['jid'])){echo base64_encode($auth['jid']);}?>";
            var j_pass="<?php if(isset($auth['j_pass'])){echo base64_encode($auth['j_pass']);}?>";
            xmpp_con = new Strophe.Connection(BOSH_SERVICE);
            //xmpp_con.connect(decode_me(jid),decode_me(j_pass),onConnect); 
            setTimeout(function(){ xmpp_con.connect(decode_me(jid),decode_me(j_pass),onConnect); }, 3000);
            //register event before page unload disconnect xmpp connection to stop any incomming message loss
            $(window).bind('beforeunload', function(){
                xmpp_con.flush();
                //xmpp_con.options.sync = true;    
                xmpp_con.disconnect();   
            });

         }
         function onConnect(status)
         {
          if(status == Strophe.Status.DISCONNECTED) {
            console.log('disconnected.');
          }else if (status == Strophe.Status.CONNECTED) {
            console.log('Connected.');
            //console.log(xmpp_con.jid);
            /*$(window).bind('beforeunload', function(){
              xmpp_con.disconnect();
              return;
            }); */
            xmpp_con.addHandler(onXmppMessage, null, 'message', null, null,  null);
            var priority=parseInt(localStorage.getItem("priority"));
            if(priority===null||priority>=127)
              priority=0;
            else
              priority++;
            xmpp_con.send($pres().c("priority").t(""+priority+""));
            localStorage.setItem("priority",priority); 
            if($('div#inbox').length>0)
              sendDelivery();
          }
         }
         function decodeEntities(s){
         return $("<div/>").html(s).text();
        }
        function onXmppMessage(msg){
          //console.log(msg);
          var id = msg.getAttribute('id');
          var to = msg.getAttribute('to');
          var from =msg.getAttribute('from').split("/");
          from=from[0].split("@");
          var type = msg.getAttribute('type');
          var elems = msg.getElementsByTagName('body');
          var datetime = msg.getAttribute('datetime');
          //console.log(msg);
          if(type == "chat" && elems.length > 0) {
              var body = elems[0];
              var message=$.trim(decodeEntities(Strophe.getText(body)));
              $.ajax({
                      cache:false,
                      type: "POST",
                      url: "/inbox/save",
                      data:"sender_id="+from[0]+"&datetime="+datetime+"&message="+message,
                      dataType: "json",
                      success:  function(response){
                     // console.log(response);
                     if($('div#inbox').length>0){
                      /*update status in db function*/
                        sendDelivery();
                      /*END*/
                        //reply = $msg({to:from,from:to,id: id,status: 'true',type: 'delivery'});
                        var item = window.dataView.getItemById(from[0]);
                        if(item){
                          item['message'] =message;
                          item['datetime'] =response['data']['datetime'];
                          item['read_status'] ="0";
                          window.dataView.updateItem(item['id'], item);
                        }else{
                           item = {"id":from[0],"sender_id":from[0],"message":message,"datetime":response['data']['datetime'],"read_status":"0"};
                           window.dataView.insertItem(0, item);
                        }
                        /*check chat box is open */
                        if($("#sms_conversion #"+from[0]+"").is(":visible")){
                          var d = new Date();
                          var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                          var selecter=$('#sms_conversion .range_btn');
                          selecter.append('<div class="bubble me"><span>'+message+'<div><div class="time">'+datetime+'</div></div></span></div>');
                          var scoll_elem=$('#sms_conversion .modal-body');
                          scoll_elem.scrollTop(scoll_elem.prop("scrollHeight"));
                        }
                        /*End*/
                      
                     }else{
                        //reply = $msg({to:from,from:to,id: id,status: 'false',type: 'delivery'});
                        var count =parseInt($("ul.nav span.msg_count").text().replace(/[^0-9]/gi, ''),10);
                        if(isNaN(count))
                          count=1;
                        else
                          count=count+1;
                        /*console.log(count);*/
                        $("ul.nav span.msg_count").text('('+count+')');
                        $("ul.nav span.glyphicon-bell").addClass('red');
                     }
                     // xmpp_con.send(reply.tree());
                      }
                  });
          }
          return true;
        }
        </script>
        <script type="text/javascript">
        $(document).ready(function() { $('body').addClass("login-page"); });
        </script>
    </body>
</html>
