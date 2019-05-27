    var $uploadCrop,reg_status,app_version,db_user_version,strophe_con_state,isBackground=false,db,need_updateGCM=false,selectMsg_arr = [],blocklist_arr =[],isAndroid=false,lookup = {},clipboard,push,last_refresh_date,load_more_date,siteurl="http://sancharapp.com",BOSH_SERVICE = 'http://sancharapp.com:5280/http-bind',xmpp_con = null,loc_Storage = window.localStorage,ses_Storage = window.sessionStorage,subscriber_id=loc_Storage.getItem("subscriber_id"),jid=loc_Storage.getItem("jid"),j_pass=loc_Storage.getItem("j_pass"),defaultImagePath="images/yuna.png",GCM_refresh_date=loc_Storage.getItem("GCM_refresh_date"),pictureSource,destinationType,showResult_timer,showResult_XHR;

    // app config ganesh
    var company_id=187;
    localStorage.setItem('company_id',company_id);
    // app config ganesh end


    //default ajax setting to change just override this option
    $.ajaxSetup({ cache: true ,type:"GET",dataType:"json",async: false,
      beforeSend: function(jqXHR,setting) { 
        try{
          if(checkInternet() == Connection.NONE){
            jqXHR.abort();
            
            if($('#privacy_model').is(':visible'))
              update_status(); 

            if($('#loader_model').is(':visible'))
              $('#loader_model').closeModal();
            
            toastDestroy();
            Materialize.toast("Please check your internet connection", 2000);
          }
          return;
        }catch(err){
          log(err);
          return;
        }
      },
      error: function(xhr, status, error) {
            if (xhr == 'undefined' || xhr == undefined) {
                log('undefined');
            }
            log('Ajax Error Status: '+status);
            log('Ajax Error Error: '+error);
          if($('#loader_model').is(':visible'))
            $('#loader_model').closeModal();
      }
      });    
//--------Intialize all plugin in device ready function only
function onDeviceReady() {
  db_user_version ='102';//stand for version without "." change this if we change database structure
  reg_status=loc_Storage.getItem("reg_status");
  //Materialize.toast("Please check your", 20000);
  if(device.platform == 'android' || device.platform == 'Android')
          isAndroid=true;
  load_DB(); //load or create all tables
  //loadGroups();//load all sender groups data
  var attachFastClick = Origami.fastclick; //to remove click delay 
  attachFastClick(document.body);

  $('#msg_model #msg_text').click(function(e){ $(this).focus();});
  
  // check user status otherwise redirect to register page
    if(reg_status=="true"){
/*         $('#homepage').html('');
         $.ajax({cache:true,url: "html/appintro.html",dataType:"html",success:  function(response){$("#homepage").html(response);},beforeSend:  function(){log('Loading AppIntro Page');}});
         return;*/
         //load_local_msg();
         reConnectXMPP();
         //load_Blocklist();
         renderMyAccount();
    }else{
      $('#homepage').html('');
      $.ajax({cache:true,url: "html/login.html",dataType:"html",success:  function(response){$("#homepage").html(response);},beforeSend:  function(){log('Loading Registration Page');}});
      //$("#homepage").load("html/registration.html");
    }
  document.addEventListener("backbutton", onBackbutton, false);
  document.addEventListener("online", onOnline, false);
  document.addEventListener("offline", onOffline, false);
  document.addEventListener("resume", onResume, false);
  document.addEventListener("pause", onPause, false);
    try{
        intializePush();
        clipboard =window.plugins.clipboard;
    }catch(err){
        log('Catch:'+err.message);
    }
    //pull to refresh logic  
  $("#list").pullToRefresh({
        refresh: 130,
        resetSpeed: '1000ms',
        lockRefresh: true
      })
      .on("move.pulltorefresh", function (evt, percentage){
        $('#touchloader #pre').attr('style','width:'+(percentage+2)+'%;');
      })
      .on("end.pulltorefresh", function (evt){
         $('#touchloader #pre').attr('style','width:0%;');
      })
      .on("refresh.pulltorefresh", function (evt, y){
        vibrate(100);
        $('#touchloader #pre').attr('style','width:0%;');
        $('#touchloader #post').show();
        setTimeout(refresh, 3000);  
      });
//end pull to refresh

$('#msg_model').on("click", ".modal-content-msg img", function (event) {
    var src=$(this).attr('src');
    lightBox(src);
});
//this will call on each load update last access date , show any message if admin set
if(reg_status=="true")
  checkServerMessage();

getVersion();
}//end onDeviceReady()----------------------------------------------------
function intializePush(){
  var notification_status = localStorage.getItem("notification_status");
  console.log('Status '+notification_status);
  if(notification_status== "No")
      showPushNotification=false;
  else
      showPushNotification=true;
    
  if(GCM_refresh_date!=null){
          var diffDays = Math.ceil(Math.abs(new Date().getTime() - GCM_refresh_date) / (1000 * 3600 * 24));
          if(diffDays>10){ 
              need_updateGCM=true;
          }
  }
        push = PushNotification.init({android: {senderID: "918909303989",force_launch:true,forcehide:showPushNotification,start_on_background:true},ios: {alert: "true",badge: "true",sound: "true"}});
        push.on('registration', function(data) {
                log(data.registrationId);
                loc_Storage.setItem("reg_id",data.registrationId);

                if(need_updateGCM==true){
                  update_GCM_ID();
                }
        });
        push.on('notification', function(data) {
          console.log(data);
          if(data.additionalData.foreground==false && checkInternet() == Connection.NONE){
            message=$.trim(decodeEntities(data.message));
            var attributes =data.additionalData.attributes;
            insert_record_received({multimedia:message,submit_datetime:attributes['submit_datetime'],mg_id:attributes['mg_id'],sender_id:data.title,route:attributes['route'],msg_id:data.additionalData.msg_id});
            console.log('save data to db gcm');
          }
          log('Received Push notification');
          //vibrate(400);
          if(strophe_con_state==false)
              reConnectXMPP();
        });
        push.on('error', function(e) {log(e.message);});
        clearbadge();
}

function parseVersionString (str) {
    if (typeof(str) != 'string') { return false; }
    var x = str.split('.');
    // parse from string or default to 0 if can't parse
    var maj = parseInt(x[0]) || 0;
    var min = parseInt(x[1]) || 0;
    var pat = parseInt(x[2]) || 0;
    return {
        major: maj,
        minor: min,
        patch: pat
    }
}
function getVersion(){
  try{
      cordova.getAppVersion.getVersionNumber().then(function (version) {
          $('#about_modal .version').text(version);
          console.log('App version'+version);   
      });
  }catch(err){
    console.log('Catch:'+err.message);
  } 
}
function clearbadge(){
    push.setApplicationIconBadgeNumber(function() {
    console.log('success');
    }, function() {
        console.log('error');
    }, 0);
}
function lightBox(src){
    $('#photoCard_model img').attr('src',src);
    $('#photoCard_model').openModal();
}
function showDp(src){
  $('#photoCard_model img').attr('src',src);
  $('#photoCard_model').openModal();
  return false;
}
function checkInternet(){
  if(isAndroid)
    return navigator.connection.type;
  else
    return Connection.CELL;
}
function onBackbutton(){
  var selector=$("div.lean-overlay");
  var model_id='';
  if($("#sidenav-overlay").is(':visible')){
     $('.button-collapse').sideNav('hide');
     return;
  }
  if(!selector.is(':visible')||$("div#register").length>0||$("div#validate").length>0){
      if(strophe_con_state==true)
        xmpp_con.disconnect();
      navigator.app.exitApp();       

  }else{
    $(".modal:visible").each(function(){
       model_id=$(this).attr('id');
    });
    //if(model_id!="loader_model")
      $('#'+model_id+'').closeModal();
  } 
}
function onOnline() {
    //check xmpp con state if disconnect then connect again
    console.log('online');
    if(strophe_con_state==false){
      reConnectXMPP(); 
    }else{
      need_Resend();
      processOfflineDeliveryQueue();
    }
}
function onOffline() {
  console.log('onOffline');
/*  if(strophe_con_state==true)
    xmpp_con.disconnect();*/
    reConnectXMPP();
}
function onPause() {
  isBackground=true;
}
/*function reConnectXMPP(){
  xmpp_con = new Strophe.Connection(BOSH_SERVICE, {'keepalive': true});
  xmpp_con.connect(jid,j_pass,onConnect);
}*/
function reConnectXMPP(){
  //alert("caller is " + arguments.callee.caller.name);
  console.log('reConnectXMPP')
   try {
      xmpp_con.restore(jid, onConnect);
   } catch(e) {
      console.log(e);
      xmpp_con = new Strophe.Connection(BOSH_SERVICE, {'keepalive': true});
      console.log('jid: ',jid,' j_pass: ',j_pass);
      xmpp_con.connect(jid,j_pass,onConnect);
   }
}
function onResume() {
  console.log('onResume');
  isBackground=false;
  if(strophe_con_state==true){
    //need to check any chat box is open or not if open then need to send any message delivery reports
    if($('#msg_model').is(':visible')){
        var id=$('#msg_model').attr('data-id');
        sendReadDeliveryReceipt(id);
    } 
  }else{
    reConnectXMPP();
  }
}
function downloadImage(download_link,id){
  //Parameters mismatch check
if(download_link == null || download_link=="")
  return;

    //checking Internet connection availablity
    if(checkInternet() == Connection.NONE){
      toastDestroy();
      Materialize.toast("Please check your internet connection", 2000);
        return;
    } else {
      try{
      //step to request a file system 
        window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function(fileSystem){
        var Folder_Name="SancharApp/SancharAppImages";
        var File_Name = new Date().getTime();
       /* var download_link = encodeURI(download_link);*/
        ext = download_link.substr(download_link.lastIndexOf('.') + 1); //Get extension of URL
        var directoryEntry = fileSystem.root; // to get root path of directory
        directoryEntry.getDirectory(Folder_Name, { create: true, exclusive: false }, function(){}, function(){}); // creating folder in sdcard
        var rootdir = fileSystem.root;
        var fp = rootdir.toURL(); // Returns Fulpath of local directory
        fp = fp + "/" + Folder_Name + "/" + File_Name + "." + ext; // fullpath and name of the file which we want to give

        var fileTransfer = new FileTransfer();
        var selector=$('#msg_model ul.modal-content li#'+id+'');
        selector.append('<span class="progress"><span class="determinate" style="width:0%"></span></span>');
        var flag=true;
        fileTransfer.onprogress = function(progressEvent) {
            if (progressEvent.lengthComputable) {
              var perc = Math.floor(progressEvent.loaded / progressEvent.total * 100);
              selector.find('.determinate').attr('style','width:'+perc+'%;');
            } else {
              if(flag){
                flag=false;
                selector.find('.determinate').removeAttr('style').addClass('indeterminate').removeClass('determinate');
              }
            }
          };
        // File download function with URL and local path
        fileTransfer.download(download_link, fp,
                  function (entry) {
                        var new_image_url=entry.toURL();
                        refreshMedia.refresh(new_image_url); 
                        console.log("download complete: " + new_image_url);
                        //code after download image update database image src with local storage path
                            db.transaction(function(tx) {
                              tx.executeSql("select id,multimedia from message where id=?",[id],function(tx,results){
                                 var old_msg=results.rows.item(0).multimedia;
                                 var tree = $("<div>" + old_msg + "</div>");
                                 tree.find('img').attr('src',new_image_url).removeAttr('data-url');
                                 var new_msg = tree.html();
                                 tx.executeSql("update message set multimedia='"+new_msg+"' where id="+id);
                                 selector.find('.sender-masg').html(new_msg);
                                 selector.find('.progress').remove();
                                 if(selector.is(':last-child')){
                                  var ul = $('#msg_model ul.modal-content');
                                  ul.animate({scrollTop: ul[0].scrollHeight},1500);
                                 }
                                 },errorCB);
                            }, errorCB);
                  },
                 function (error) {
                     //Download abort errors or download failed errors
                     console.log("download error source " + error.source);
                     console.log("download error target " + error.target);
                     console.log("upload error code" + error.code);
                 }
        );
          }, function(error){
            console.log('requestFileSystem:'+JSON.stringify(error));
          
        }); 

    }catch(err){
        alert(err.message);
    }
}//end else
}

