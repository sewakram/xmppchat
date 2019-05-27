
<?php
date_default_timezone_set('Asia/Calcutta');
use Phalcon\Http\Response,
    Phalcon\Http\Request,
    Phalcon\Mvc\Micro,
    Phalcon\Mvc\Model\Query,
    Phalcon\Db\Column,
    Phalcon\Mvc\Url;

$app = new Micro();

// Use Loader() to autoload our model
$loader = new \Phalcon\Loader();

$loader->registerDirs(array(
    __DIR__ . '/models/'
))->register();

$di = new \Phalcon\DI\FactoryDefault();

//Set up the database service
$di->set('db', function(){
    return new \Phalcon\Db\Adapter\Pdo\Mysql(array(
        "host" => "localhost",
        "username" => "sanchar_app",
        "password" => "nbMbRaSwAN6C8vQb",
        "dbname" => "sanchar_app"
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

//Retrieves  group list
$app->post('/test', function() use($app){
    try{
   
    }catch (Exception $e) {
      echo 'Caught exception: ',  $e->getMessage(), "\n";
    }
});
//Register subscriber
$app->get('/updateProfiles', function () {

});
//Register subscriber
$app->get('/subscriber/register', function () {

});
//Edit subscriber
$app->get('/subscriber/edit', function () {

});
//Validate Contact
$app->get('/subscriber/validate', function () {

});

//Add Feedback
$app->get('/feedback', function() {

});
//Add Feedback
$app->get('/group/permission', function() {

});
//get message queue
$app->get('/messages', function() {

});
$app->post('/getContacts', function() {

});
$app->post('/uploadprofile', function() {

});
$app->post('/uploadprofile2', function() {

});
$app->post('/uploadfiles', function() {

});
/*$app->get('/notification_delivery', function() {

});
$app->get('/notification_delivery_single', function() {

});*/
$app->get('/update_GCM_ID', function() {

});
//get Blocklist
$app->get('/getConfig', function() {

});
$app->get('/update_NotificationStatus', function() {

});
$app->get('/feedback/update', function() {

});
$app->get('/feedback/result', function() {

});
$app->get('/reportspam', function() {

});
$app->get('/resendOTP', function() {

});
$app->get('/jointsearch', function(){
});
$app->get('/jointfollow', function(){
});
$app->get('/jointunfollow', function(){

});
$app->post('/getUnprocessSMS', function(){

});
$app->post('/processstatusSMS', function(){

});
$app->get('/checkServerMessage', function () {

});
/*******************************************End All URL************************************************************/

function customError($errno, $errstr,$errfile,$errline) {
  file_put_contents("api_log.txt", "\n"."Error:[$errno] $errstr $errfile $errline",FILE_APPEND);
  //echo "<b>Error:</b> [$errno] $errstr";
}

/*******************************************Main Function************************************************************/

  function call_msg_server($url,$param){
    global $app;
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL,$app->config->site->url.$url.'?'.$param); 
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);   
    $response = curl_exec($ch);
    curl_close($ch);
    return $response;
  }
    $app->post('/test', function() use($app){

    }
  $app->post('/updateProfiles', function() use($app){
      $response = new Response();
      $data=$app->request->getPost('data');
      if(!$data) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
      }
      $result=array();
      foreach ($data as $key => $value) {
        $photo=explode("?", $value['photo']);
        $filename='../public/profile/'.$photo[0];
        if (file_exists($filename)) {
            if(count($photo)>1){
              if(filemtime($filename)!=$photo[1])
                array_push($result, array("mg_id"=>$key,"photo"=>$photo[0].'?'.filemtime($filename)));
            }else{
                array_push($result, array("mg_id"=>$key,"photo"=>$photo[0].'?'.filemtime($filename)));
            }
        } 
      }
      $response->setJsonContent($result);
      return $response;
  });
  /*******************************************uploadprofile Function************************************************************/
$app->post('/uploadprofile', function() use($app){
  try {
    $response = new Response();
    $subscriber_id=$app->request->get('subscriber_id');
    if (!$subscriber_id || !$app->request->hasFiles()) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }
    //checking if file exsists
    $img_path='../public/linkappprofile/' .$subscriber_id.'.jpg';
    //if(file_exists($img_path)) unlink($img_path);
    foreach($app->request->getUploadedFiles() as $file) {
      $flag=$file->moveTo($img_path);
    }
    if($flag){
      $param="subscriber_id=$subscriber_id&image_name=".$subscriber_id.".jpg";
      $result=call_msg_server('/msg-api/uploadprofile',$param);
      echo $result;
    }else{
      $response->setJsonContent(array('status' => 'false'));
      return $response;
    }
    }catch(Exception $e) {
      file_put_contents("../public/app_log.txt", "\n".$e->getMessage(),FILE_APPEND);
    }
});
/*******************************************End uploadprofile Function************************************************************/
 /*******************************************uploadprofile Function************************************************************/
$app->post('/uploadprofile2', function() use($app){
  try {
    $response = new Response();
    $subscriber_id=$app->request->get('subscriber_id');
    $data=$app->request->getPost('imagebase64');

    if (!$subscriber_id || !$data) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }
    //checking if file exsists
    $img_path='../public/linkappprofile/' .$subscriber_id.'.jpg';
    list($type, $data) = explode(';', $data);
    list(, $data)      = explode(',', $data);
    $data = base64_decode($data);
    if(file_exists($img_path)) unlink($img_path);
    
    // print_r($data);
    $flag=file_put_contents($img_path, $data);
    if($flag){
      $param="subscriber_id=$subscriber_id&image_name=".$subscriber_id.".jpg";
      $result=call_msg_server('/msg-api/uploadprofile',$param);
      echo $result;
/*      $response->setJsonContent(array('status' => 'true','url'=>$result));
      return $response;*/
    }else{
      $response->setJsonContent(array('status' => 'false','img_path'=>$img_path,'data'=>$data));
      return $response;
    }
    }catch(Exception $e) {
      file_put_contents("../public/app_log.txt", "\n".$e->getMessage(),FILE_APPEND);
    }
});

