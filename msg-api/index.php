
<?php
header('Access-Control-Allow-Origin: *'); 
error_reporting(E_ALL);
ini_set('display_errors', 1);
date_default_timezone_set('Asia/Calcutta');
use Phalcon\Http\Response,
    Phalcon\Http\Request,
    Phalcon\Mvc\Micro,
    Phalcon\Db\Column,
    Phalcon\Mvc\Model\Validator\Uniqueness as Uniqueness;

define("profile_image", "http://www.sancharapp.com/linkappprofile/", true);                   
$app = new Micro();

// Use Loader() to autoload our model
$loader = new \Phalcon\Loader();

$loader->registerDirs(array(
    __DIR__ . '/models/'
))->register();

$di = new \Phalcon\DI\FactoryDefault();

//Set up the database service
// $di->set('db', function(){
//     return new \Phalcon\Db\Adapter\Pdo\Mysql(array(
//         "host" => "localhost",
//         "username" => "sanchar_app" ,
//         "password" => "nbMbRaSwAN6C8vQb",
//         "dbname" => "sanchr5m_messaging_db",
//     ));
// });

$di->set('db', function() {
	$dbclass = 'Phalcon\Db\Adapter\Pdo\\Mysql';
	return new $dbclass(array(
        "host" => "localhost",
        "username" => "sanchar_app" ,
        "password" => "nbMbRaSwAN6C8vQb",
        "dbname" => "sanchr5m_messaging_db",
	));
});


$di->set('config', function() {
    return new \Phalcon\Config\Adapter\Ini("./config/config.ini");
});

//Create and bind the DI to the application
$app = new \Phalcon\Mvc\Micro($di);

//set error handler
set_error_handler("customError");
/*******************************************All URL************************************************************/

//Adds register Contact
$app->get('/subscriber/register', function () {

});
//edit subscriber
$app->get('/subscriber/edit', function () {

});
//Validate Contact
$app->get('/subscriber/validate', function () {

});

//companyUsers Contact
$app->get('/companyUsers', function () {

});

//makeDelivery to app user
$app->get('/makeDelivery', function () {

});

//Add Feedback
$app->get('/group/permission', function() {

});

$app->get('/web_register', function() {

});

$app->get('/webappuser_register', function() {

});

//send message
$app->post('/send_msg', function() {

});
//send message
$app->post('/joint_send', function() {

});
//send excel message
$app->get('/send_excel_msg', function() {

});
//get message queue
$app->get('/messages', function() {

});
$app->get('/xmpp_delivery', function() {

});
/*$app->get('/get_failed_messages', function() {

});*/
$app->post('/sortMobile_Numbers', function() {

});
/*Param Subscriber id array use for joint*/
$app->post('/getMobile_Numbers', function() {

});
$app->post('/getContacts', function() {

});
$app->get('/test', function () use ($app) {  
  //$msg_id=$app->request->get('msg_id');
  //file_put_contents("msg_api_log.txt", "\n".$msg_id,FILE_APPEND);
});
$app->get('/update_GCM_ID', function() {

});
//get Blocklist
$app->get('/getBlocklist', function() {

});
$app->get('/update_NotificationStatus', function() {

});
//send feedback
$app->post('/send_feedback', function() {

});
$app->get('/reportspam', function() {

});
//get SpamList
$app->get('/getSpamList', function() {

});
$app->post('/getSubsciberByPincode', function() {

});
$app->post('/resendOTP', function() {

});
$app->get('/uploadprofile', function() {

});
$app->get('/checkServerMessage', function() {

});
/*******************************************End All URL************************************************************/
function customError($errno, $errstr,$errfile,$errline) {
  file_put_contents("../public/msg_api_log.txt", "\n"."Error:[$errno] $errstr $errfile $errline",FILE_APPEND);
  //echo "<b>Error:</b> [$errno] $errstr";
}
/*******************************************Main Function************************************************************/
  function curl_redirect($url,$param){
    global $app;
    $ch = curl_init();
    // echo $app->config->site->url.$url;exit;
    curl_setopt($ch, CURLOPT_URL,$app->config->site->url.$url.'?'.$param); 
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);   
    $response = curl_exec($ch);
    curl_close($ch);
    return $response;
  }

$app->get('/gcmdelivery', function() use($app){
  $msg_id=$app->request->get('msg_id');
  file_put_contents("msg_api_log.txt", "\n".$msg_id,FILE_APPEND);
  $sql = "UPDATE `message` SET `done_datetime` ='".date("Y-m-d H:i:s")."',`status` = 'Delivered'  WHERE msg_id ='".$msg_id."' AND status <>'Read'";
  $app->db->query($sql);
  $sql3="SELECT `src_msg_id` as id,`status` FROM `message` WHERE `msg_id`='".$msg_id."'";
          //echo $sql3;
  $result=$app->db->query($sql3);
  $result->setFetchMode(Phalcon\Db::FETCH_ASSOC);
  $result=$result->fetchAll();
  forward('linkapp',json_encode($result));//send back to website update status
});
/*******************************************Message queue Function************************************************************/
$app->get('/messages', function() use($app){
     $response = new Response(); 
     //include("./cryptojs-aes.php");
     $subscriber_id=$app->request->get('subscriber_id','int');
     $last_access_date=base64_decode($app->request->get('last_access_date'));
     /*$last_access_date=date("Y-m-d H:i:s", $last_access_date/1000);*/
    if (!$subscriber_id) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }

    $message =new Messages(); 
    $result=$message->getData($subscriber_id,$last_access_date);
    $subscriber = Subscriber::findFirst($subscriber_id);
    if($subscriber){
      $subscriber->last_date_access=date("Y-m-d H:i:s");
      $subscriber->save();
    }
    //echo json_encode($result);
    echo json_encode($result);
    //echo cryptoJsAesEncrypt(json_encode($result),"Wg.12345");
});
/*******************************************End Message queue Function************************************************************/
/*******************************************Blocklist Function************************************************************/
$app->get('/getBlocklist', function() use($app){
     $response = new Response(); 
     $subscriber_id=$app->request->get('subscriber_id','int');
    
     $permiss =new Permissions(); 
     $result=$permiss->getBlocklist($subscriber_id);
     return $result;
});
/*******************************************End Blocklist Function************************************************************/
/*******************************************uploadprofile Function************************************************************/
$app->get('/uploadprofile', function() use($app){
      $response = new Response(); 
      $subscriber_id=$app->request->get('subscriber_id','int');
      $image_name=$app->request->get('image_name');
      $subscriber = Subscriber::findFirst($subscriber_id);
      if($subscriber){
        $subscriber->profile_image=$image_name;
        if ($subscriber->update()) { 
            $response->setJsonContent(profile_image.$image_name.'?lastmod='.uniqid());
            return $response;
            exit();
        }
      }
      $response->setJsonContent(array('status' => 'false'));
      return $response;
});
/*******************************************End uploadprofile Function************************************************************/
/*******************************************SpamList Function************************************************************/
$app->get('/getSpamList', function() use($app){
     $spam =new Spam(); 
     $result=$spam->getSpamList();
     return $result;
});
/*******************************************End SpamList Function************************************************************/
/*******************************************Subscriber List Pincode Function************************************************************/
$app->post('/getSubsciberByPincode', function() use($app){
     //$pincode=$app->request->get('pincode');
     $pincode=$app->request->getPost('pincode');
     $subscriber =new Subscriber(); 
     $result=$subscriber->getSubsciberByPincode($pincode);
     return $result;
});