//ganesh downloadFile for mp3 audio video
function downloadFile(download_link,id,type){
  console.log('download_link: ',download_link);

  //Parameters mismatch check
if(download_link == null || download_link=="")
  return;

    //checking Internet connection availablity
    if(checkInternet() == Connection.NONE){
      toastDestroy();
      Materialize.toast("Please check your internet connection", 2000);
        return;
    } else {
      try{
      //step to request a file system 
        window.requestFileSystem(LocalFileSystem.PERSISTENT, 0, function(fileSystem){
        var Folder_Name="SancharApp/SancharAppImages";
        var File_Name = new Date().getTime();
       /* var download_link = encodeURI(download_link);*/
        ext = download_link.substr(download_link.lastIndexOf('.') + 1); //Get extension of URL
        var directoryEntry = fileSystem.root; // to get root path of directory
        directoryEntry.getDirectory(Folder_Name, { create: true, exclusive: false }, function(){}, function(){}); // creating folder in sdcard
        var rootdir = fileSystem.root;
        var fp = rootdir.toURL(); // Returns Fulpath of local directory
        fp = fp + "/" + Folder_Name + "/" + File_Name + "." + ext; // fullpath and name of the file which we want to give

        var fileTransfer = new FileTransfer();
        var selector=$('#msg_model ul.modal-content li#'+id+'');
        selector.append('<span class="progress"><span class="determinate" style="width:0%"></span></span>');
        var flag=true;
        fileTransfer.onprogress = function(progressEvent) {
            if (progressEvent.lengthComputable) {
              var perc = Math.floor(progressEvent.loaded / progressEvent.total * 100);
              selector.find('.determinate').attr('style','width:'+perc+'%;');
            } else {
              if(flag){
                flag=false;
                selector.find('.determinate').removeAttr('style').addClass('indeterminate').removeClass('determinate');
              }
            }
          };
        // File download function with URL and local path
        fileTransfer.download(download_link, fp,
                  function (entry) {
                        var new_image_url=entry.toURL();
                        refreshMedia.refresh(new_image_url); 
                        console.log("download complete: " + new_image_url);
                        //code after download image update database image src with local storage path
                            db.transaction(function(tx) {
                              tx.executeSql("select id,multimedia from message where id=?",[id],function(tx,results){
                                 var old_msg=results.rows.item(0).multimedia;
                                 console.log('old_msg: ',old_msg);
                                 var tree = $("<div>" + old_msg + "<source src="+new_image_url+" type='audio/ogg'></audio></div>");
                                 console.log('mp3 from database tree: ',tree);
                                 tree.find(type).removeAttr('data-url');
                                 var new_msg = tree.html();
                                 tx.executeSql("update message set multimedia='"+new_msg+"' where id="+id);
                                 selector.find('.sender-masg').html(new_msg);
                                 selector.find('.progress').remove();
                                 if(selector.is(':last-child')){
                                  var ul = $('#msg_model ul.modal-content');
                                  ul.animate({scrollTop: ul[0].scrollHeight},1500);
                                 }
                                 },errorCB);
                            }, errorCB);
                  },
                 function (error) {
                     //Download abort errors or download failed errors
                     console.log("download error source " + error.source);
                     console.log("download error target " + error.target);
                     console.log("upload error code" + error.code);
                 }
        );
          }, function(error){
            console.log('requestFileSystem:'+JSON.stringify(error));
          
        }); 

    }catch(err){
        alert(err.message);
    }
}//end else
}


function sendReadDeliveryReceipt(id){
    db.transaction(function(tx) {
      tx.executeSql("select id,read_status,msg_id from message where group_id=? AND read_status='false' ORDER by datetime DESC",[id],function(tx,results){
        var count=results.rows.length;
        console.log('sendReadDeliveryReceipt: '+count);
        for(var i=0; i<count; i++) {
                var read_status=results.rows.item(i).read_status;
                //console.log('DD'+read_status);
                if(read_status=='false'){
                    var d = new Date();
                    var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
            console.log('admin2: ',id);
                    var delivery_reply = $msg({to:id+'@sancharapp.com',from: jid,id:results.rows.item(i).msg_id,datetime: datetime,type: 'chat'}).c('body').t("Read");
                    var message_extra={submit_datetime:datetime};
                      delivery_reply.up().c("message_extra").t(JSON.stringify(message_extra));
                    xmpp_con.send(delivery_reply);
                    updateRead_status_group('received',id);
                    $('ul#inbox_list > li#'+id+'').find('p.unread').addClass('read').removeClass('unread');
                    renderUnreadCount(id);
                }

        }
      },errorCB);
    }, errorCB); 
}
function processOfflineDeliveryQueue(){
  /*Code start-------------------*/
  if(strophe_con_state==true && checkInternet() != Connection.NONE){
        var ids=JSON.parse(localStorage.getItem("pending_delivery_msg_ids"));
        console.log('processOfflineQueue:');
        if(ids){
          $.each(ids, function(key, value ){
            /*This send msg read status*/
            console.log('admin3: ',ids);
            var delivery_reply = $msg({to:ids+'@sancharapp.com',from: jid,id:value.id,datetime: value.datetime,type: 'chat'}).c('body').t(value.status);
            var message_extra={submit_datetime:datetime};
                      delivery_reply.up().c("message_extra").t(JSON.stringify(message_extra));
            xmpp_con.send(delivery_reply);
          });
          ids=[];
          localStorage.setItem("pending_delivery_msg_ids",JSON.stringify(ids));
        }
  }
  /*Code end---------------------*/
}
function vibrate(time){
  navigator.vibrate(time);
}
function getDetails(mg_id,param){
   var str;
   switch (param) {
    case "displayName":
    /*    if(lookup[mg_id]==undefined)
          str=mg_id;
        else*/
          str=lookup[mg_id]["displayName"];
          console.log("lookup: ",lookup);
        break;
    case "photo":
        if(lookup[mg_id]==undefined || lookup[mg_id]["photo"]==undefined)
          str=siteurl+'/profile/'+mg_id+'.jpg';//str=defaultImagePath;
        else
          str=siteurl+'/profile/'+lookup[mg_id]["photo"];
        break;
  } 
  return str;
}
function openExternal(elem) {
    window.open(elem.href, "_system");
    return false; // Prevent execution of the default onClick handler 
}
function getClass(read_status){
    var read_class;
    switch(read_status) {
      case "true":
        read_class='mdi-action-done-all remove_color'; //double tick(blue) on user end delivery
        break;
      case "false":
        read_class='mdi-action-done-all'; //double tick(green) on read
        break;
      case "":
        read_class='mdi-action-done';   //single tick on delivery server
      break;
      case "delivery":
        read_class='mdi-action-done';
        break;
      case "read":
        read_class='mdi-action-done-all';
        break;
      default:
        read_class='mdi-action-schedule';
    }
  return read_class;
}
function displayDate(dt) {
    dt=dt.replace(/[-]/g, '/');
    var date = new Date(dt);
    var day = date.getDay()
    var cur_date = new Date();
    var timeDiff = Math.abs(cur_date.getTime() - date.getTime());
    var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
    //log(diffDays)
    if(day==cur_date.getDay() && diffDays<7){
     return getAmPm(dt);
    }
    else if(diffDays==1){
      return "Yesterday";
    }
    else if(diffDays>=2 && diffDays <=6){ 
      var daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday','Friday', 'Saturday'];
      var weekDay = daysOfWeek[day];
      return weekDay;    
    } 
    else{
      var d=dt.split(" ");
      var d1=d[0].split('/');
      var display_date=d1[2] +'/'+ d1[1] +'/'+ d1[0].slice(2,4);
      return display_date;
    }
}
function getAmPm(dt){
var time=dt.split(" ");
      time = time[1].slice(0,5).toString ().match (/^([01]\d|2[0-3])(:)([0-5]\d)(:[0-5]\d)?$/) || [time];
      if (time.length > 1) { // If time format correct
        time = time.slice (1);  // Remove full string match value
        time[5] = +time[0] < 12 ? 'am' : 'pm'; // Set AM/PM
        time[0] = +time[0] % 12 || 12; // Adjust hours
      }
      return time.join (''); // return adjusted time or original string
}
function chatdisplayDate(dt) {
    dt=dt.replace(/[-]/g, '/');
    var date = new Date(dt);
    var day = date.getDay()
    var cur_date = new Date();
    var timeDiff = Math.abs(cur_date.getTime() - date.getTime());
    var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
    //log(diffDays)
    if(day==cur_date.getDay() && diffDays<7){
    return getAmPm(dt);
    }
    else if(diffDays==1){
      return "Yesterday "+getAmPm(dt);
    }
    else if(diffDays>=2 && diffDays <=6){ 
      var daysOfWeek = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday','Friday', 'Saturday'];
      var weekDay = daysOfWeek[day];
      return weekDay+' '+getAmPm(dt);    
    } 
    else{
      var d=dt.split(" ");
      var d1=d[0].split('/');
      var display_date=d1[2] +'/'+ d1[1] +'/'+ d1[0].slice(2,4);
      return display_date+' '+getAmPm(dt);
    }
}