// upload files from app user
$app->post('/uploadfiles', function() use($app){
  try {
    $response = new Response();
    $subscriber_id=$app->request->get('subscriber_id');
    // $subscriber_id=208;
    $fname = urldecode($_FILES["file"]["name"]).".jpg";
    $url='../public/user_images/'.$subscriber_id.'/images/';
// //Move your files into upload folder
//  #define a “unique” name and a path to where our file must go
// $path ='../public/user_images/'.$subscriber_id.'/images/'.md5(uniqid(rand(), true)).'-'.strtolower($upload->getname());
$path ='../public/user_images/';
if ($_FILES['file']['name'] !=""){
    // Checking filetype

    // if($_FILES['file']['type']!="application/pdf") {
    //     die("You can only upload PDF files");
    // }

    // Checking filesize
    // if ($_FILES['file']['size']>1048576) {
    //     die("The file is too big. Max size is 1MB");
    // }

    if(!is_dir($path.$subscriber_id."/images/")) {
        mkdir($path.$subscriber_id."/images/", 0777, true); 
    }

    $rawBaseName = pathinfo($fname, PATHINFO_FILENAME );
    $extension = pathinfo($fname, PATHINFO_EXTENSION );
    $counter = 0;
    while(file_exists($path.$subscriber_id."/images/".$fname)) {
        $fname = $rawBaseName . $counter . '.' . $extension;
        $counter++;
    };

    $result=move_uploaded_file($_FILES['file']['tmp_name'],$path.$subscriber_id."/images/".$fname);  
if($result)
{
    $real_path=$app->config->site->url.'/public/user_images/'.$subscriber_id.'/images/'.$fname;
  echo json_encode(array('status' => 'success', 'messages' => 'send success','real_path'=>$real_path));
}
else{
    echo json_encode(array('status' => 'error', 'messages' => 'Not able to upload file'));

}
}else{
    echo json_encode(array('status' => 'error', 'messages' => 'plz upload file'));
    // echo 'plz upload file';
}

// echo $result;
    exit();
    $data=$app->request->getPost('imagebase64');

    if (!$subscriber_id || !$data) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }
    //checking if file exsists
    $img_path='../public/linkappprofile/' .$subscriber_id.'.jpg';
    list($type, $data) = explode(';', $data);
    list(, $data)      = explode(',', $data);
    $data = base64_decode($data);
    if(file_exists($img_path)) unlink($img_path);
    
    // print_r($data);
    $flag=file_put_contents($img_path, $data);
    if($flag){
      $param="subscriber_id=$subscriber_id&image_name=".$subscriber_id.".jpg";
      $result=call_msg_server('/msg-api/uploadprofile',$param);
      echo $result;
/*      $response->setJsonContent(array('status' => 'true','url'=>$result));
      return $response;*/
    }else{
      $response->setJsonContent(array('status' => 'false','img_path'=>$img_path,'data'=>$data));
      return $response;
    }
    }catch(Exception $e) {
      file_put_contents("../public/app_log.txt", "\n".$e->getMessage(),FILE_APPEND);
    }
});
// end upload files from app user
/*******************************************End uploadprofile Function************************************************************/
/*******************************************get Contact Function************************************************************/
$app->post('/getContacts', function() use($app){
    $response = new Response(); 
    $mobile=$app->request->getPost('mobile');
    file_put_contents("../public/app_log.txt", "\n".'API param:'.$mobile,FILE_APPEND);
    if (!$mobile) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }
    $param="mobile=$mobile";
    $result=call_msg_server('/msg-api/getContacts',$param);
    echo $result;
});
/*******************************************End get Contact Function************************************************************/
/*******************************************Message queue Function************************************************************/
$app->get('/messages', function() use($app){
    $response = new Response();
    $subscriber_id=$app->request->get('subscriber_id','int');
    $last_access_date=base64_encode($app->request->get('last_access_date'));
    //$mobile=$app->request->get('mobile');
    if (!$subscriber_id) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }
    $param="subscriber_id=$subscriber_id&last_access_date=$last_access_date";
    $result=call_msg_server('/msg-api/messages',$param);
    echo $result;
});
/*******************************************End Message queue Function************************************************************/
/*******************************************jointsearch Function start***************************************************************/
$app->get('/jointsearch', function() use($app){
    $response = new Response();
    $arr=array();
    $keyword=$app->request->get('keyword');
    $subscriber_id=$app->request->get('subscriber_id');
    //$sql="SELECT distinct id,mg_id,joint_handle  FROM `user` WHERE( firstname LIKE  '%".$keyword."%' or lastname LIKE  '%".$keyword."%' or joint_handle LIKE  '%".$keyword."%') and type='Group Admin' and joint_handle is not null";
    $sql="SELECT distinct u.id,u.mg_id,u.joint_handle,s.text as senderID FROM `user` u,`senderID` s WHERE( u.firstname LIKE '%".$keyword."%' or u.lastname LIKE '%".$keyword."%' or u.joint_handle LIKE '%".$keyword."%') AND s.user_id=u.id AND u.type='Group Admin' and u.joint_handle is not null ";
    $result=$app->db->fetchAll($sql);
    foreach ($result as $row) {
        $obj = new User();
        $user_permission = $obj->getPermissions($row['id']);
        if($user_permission['joint'] == 'Yes'){
              $sql1="SELECT * FROM `joint` WHERE mg_id=".$row['mg_id']." AND subscriber_id=".$subscriber_id."";
              $result1=$app->db->fetchOne($sql1, Phalcon\Db::FETCH_ASSOC);
              if($result1)
                array_push($arr,array('data' =>$row,'status'=>true));
              else
                array_push($arr,array('data' =>$row,'status'=>false));
        }
    }
    $response->setJsonContent($arr);
    return $response;
});
/*******************************************jointsearch Function end***************************************************************/
/*******************************************jointfollow Function start***************************************************************/
$app->get('/jointfollow', function() use($app){
    $response = new Response();
    $sub_id=$app->request->get('subscriber_id');
    $mg_id=$app->request->get('mg_id');
    $joint = new Joint();
    $joint->subscriber_id = $sub_id;
    $joint->mg_id=$mg_id;
    if ($joint->save() == false) {
        $errors = array();
        foreach ($joint->getMessages() as $message) {
                $errors[] = $message->getMessage();
        }
        $response->setJsonContent(array('status'=>false,'messages'=>$errors));
    }else
        $response->setJsonContent(array('status'=>true));
     return $response;
});
/*******************************************jointfollow Function end***************************************************************/
/*******************************************jointunfollow Function start***************************************************************/
$app->get('/jointunfollow', function() use($app){
      $response = new Response();
      $sub_id=$app->request->get('subscriber_id');
      $mg_id=$app->request->get('mg_id');
      $sql="DELETE from `joint` WHERE subscriber_id=".$sub_id." AND mg_id=".$mg_id."";
      if($app->db->execute($sql))
        $response->setJsonContent(array('status'=>true));
      else
        $response->setJsonContent(array('status'=>false,'messages'=>'Please try again later'));
      return $response;
});
/***********************jointunfollow Function end*******************************************************/
/***********************getUnprocessSMS Function start*******************************************************/
$app->post('/getUnprocessSMS', function() use($app){
      //update admin config time to know local server status if fetch from local server
      $config = Configuration::findFirst();
      if($app->request->getPost('server')=="local"){
        $config->last_local_access_datetime=date('Y-m-d H:i:s');
        $config->update();
      }
      //end update config time

      $sql="SELECT id,url,status from `local_sms_table` WHERE STATUS=0 LIMIT $config->sms_request_limit";
      $result=$app->db->fetchAll($sql);
      if($result){
        $str = implode(',', array_map(function($el){ return $el['id']; }, $result));
        $sql_update="UPDATE `local_sms_table` SET STATUS=1 WHERE id IN($str)";
        $app->db->execute($sql_update);
      }
      echo json_encode($result);
});
/***********************getUnprocessSMS Function end*******************************************************/
/***********************processstatusSMS Function start*******************************************************/
 $app->post('/processstatusSMS', function()use($app){
  $response = new Response();
  $data=$app->request->getPost("ids");
  $res=implode(",",json_decode($data));
  if($res){
    $sql="update  `local_sms_table` set  STATUS=1 WHERE id IN (".$res.")";
    if($app->db->execute($sql))
      $response->setJsonContent(array('status'=>true));
    else
      $response->setJsonContent(array('status'=>false,'messages'=>'Please try again later'));
  }else{
    $response->setJsonContent(array('status'=>false,'messages'=>'Please try again later'));
  }
    return $response;
});
 /***********************processstatusSMS Function end*******************************************************/