$app->get('/webappuser_register', function() use($app){
  // try{
    // echo $type;
  $response = new Response();
  $type=$app->request->get('type');
  $mobile=$app->request->get('mobile');
  $domain='';
  if($type=="LinkApp")
  $domain='sancharapp.com';
  $j_pass=substr(uniqid(),0,10);
  $MGroups=new MGroups();
    $MGroups->type=$type;
    $MGroups->priority='priority';
    $MGroups->save();
   $param="mobile=$mobile&j_pass=$j_pass&domain=$domain";
    // print_r($param);
  $result=curl_redirect('/msg-api/JAXL/register.php',$param);
  if($result=='success'){
  $response->setStatusCode(201,"success");
  $response->setJsonContent(array('status' => 'success','result'=>array("mg_id"=>$MGroups->id, "jid"=>$mobile.'@'.$domain, "j_pass"=>$j_pass)));
  return $response;
}else{
        $response->setJsonContent(array('status2' => 'error', 'messages' => "Not registered"));
        return $response;
        exit();
    }
//   }catch(Exception $e){
//                  echo '<pre>';print_r($e->getMessage());exit;
//             }
});
/*******************************************End Subscriber List Pincode  Function************************************************************/
$app->get('/web_register', function() use($app){
    $response = new Response();
     // print_r($_REQUEST);
    // return $_REQUEST;exit;
    $type=$app->request->get('type');
    $name=$app->request->get('name');
    $pincode=$app->request->get('pincode');
    $mobile=$app->request->get('mobile');
    $domain='';
    if($type=="LinkApp")
      $domain='sancharapp.com';
    $j_pass=substr(uniqid(),0,10);
    $MGroups=new MGroups();
    $MGroups->type=$type;
    $MGroups->priority='priority';
    $MGroups->save();
    $param="mobile=$mobile&j_pass=$j_pass&domain=$domain";
    // $param="mobile=$MGroups->id&j_pass=$j_pass&domain=$domain";
    // echo $param;exit;
    $result=curl_redirect('/msg-api/JAXL/register.php',$param);
     // print_r($result);exit;
    // return $result;exit;
    if($result=='success'){
        $subscriber=new Subscriber();
        // Get Phalcon\Mvc\Model\Metadata instance
        // echo '<pre>';
        // $metadata = $subscriber->getModelsMetaData();
        // print_r($metadata);
        // // Get subscribers fields names
        // $attributes = $metadata->getAttributes($subscriber);
        // print_r($attributes);
        // // Get subscribers fields data types
        // $dataTypes = $metadata->getDataTypes($subscriber);
        // print_r($dataTypes);
        // exit();
        // $subscriber->setStatus("Web");
        $subscriber->name=$name;
        $subscriber->app_type="Web";
        $subscriber->ustatus="Verified";
        $subscriber->mg_id=$MGroups->id;
        $subscriber->jid=$mobile.'@'.$domain;
        // $subscriber->jid=$MGroups->id.'@'.$domain;
        $subscriber->j_pass=$j_pass;
        $subscriber->type=$type; 

        $subscriber->mobile=$mobile;
        $subscriber->pincode_home=$pincode;
        $subscriber->pincode_work=null;
        $subscriber->reg_id=null;
        $subscriber->security_code=null;
        $subscriber->default_mg_id=null;
        $subscriber->last_date_access=null;
        $subscriber->notification_status=null;
        // print_r($pincode);exit;
        if($subscriber->save() == false){
          $errors = array();
          foreach ($subscriber->getMessages() as $message) {
            $errors[] = $message->getMessage();
          }
          $response->setStatusCode(200, "invalid");
          $response->setJsonContent(array('status' => 'error', 'messages' => $errors));
        }else {  
        $response->setStatusCode(201,"success");
        $response->setJsonContent(array('status' => 'success','result'=>array("mg_id"=>$subscriber->mg_id, "jid"=>$subscriber->jid, "j_pass"=>$subscriber->j_pass))); 

        }
    return $response;
    }else{
        $response->setJsonContent(array('status2' => 'error', 'messages' => $result));
        return $response;
        exit();
    }
});
/*******************************************resendOTP Function************************************************************/
$app->get('/resendOTP', function() use ($app) {
  $response = new Response();
  include_once './GCM.php'; 
  $gcm = new GCM();
  $mobile=$app->request->get('mobile','int');
  $subscriber_id=$app->request->get('subscriber_id','int');
  $subscriber = Subscriber::findFirst($subscriber_id);
  if($subscriber){
        //sms to app with security code //
       $gcm->send_SecurityCode($subscriber->mobile, "$subscriber->security_code");
       $response->setJsonContent(array('status' => 'true','OTP'=>$subscriber->security_code));
       return $response;
       exit();
  }
  $errors = array();
  foreach ($subscriber->getMessages() as $message) {
      $errors[] = $message->getMessage();
  }
  $response->setJsonContent(array('status' => 'false', 'messages' => $errors));
  return $response;
});
/*******************************************END resendOTP Function************************************************************/
/*******************************************Register Function************************************************************/
$app->get('/subscriber/register', function() use ($app) {

    $response = new Response();
    include_once './GCM.php'; 
    $gcm = new GCM();
   
    $mobile=$app->request->get('mobile','int');
    // $pincode_home=$app->request->get('pincode_home','int');
    // $pincode_work=$app->request->get('pincode_work','int');
    $name=$app->request->get('name','string');
    $email=$app->request->get('email','string');
    $app_type=$app->request->get('app_type');
    $reg_id=$app->request->get('reg_id');
    // $type=$app->request->get('type');
    $type="LinkApp";
    $company_id=$app->request->get('company_id');

    //$default_mg_id=$app->request->get('default_mg_id');
    $domain='sancharapp.com';
    $j_pass=substr(uniqid(),0,10);
    $MGroups=new MGroups();
 
    $subscriber = Subscriber::findFirst("mobile=".$mobile);
    
    if(!$subscriber){
      //include_once './JAXL/register.php';
      //$xmppObj = new xmpp();
      //$xmppObj->register_user("$mobile","$j_pass","$domain");
       $param="mobile=$mobile&j_pass=$j_pass&domain=$domain";
       $result=curl_redirect('/msg-api/JAXL/register.php',$param);
    //    print_r($result);exit;
      if($result=='success'){
        $MGroups->type=$type;
        $MGroups->priority='priority';
        $MGroups->save();

        $subscriber=new Subscriber();
        $subscriber->mobile=$mobile;
        // $subscriber->pincode_home=$pincode_home;
        // $subscriber->pincode_work=$pincode_work;
        $subscriber->name=$name;
        $subscriber->email=$email;
        $subscriber->app_type=$app_type;
        $subscriber->reg_id=$reg_id;
        $subscriber->mg_id=$MGroups->id;
        $subscriber->jid=$mobile.'@'.$domain;
        $subscriber->j_pass=$j_pass;
        if($company_id)
        {
            $subscriber->company_id=$company_id;
        }

        $subscriber->ustatus='Unverified';
        $subscriber->security_code=substr(str_shuffle('0123456789') , 0 , 4 );
        $subscriber->type=$type;
        //$subscriber->default_mg_id=$default_mg_id;
        $subscriber->last_date_access=date("Y-m-d H:i:s");
        $subscriber->notification_status='Yes';
          // print_r($subscriber);exit;
          if ($subscriber->save() == true) {
             /* if($default_mg_id && $default_mg_id!="null"){
                $permissions=new Permissions();
                $permissions->status='Yes';
                $permissions->mg_id=$default_mg_id;
                $permissions->subscriber_id=$subscriber->id;
                $permissions->save();
              }*/
            //Change the HTTP status
            $response->setStatusCode(201,"success");
            $response->setJsonContent(array('status' => 'registered','email' => $subscriber->email,'name' => $subscriber->name, 'subscriber_id' => $subscriber->id,'jid' => base64_encode($subscriber->jid)));

            //sms to app with security code //
            $gcm->send_SecurityCode($subscriber->mobile, "$subscriber->security_code");
            return $response;
            exit();
          }
      }else{
          //if not register on XAMPP Server
        $response->setJsonContent(array('status' => 'error1', 'messages' => $result));
        return $response;
        exit();
      }
  }else{
    if($subscriber->app_type!='Web'){
      $subscriber->security_code=substr(str_shuffle('0123456789') , 0 , 4 );
      $subscriber->name=$name;
      $subscriber->email=$email;
      $subscriber->app_type=$app_type;
      $subscriber->reg_id=$reg_id;
      $subscriber->type=$type;
      // $subscriber->pincode_home=$pincode_home;
      // $subscriber->pincode_work=$pincode_work;
    //   $subscriber->ustatus='Verified';
      //$subscriber->default_mg_id=$default_mg_id;
      $subscriber->notification_status='Yes';
      if ($subscriber->save() == true) {     
          //Change the HTTP status
     /*     if($default_mg_id && $default_mg_id!="null"){
              $permiss=Permissions::findFirst("subscriber_id=$subscriber->id AND mg_id=$default_mg_id");
              if(!$permiss){
                $permissions=new Permissions();
                $permissions->status='Yes';
                $permissions->mg_id=$default_mg_id;
                $permissions->subscriber_id=$subscriber->id;
                $permissions->save();
              }
          }*/
          $prof_img='';
          if($subscriber->profile_image)
            $prof_img=profile_image.$subscriber->profile_image;
          $user_details=array('name' =>$subscriber->name,'dob' =>$subscriber->dob,'doa' =>$subscriber->doa,'gender' =>$subscriber->gender,'occupation' =>$subscriber->occupation,'profile_image'=>$prof_img);
          $response->setJsonContent(array('status' => 'registered', 'subscriber_id' => $subscriber->id,'jid' => base64_encode($subscriber->jid),'user_details'=>$user_details));

          //sms to app with security code //
          $gcm->send_SecurityCode($subscriber->mobile, "$subscriber->security_code");
          return $response;
          exit();
      }
      }
  }


          $errors = array();
          if($subscriber->app_type=='Web'){
            // $errors[]= 'Sorry!Contact Administrator';
            array_push($errors, 'Sorry! Contact to Administrator');
          }
          // print_r($errors);exit;
          foreach ($subscriber->getMessages() as $message) {
            $errors[] = $message->getMessage();
          }
           
          
          //Send errors to the client
          $response->setStatusCode(200, "error");
          $response->setJsonContent(array('status' => 'error2', 'messages' => $errors));
          return $response;
});
/*******************************************End Register Function************************************************************/
/*******************************************edit Function************************************************************/
$app->get('/subscriber/edit', function() use ($app) {

    $response = new Response();

    $subscriber_id=$app->request->get('subscriber_id','int');
    $pincode_home=$app->request->get('pincode_home','int');
    $pincode_work=$app->request->get('pincode_work','int');
    $dob=$app->request->get('dob');
    $doa=$app->request->get('doa');
    $gender=$app->request->get('gender');
    $name=$app->request->get('name');
    $occupation=$app->request->get('occupation');

    $subscriber = Subscriber::findFirst($subscriber_id);
    if($subscriber){
      $subscriber->pincode_home=$pincode_home;
      $subscriber->pincode_work=$pincode_work;

      $subscriber->dob=$dob;
      $subscriber->doa=$doa;
      $subscriber->gender=$gender;
      $subscriber->name=$name;
      $subscriber->occupation=$occupation;
      if ($subscriber->save() == true) {     
          $response->setJsonContent(array('status' => 'true'));
          return $response;
          exit();
      }
    }
    $errors = array();
    foreach ($subscriber->getMessages() as $message) {
        $errors[] = $message->getMessage();
    }
    //Send errors to the client
    $response->setStatusCode(200, "error");
    $response->setJsonContent(array('status' => 'error', 'messages' => $errors));
    return $response;
});
/*******************************************End Register Function************************************************************/
/*******************************************update group permission Function************************************************************/
$app->get('/group/permission', function() use($app){
    $response = new Response();

    $subscriber_id=$app->request->get('subscriber_id','int');
    $status=$app->request->get('status','string');
    $mg_id=$app->request->get('mg_id');
    $mobile=$app->request->get('mobile');
    
    if($mg_id=="null"){
      $subscriber=Subscriber::findFirst("mobile=$mobile");
      $mg_id=$subscriber->mg_id;
    }
    $permissions=Permissions::findFirst("subscriber_id=$subscriber_id AND mg_id=$mg_id");
    if($permissions){
      $permissions->status=$status;
    }else{
       $permissions=new Permissions();
       $permissions->status=$status;
       $permissions->mg_id=$mg_id;
       $permissions->subscriber_id=$subscriber_id; 
    }     
    if($permissions->save()== true){      
               $response->setStatusCode(200, "success");
               $response->setJsonContent(array('status' => 'success'));
    }else{
         $errors = array();
          foreach ($permissions->getMessages() as $message) {
            $errors[] = $message->getMessage();
          }
        $response->setStatusCode(200, "invalid");
        $response->setJsonContent(array('status' => 'invalid','messages'=>$errors));
    }

     return $response;
});
/*******************************************End update group permission Function************************************************************/
 /*$response = new Response();
        $response->setJsonContent($data);
        return $response;
        exit();*/
   