function log(msg) 
{
     //console.log(': -'+arguments.callee.caller.name);
     console.log(msg);
     //$('div#homepage').append(msg+'<br/>');
     //Materialize.toast(msg, 3000);
}
function onConnect(status)
{
  console.log('onConnect status: ',status);
  if (status == Strophe.Status.DISCONNECTED) {
    strophe_con_state=false;
    console.log('disconnected.');
    $("#disconnect").removeClass("hide");
  }/*else if (status == Strophe.Status.ATTACHED) {
    strophe_con_state=true;
    log('ATTACHED.');
    $("#disconnect").addClass("hide");
    xmpp_con.addHandler(onXmppMessage, null, 'message', null, null,  null); 
    xmpp_con.send($pres().tree());
    setTimeout(need_Resend, 1000);
    processOfflineDeliveryQueue();
  }*/else if (status == Strophe.Status.CONNECTED ||status == Strophe.Status.ATTACHED) {
    strophe_con_state=true;
    console.log('Connected.');
    $("#disconnect").addClass("hide");
    xmpp_con.addHandler(onXmppMessage, null, 'message', null, null,  null); 
    xmpp_con.send($pres().tree());
    setTimeout(need_Resend, 1000);
    processOfflineDeliveryQueue();
  }
}
function decodeEntities(encodedString) {
    return $("<div/>").html(encodedString).text();
}

function receive_delivery(id,group_id,status){
  var data_id=$('#msg_model').attr('data-id');
  var selector = $('#msg_model ul.modal-content');//
  if(id=="deliver_all"){
      updateRead_status_group('sent',group_id);
     //console.log("deliver_all");
      //main list
      var inbox_li = $('ul#inbox_list li.'+group_id+'');//
      if(inbox_li.length>0)
        inbox_li.find('p.secondary-content i').attr('class','mdi-action-done-all remove_color');
      //if chat box open 
      if(selector.is(':visible') && data_id==group_id){
        $('span.sender-time .read_status i').each(function() {
          $(this).attr('class','mdi-action-done-all remove_color');
        });
      }
  }else{
    var li=selector.find('li#'+id+' span.sender-time i');
    updateRead_status(id,status);
    if(selector.is(':visible') && data_id==group_id)
      li.attr('class',getClass(status));

    var inbox_li = $('ul#inbox_list li.'+group_id+'');//
    if(inbox_li.length>0)
      inbox_li.find('p.secondary-content i').attr('class',getClass(status));
        
  }
}