/*******************************************grouplist Function**************************************************/
/*//Retrieves all grouplist
$app->get('/grouplist', function() use ($app) {
    $response = new Response();
    $mobile=$app->request->get('mobile');
    
    if (!$mobile) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }

    $group=new Group();
    $result=$group->getData($mobile);
    echo json_encode($result);
    
});*/

/*******************************************END grouplist Function***********************************************************/

/*******************************************Register subscriber  Function****************************************************/
$app->get('/subscriber/register', function() use ($app) {    
    $response = new Response();
    
    $mobile=$app->request->get('mobile','int');
    $pincode_home=$app->request->get('pincode_home','int');
    $pincode_work=$app->request->get('pincode_work','int');
    //$name=base64_encode($app->request->get('name','string'));
    $app_type=$app->request->get('app_type');
    $reg_id=$app->request->get('reg_id');
    $company_id=$app->request->get('company_id');
    $type='LinkApp';
    //$group_id=$app->request->get('group_id');
    //$group=new Group();
    //$default_mg_id=$group->getMgId($group_id);

   // if (!$mobile || !$name || !$app_type || !$reg_id) {
    if (!$mobile  || !$app_type || !$reg_id || !$pincode_home || !$company_id) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'some Param is missing'));
        return $response;
        exit();
    }

    //$param="mobile=$mobile&name=$name&app_type=$app_type&reg_id=$reg_id&type=$type&default_mg_id=$default_mg_id";
    $param="mobile=$mobile&pincode_home=$pincode_home&pincode_work=$pincode_work&app_type=$app_type&reg_id=$reg_id&type=$type";
    $result=call_msg_server('/msg-api/subscriber/register',$param);
    $response->setContent($result);
    return $response;
});
/*******************************************End Register subscriber  Function************************************************/
/*******************************************Register subscriber  Function****************************************************/
$app->get('/subscriber/edit', function() use ($app) {    
    $response = new Response();

    $subscriber_id=$app->request->get('subscriber_id','int');
    $pincode_home=$app->request->get('pincode_home','int');
    $pincode_work=$app->request->get('pincode_work','int');
    $dob=$app->request->get('dob');
    $doa=$app->request->get('doa');
    $gender=$app->request->get('gender');
    $name=urlencode($app->request->get('name'));
    $occupation=urlencode($app->request->get('occupation'));
   // if (!$mobile || !$name || !$app_type || !$reg_id) {
    if (!$subscriber_id  || !$pincode_home) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'some Param is missing'));
        return $response;
        exit();
    }

    //$param="mobile=$mobile&name=$name&app_type=$app_type&reg_id=$reg_id&type=$type&default_mg_id=$default_mg_id";
    $param="subscriber_id=$subscriber_id&pincode_home=$pincode_home&pincode_work=$pincode_work&occupation=$occupation&name=$name&gender=$gender&doa=$doa&dob=$dob";
    $result=call_msg_server('/msg-api/subscriber/edit',$param);
    $response->setContent($result);
    return $response;
});
/*******************************************End Register subscriber  Function************************************************/