/*******************************************validate Function************************************************************/
$app->get('/subscriber/validate', function() use($app){
     $response = new Response(); 
     $subscriber_id=$app->request->get('subscriber_id','int');
     $security_code=$app->request->get('security_code');
     $report="fail";
     $subscriber = Subscriber::findFirst("security_code ='$security_code' AND id=$subscriber_id");
    //  print_r($subscriber);
    //  exit;   
     if(count($subscriber)>0){
           $subscriber->ustatus = 'Verified';  
         
          if($subscriber->save() == true){
              $response->setJsonContent(array('status' => 'success','last_access_date'=>$subscriber->last_date_access,'j_pass'=>base64_encode($subscriber->j_pass)));
              $report="success";
          }
        }
    if($report=="fail"){
        $errors = array();
        foreach ($subscriber->getMessages() as $message){
          $errors[] = $message->getMessage();
        }
        $response->setJsonContent(array('status' => 'invalid', 'messages' => $errors,'subscriber_id'=>$subscriber_id,'security_code'=>$security_code,'subscriber'=>$subscriber));
    }


     return $response;
});
/*******************************************End validate Function************************************************************/

/*******************************************send message function**************************************************************/

$app->post('/send_msg', function() use($app){
    // echo "ganesh";
      $response = new Response();
      $mg_id = $app->request->getPost('mg_id','int');
      $text = urldecode($app->request->getPost('text'));
      $multimedia = html_entity_decode(base64_decode($app->request->getPost('multimedia')));
    $datetime = base64_decode($app->request->getPost('datetime'));
      $mobile = json_decode($app->request->getPost('mobile'),true);
      $status = $app->request->getPost('status');
      //$route = $app->request->get('route');
      $src_msg_id = $app->request->getPost('src_msg_id');
      $sender_id = $app->request->getPost('sender_id');
      $option = $app->request->getPost('option');
      $app_access_days = $app->request->getPost('app_access_days');
      $msg_quota = $app->request->getPost('sms_quota');
      $msg_limit = $app->request->getPost('msg_limit');
      $char_limit = $app->request->getPost('char_limit');
      $sender_jid=$app->request->getPost('sender_jid');
    $sender_pass=$app->request->getPost('sender_pass');
// print_r($_REQUEST);
// exit;
      include_once './GCM.php';    
      require_once './Batch.php'; 
      $gcm = new GCM();
    
      $access_date = date('Y-m-d', strtotime('-'.$app_access_days.' days'));
      $subscriber = new Subscriber();
      $message =new Messages(); 
      $subscriber_id = ''; $msg_id = '';
      $res = array();
      $mobile_arr = array();
      foreach ($mobile as $src_msg_id => $mobile_no)
        $mobile_arr[] = $mobile_no;

      $verify_subscriber = $subscriber->verifySubscriber($mobile_arr,$access_date,$mg_id);
// return($verify_subscriber);exit;
      $insert_arr = array(); $reg_ids_Android = array();$reg_ids_iOS = array(); $jids = array();
      foreach ($mobile as $src_msg_id => $mobile_no) {
                $result = array();
                if(!array_key_exists($mobile_no, $verify_subscriber) || $verify_subscriber[$mobile_no]['permissions']=='No'){
                    //$result['error'] = 'app not installed'; 
                    $res[$src_msg_id] = 'Failed';               
                }else{
                        $msg_id = uniqid();
                        $insert_arr[$src_msg_id][]=$mg_id;
                        $insert_arr[$src_msg_id][]=$src_msg_id;
                        $insert_arr[$src_msg_id][]=$verify_subscriber[$mobile_no]['id'];
                        $insert_arr[$src_msg_id][]=$msg_id;
                        $insert_arr[$src_msg_id][]=$mobile_no;
                        $insert_arr[$src_msg_id][]=$text;
                        $insert_arr[$src_msg_id][]=$multimedia;
                        $insert_arr[$src_msg_id][]=$datetime;
                        $insert_arr[$src_msg_id][]="Sent";
                        $insert_arr[$src_msg_id][]="Notification";
                        $insert_arr[$src_msg_id][]=$sender_id;

                    if($verify_subscriber[$mobile_no]['notification_status']=="Yes"){ //check DND number
                        if($verify_subscriber[$mobile_no]['app_type']=="Android"){
                            $reg_ids_Android[$msg_id] = $verify_subscriber[$mobile_no]['reg_id'];
                        }else{
                            $reg_ids_iOS[$msg_id] = $verify_subscriber[$mobile_no]['reg_id'];  
                        }
                    }
                    $jids[$msg_id] = $verify_subscriber[$mobile_no]['jid'];
                    $res[$src_msg_id] = 'Sent';             
                }              
      }//end for each 
    //   print_r($insert_arr);
      if(!empty($insert_arr)){
        $batch = new Batch('message');
        $batch->setRows(['mg_id','src_msg_id','subscriber_id','msg_id','mobile','text','multimedia','submit_datetime','status','route','sender_id'])
        ->setValues($insert_arr)->insert(); 
        
        if($text==""||$text==null){
          $text="Image";
          $xmpp_message=$multimedia;//for sending xmpp 
        }else{
          $xmpp_message="<p>".$text."</p>";//for sending xmpp 
        }
        //sending with xmpp message to app
        $xmpp_msg_attribute=json_encode(array("route" => "Notification","mg_id" => $mg_id,"submit_datetime" => $datetime,'sender_id'=>$sender_id));

        if(!empty($reg_ids_Android))
          $gcm->sendAndroid_notificationSingle($reg_ids_Android, $text,$sender_id,$xmpp_msg_attribute);

        if(!empty($reg_ids_iOS))
          $gcm->sendiOS_notification($reg_ids_iOS,$text,$sender_id);  
        
        if(!empty($jids)){
            // return print_r($jids);exit();
$gcm->sendXMPP_notification($jids,$xmpp_message,$sender_id,$xmpp_msg_attribute,$sender_jid,$sender_pass); 
 
        }
       
      }     

      $response->setStatusCode(201,"success");
      $response->setJsonContent($res); 
      return $response;
});//end main function