function onXmppMessage(msg) {
    console.log('onXmppMessage: ',msg);
    var ele_message_extra =  msg.getElementsByTagName('message_extra');
    var message_extra=$.trim(decodeEntities(Strophe.getText(ele_message_extra[0])));
    console.log('message_extra : ',message_extra);
    var id = msg.getAttribute('id');
    console.log('activeId : ',id);
    //$('div#homepage').append(id+'<br/>');
    var to = msg.getAttribute('to');
    var from = msg.getAttribute('from');
    var type = msg.getAttribute('type');
    var elems = msg.getElementsByTagName('body');
    var sender_id = msg.getAttribute('sender_id');
    var datetime = msg.getAttribute('datetime');

    // for msg extra
    var ele_message_extra = msg.getElementsByTagName('message_extra');
    var message_extra = $.trim(decodeEntities(Strophe.getText(ele_message_extra[0])));
    console.log('message_extra : ',message_extra);
    if(message_extra)
    {
      var attributes = JSON.parse(message_extra);
      console.log('attributes: ',attributes);
      var type_msg = attributes['type'];
    }

    if(type_msg == "delivery"){

      var status = attributes['status'];
      console.log('type-msg: '+type_msg,' status:',status);

      mobile=from.split("@"); console.log('mymobile'+mobile[0]); console.log('mystatus'+status);
      receive_delivery(id,mobile[0],status);//get message delivery from sender
    }
    else{
      console.log('chatting');
      var body = elems[0];
      message=$.trim(decodeEntities(Strophe.getText(body)));
      // var attributes =JSON.parse(msg.getAttribute('attributes'));
       var attributes =JSON.parse(message_extra);
      console.log('onXmppMessage',attributes);
      mobile=from.split("@"); 
      insert_record_received({multimedia:message,submit_datetime:attributes['submit_datetime'],mg_id:mobile[0],sender_id:attributes['sender_id'],route:attributes['route'],msg_id:id});
    }
    return true;
}  
function successHandler (result) {
   // alert_msg('success:'+ result +'');
}
function errorHandler (error) {
   // alert_msg('<li>error:'+ error +'</li>');
}
function update_GCM_ID(){
    var reg_id=loc_Storage.getItem("reg_id");
    var param="reg_id="+reg_id+"&subscriber_id="+subscriber_id;
    $.ajax({
            url: siteurl+"/api/update_GCM_ID",
            data:param,
            success:  function(response){
              if(response['status']=='success'){
                log('GCM ID Updated');
                loc_Storage.setItem("GCM_refresh_date",new Date().getTime());
              }else{ 
                log('GCM ID Failed to Update');
              }
            }
                
    });
          
};
function renderMyAccount(){
  try{
  $('#profile_modal .datepicker').pickadate({selectMonths: true, selectYears: 50,max:new Date(),container:'#profile_modal',onClose: function() {
        $(document.activeElement).blur();
    }, onSet: function( arg ){
        if ( 'select' in arg ){ //prevent closing on selecting month/year
            this.close();
        }
    }});
  $("#profile_modal #mobile").val(loc_Storage.getItem("mobile"));
  $("#profile_modal #pincode_home").val(loc_Storage.getItem("pincode_home"));
  $("#profile_modal #pincode_work").val(loc_Storage.getItem("pincode_work"));
  
  var user_details=JSON.parse(loc_Storage.getItem("user_details"));
  if(user_details)
  {
      $("#profile_modal #name").val(user_details['name']);
      $("#profile_modal #dob").val(user_details['dob']);
      $("#profile_modal #doa").val(user_details['doa']);
      var $input = $('#profile_modal #dob').pickadate();
      var picker_dob = $input.pickadate('picker');
      picker_dob.set('select', ''+user_details['dob']+'', { format: 'yyyy-mm-dd' });

      var $input = $('#profile_modal #doa').pickadate();
      var picker_doa = $input.pickadate('picker');
      picker_doa.set('select', ''+user_details['doa']+'', { format: 'yyyy-mm-dd' });
      if(user_details['gender'])
      $("#profile_modal .gender input#"+user_details['gender']+"").prop("checked", true);
      $("#profile_modal #occupation").val(user_details['occupation']);
      if(user_details['profile_image']!='' && user_details['profile_image']!=null){
          var largeImage= $('img#default-img');
          largeImage.attr("src",user_details['profile_image']);
      } 
  } 
  //$("#profile_modal .input-field label").addClass('active');
  $('#profile_modal .input-field input[value!=""]').parents('div').find('label').addClass('active');
  $('#profile_modal .occupation label').removeClass('active');
  $('#profile_modal select#occupation').material_select();
  }catch(err){
        alert(err.message);
  }
/*  $('#profile_modal .datepicker').pickadate({selectMonths: true, selectYears: 50,max:new Date() });*/
}
function block_unblock(id){
  $('#loader_model').openModal({dismissible: false,opacity: .3});
  setTimeout(function(){
  var status= blocklist_arr.indexOf(''+id+'') !=-1 ? 'Yes' : 'No';
  var mg_id=id;
  var displayName=$('ul#inbox_list li.'+id+'').find('span.title').text();
  var dataString = "subscriber_id="+subscriber_id+"&mg_id="+mg_id+"&mobile=null&status="+status;
  //log(dataString);
            $.ajax({      
                  url: siteurl+"/api/group/permission",
                  data: dataString,
                  success: function(response){
                    if(response.status == 'success'){                   
                       db.transaction(function(tx) {
                        if(status=='No'){
                          tx.executeSql("UPDATE groups SET is_blocked='true' where id='"+id+"'",[],function(tx, results){
                            Materialize.toast(displayName+" add to Blocklist", 2000);
                            log(id+': Blocked');
                            load_Blocklist();
                            $('#loader_model').closeModal();
                          },errorCB);
                        }else{
                          tx.executeSql("UPDATE groups SET is_blocked='false' where id='"+id+"'",[],function(tx, results){
                            log(id+': UnBlocked');
                            Materialize.toast(displayName+" remove from Blocklist", 2000);
                            load_Blocklist();
                            $('#loader_model').closeModal();
                          },errorCB);
                        }
                       });//db end
                    }else{
                      $('#loader_model').closeModal();
                      Materialize.toast("Please try after Some time", 3000);
                    }//end if

                  }//end sucsess         
              });
  }, 1000);
}
/******************database functions******************/ 
function need_Resend(){
  log('Check need_Resend');
  if(checkInternet() != Connection.NONE && strophe_con_state==true){
    db.transaction(function(tx) {
        tx.executeSql("select id, multimedia, datetime,read_status,group_id,type,source from message where read_status='null'",[],function(tx,results){
          var count=results.rows.length;
          log('Message Resending :'+count);
           for(var i=0; i<count; i++) {
              var group_id=results.rows.item(i).group_id;
              var id=results.rows.item(i).id;
              var multimedia=results.rows.item(i).multimedia;
              var d = new Date();
              var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
              var msg=$msg({to:group_id+'@sancharapp.com', type: 'chat',id: id,datetime:datetime}).c('body').t(multimedia);
              xmpp_con.send(msg);
              updateRead_status(id,'');

              var inbox_li = $('ul#inbox_list li.'+group_id+'');//
              inbox_li.find('p.secondary-content i').attr('class','mdi-action-done');

              var data_id=$('#msg_model').attr('data-id');
              var selector = $('#msg_model ul.modal-content');//
              var li=selector.find('li#'+id+' span.sender-time i');
              if(selector.is(':visible') && data_id==group_id)
                li.attr('class',getClass(''));
           }
        } ,errorCB);
    }, errorCB); 
 }
}
function load_Blocklist(){
  blocklist_arr =[];
  $('#blocklist_modal ul#blockcontact_list').html('');
  db.transaction(function(tx) {
  tx.executeSql("select id,displayName from groups where is_blocked='true' ",[],function(tx,results){
        var count=results.rows.length;
        $("#privacy_model .blocklist .badge").html(count+' Contacts');
        log("Blocklist:"+count);
        if(count==0){
          var html ='<li class="collection-item">No blocked contacts.</li><li class="collection-item">Blocked contacts will no longer be able to send you any message.</li>';
          $('#blocklist_modal ul#blockcontact_list').append(html);
        }else{
          $('#blocklist_modal ul#blockcontact_list').append('<li class="collection-item collection-header"><h6>Tap to unblock.</h6></li>');
        }
        for(var i=0; i<count; i++) {
          var group_id=results.rows.item(i).id;
          var displayName=results.rows.item(i).displayName;
          var photo=getDetails(group_id,"photo"); 
          blocklist_arr.push(""+group_id+"");
          var html =  '<li class="collection-item waves-effect avatar"><a href="#" onclick="option_model('+group_id+');"><img src="'+photo+'" alt="" class="circle"></i>';
              html += '<span class="title">' + displayName+'</span><p>Web</p>';
              html += '</a></li>';
          $('#blocklist_modal ul#blockcontact_list').append(html);
        }//end loop
  } ,errorCB);
 },errorCB,successHandler);
}
function load_DB(){
  db = window.openDatabase("sancharapp", "1.0", "sancharapp", 200000);//general emulator

    // if(isAndroid)
    //   db = window.sqlitePlugin.openDatabase({name: 'sancharapp2.db', location: 'default'});
    //   //db = window.sqlitePlugin.openDatabase({name: "sancharapp.db", androidLockWorkaround: 1,androidDatabaseImplementation: 2});//android only
    // else
    //   db = window.openDatabase("sancharapp", "1.0", "sancharapp", 200000);//general emulator
      //db = window.sqlitePlugin.openDatabase({name: "sancharapp.db", location: 1});//for ios only
      try{
              var latest_version=db_user_version;
              var running_version = loc_Storage.getItem("db_app_version");
              running_version=(running_version) ? running_version : latest_version;
              console.log('version latest'+latest_version);
              console.log('version running'+running_version);

              if(latest_version > running_version){
                  console.log('using old db');//need to alter,update,delete table 
                  db.transaction(function(tx) {
                            //tx.executeSql("delete from message");
                            //tx.executeSql("ALTER TABLE groups ADD COLUMN photo");
                            //tx.executeSql("UPDATE message SET source='website' where sender_id!=''");
                            //tx.executeSql('DROP TABLE groups');
                            //tx.executeSql('DROP TABLE message');
                              createTables();
                              loc_Storage.setItem("db_app_version",latest_version);
                              //document.location.reload(true);
                  },errorCB); 
              }else {
                  console.log('using latest db');
                  createTables();
                  loc_Storage.setItem("db_app_version",latest_version);
              }
      }catch(err){
            log('Catch:'+err.message);
            createTables();
            loc_Storage.setItem("db_app_version",latest_version);
      }                  
}
function createTables(){
  console.log('createTables');
            db.transaction(function(tx) {
                tx.executeSql("CREATE TABLE IF NOT EXISTS groups(id PRIMARY KEY,displayName,is_verified,is_blocked,photo)");
                tx.executeSql("CREATE TABLE IF NOT EXISTS message(id INTEGER PRIMARY KEY,multimedia,datetime,read_status,group_id,type,source,msg_id,file,filetype,server_url)");
                
                //tables are ready now now safe to call other db depenent function
                if(reg_status=="true"){
                    loadGroups();//load all sender groups data
                    load_local_msg();
                    load_Blocklist();
                    // populateDB();
                }
                //end other database function callback

            },errorCB); 
}          
function loadGroups(){
  console.log('loadGroups');
  lookup = {};
  db.transaction(function(tx) {
  tx.executeSql("select id,displayName,is_verified,photo from groups",[],function(tx,results){
        var count=results.rows.length;
        for(var i=0; i<count; i++) {
          var id=results.rows.item(i).id;
          var displayName=results.rows.item(i).displayName;
          var is_verified=results.rows.item(i).is_verified;
          var photo=results.rows.item(i).photo;
          lookup[id] ={displayName:displayName,is_verified:is_verified,photo:photo};
        }//end loop
        //console.log(lookup);
        /*check profile image from server*/
        if(count)
        updateProfile();
        /*END*/
       
  } ,errorCB);
 },errorCB,successHandler);

}
function updateProfile(){
   /*check profile image from server*/
        $.ajax({
          url: siteurl+"/api/updateProfiles",
          type:"POST",
          data:{data:lookup},
          success:  function(response){
            $.each( response, function( key, value ) {
                 db.transaction(function(tx) {
                  tx.executeSql("UPDATE groups SET photo='"+value['photo']+"' WHERE id='"+value['mg_id']+"' ",[]);
                  if(lookup[value['mg_id']].photo)
                  lookup[value['mg_id']].photo =value['photo'];
                  var inbox_li = $('ul#inbox_list li.'+value['mg_id']+'');//
                  inbox_li.find("img#dp").attr("src",getDetails(value['mg_id'],"photo"));
                },errorCB); 
            });
          }
      });
    /*END*/
}
function checkServerMessage(){
  console.log('checkServerMessage subscriber_id: ',subscriber_id);
/*check checkServerMessage*/
        $.ajax({
          url: siteurl+"/api/checkServerMessage",
          data:"subscriber_id="+subscriber_id,
          success:  function(response){
            console.log('checkServerMessage response: ',response);
            $("#alert_model .footer").removeClass("hide");
            if(response['status']==true){
              $("#alert_model .server-message").html("<p>"+response['message']+"</p>");
              if(response['anchor']){
                $("#alert_model .footer #dltbtn").remove();
                $("#alert_model .footer").prepend(response['anchor']);
                if(response['strict']==true)
                  $("#alert_model .footer #cacel_btn").addClass("hide");
              }

              $("#alert_model").openModal({dismissible: response['strict']});
            }
          }
      });
    /*END*/
}      
function populateDB(tx){
    if(strophe_con_state==false){
      reConnectXMPP();
      return;
    }

    last_access_date=loc_Storage.getItem("last_access_date");
    //last_access_date='2015-05-01 00:00:30';
    var param="subscriber_id="+subscriber_id+"&last_access_date="+last_access_date;
    // log(param);
    console.log('/api/messages param: ',param);
    if($('#touchloader #post').is(':visible')){
      $('#touchloader #post').hide();
    }
    $.ajax({
      url: siteurl+"/api/messages",
      data:param,
      success:  function(response){
                var response=jQuery.parseJSON(Base64.decode(response));
                console.log(response);
                db.transaction(function(tx) {
                //tx.executeSql('DROP TABLE IF EXISTS message');
                  $.each(response, function(i, val) {
                    if(val['route']=="Feedback")
                      type="Feedback";
                    else
                      type="received";
                    var data_id=$('#msg_model').attr('data-id');
                    var selector = $('#msg_model ul.modal-content');//
                    var read_status='false';
                    var delivery_status='Delivered';
                    if (selector.is(':visible') && data_id==val['mg_id'] && isBackground==false){
                      read_status='true';
                      delivery_status='Read';
                    } 
                    //console.log('DD'+delivery_status);
                    //This send msg delivery status read or deliver
                      var d = new Date();
                      var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
            console.log('admin4: ',data_id);
                      var delivery_reply = $msg({to:data_id+'@sancharapp.com',from: jid,id:val['msg_id'],datetime: datetime,type: 'chat'}).c('body').t(delivery_status);
                      var message_extra={submit_datetime:datetime};
                      delivery_reply.up().c("message_extra").t(JSON.stringify(message_extra));
                      xmpp_con.send(delivery_reply);

                      tx.executeSql("insert into message (multimedia,datetime,read_status,group_id,type,source,msg_id) values (?,?,?,?,?,?,?)",[$.trim(val['multimedia']),val['submit_datetime'],read_status,val['mg_id'],type,'website',val['msg_id']],function(tx, results){
                        var id=results.insertId;
                        var dt=val['submit_datetime'];
                        if(loc_Storage.getItem("last_access_date") < dt && dt!='undefined')  
                         loc_Storage.setItem("last_access_date",dt);
                          //insert in group table 
                          if(lookup[''+val['mg_id']+'']==undefined){
                            tx.executeSql("INSERT into groups (id,displayName,is_verified,is_blocked,photo) values ('"+val['mg_id']+"','"+val['sender_id']+"','false','false','"+val['mg_id']+".jpg')",[]);
                            lookup[val['mg_id']] ={displayName:val['sender_id'],is_verified:'false'};
                          }else{
                            tx.executeSql("UPDATE groups SET displayName='"+val['sender_id']+"' WHERE id='"+val['mg_id']+"'",[]);
                          }
                          
                          refresh_renderList(id,val['multimedia'],val['submit_datetime'],read_status,val['mg_id'],type,'website');
                          refreshshowPopup(id,val['multimedia'],val['submit_datetime'],read_status,val['mg_id'],type,'website');
                       },errorCB);
                        

                  });
                },errorCB)
      }//end sucess
                    
    });//end ajax
}
function offlineDeliveryQueue(obj){
  var ids=JSON.parse(localStorage.getItem("pending_delivery_msg_ids"));
  if(ids=="" ||ids==null){ids=[];}
  ids.push(obj);
  localStorage.setItem("pending_delivery_msg_ids",JSON.stringify(ids));
}
function insert_record_received(val){

  console.log('insert_record_received: ',val);
                //tx.executeSql('DROP TABLE IF EXISTS message');
      db.transaction(function(tx) {
        tx.executeSql("select id from message where msg_id='"+val['msg_id']+"'",[],function(tx, results){
            var count=results.rows.length;
            console.log(results.rows);
            if(count==0){
                    if(val['route']=="Feedback")
                      type="Feedback";
                    else
                      type="received";
                    var data_id=$('#msg_model').attr('data-id');
                    var selector = $('#msg_model ul.modal-content');//
                    var read_status='false';
                    var delivery_status='Delivered';
                    if (selector.is(':visible') && data_id==val['mg_id'] && isBackground==false){
                      read_status='true';
                      delivery_status='Read';
                    } 
                    console.log('DD'+delivery_status);
                    /*This send msg delivery status read or deliver*/
                      var d = new Date();
                      var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                      if(checkInternet() != Connection.NONE && strophe_con_state==true){
            console.log('admin5: ',val['mg_id']);
                          var delivery_reply = $msg({to:val['mg_id']+'@sancharapp.com',from: jid,id:val['msg_id'],datetime: datetime,type: 'chat'}).c('body').t(delivery_status);
                          var message_extra={submit_datetime:datetime,type:delivery_status};
                      delivery_reply.up().c("message_extra").t(JSON.stringify(message_extra));
                          xmpp_con.send(delivery_reply);
                      }else{
                        offlineDeliveryQueue({id:val['msg_id'],datetime:datetime,status:delivery_status});
                      }
                    /***********************************************/
                      tx.executeSql("insert into message (multimedia,datetime,read_status,group_id,type,source,msg_id) values (?,?,?,?,?,?,?)",[$.trim(val['multimedia']),val['submit_datetime'],read_status,val['mg_id'],type,'website',val['msg_id']],function(tx, results){
                          var id=results.insertId;
                          //insert in group table 
                          if(lookup[''+val['mg_id']+'']==undefined){
                            tx.executeSql("INSERT into groups (id,displayName,is_verified,is_blocked,photo) values ('"+val['mg_id']+"','"+val['sender_id']+"','false','false','"+val['mg_id']+".jpg')",[]);
                            lookup[val['mg_id']] ={displayName:val['sender_id'],is_verified:'false'};
                          }else{
                            tx.executeSql("UPDATE groups SET displayName='"+val['sender_id']+"' WHERE id='"+val['mg_id']+"'",[]);
                          }
                          
                          refresh_renderList(id,val['multimedia'],val['submit_datetime'],read_status,val['mg_id'],type,'website');
                          refreshshowPopup(id,val['multimedia'],val['submit_datetime'],read_status,val['mg_id'],type,'website');
                       },errorCB);
              }
        },errorCB);
    },errorCB)
} 