/*******************************************validate Function****************************************************************/
$app->get('/subscriber/validate', function() use($app){
     $response = new Response(); 
     $subscriber_id=$app->request->get('subscriber_id','int');
     $security_code=$app->request->get('security_code'); 

     if (!$subscriber_id || !$security_code) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'some Param is missing'));
        return $response;
        exit();
     }
    
     $param="subscriber_id=$subscriber_id&security_code=$security_code";
     $result=call_msg_server('/msg-api/subscriber/validate',$param);
     $response->setContent($result);
     return $response;
});
/*******************************************End validate Function************************************************************/

 /*$response = new Response();
        $response->setJsonContent($data);
        return $response;
        exit();*/
   

/*******************************************update group permission Function**************************************************/
$app->get('/group/permission', function() use($app){
    $response = new Response();

    $subscriber_id=$app->request->get('subscriber_id');
    $status=$app->request->get('status');
    $mg_id=$app->request->get('mg_id');
    $mobile=$app->request->get('mobile');

    if (!$subscriber_id || !$status || !$mg_id) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'some Param is missing'));
        return $response;
        exit();
    }
    
    $param="subscriber_id=$subscriber_id&mg_id=$mg_id&status=$status&mobile=$mobile";
    $result=call_msg_server('/msg-api/group/permission',$param);
    $response->setContent($result);
    return $response;
});
/*******************************************End update group permission Function***********************************************/