//makeDelivery read , deliver msg reply to app user
$app->post('/makeDelivery', function() use($app){
    // echo "ganesh";
      $response = new Response();
    //   $mg_id = $app->request->getPost('mg_id','int');
    $datetime = base64_decode($app->request->getPost('datetime'));
      $jids = json_decode($app->request->getPost('mobile'),true);
    //   $sender_id = $app->request->getPost('sender_id');
      $sender_jid=$app->request->getPost('sender_jid');
    $sender_pass=$app->request->getPost('sender_pass');
print_r($_REQUEST);
exit;
      include_once './GCM.php';    
      require_once './Batch.php'; 
      $gcm = new GCM();

        $xmpp_message="<p>Deliver</p>";//for sending xmpp 

        //sending with xmpp message to app
        $xmpp_msg_attribute=json_encode(array("route" => "Notification","mg_id" => $mg_id,"submit_datetime" => $datetime,'sender_id'=>$sender_id));

        // if(!empty($reg_ids_Android))
        //   $gcm->sendAndroid_notificationSingle($reg_ids_Android, $text,$sender_id,$xmpp_msg_attribute);

        // if(!empty($reg_ids_iOS))
        //   $gcm->sendiOS_notification($reg_ids_iOS,$text,$sender_id); 
        
        if(!empty($jids)){// return print_r($xmpp_msg_attribute);exit();
$gcm->sendXMPP_notification($jids,$xmpp_message,$sender_id,$xmpp_msg_attribute,$sender_jid,$sender_pass); 
}     

      $response->setStatusCode(201,"success");
      $response->setJsonContent($res); 
      return $response;
});//makeDelivery end main function