// ganesh insert file insert file Record
//to  just insert file and render on screen
//msg not send with this funtion
//we will wait to complete upload file
function insert__fileRecord(multimedia,group_id,type,datetime,source){
  var XMPP_refresh_date;
  switch (type) {
            case "received":
                    var data_id=$('#msg_model').attr('data-id');
                    var selector = $('#msg_model ul.modal-content');//
                     if (selector.is(':visible')&& data_id==group_id) 
                      read_status='true';
                    else
                      read_status='false';
                    XMPP_refresh_date=datetime;
                break;
            case "Feedback":
                    read_status='true';
                    var d = new Date();
                    XMPP_refresh_date=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                break;
            default:
                  var d = new Date();
                  XMPP_refresh_date=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                  read_status='null';
                break;
  } 
  db.transaction(function(tx) {
      tx.executeSql("insert into message(multimedia,datetime,read_status,group_id,type,source,msg_id) values(?,?,?,?,?,?,?)",[""+multimedia+"",""+XMPP_refresh_date+"",""+read_status+"",""+group_id+"",""+type+"",""+source+"",null], function(tx, results){
        var id=results.insertId;
        //change status verified of sender by giving reply to his message
        if(lookup[group_id]["is_verified"]=='false' && type=='sent'){
          verifyUser(group_id);
        }
        //end    
        //render both message list-----------------------------------------------------------             
        refresh_renderList(id,multimedia,XMPP_refresh_date,read_status,group_id,type,source);
        refreshshowPopup(id,multimedia,XMPP_refresh_date,read_status,group_id,type,'null');       
        //end-----------------------------------------------------------------------------
      },errorCB);
  },errorCB)
}

function insert_record(multimedia,group_id,type,datetime,source){
  var XMPP_refresh_date;
  switch (type) {
            case "received":
                    var data_id=$('#msg_model').attr('data-id');
                    var selector = $('#msg_model ul.modal-content');//
                     if (selector.is(':visible')&& data_id==group_id) 
                      read_status='true';
                    else
                      read_status='false';
                    XMPP_refresh_date=datetime;
                break;
            case "Feedback":
                    read_status='true';
                    var d = new Date();
                    XMPP_refresh_date=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                break;
            default:
                  var d = new Date();
                  XMPP_refresh_date=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                  read_status='null';
                break;
  } 
  db.transaction(function(tx) {
      tx.executeSql("insert into message(multimedia,datetime,read_status,group_id,type,source,msg_id) values(?,?,?,?,?,?,?)",[""+multimedia+"",""+XMPP_refresh_date+"",""+read_status+"",""+group_id+"",""+type+"",""+source+"",null], function(tx, results){
        var id=results.insertId;
        //change status verified of sender by giving reply to his message
        if(lookup[group_id]["is_verified"]=='false' && type=='sent'){
          verifyUser(group_id);
        }
        //end    
        //render both message list-----------------------------------------------------------             
        refresh_renderList(id,multimedia,XMPP_refresh_date,read_status,group_id,type,source);
        refreshshowPopup(id,multimedia,XMPP_refresh_date,read_status,group_id,type,'null');       
        //end-----------------------------------------------------------------------------
      },errorCB);
  },errorCB)
}
function errorCB(err) {
    //console.log(': -'+arguments.callee.caller.name);
    log("SQL Error: "+err.message);
    if($('#loader_model').is(':visible'))
      $('#loader_model').closeModal();
    return;
}
function verifyUser(group_id){
  db.transaction(function(tx) {
    tx.executeSql("UPDATE groups SET is_verified='true' WHERE id='"+group_id+"' ",[]);
    lookup[group_id] ={displayName:getDetails(group_id,'displayName'),is_verified:'true'};
    $('#msg_model ul.modal-content').find('li.remove_li').hide('fast');
  },errorCB);
}    
function refresh(){
  console.log('refresh');
  if($('#touchloader #post').is(':visible')){
      $('#touchloader #post').hide();
  }
  if(strophe_con_state==false){
    reConnectXMPP();
    return;
  }
}
//for local db callback
function load_local_msg(){
      db.transaction(function(tx) {
           tx.executeSql("select a.id,a.multimedia,a.datetime,a.read_status,a.group_id,a.type,a.source from message a inner join (select group_id, max(datetime) as datetime from message group by group_id ORDER by datetime) as b on a.group_id = b.group_id and a.datetime = b.datetime",[],renderList,errorCB); 
      }, errorCB);
}
//for local db callback
function renderUnreadCount(group_id){
      db.transaction(function(tx) {
           tx.executeSql("select id from message where read_status='false' AND (type='received' OR type='Feedback') AND group_id=?",[group_id],function(tx, results){
            var count=results.rows.length;
            var inbox_li = $('ul#inbox_list li.'+group_id+'');//
            if(count>0){
              inbox_li.find('span.unread_count').html(count);
            }else{
              inbox_li.find('span.unread_count').html("");
            }
           },errorCB); 
      }, errorCB);
}
//single message list function      
function single_Popup(id) {
    $('#loader_model').openModal({dismissible: false,opacity: .3});
    db.transaction(function(tx) {
      // tx.executeSql("select id, multimedia, datetime,read_status,group_id,type,source,msg_id from message where group_id=? ORDER by datetime DESC LIMIT 21",[id],showPopup,errorCB);
      tx.executeSql("select id, multimedia, datetime,read_status,group_id,type,source,msg_id from message where group_id=? ORDER by id DESC LIMIT 21",[id],showPopup,errorCB);
    }, errorCB); 
}
//single message list function      
function single_search_Popup(id) {
    $('#loader_model').openModal({dismissible: false,opacity: .3});
    db.transaction(function(tx) {
      // tx.executeSql("select id, multimedia, datetime,read_status,group_id,type,source,msg_id from message where group_id=? ORDER by datetime DESC LIMIT 21",[id],showFromSearchPopup,errorCB);
      tx.executeSql("select id, multimedia, datetime,read_status,group_id,type,source,msg_id from message where group_id=? ORDER by id DESC LIMIT 21",[id],function(tx,results){
        var count=results.rows.length;
        log('single_search_Popup result: '+count);
        if(count>0){ // msg found for user
          showFromSearchPopup(tx,results);
        }else{
          showNoUserMsgPopup(id);
        }
      },errorCB);
    }, errorCB); 
}

// ganesh no msg user
//if no msg found in localdatabase
function showNoUserMsgPopup(mobile){
  console.log('single_search_Popup lookup: ',lookup[mobile]);
  var group_id=mobile;
  $('#msg_model ul.modal-content , #msg_model span.title').html('');
  $('#msg_model #options').hide();
  $('#msg_model #first_header').show();
  $('#msg_model #msg_text').val('');
  var ul=$('#msg_model ul.modal-content');
var source='website';
mobile_val[0] =group_id;

     //is sender verified by user
     if(lookup[group_id]["is_verified"]=='false'){
      ul.append('<li class="modal-content-msg left remove_li grey"><a onclick="verifyUser('+group_id+');" class="white waves-effect waves-light btn-flat left">Accept</a><a onclick="confirm_spam_model('+group_id+')" class="white waves-effect waves-light btn-flat right">Spam</a><a onclick="block_unblock('+group_id+')" class="white waves-effect waves-light btn-flat right">Block</a></li>');
     }   
      //$('#msg_model span.title , #photoCard_model span.title').html(title);
      $('#msg_model span.title').html(lookup[group_id]['displayName']);
      var img=getDetails(group_id,"photo");
      $('#msg_model img.dp').attr('src',img);
      $('#msg_model').attr({"data-id":group_id, "data-source":source});
      
      /*if($('ul#inbox_list > li#'+group_id+'').find('p.unread').hasClass('unread'))*/
      $('ul#inbox_list > li#'+group_id+'').find('p.unread').addClass('read').removeClass('unread');
            
      $('#msg_model').openModal();
      ul.linkify({handleLinks: function (links) {links.after(function (i) { $(this).attr('onClick','javascript:return openExternal(this)');return; });}});  
      $("#msg_model .modal-content-msg img").css('pointer-events', 'none');
      setTimeout(function(){
        ul.animate({scrollTop: ul[0].scrollHeight}, 500);
        $("#msg_model .modal-content-msg img").css('pointer-events', 'auto');
        $('#msg_model #msg_text').trigger("change");
        //$('#loader_model').closeModal();
       }, 600);
      ul.scrollTop(ul.prop("scrollHeight"));

  renderUnreadCount(group_id);
  $('#loader_model').closeModal();
}

// ganesh no msg userend

//load more message function
function loadMore(id) {
    
    db.transaction(function(tx) {
      tx.executeSql("select id, multimedia, datetime,read_status,group_id,type from message where group_id='"+id+"' AND datetime < Datetime('"+load_more_date+"') ORDER by datetime DESC LIMIT 21 ",[],function(tx, results){
        var count=results.rows.length;
        log("Load More:"+count+' refresh_date:'+load_more_date);
        for(var i=0; i<count; i++) {
          refreshshowPopup(results.rows.item(i).id,results.rows.item(i).multimedia,results.rows.item(i).datetime,results.rows.item(i).read_status,results.rows.item(i).group_id,results.rows.item(i).type,'loadMore');
        }
        var selector = $('#msg_model ul.modal-content>li.loadMorebtn');//
                 
        selector.remove();
        $('#msg_model ul.modal-content').find('li#'+results.rows.item(0).id+'').attr('tabindex', -1).focus();
                
        if(count>20){
          load_more_date=results.rows.item(count-1).datetime;
          $('#msg_model ul.modal-content').prepend('<li class="loadMorebtn center" style="padding-bottom:8px;" ><a onclick="loadMore('+results.rows.item(count-1).group_id+')" class="btn_blue waves-effect waves-light btn">Load earlier</a></li>');
        }
                  
      },errorCB);
    }, errorCB);
}
function updateRead_status(id,status){
    db.transaction(function(tx) {
      tx.executeSql("update message set read_status='"+status+"' where id="+id);
    }, errorCB);
}
function updateRead_status_group(type,group_id){
  var sql;
  if(type=="sent")
    sql="update message set read_status='true' where read_status='false' AND type='sent' AND group_id='"+group_id+"'";
  else
    sql="update message set read_status='true' where read_status='false' AND type!='sent' AND group_id='"+group_id+"'";

    db.transaction(function(tx) {
      tx.executeSql(sql);
    }, errorCB);
}
function delete_group_record(id){
    db.transaction(function(tx) {
      tx.executeSql("delete from message where group_id='"+id+"'");
    },errorCB,
        function(){
          $('#confirm_model').closeModal();
          $('ul#inbox_list li.'+id+'').slideUp("normal", function() { $(this).remove(); } );
        });
}
/********************End database functions******************************************/  