/*******************************************feedback Function******************************************************************/
$app->get('/feedback', function() use($app){
     $response = new Response(); 
     $mobile=$app->request->get('mobile');
     $subject=$app->request->get('subject');
     $message=$app->request->get('message');
     if (!$subject || !$message ||!$mobile) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'All fields are required'));
        return $response;
        exit();
     }
     /*send email to admin*/
                  require_once('../app/library/Mail/class.phpmailer.php');
                  $Username = "beforedoctor.com@gmail.com";
                  $Password = "Wg@12345";
                  $mail             = new PHPMailer();
                  $body             = $message;
                  $mail->IsSMTP();
                  //$mail->SMTPDebug  = 2;
                  $mail->SMTPAuth   = true;    
                  $mail->Host       = "smtp.gmail.com";
                  $mail->Port       = 587;
                  $mail->Username   = $Username;
                  $mail->Password   = $Password;
                  $mail->SMTPSecure = 'tls';
                  $mail->SetFrom($Username, "Sancharapp");
                  $mail->Subject    = $subject.' :from '.$mobile;
               
                  $mail->MsgHTML($body);
                  $address = "dhiraj.ingole@webgile.com";
                  $mail->AddAddress($address);
               /*   if(!$mail->Send())
                    echo "Message was not sent <br />PHPMailer Error: " . $mail->ErrorInfo;
                else
                    echo "Message has been sent";*/
     /*END send email to admin*/
     if ($mail->Send()){
        $response->setStatusCode(200,"success");
        $response->setJsonContent(array('status' => 'success'));
      } else{            
        $response->setStatusCode(200, "invalid");
        $response->setJsonContent(array('status' => 'invalid', 'messages' => 'Try after some time'));
      }

     return $response;
});

