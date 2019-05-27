<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        {{ get_title() }}
        {{ stylesheet_link('css/bootstrap.min.css') }}

        <!-- <link rel="stylesheet" type="text/css" href="/css/sanchar.css?v<?=time()?>"> -->
        {{ javascript_include('js/jquery.min.js') }}
        {{ javascript_include('js/utils.js') }}

        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="LinkApp">
        <meta name="author" content="LinkApp">
        <link href="https://fonts.googleapis.com/css?family=Fjalla+One|Roboto:300,400,700" rel="stylesheet">

        <!-- coco ganesh -->
           <!-- Base Css Files -->
        <link href="/assets/libs/jqueryui/ui-lightness/jquery-ui-1.10.4.custom.min.css" rel="stylesheet" />
        <link href="/assets/libs/bootstrap/css/bootstrap.min.css" rel="stylesheet" />
        <link href="/assets/libs/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
        <link href="/assets/libs/fontello/css/fontello.css" rel="stylesheet" />
        <link href="/assets/libs/animate-css/animate.min.css" rel="stylesheet" />
        <link href="/assets/libs/nifty-modal/css/component.css" rel="stylesheet" />
        <link href="/assets/libs/magnific-popup/magnific-popup.css" rel="stylesheet" /> 
        <link href="/assets/libs/ios7-switch/ios7-switch.css" rel="stylesheet" /> 
        <link href="/assets/libs/pace/pace.css" rel="stylesheet" />
        <link href="/assets/libs/sortable/sortable-theme-bootstrap.css" rel="stylesheet" />
        <link href="/assets/libs/bootstrap-datepicker/css/datepicker.css" rel="stylesheet" />
        <link href="/assets/libs/jquery-icheck/skins/all.css" rel="stylesheet" />
        <!-- Code Highlighter for Demo -->
        <link href="/assets/libs/prettify/github.css" rel="stylesheet" />
        
                <!-- Extra CSS Libraries Start -->
                <link href="/assets/libs/rickshaw/rickshaw.min.css" rel="stylesheet" type="text/css" />
                <link href="/assets/libs/morrischart/morris.css" rel="stylesheet" type="text/css" />
                <link href="/assets/libs/jquery-jvectormap/css/jquery-jvectormap-1.2.2.css" rel="stylesheet" type="text/css" />
                <link href="/assets/libs/jquery-clock/clock.css" rel="stylesheet" type="text/css" />
                <link href="/assets/libs/bootstrap-calendar/css/bic_calendar.css" rel="stylesheet" type="text/css" />
                <link href="/assets/libs/sortable/sortable-theme-bootstrap.css" rel="stylesheet" type="text/css" />
                <link href="/assets/libs/jquery-weather/simpleweather.css" rel="stylesheet" type="text/css" />
                <link href="/assets/libs/bootstrap-xeditable/css/bootstrap-editable.css" rel="stylesheet" type="text/css" />
                <link href="/assets/css/style.css" rel="stylesheet" type="text/css" />
                <!-- Extra CSS Libraries End -->
        <link href="/assets/css/style-responsive.css" rel="stylesheet" />

        <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
        <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
        <![endif]-->

        <link rel="shortcut icon" href="/assets/img/favicon.ico">
        <link rel="apple-touch-icon" href="/assets/img/apple-touch-icon.png" />
        <link rel="apple-touch-icon" sizes="57x57" href="/assets/img/apple-touch-icon-57x57.png" />
        <link rel="apple-touch-icon" sizes="72x72" href="/assets/img/apple-touch-icon-72x72.png" />
        <link rel="apple-touch-icon" sizes="76x76" href="/assets/img/apple-touch-icon-76x76.png" />
        <link rel="apple-touch-icon" sizes="114x114" href="/assets/img/apple-touch-icon-114x114.png" />
        <link rel="apple-touch-icon" sizes="120x120" href="/assets/img/apple-touch-icon-120x120.png" />
        <link rel="apple-touch-icon" sizes="144x144" href="/assets/img/apple-touch-icon-144x144.png" />
        <link rel="apple-touch-icon" sizes="152x152" href="/assets/img/apple-touch-icon-152x152.png" />
        <!-- coco end ganesh -->

        <?php $this->assets->outputCss(); ?>
    </head>
    <body>
       
        {{ content() }}
        {{ javascript_include('js/bootstrap.min.js') }}       
        {{ javascript_include('js/XMPP/strophe.min.js') }}
        {{ stylesheet_link('css/fontawesome/font-awesome.min.css') }}
        {{ javascript_include('https://www.google.com/recaptcha/api.js')}} 
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

<script>
    var resizefunc = [];
  </script>

        <!-- coco ganesh js -->
        <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
  <!-- <script src="/assets/libs/jquery/jquery-1.11.1.min.js"></script> -->
  <!-- <script src="/assets/libs/bootstrap/js/bootstrap.min.js"></script> -->
  <script src="/assets/libs/jqueryui/jquery-ui-1.10.4.custom.min.js"></script>
  <script src="/assets/libs/jquery-ui-touch/jquery.ui.touch-punch.min.js"></script>
  <script src="/assets/libs/jquery-detectmobile/detect.js"></script>
  <script src="/assets/libs/jquery-animate-numbers/jquery.animateNumbers.js"></script>
  <script src="/assets/libs/ios7-switch/ios7.switch.js"></script>
  <script src="/assets/libs/fastclick/fastclick.js"></script>
  <script src="/assets/libs/jquery-blockui/jquery.blockUI.js"></script>
  <script src="/assets/libs/bootstrap-bootbox/bootbox.min.js"></script>
  <script src="/assets/libs/jquery-slimscroll/jquery.slimscroll.js"></script>
  <script src="/assets/libs/jquery-sparkline/jquery-sparkline.js"></script>
  <script src="/assets/libs/nifty-modal/js/classie.js"></script>
  <script src="/assets/libs/nifty-modal/js/modalEffects.js"></script>
  <script src="/assets/libs/sortable/sortable.min.js"></script>
  <script src="/assets/libs/bootstrap-fileinput/bootstrap.file-input.js"></script>
  <script src="/assets/libs/bootstrap-select/bootstrap-select.min.js"></script>
  <script src="/assets/libs/bootstrap-select2/select2.min.js"></script>
  <script src="/assets/libs/magnific-popup/jquery.magnific-popup.min.js"></script> 
  <script src="/assets/libs/pace/pace.min.js"></script>
  <script src="/assets/libs/bootstrap-datepicker/js/bootstrap-datepicker.js"></script>
  <script src="/assets/libs/jquery-icheck/icheck.min.js"></script>

  <!-- Demo Specific JS Libraries -->
  <script src="/assets/libs/prettify/prettify.js"></script>

  <script src="/assets/js/init.js"></script>

  <!-- coco ganesh js end -->
    </body>
</html>