/***************render list,chatbox functions******************/       
function refresh_renderList(id,multimedia,datetime,read_status,group_id,type,source){
    renderUnreadCount(group_id);
    /*    multimedia="<p>"+multimedia+"</p>";*/
    if(($(multimedia).find('img:first').length) > 0)
      desc = 'Image';
    else if(type=='Feedback')
      desc = $(multimedia).find('label.que').text().substr(0,80);
/*    else if(($(multimedia).find('iframe:first').length) > 0)
      desc = 'Video';*/
    else
      desc =($($.parseHTML(multimedia)).text()).substr(0,80); 
          
      var display_date=displayDate(datetime);
      var inbox_li = $('ul#inbox_list li.'+group_id+'');//
      
      if(inbox_li.length>0){
        inbox_li.find('p.msg-text').html(desc+'<span class="right badge unread_count"></span>');
        inbox_li.find('p.secondary-content').html(display_date+' <i class=""></i> ');
        inbox_li.prependTo($("#inbox_list"));
      }else{
        var img=getDetails(group_id,"photo");
        var displayName=getDetails(group_id,"displayName");       
        $("ul#inbox_list").prepend('<li data-source="'+source+'" id='+group_id+' class="waves-effect collection-item avatar '+group_id+'"><a class="modal-trigger" id='+group_id+' href="#msg_model"><img src="'+img+'" alt="" id="dp" class="circle"><span class="title">'+displayName+'</span><p class="msg-text">'+desc+'<span class="right badge unread_count"></span></p><p class="secondary-content">'+display_date+' <i class=""></i></p></a></li>');
        inbox_li = $('ul#inbox_list li.'+group_id+'');//
      }
      
      if(type=='received'||type=='Feedback'){
        if(read_status=="true")
          inbox_li.find('p.secondary-content').addClass('read').removeClass('unread');
        else
          inbox_li.find('p.secondary-content').addClass('unread').removeClass('read');
      }else{
        inbox_li.find('p.secondary-content i').attr('class',getClass(read_status));
        inbox_li.find('p.secondary-content').addClass('read').removeClass('unread');
      }
      
}
function renderList(tx,results){
    var count=results.rows.length;
    log('Inbox: '+count);
    if (count == 0) {
      Materialize.toast('You do not have any messages.!', 4000);//$("ul#inbox_list").append('<li style="text-align:center;">You do not have any messages.</li>');
    }
    else {
      var dt=results.rows.item(count-1).datetime;
      if(loc_Storage.getItem("last_access_date") < dt && dt!='undefined')  
      loc_Storage.setItem("last_access_date",results.rows.item(count-1).datetime);
 
      for(var i=0; i<count; i++) {
          var html=results.rows.item(i).multimedia;
          if(html!=null){
            refresh_renderList(results.rows.item(i).id,results.rows.item(i).multimedia,results.rows.item(i).datetime,results.rows.item(i).read_status,results.rows.item(i).group_id,results.rows.item(i).type,results.rows.item(i).source) 
          }
      }
    }
    setTimeout(function(){$('#loader_model').closeModal(); }, 1000);
    //refresh();
}
function showPopup(tx,results){
    $('#msg_model ul.modal-content , #msg_model span.title').html('');
    $('#msg_model #options').hide();
    $('#msg_model #first_header').show();
    $('#msg_model #msg_text').val('');
    try{
    /*code to handle share from other app*/
         //CDV.WEBINTENT.getExtra(CDV.WEBINTENT.EXTRA_TEXT,
        window.plugins.webintent.getExtra(CDV.WEBINTENT.EXTRA_TEXT,  
            function(url) {
                //alert(url);// url is the value of EXTRA_TEXT
                $('#msg_model #msg_text').val(url);
            }, function() {
                console.log('There was no extra supplied.');
            }
          );
    /*End app share code from other app*/
    }catch(err){
        console.log(err.message);
    }
    $('#msg_model #msg_text').trigger("change");
    var unread_status=false;
    var ul=$('#msg_model ul.modal-content');
    mobile_val = [];
    var count=results.rows.length;
    log('showPopup: '+count);
    var group_id=results.rows.item(count-1).group_id;
    var title =getDetails(group_id,"displayName");
    for(var i=0; i<count; i++) {
      var id=results.rows.item(i).id;
      var html=results.rows.item(i).multimedia;
      if(($(html).find('img:first').attr("data-url")))
          html = '<a id="download_link_anchor_'+id+'" onclick="download_me('+id+',event);" class="mdi-file-file-download">'+html+'</a>';
      else if((($(html).is('audio')) || ($(html).is('video'))) && ($(html).attr("data-url")) )
      {
        console.log('check data-url: ',($(html).attr("data-url")));
      html = '<a id="download_link_anchor_'+id+'" onclick="download_me('+id+',event);" class="mdi-file-file-download">'+html+'</a>';
      }
console.log('multimedia html: ',html);

      var datetime=results.rows.item(i).datetime;
      var display_date=chatdisplayDate(datetime);
      var read_status=results.rows.item(i).read_status;
      var source=results.rows.item(i).source;
      mobile_val[0] =results.rows.item(i).group_id;
      var read_span;
      msg_type='right';

      if(read_status=='false'){
        /*This send msg read status*/

          var d = new Date();
          var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
          if(checkInternet() != Connection.NONE && strophe_con_state==true){
            console.log('admin6: ',group_id);
            var delivery_reply = $msg({to:group_id+'@sancharapp.com',from: jid,id:results.rows.item(i).msg_id,datetime: datetime,type: 'chat'}).c('body').t("Read");
            var message_extra={submit_datetime:datetime,type:'read'};
                      delivery_reply.up().c("message_extra").t(JSON.stringify(message_extra));
            xmpp_con.send(delivery_reply);
          }else{
            offlineDeliveryQueue({id:results.rows.item(i).msg_id,datetime:datetime,status:"Read"});
          }
        /***********************************************/
      }
      switch(results.rows.item(i).type) {
            case "received":
                    msg_type='left';
                    read_span='';
                break;
            case "Feedback":
                 msg_type='center';
                 read_span='';
                break;
            default:
                   if(read_status=="null" && checkInternet() != Connection.NONE && strophe_con_state==true){
                    var d = new Date();
                    var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
                    console.log('datetime: ',datetime);
                    var message_extra={datetime:datetime};
                    console.log('message_extra: ',message_extra);
                    var msg=$msg({to:group_id+'@sancharapp.com', type: 'chat',id: id,datetime:datetime}).c('body').t(html);
                    msg.up().c("message_extra").t(JSON.stringify(message_extra));                    
                    xmpp_con.send(msg);
                    updateRead_status(id,'');
                    read_status='';
                    var inbox_li = $('ul#inbox_list li.'+group_id+'');//
                    inbox_li.find('p.secondary-content i').attr('class','mdi-action-done');
                  }        
                  read_span='<span class="right read_status"><i class="'+getClass(read_status)+'"></i></span>';
                break;
      }//end switch  
      var view=
                 '<li id='+id+' class="modal-content-msg '+msg_type+'">'+
                 '<span class="checkbox_align"><input value="'+id+'" onclick="update_SelectMsgcount(this);" name="selector[]" type="checkbox" id="check_'+id+'"/><label for="check_'+id+'"></label></span>'+
                 '<i class="mdi-navigation-arrow-drop-down '+msg_type+' '+msg_type+'_side_arrow"></i>'+
                 //'<span class="common sender-name"><b>'+title+'</b></span>'+
                 '<span class="common sender-masg">'+html+'</span>'+
                 '<span class="common sender-time">'+display_date+''+read_span+'</span>'+
                 '</li>';

        ul.prepend(view);
        load_more_date=datetime; 
    }//end lopp

    updateRead_status_group('received',group_id);
    if(count>20)
      ul.prepend('<li class="loadMorebtn center" style="padding-bottom:8px;" ><a onclick="loadMore('+group_id+')" class="btn_blue waves-effect waves-light btn">Load earlier</a></li>');
   
     //is sender verified by user
     if(lookup[group_id]["is_verified"]=='false'){
      ul.append('<li class="modal-content-msg left remove_li grey"><a onclick="verifyUser('+group_id+');" class="white waves-effect waves-light btn-flat left">Accept</a><a onclick="confirm_spam_model('+group_id+')" class="white waves-effect waves-light btn-flat right">Spam</a><a onclick="block_unblock('+group_id+')" class="white waves-effect waves-light btn-flat right">Block</a></li>');
     }   
      //$('#msg_model span.title , #photoCard_model span.title').html(title);
      $('#msg_model span.title').html(title);
      var img=getDetails(group_id,"photo");
      $('#msg_model img.dp').attr('src',img);
      $('#msg_model').attr({"data-id":group_id, "data-source":source});
      
      /*if($('ul#inbox_list > li#'+group_id+'').find('p.unread').hasClass('unread'))*/
      $('ul#inbox_list > li#'+group_id+'').find('p.unread').addClass('read').removeClass('unread');
            
      $('#msg_model').openModal();
      ul.linkify({handleLinks: function (links) {links.after(function (i) { $(this).attr('onClick','javascript:return openExternal(this)');return; });}});  
      $("#msg_model .modal-content-msg img").css('pointer-events', 'none');
      setTimeout(function(){
        ul.animate({scrollTop: ul[0].scrollHeight}, 500);
        $("#msg_model .modal-content-msg img").css('pointer-events', 'auto');
        $('#msg_model #msg_text').trigger("change");
        //$('#loader_model').closeModal();
       }, 600);
      ul.scrollTop(ul.prop("scrollHeight"));

  renderUnreadCount(group_id);
  $('#loader_model').closeModal();
};