/*******************************************End feedback Function**************************************************************/
/*******************************************update GCM reg ID Function******************************************************************/
$app->get('/update_GCM_ID', function() use($app){
     $response = new Response(); 
     $subscriber_id=$app->request->get('subscriber_id','int');
     $reg_id=$app->request->get('reg_id');
   
    if(!$subscriber_id || !$reg_id) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'some Param is missing'));
        return $response;
        exit();
    }
     
     $param="subscriber_id=$subscriber_id&reg_id=$reg_id";     
     $result=call_msg_server('/msg-api/update_GCM_ID',$param);
     //$result=json_decode($result,true);
     $response->setContent($result);
     return $response;
});

/*******************************************End update GCM reg ID Function**************************************************************/
/*******************************************Blocklist  Function************************************************************/
$app->get('/getConfig', function() use($app){
    //$start = microtime(true);
    $final_result=array();
    $response = new Response(); 
    $subscriber_id=$app->request->get('subscriber_id','int');
    $pincodes=$app->request->get('pincodes');
    if (!$subscriber_id || !$pincodes) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }
    $param="subscriber_id=$subscriber_id";
    $result=json_decode(call_msg_server('/msg-api/getBlocklist',$param),true);
    $user =new User(); 
    if(count($result)>0){
        $mg_ids=implode(",",$result);
        $blocklist=$user->getBlocklist($mg_ids);
        array_push($final_result, array('blocklist' =>$blocklist));
    }
    //load welcome messages
    $default_messages=$user->getDefaultMessages($subscriber_id,$result);//get default welcome message admin / public service 
    $appusermsg=$user->getAppuserMessage($subscriber_id,5);
    $usermsg=$user->getUserMessage($subscriber_id,5);
    array_push($final_result, array('default_messages' =>$default_messages,'Appuser_messages' =>$appusermsg,'User_messages' =>$usermsg));
    //echo round((microtime(true) - $start),3)."sec";
    //file_put_contents("api_log.txt", "\n".print_r($final_result, true),FILE_APPEND);
    echo json_encode($final_result);
});
/*******************************************End Blocklist  Function************************************************************/
/*******************************************update GCM reg ID Function******************************************************************/
$app->get('/update_NotificationStatus', function() use($app){
     $response = new Response(); 
     $subscriber_id=$app->request->get('subscriber_id','int');
     $status=$app->request->get('status');
   
    if(!$subscriber_id || !$status) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'some Param is missing'));
        return $response;
        exit();
    }
     
     $param="subscriber_id=$subscriber_id&status=$status";     
     $result=call_msg_server('/msg-api/update_NotificationStatus',$param);
     $response->setContent($result);
     return $response;
});

/*******************************************End update GCM reg ID Function**************************************************************/
/*******************************************update feedback website Function******************************************************************/
$app->get('/feedback/update', function() use($app){
     $response = new Response(); 
     
     $mobile= $app->request->get('mobile');
     $feed_id= $app->request->get('feed_id');
     $answers= $app->request->get('answers');
     $datetime=date('Y-m-d H:i:s');

    if(!$mobile || !$feed_id||!$answers) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'some Param is missing'));
        return $response;
        exit();
    }
     $sql='UPDATE `feedback_results` SET `ustatus`="Delivered",`datetime`="'.$datetime.'",`answers`="'.$answers.'" WHERE mobile='.$mobile.' AND feed_id='.$feed_id.'';
      // echo $sql;exit;
     if($app->db->execute($sql))
        $response->setJsonContent(array('status'=>'success'));
     else
        $response->setJsonContent(array('status'=>'failed','message'=>'Please try later'));
     return $response;
});

//ganesh
$app->get('/feedback/result', function() use($app){
     $response = new Response(); 
     $feed_id= $app->request->get('feed_id');
    //  echo $feed_id;exit;

     $feedback=new Feedback();
     echo $result=$feedback->results($feed_id);
});