/*joint_send*/
$app->post('/joint_send', function() use($app){
      $response = new Response();
      $mg_id = $app->request->getPost('mg_id','int');
      $text = urldecode($app->request->getPost('text'));
      $multimedia = html_entity_decode(base64_decode($app->request->getPost('multimedia')));
      $datetime = base64_decode($app->request->getPost('datetime'));
      $mobile = json_decode($app->request->getPost('mobile'),true);

      $src_msg_id = $app->request->getPost('src_msg_id');
      $sender_id = $app->request->getPost('sender_id');

      $app_access_days = $app->request->getPost('app_access_days');

      include_once './GCM.php';    
      require_once './Batch.php'; 
      $gcm = new GCM();
      $access_date = date('Y-m-d', strtotime('-'.$app_access_days.' days'));
      $subscriber = new Subscriber();
      $message =new Message(); 
      $subscriber_id = ''; $msg_id = '';
      $res = array();
      $mobile_arr = array();
      foreach ($mobile as $src_msg_id => $mobile_no)
        $mobile_arr[] = $mobile_no;

      $verify_subscriber = $subscriber->verifySubscriber($mobile_arr,$access_date,$mg_id);
   
      $insert_arr = array(); $reg_ids_Android = array();$reg_ids_iOS = array(); $jids = array();
      foreach ($mobile as $src_msg_id => $mobile_no) {
                $result = array();
                if(!array_key_exists($mobile_no, $verify_subscriber) || $verify_subscriber[$mobile_no]['permissions']=='No'){
                    //$result['error'] = 'app not installed'; 
                    $res[$src_msg_id] = 'Failed';               
                }else{
                        $msg_id = uniqid();
                        $insert_arr[$src_msg_id][]=$mg_id;
                        $insert_arr[$src_msg_id][]=$src_msg_id;
                        $insert_arr[$src_msg_id][]=$verify_subscriber[$mobile_no]['id'];
                        $insert_arr[$src_msg_id][]=$msg_id;
                        $insert_arr[$src_msg_id][]=$mobile_no;
                        $insert_arr[$src_msg_id][]=$text;
                        $insert_arr[$src_msg_id][]=$multimedia;
                        $insert_arr[$src_msg_id][]=$datetime;
                        $insert_arr[$src_msg_id][]="Sent";
                        $insert_arr[$src_msg_id][]="Joint";
                        $insert_arr[$src_msg_id][]=$sender_id;

                    if($verify_subscriber[$mobile_no]['notification_status']=="Yes"){ //check DND number
                        if($verify_subscriber[$mobile_no]['app_type']=="Android"){
                            $reg_ids_Android[] = $verify_subscriber[$mobile_no]['reg_id'];
                        }else{
                            $reg_ids_iOS[] = $verify_subscriber[$mobile_no]['reg_id'];  
                        }
                    }
                    $jids[$msg_id] = $verify_subscriber[$mobile_no]['jid'];
                    $res[$src_msg_id] = 'Sent';             
                }              
      }//end for each 
      if(!empty($insert_arr)){
        $batch = new Batch('message');
        $batch->setRows(['mg_id','src_msg_id','subscriber_id','msg_id','mobile','text','multimedia','submit_datetime','status','route','sender_id'])
        ->setValues($insert_arr)->insert(); 
        
        if($text==""||$text==null){
          $text="Image";
          $xmpp_message=$multimedia;//for sending xmpp 
        }else{
          $xmpp_message="<p>".$text."</p>";//for sending xmpp 
        }
        //sending with xmpp message to app
        $xmpp_msg_attribute=json_encode(array("route" => "Joint","mg_id" => $mg_id,"submit_datetime" => $datetime));
        //we are sending silent update right now
        //if(!empty($reg_ids_Android))
          //$gcm->sendAndroid_notification($reg_ids_Android, $text,$sender_id);

        //if(!empty($reg_ids_iOS))
          //$gcm->sendiOS_notification($reg_ids_iOS,$text,$sender_id);  
        
        if(!empty($jids))
          $gcm->sendXMPP_notification($jids,$xmpp_message,$sender_id,$xmpp_msg_attribute); 
      }     

      $response->setStatusCode(201,"success");
      $response->setJsonContent($res); 
      return $response;
});//end main function
/*joint_send*/
/*******************************************send website user feedback function**************************************************************/