//to search and send msg to company users
function showFromSearchPopup(tx,results){
    $('#msg_model ul.modal-content , #msg_model span.title').html('');
    $('#msg_model #options').hide();
    $('#msg_model #first_header').show();
    $('#msg_model #msg_text').val('');
    try{
    /*code to handle share from other app*/
         //CDV.WEBINTENT.getExtra(CDV.WEBINTENT.EXTRA_TEXT,
        window.plugins.webintent.getExtra(CDV.WEBINTENT.EXTRA_TEXT,  
            function(url) {
                //alert(url);// url is the value of EXTRA_TEXT
                $('#msg_model #msg_text').val(url);
            }, function() {
                console.log('There was no extra supplied.');
            }
          );
    /*End app share code from other app*/
    }catch(err){
        console.log(err.message);
    }
    $('#msg_model #msg_text').trigger("change");
    var unread_status=false;
    var ul=$('#msg_model ul.modal-content');
    mobile_val = [];
    var count=results.rows.length;
    log('showFromSearchPopup: '+count);
    if(count>0){ //no msg found for user
   
    var group_id=results.rows.item(count-1).group_id;
    var title =getDetails(group_id,"displayName");
    for(var i=0; i<count; i++) {
      var id=results.rows.item(i).id;
      var html=results.rows.item(i).multimedia;
      if(($(html).find('img:first').attr("data-url")))
          html = '<a id="download_link_anchor_'+id+'" onclick="download_me('+id+',event);" class="mdi-file-file-download">'+html+'</a>';
      else if((($(html).is('audio')) || ($(html).is('video'))) && ($(html).attr("data-url")) )
      {
        console.log('check data-url: ',($(html).attr("data-url")));
      html = '<a id="download_link_anchor_'+id+'" onclick="download_me('+id+',event);" class="mdi-file-file-download">'+html+'</a>';
      }
console.log('multimedia html: ',html);

      var datetime=results.rows.item(i).datetime;
      var display_date=chatdisplayDate(datetime);
      var read_status=results.rows.item(i).read_status;
      var source=results.rows.item(i).source;
      mobile_val[0] =results.rows.item(i).group_id;
      var read_span;
      msg_type='right';

      if(read_status=='false'){
        /*This send msg read status*/

          var d = new Date();
          var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
          if(checkInternet() != Connection.NONE && strophe_con_state==true){
            console.log('admin1: ',group_id);
            var delivery_reply = $msg({to:group_id+'@sancharapp.com',from: jid,id:results.rows.item(i).msg_id,datetime: datetime,type: 'chat'}).c('body').t("Read");
            var message_extra={submit_datetime:datetime};
                      delivery_reply.up().c("message_extra").t(JSON.stringify(message_extra));
            xmpp_con.send(delivery_reply);
          }else{
            offlineDeliveryQueue({id:results.rows.item(i).msg_id,datetime:datetime,status:"Read"});
          }
        /***********************************************/
      }
      switch(results.rows.item(i).type) {
            case "received":
                    msg_type='left';
                    read_span='';
                break;
            case "Feedback":
                 msg_type='center';
                 read_span='';
                break;
            default:
                   if(read_status=="null" && checkInternet() != Connection.NONE && strophe_con_state==true){
                    var d = new Date();
                    var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);

                    var msg=$msg({to:group_id+'@sancharapp.com', type: 'chat',id: id,datetime:datetime}).c('body').t(html);
                    xmpp_con.send(msg);
                    updateRead_status(id,'');
                    read_status='';
                    var inbox_li = $('ul#inbox_list li.'+group_id+'');//
                    inbox_li.find('p.secondary-content i').attr('class','mdi-action-done');
                  }        
                  read_span='<span class="right read_status"><i class="'+getClass(read_status)+'"></i></span>';
                break;
      }//end switch  
      var view=
                 '<li id='+id+' class="modal-content-msg '+msg_type+'">'+
                 '<span class="checkbox_align"><input value="'+id+'" onclick="update_SelectMsgcount(this);" name="selector[]" type="checkbox" id="check_'+id+'"/><label for="check_'+id+'"></label></span>'+
                 '<i class="mdi-navigation-arrow-drop-down '+msg_type+' '+msg_type+'_side_arrow"></i>'+
                 //'<span class="common sender-name"><b>'+title+'</b></span>'+
                 '<span class="common sender-masg">'+html+'</span>'+
                 '<span class="common sender-time">'+display_date+''+read_span+'</span>'+
                 '</li>';

        ul.prepend(view);
        load_more_date=datetime; 
    }//end lopp

    updateRead_status_group('received',group_id);
    if(count>20)
      ul.prepend('<li class="loadMorebtn center" style="padding-bottom:8px;" ><a onclick="loadMore('+group_id+')" class="btn_blue waves-effect waves-light btn">Load earlier</a></li>');
   
     //is sender verified by user
     if(lookup[group_id]["is_verified"]=='false'){
      ul.append('<li class="modal-content-msg left remove_li grey"><a onclick="verifyUser('+group_id+');" class="white waves-effect waves-light btn-flat left">Accept</a><a onclick="confirm_spam_model('+group_id+')" class="white waves-effect waves-light btn-flat right">Spam</a><a onclick="block_unblock('+group_id+')" class="white waves-effect waves-light btn-flat right">Block</a></li>');
     }   
      //$('#msg_model span.title , #photoCard_model span.title').html(title);
      $('#msg_model span.title').html(title);
      var img=getDetails(group_id,"photo");
      $('#msg_model img.dp').attr('src',img);
      $('#msg_model').attr({"data-id":group_id, "data-source":source});
      
      /*if($('ul#inbox_list > li#'+group_id+'').find('p.unread').hasClass('unread'))*/
      $('ul#inbox_list > li#'+group_id+'').find('p.unread').addClass('read').removeClass('unread');
            
      $('#msg_model').openModal();
      ul.linkify({handleLinks: function (links) {links.after(function (i) { $(this).attr('onClick','javascript:return openExternal(this)');return; });}});  
      $("#msg_model .modal-content-msg img").css('pointer-events', 'none');
      setTimeout(function(){
        ul.animate({scrollTop: ul[0].scrollHeight}, 500);
        $("#msg_model .modal-content-msg img").css('pointer-events', 'auto');
        $('#msg_model #msg_text').trigger("change");
        //$('#loader_model').closeModal();
       }, 600);
      ul.scrollTop(ul.prop("scrollHeight"));

  renderUnreadCount(group_id);
  $('#loader_model').closeModal();
}
else{

  db.transaction(function(tx) {
    // tx.executeSql("select id, multimedia, datetime,read_status,group_id,type,source,msg_id from message where group_id=? ORDER by datetime DESC LIMIT 21",[id],showPopup,errorCB);
    tx.executeSql("select id, multimedia, datetime,read_status,group_id,type,source,msg_id from message where group_id=? ORDER by id DESC LIMIT 21",[id],showFromSearchPopup,errorCB);
  }, errorCB); 

  var group_id=results.rows.item(count-1).group_id;
  var title =getDetails(group_id,"displayName");

  $('#msg_model').openModal();
  $('#loader_model').closeModal();

}
};