/*******************************************End update feedback website Function**************************************************************/
/*******************************************update feedback website Function******************************************************************/
$app->get('/reportspam', function() use($app){
      $response = new Response(); 
     
      $subscriber_id= $app->request->get('subscriber_id');
      $mg_id= $app->request->get('mg_id');
      $reason= urlencode($app->request->get('reason'));
      if(!$subscriber_id || !$mg_id) {
          $response->setJsonContent(array('status' => 'error', 'messages' => 'some Param is missing'));
          return $response;
          exit();
      }
      $param="subscriber_id=$subscriber_id&mg_id=$mg_id&reason=$reason";     
      $result=call_msg_server('/msg-api/reportspam',$param);
      $response->setContent($result);
      return $response;
});

/*******************************************End update feedback website Function**************************************************************/
/*******************************************resendOTP Function******************************************************************/
$app->get('/resendOTP', function() use($app){
     $response = new Response();
     $subscriber_id=$app->request->get('subscriber_id','int');
     $mobile=$app->request->get('mobile');

    if(!$subscriber_id || !$mobile) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'some Param is missing'));
        return $response;
        exit();
    }

     $param="subscriber_id=$subscriber_id&mobile=$mobile";
     $result=call_msg_server('/msg-api/resendOTP',$param);
     $response->setContent($result);
     return $response;
});

/*******************************************End update GCM reg ID Function**************************************************************/
/*******************************************checkServerMessage Function************************************************************/
$app->get('/checkServerMessage', function() use($app){
    $response = new Response();
    $subscriber_id=$app->request->get('subscriber_id','int');
    if (!$subscriber_id) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }
    $param="subscriber_id=$subscriber_id";
    $result=call_msg_server('/msg-api/checkServerMessage',$param);
    $response->setContent($result);
    return $response;
});
/*******************************************End checkServerMessage Function************************************************************//*$app->get('/notification_delivery', function() use($app){
    $response = new Response();
    $subscriber_id=$app->request->get('subscriber_id','int');
    $last_access_date=base64_encode($app->request->get('last_access_date'));
    if (!$subscriber_id || !$last_access_date) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }
    $param="subscriber_id=$subscriber_id&last_access_date=$last_access_date&type=BeforeDoctor";
    $result=call_msg_server('http://beforedoctor.com/msg-api/notification_delivery',$param);
    echo $result;
});
$app->get('/notification_delivery_single', function() use($app){
    $response = new Response(); 
    $subscriber_id=$app->request->get('subscriber_id','int');
    $msg_id=$app->request->get('msg_id');
    
    //$mobile=$app->request->get('mobile');
    if (!$subscriber_id) {
        $response->setJsonContent(array('status' => 'error', 'messages' => 'Param is missing'));
        return $response;
        exit();
    }
    $param="subscriber_id=$subscriber_id&msg_id=$msg_id&type=BeforeDoctor";
    $result=call_msg_server('http://beforedoctor.com/msg-api/notification_delivery_single',$param);
    echo $result;
});*/

/*******************************************End main Function******************************************************************/


$app->notFound(function () use ($app) {
    $app->response->setStatusCode(404, "Not Found")->sendHeaders();
    echo 'Page not found!';
});
$app->before(function () use ($app) {
        //store in log file
        $sPath = '../public/log/app/' . date('Y-m-d') . '.log';
        file_put_contents($sPath,"\n"."Request----->"."\n".print_r($_REQUEST,true),FILE_APPEND);
});
$app->after(function () use ($app) {
    // This is executed after the route is executed
  try{
    $sPath = '../public/log/app/' . date('Y-m-d') . '.log';
    $content=$app->getReturnedValue();//($app->getReturnedValue()->getContent()) ? $app->getReturnedValue()->getContent() : '';
    file_put_contents($sPath,"\n"."Response----->"."\n".print_r($content,true),FILE_APPEND);
  }catch (Exception $e) {
    file_put_contents("api_log.txt", $e->getMessage()."\n",FILE_APPEND);
  }
});

$app->handle();
?>