$app->post('/send_feedback', function() use($app){
      $response = new Response();
      $mg_id = $app->request->getPost('mg_id','int');
      $multimedia = html_entity_decode(base64_decode($app->request->getPost('multimedia')));
      $datetime = base64_decode($app->request->getPost('datetime'));
      $sender_id = $app->request->getPost('sender_id');
      $sen_pass = $app->request->getPost('sen_pass');
      $sender_jid = $app->request->getPost('sender_jid');
      $app_access_days = $app->request->getPost('app_access_days');
      $mobile = json_decode($app->request->getPost('mobile'),true);
      $msg_quota = $app->request->getPost('sms_quota');
      $msg_limit = $app->request->getPost('msg_limit');
// print_r($mobile);
      include_once './GCM.php';    
      require_once './Batch.php'; 
      $gcm = new GCM();
      $access_date = date('Y-m-d', strtotime('-'.$app_access_days.' days'));
      $subscriber = new Subscriber();
      $message =new Messages(); 
      $subscriber_id = ''; 
      $msg_id = '';
      $res = array();
      $mobile_arr = array();
      foreach ($mobile as $src_msg_id => $mobile_no)
        $mobile_arr[] = $mobile_no;
      // print_r($mobile_arr);
 $verify_subscriber = $subscriber->verifySubscriber($mobile_arr,$access_date,$mg_id);
 // print_r($verify_subscriber);

      $insert_arr = array(); 
      $reg_ids_Android = array();
      $reg_ids_iOS = array(); 
      $jids = array();
      foreach ($mobile as $src_msg_id => $mobile_no) {
                $result = array();
                if(!array_key_exists($mobile_no, $verify_subscriber) || $verify_subscriber[$mobile_no]['permissions']=='No'){
                    //$result['error'] = 'app not installed'; 
                    $res[$src_msg_id] = 'Failed';               
                }else{
                        $msg_id = uniqid();
                        $insert_arr[$src_msg_id][]=$mg_id;
                        $insert_arr[$src_msg_id][]=$src_msg_id;
                        $insert_arr[$src_msg_id][]=$verify_subscriber[$mobile_no]['id'];
                        $insert_arr[$src_msg_id][]=$msg_id;
                        $insert_arr[$src_msg_id][]=$mobile_no;
                        $insert_arr[$src_msg_id][]='';
                        $insert_arr[$src_msg_id][]=$multimedia;
                        $insert_arr[$src_msg_id][]=$datetime;
                        $insert_arr[$src_msg_id][]="Sent";
                        $insert_arr[$src_msg_id][]="Feedback";
                        $insert_arr[$src_msg_id][]=$sender_id;

                    if($verify_subscriber[$mobile_no]['notification_status']=="Yes"){ //check DND number
                        if($verify_subscriber[$mobile_no]['app_type']=="Android"){
                            $reg_ids_Android[] = $verify_subscriber[$mobile_no]['reg_id'];
                        }else{
                            $reg_ids_iOS[] = $verify_subscriber[$mobile_no]['reg_id'];  
                        }
                    }
                    $jids[$msg_id] = $verify_subscriber[$mobile_no]['jid'];
                    $res[$src_msg_id] = 'Sent';             
                }              
      }//end for each 
      // print_r($insert_arr);exit;
      if(!empty($insert_arr)){
        $batch = new Batch('message');
        $batch->setRows(['mg_id','src_msg_id','subscriber_id','msg_id','mobile','text','multimedia','submit_datetime','status','route','sender_id'])
        ->setValues($insert_arr)->insert(); 
   
        $text="Feedback";
        $xmpp_message=$multimedia;
        $xmpp_msg_attribute=json_encode(array("route" => "Feedback","mg_id" => $mg_id,"submit_datetime" => $datetime));

        if(!empty($reg_ids_Android))
          $gcm->sendAndroid_notification($reg_ids_Android, $text,$sender_id);

        if(!empty($reg_ids_iOS))
          $gcm->sendiOS_notification($reg_ids_iOS,$text,$sender_id);  
        // print_r($sen_pass);exit;
        if(!empty($jids))
          $gcm->sendXMPP_notification($jids,$xmpp_message,$sender_id,$xmpp_msg_attribute,$sender_jid,$sen_pass); 
      }     

      $response->setStatusCode(201,"success");
      $response->setJsonContent($res); 
      return $response;
});//end main function

$app->post('/sortMobile_Numbers', function() use($app){
    $response = new Response();
    $mobile = json_decode($app->request->getPost('mobile'),true);
    $app_access_days = $app->request->getPost('app_access_days');
    $access_date = date('Y-m-d', strtotime('-'.$app_access_days.' days'));
    $mobile_str = implode(",",$mobile);
    
    $smt = $app->db->query("SELECT s.mobile FROM subscriber s WHERE s.mobile IN (".$mobile_str.") AND s.app_type != 'Web' AND s.status =  'Verified' AND s.last_date_access >=  '".$access_date."'");
    $smt->setFetchMode(PDO::FETCH_COLUMN,0);
   
    $notification_numbers=$smt->fetchAll();
    $sms_numbers=array_diff($mobile,$notification_numbers);
   
    $result['sms'] = $sms_numbers;
    $result['notification'] = $notification_numbers;
    $response->setJsonContent($result);  
    return $response;   
});
$app->post('/getMobile_Numbers', function() use($app){
    $response = new Response();
    $subscribers = json_decode($app->request->getPost('subscribers'),true);
    $app_access_days = $app->request->getPost('app_access_days');
    $access_date = date('Y-m-d', strtotime('-'.$app_access_days.' days'));
    $subscribers_str = implode(",",$subscribers);
    
    $smt = $app->db->query("SELECT s.mobile FROM subscriber s WHERE s.id IN (".$subscribers_str.") AND s.app_type != 'Web' AND s.status =  'Verified' AND s.last_date_access >=  '".$access_date."'");
    $smt->setFetchMode(PDO::FETCH_COLUMN,0);
    $result=$smt->fetchAll();
    $response->setJsonContent($result);  
    return $response;   
});
$app->post('/getContacts', function() use($app){
    $response = new Response();
    $mobile = json_decode($app->request->getPost('mobile'),true);
    $mobile_str = implode(",",$mobile);
//    file_put_contents("../public/app_log.txt", "\n".'MSG-API param:'.$mobile_str,FILE_APPEND);
    $res = $app->db->query("SELECT s.mobile FROM subscriber s WHERE s.mobile IN (".$mobile_str.") AND s.app_type != 'Web' AND s.status =  'Verified'")->fetchAll();
    $result = array();
    foreach ($res as $key => $value){
      $result[] = $value['mobile'];
    } 
    $response->setStatusCode(201,"success");
    $response->setJsonContent($result);  
    return $response;   

});