function download_me(id,event){
      event.stopImmediatePropagation();
      console.log('download_me');
      var selecter=$('#msg_model ul.modal-content li#'+id+'');
      var download_link=selecter.find('img').attr('data-url');
      if(download_link)
      downloadImage(download_link,id); //to download image
      else{
      console.log('downloadFile');
      if(selecter.find('audio').attr('data-url'))
      {
        download_link=selecter.find('audio').attr('data-url');
        // console.log('download_link: ',download_link);
        downloadFile(download_link,id,'audio'); //ganesh to download mp3 /video

      }else{
        download_link=selecter.find('video').attr('data-url');
        downloadFile(download_link,id,'video'); //ganesh to download mp3 /video

      }
      }


}
//to send msg
function refreshshowPopup(id,multimedia,datetime,read_status,group_id,type,source_function){
    var data_id=$('#msg_model').attr('data-id');
    var selector = $('#msg_model ul.modal-content');//
    if(type=='sent'){
      if(read_status=="null" && checkInternet() != Connection.NONE && strophe_con_state==true){
          var d = new Date();
          var datetime=d.toJSON().slice(0,10) +' '+d.toTimeString().slice(0,9);
          console.log('multimedia msg: ',multimedia);
          var imageURI=$(multimedia).find('img:first').attr('src');          
          console.log('imageURI: ',imageURI);
          console.log('group_id:',group_id);
          console.log('multimedia:',multimedia);
             if(imageURI)
             {
              //  upload file
              var url= siteurl+"/api/uploadfiles?subscriber_id="+subscriber_id;
              var options = new FileUploadOptions();
              options.fileKey = "file";
              console.log('imageURI: ',imageURI);
              options.fileName = imageURI.substr(imageURI.lastIndexOf('/') + 1);
              options.mimeType = "image/jpeg";
              console.log(options.fileName);
              var params = new Object();
              params.value1 = "test";
              params.value2 = "param";
              options.params = params;
              options.chunkedMode = false;
             console.log('imageURI: ',imageURI);
             var ft = new FileTransfer();
              ft.upload(imageURI,url, function(result){
              console.log((result));  
              try {
             var response=JSON.parse(result.response);
              console.log(response);  
              // console.log(JSON.parse(result.response));  
              console.log('real_path: ',response.real_path);
              // var server_path=
              var tosendfile='<img class="responsive-img" src="'+response.real_path+'">'; //server path
              console.log('datetime: ',datetime);
              var msg=$msg({to:group_id+'@sancharapp.com', type: 'chat',id: id,datetime:datetime}).c('body').t(tosendfile);
              var message_extra={submit_datetime:datetime};
              msg.up().c("message_extra").t(JSON.stringify(message_extra));//to send extra parameters
              xmpp_con.send(msg);
              updateRead_status(id,'');
              read_status='';
              var inbox_li = $('ul#inbox_list li.'+group_id+'');//
              inbox_li.find('p.secondary-content i').attr('class','mdi-action-done');
              } catch (error) {
                console.log('some error; ',error);
              }
              }, function(error){
              console.log(JSON.stringify(error));
              }, options);
             }else{
//ganesh send plain mesg
console.log('datetime: ',datetime);
                    var message_extra={submit_datetime:datetime};
                    console.log('message_extra1: ',message_extra);
var msg=$msg({to:group_id+'@sancharapp.com', type: 'chat',id: id,datetime:datetime}).c('body').t(multimedia);
msg.up().c("message_extra").t(JSON.stringify(message_extra));
console.log('msg to send: ',msg);
xmpp_con.send(msg);
updateRead_status(id,'');
read_status='';
var inbox_li = $('ul#inbox_list li.'+group_id+'');//
inbox_li.find('p.secondary-content i').attr('class','mdi-action-done');
             }      
          
      }
    } 
    if (selector.is(':visible')&& data_id==group_id){
        var display_date=chatdisplayDate(datetime);        
        
        switch (type) {
            case "received":
                 msg_type='left';
                 read_span='';
                break;
            case "Feedback":
                 msg_type='center';
                 read_span='';
                break;
            default:
                msg_type='right';
                read_span='<span class="right read_status"><i class="'+getClass(read_status)+'"></i></span>';
                break;
        } 
        if(($(multimedia).find('img:first').attr("data-url")))
          multimedia = '<a id="download_link_anchor_'+id+'" onclick="download_me('+id+',event);" class="mdi-file-file-download">'+multimedia+'</a>';
        else if(($(multimedia).is('audio')) || ($(multimedia).is('video')))
        {
          multimedia = '<a id="download_link_anchor_'+id+'" onclick="download_me('+id+',event);" class="mdi-file-file-download">'+multimedia+'</a>';
        }
console.log('multimedia: ',multimedia);
        var view='<li id='+id+' class="modal-content-msg '+msg_type+'">'+
         '<span class="checkbox_align"><input value="'+id+'" onclick="update_SelectMsgcount(this);" name="selector[]" type="checkbox" id="check_'+id+'"/><label for="check_'+id+'"></label></span>'+
                 '<i class="mdi-navigation-arrow-drop-down '+msg_type+' '+msg_type+'_side_arrow"></i>'+
                 //'<span class="common sender-name"><b>'+title+'</b></span>'+
                 '<span class="common sender-masg">'+multimedia+'</span>'+
                 '<span class="common sender-time">'+display_date+''+read_span+'</span>'+
                 '</li>';

        if(source_function=='loadMore'){
          selector.prepend(view);
        }else{
          selector.append(view);
          selector.animate({scrollTop: selector[0].scrollHeight},1500);
        }
        var remove_li=selector.find("li.remove_li");
        if(remove_li.length>0)
          $(remove_li).appendTo(selector);
        
     $('#msg_model ul.modal-content').linkify({handleLinks: function (links) {links.after(function (i) { $(this).attr('onClick','javascript:return openExternal(this)');return; });}});       
    }         
};   
/***********End rebder,chatbox functions*******************************/       
// Create Base64 Object
var Base64={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",encode:function(e){var t="";var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},decode:function(e){var t="";var n,r,i;var s,o,u,a;var f=0;e=e.replace(/[^A-Za-z0-9\+\/\=]/g,"");while(f<e.length){s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64){t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}}t=Base64._utf8_decode(t);return t},_utf8_encode:function(e){e=e.replace(/\r\n/g,"\n");var t="";for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048){t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},_utf8_decode:function(e){var t="";var n=0;var r=c1=c2=0;while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);n++}else if(r>191&&r<224){c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}else{c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}return t}}



// new js changes ganesh
function companyUsers(str) {
  if(showResult_timer) clearTimeout(showResult_timer);
  if (str.length==0) {
    return;
  }
  console.log(str);
  showResult_timer = setTimeout(function(){
      // Cancel the last request if valid
      if(showResult_XHR) showResult_XHR.abort();
      $('#loader_model').openModal({dismissible: false,opacity: .3});
        showResult_XHR = $.ajax({
        url: siteurl+"/msg-api/companyUsers",
        type:'post',
        data:{mobile:str,subscriber_id:subscriber_id},
        beforeSend:function(){

        },
        success:function(response){
         console.log(response);
         $("#search_modal #search_list").html("");
          var count1=response.result.length;
          //console.log(count);
          var html='<li class="collection-header"><h6>search result ('+count1+') for "'+str+'"</h6></li>';
          if(count1){
              for (var i = 0; i < count1; i++) {
                // if(response.result[i]['status']==false){
                //   html+= '<li class="avatar collection-item"><img src="'+getDetails(response[i]['data']['mg_id'],"photo")+'" alt="" class="circle"><span class="title">'+response[i]['data']['senderID']+'</span> <p>'+response[i]['data']['joint_handle']+'</p><a onClick="follow(this,'+response[i]['data']['mg_id']+')" href="#!" class="follow joint waves-effect secondary-content"></a></li>';
                // }
                // else{
                //     html+= '<li class="avatar collection-item"><img src="'+getDetails(response[i]['data']['mg_id'],"photo")+'" alt="" class="circle"><span class="title">'+response[i]['data']['senderID']+'</span> <p>'+response[i]['data']['joint_handle']+'</p><a onClick="unfollow(this,'+response[i]['data']['mg_id']+')" href="#!" class="unfollow joint waves-effect secondary-content"></a></li>';
                // }

                // html+= '<li class="avatar collection-item"><span class="title">'+response.result[i]['name']+'</span> <p>'+response.result[i]['mobile']+'</p><a onClick="follow(this,'+response.result[i]['jid']+')" href="#!" class="follow joint waves-effect secondary-content"></a></li>';
                html+= '<li class="avatar  collection-item searchCompanyUser" id="'+response.result[i]['mobile']+'" data-info=\''+JSON.stringify(response.result[i])+'\'><span class="title">'+response.result[i]['name']+'</span><a  id="'+response.result[i]['mobile']+'" href="#msg_model" class="  follow modal-trigger joint waves-effect secondary-content"> <p>'+response.result[i]['mobile']+'</p></a></li>';
{/* <a ><img src="http://sancharapp.com/profile/0.jpg?1529308919" alt="" id="dp" class="circle"><span class="title">linkapp</span><p class="msg-text">Your welcome messagefsdgfdg<span class="right badge unread_count"></span></p><p class="secondary-content read">2:34pm <i class=""></i> </p></a> */}
              };
          }
          $("#search_modal #search_list").html(html);
          /*code to fetch data from local db app*/
            db.transaction(function(tx) {
              tx.executeSql("select id,displayName from groups where displayName LIKE '%"+str+"%' OR id LIKE '%"+str+"%' ",[],function(tx,results){
                    var count=results.rows.length;
                    var li='';
                    for(var i=0; i<count; i++) {
                      var id=results.rows.item(i).id;
                      var displayName=results.rows.item(i).displayName;
                      li+= '<li class="avatar collection-item"><img src="'+getDetails(id,"photo")+'" alt="" class="circle"><span class="title">'+displayName+'</span><a onClick="single_Popup(&#39;'+id.trim()+'&#39;)" href="#!" class="waves-effect btn secondary-content"><i class="mdi-action-launch"></i></a></li>';
                    $("#search_modal #search_list .collection-header").after(li);
                       
                    }//end loop
                    $("#search_modal #search_list .collection-header").after(li);
                    //console.log(lookup);
              } ,errorCB);
             },errorCB,successHandler);
            /*End code to fetch data from local db app*/
          $('#loader_model').closeModal();
        },
        error:function(response){
          console.log('error ',response.error);
        }
      });
  }, 500);// wait for quarter second.    
}

//ganesh select image
function upload_send(){
  console.log('ok');
   navigator.camera.getPicture(function(f) {
  console.log('orifginal: ',f);
  var newHtml = "<img style='width:70%;height:100px;' src='"+f+"'>"; 
      try{
        $("#image_modal_send").openModal();
      $('#image_modal_send #image_modal_send_demoupload').html(newHtml);
  window.FilePath.resolveNativePath(f, successCallback, errorCallback);

      // $('#image_modal_send #image_modal_send_imagebase64').val(f);
        $('.thumb').hide();
      }
      catch(err){
        alert('error2: '+err.message);
      }

   }, function(e) {
       alert("Error, check console.");
       console.dir(e);
   }, { 
       quality: 50,
       sourceType: Camera.PictureSourceType.PHOTOLIBRARY,
       destinationType: Camera.DestinationType.FILE_URI,        
   });

}

function upload_image_modal_send(){
  var to=$('#msg_model').data('id');
  var imageURI=$('#image_modal_send #image_modal_send_imagebase64').val();
  var message='<p><img class="responsive-img" src="'+imageURI+'"></p>';
  insert_record(message,to,'sent',null,'website');

  $('#image_modal_send').closeModal();

  // $('#loader_model').openModal();
//  var url= siteurl+"/api/uploadfiles?subscriber_id="+subscriber_id;

//     var options = new FileUploadOptions();
//     options.fileKey = "file";
//     options.fileName = imageURI.substr(imageURI.lastIndexOf('/') + 1);
//     options.mimeType = "image/jpeg";
//     console.log(options.fileName);
//     var params = new Object();
//     params.value1 = "test";
//     params.value2 = "param";
//     options.params = params;
//     options.chunkedMode = false;
//    console.log('imageURI: ',imageURI);
//    var ft = new FileTransfer();
//     ft.upload(imageURI,url, function(result){
//     console.log((result));  
//     try {
//     console.log((result.response));  
//     console.log(JSON.parse(result.response));  
      
//     } catch (error) {
//       console.log('some error; ',error);
//     }
//     }, function(error){
//     console.log(JSON.stringify(error));
//     }, options);
  

//   setTimeout(function(){
//     $uploadCrop.croppie('result', {
//       type: 'canvas',
//       size: 'viewport'
//     }).then(function (resp) {

//     $('#upload_image_modal_send_slide-profile #image_modal_send_imagebase64').val(resp);
// console.log('upload_image_modal_send_slide-profile: ',$('#upload_image_modal_send_slide-profile #upload_image_modal_send_myform').serializeArray());
//     // $.ajax({
//     // type:'POST',
//     // url:siteurl+"/api/uploadprofile2?subscriber_id="+subscriber_id,
//     // data:$('#upload_image_modal_send_slide-profile #upload_image_modal_send_myform').serializeArray(),
//     // dataType:'json',
//     // contentType:'application/x-www-form-urlencoded;charset=UTF-8',
//     // cache:false,
//     // success:function(response)
//     // {
//     //   if(response.status!='false')
//     //   {
//     //     var string = Math.random().toString(36).substring(12);
//     //     var imageURI=response;
//     //     var largeImage= $('#profile-img img#default-img');
//     //     largeImage.attr("src",imageURI+"?lastmod="+string);
//     //     var user_details=JSON.parse(localStorage.getItem("user_details"));
//     //     user_details['profile_image']= imageURI;
//     //     localStorage.setItem("user_details", JSON.stringify(user_details));
//     //     Materialize.toast("Successfully uploaded", 2000);
//     //     $("#image_modal").closeModal();
//     //     $('#loader_model').closeModal();
//     //   }
//     // },
//     // error:function(xhr, status, error)
//     // {
//     //   $('#loader_model').closeModal();
//     //   alert(xhr);
//     //   alert(status);
//     // }
//     // });
//     });
// },100);
}


function successCallback(entry) {
  console.log('successCallback:',entry);
$('#image_modal_send #image_modal_send_imagebase64').val(entry);
}

function errorCallback(error) {
  alert(JSON.stringify(error));
  console.log(error);
}