$app->get('/xmpp_delivery', function() use($app){
    require_once 'JAXL/jaxl.php';
    global $msg_Array,$client,$app,$start,$xmpp_admin,$total_time;

    $start_time = microtime(true);
    $total_time = 0;
    $xmpp_admin=$app->config->xmpp_admin;

file_put_contents("../public/Croncache.txt", "\n".'----------->'."\n",FILE_APPEND);
while($total_time < 60)//run while less than a minute
  {
    $start = microtime(true);
    $msg_Array = array();

    $client = new JAXL(array('jid' =>$xmpp_admin->jid,'pass' => $xmpp_admin->pass,'auth_type' => 'DIGEST-MD5','priv_dir'=>'priv_dir','log_level' => JAXL_ERROR,'strict'=>TRUE));
    $client->require_xep(array('0199'));

    $client->add_cb('on_auth_success', function() {
        global $client,$xmpp_admin;
        //file_put_contents("../public/Croncache.txt", "\n"."got on_auth_success cb",FILE_APPEND);
        $client->set_status("available!", "dnd", 10);
        $client->send_chat_msg($xmpp_admin->jid,"ping");
    });
    $client->add_cb('on_chat_message', function($msg) {
        global $client,$msg_Array;
        //file_put_contents("../public/Croncache.txt", "\n"."got on_chat_message cb",FILE_APPEND);
        if($msg->body!="ping"){
         //if same time read and deliver status comes 
          if(array_key_exists($msg->id,$msg_Array)){
            if($msg_Array[$msg->id]['status']=='Delivered')
                $msg_Array[$msg->id]=array('datetime' =>$msg->datetime,'status'=>$msg->body);
          }else{
              $msg_Array[$msg->id]=array('datetime' =>$msg->datetime,'status'=>$msg->body);
          }
          //array_push($msg_Array,array($msg->id=>array('datetime' =>$msg->datetime,'status'=>$msg->body)));
        }
        //file_put_contents("../public/Croncache.txt", "\n".print_r($msg_Array, true),FILE_APPEND);
        $client->send_end_stream();
    });
    $client->add_cb('on_disconnect', function() {
         global $msg_Array,$app,$start,$client,$total_time;
         //file_put_contents("../public/Croncache.txt", "\n"."got on_disconnect cb",FILE_APPEND);
        if(count($msg_Array)>0){
          $sql = "UPDATE `message` SET `done_datetime` = CASE msg_id ";
          $sql2 = " END, `status` = CASE msg_id ";
          $ids='';
          foreach ($msg_Array as $id => $val) {
                  $sql .= "WHEN '".$id."' THEN '".$val['datetime']."'";
                  $sql2 .= " WHEN '".$id."' THEN '".$val['status']."'";
                  $ids .="'".$id."',";
          }
          $sql .= $sql2." END WHERE msg_id IN (".rtrim($ids, ",").") AND status <>'Read'";
          //file_put_contents("../public/app_log.txt", "\n".$sql,FILE_APPEND);
          //echo $sql;
          $app->db->query($sql);
          $sql3="SELECT `src_msg_id` as id,`status` FROM `message` WHERE `msg_id` IN (".rtrim($ids, ",").")";
          //echo $sql3;
          $result=$app->db->query($sql3);
          $result->setFetchMode(Phalcon\Db::FETCH_ASSOC);
          $result=$result->fetchAll();
          forward('linkapp',json_encode($result));//send back to website update status
        }
        //echo ':'.round((microtime(true) - $start),3)."sec DT: ".date("D, d M y H:i:s O");
        file_put_contents("../public/Croncache.txt", "\n". 'XMPP delivery:msg('.count($msg_Array).')'.round((microtime(true) - $start),3)." sec DT: ".date("D, d M y H:i:s O"),FILE_APPEND);
        unset($msg_Array);
        unset($start);
    });
  $client->start();
  sleep(20);//wait amount in seconds
  $total_time =  round(microtime(true) - $start_time) ;
 }//end while 
 exit();
});
/*******************************************update GCM reg ID app Function******************************************************************/
$app->get('/update_GCM_ID', function() use($app){
    $response = new Response(); 
    $subscriber_id=$app->request->get('subscriber_id','int');
    $reg_id=$app->request->get('reg_id');
      
    $subscriber = Subscriber::findFirst($subscriber_id);
    $subscriber->reg_id=$reg_id;
    if($subscriber->update() == false) {
          $errors = array();
          foreach ($subscriber->getMessages() as $message){
            $errors[] = $message->getMessage();
          }
      $response->setStatusCode(200, "invalid");
      $response->setJsonContent(array('status' => 'invalid', 'messages' => $errors));
     }else{  
        $response->setStatusCode(201,"success");
        $response->setJsonContent(array('status' => 'success')); 
     }
    
     return $response;
});

/*******************************************End update GCM reg ID Function**************************************************************/
/*******************************************update update_NotificationStatus app Function******************************************************************/
$app->get('/update_NotificationStatus', function() use($app){
    $response = new Response(); 
    $subscriber_id=$app->request->get('subscriber_id','int');
    $status=$app->request->get('status');
      
    $subscriber = Subscriber::findFirst($subscriber_id);
    $subscriber->notification_status=$status;
    if($subscriber->update() == false) {
          $errors = array();
          foreach ($subscriber->getMessages() as $message){
            $errors[] = $message->getMessage();
          }
      $response->setStatusCode(200, "invalid");
      $response->setJsonContent(array('status' => 'invalid', 'messages' => $errors));
     }else{  
        $response->setStatusCode(201,"success");
        $response->setJsonContent(array('status' => 'success')); 
     }
    
     return $response;
});
/*******************************************update group permission Function************************************************************/
$app->get('/reportspam', function() use($app){
    $response = new Response();

    $subscriber_id=$app->request->get('subscriber_id','int');
    $reason=urldecode($app->request->get('reason'));
    $mg_id=$app->request->get('mg_id');
    $spam=new Spam();    
    $result=$spam->saveSpam($subscriber_id,$mg_id,$reason);
    $response->setJsonContent($result);
    return $response;
});
/*******************************************End update group permission Function************************************************************/
/*******************************************checkServerMessage Function************************************************************/
$app->get('/checkServerMessage', function() use($app){
    $response = new Response(); 
    $subscriber_id=$app->request->get('subscriber_id','int');
    $subscriber = Subscriber::findFirst($subscriber_id);
    if($subscriber){
      $subscriber->last_date_access=date("Y-m-d H:i:s");
      $subscriber->save();
    }
    $response->setJsonContent(array('status' =>false,'anchor'=>'<a style="border-right:0px;" onclick="javascript:return openExternal(this);" id="dltbtn" class="waves-effect waves-blue btn-flat" href="http://sancharapp.com/d">Upgrade</a>','message' => "Please Upgrade App",'strict' => false));
    return $response;
});
/*******************************************End checkServerMessage Function************************************************************//*******************************************End update_NotificationStatus Function**************************************************************/

//ganesh new function started

$app->post('/companyUsers', function() use($app){
    $response = new Response();
    $mobile = $app->request->getQuery('mobile');
    // $mobile_str = implode(",",$mobile);
//    file_put_contents("../public/app_log.txt", "\n".'MSG-API param:'.$mobile_str,FILE_APPEND);
$sql="SELECT s.id,s.mobile,s.name,s.jid FROM subscriber s WHERE s.mobile like ('".$mobile."%') AND s.app_type != 'Web' AND s.ustatus =  'Verified'";   
// $user=Subscriber::findFirst("mobile=$mobile AND status='Verified'");
// $res = $app->db->query()->fetchAll($sql);
$res=$app->db->query($sql)->fetchAll();
if(count($res))
{
    echo json_encode(array('msg'=>'success','result'=>$res));
}else{
    echo json_encode(array('msg'=>'error','result'=>'Not found any Contact with this number'));

}
// print_r($res);
// exit;

    // $result = array();
    // foreach ($res as $key => $value){
    //   $result[] = $value['mobile'];
    // } 
    // $response->setStatusCode(201,"success");
    // $response->setJsonContent($result);  
    // return $response;   

// echo json_encode(array('msg'=>'success','result'=>array('name'=>$user->name,'jid'=>$user->jid)));
});

//ganesh new function ended




/*$app->get('/message_delivery', function() use($app){
        $response = new Response();
        $type=$app->request->get('type');
        if (!$type) {
              $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
              return $response;
              exit();
        }

        include_once './smppclass.php';
        $smpp_config=$app->config->smpp;
        $smpp = new SMPPClass();
        $smpp->_debug = true;
        $smpp->SetSender($smpp_config->from);
        $smpp->Start($smpp_config->smpphost,$smpp_config->smppport, $smpp_config->systemid, $smpp_config->password, $smpp_config->system_type);
        echo "start---------------------------------------------------<br/>";
        $data=$smpp->TestLink();
        
        if(count(json_decode($data, true))>0){
            forward($type,$data);
        }
});

$app->get('/notification_delivery', function() use($app){
       $response = new Response(); 
       $subscriber_id=$app->request->get('subscriber_id','int');
       $last_access_date=base64_decode($app->request->get('last_access_date'));
       $type=$app->request->get('type');
       $obj=array(); 

       $message = Message::find("status='' AND subscriber_id=$subscriber_id AND submit_datetime >'".$last_access_date."'");
       foreach ($message as $value) {
          $msg = Message::findFirst($value->id);
            if($msg){
             $msg->status='DELIVRD';
             $msg->done_datetime=date('Y-m-d H:i');
             $res=$msg->update();
             $arr1 = array('id' => $msg->src_msg_id,'status'=>$msg->status);
             array_push($obj,$arr1);
             echo $res;
           }
       }

       $data=json_encode($obj);
       if(count($obj)>0){ 
            forward($type,$data);
       }
});
$app->get('/notification_delivery_single', function() use($app){
       $response = new Response();
       $obj=array(); 
       $subscriber_id=$app->request->get('subscriber_id','int');
       $msg_id=$app->request->get('msg_id');
       $type=$app->request->get('type');

       $message = Message::findFirst("subscriber_id=$subscriber_id AND msg_id=$msg_id AND status<>'DELIVRD' ");
       if($message){
         $message->status='DELIVRD';
         $message->done_datetime=date('Y-m-d H:i');
         $res=$message->update();
         $arr1 = array('id' => $message->src_msg_id,'status'=>$message->status);
         array_push($obj,$arr1);
         echo $res;
       }
       $data=json_encode($obj);
       if(count($obj)>0){
            forward($type,$data);
       }
});

$app->get('/get_failed_messages', function() use($app){
    $response = new Response();
    $message = $app->db->query("SELECT m.src_msg_id FROM `message` m, MGroups mg WHERE m.status IN ('EXPIRED','UNDELIV','REJECTD') AND mg.id = m.mg_id AND mg.type = 'BeforeDoctor'")->fetchAll();
    $result = array();
    foreach ($message as $key => $value)
      $result[] = $value['src_msg_id'];
    $response->setStatusCode(200, "success");
    $response->setJsonContent($result);
    return $response;
});
*/
function forward($type,$data){
    $url='';
    if($type=='linkapp')
      $url='http://www.sancharapp.com/message/delivery';

    //file_put_contents("../public/Croncache.txt", "\n".$url.$data,FILE_APPEND);
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, 1);
    curl_setopt($ch, CURLOPT_POSTFIELDS,"data=$data");
    $response = curl_exec($ch);
    curl_close($ch);
} 
/*******************************************End main Function************************************************************/


$app->notFound(function () use ($app) {
    $app->response->setStatusCode(404, "Not Found")->sendHeaders();
    echo 'This is crazy, but this page was not found!';
});

$app->handle();
?>