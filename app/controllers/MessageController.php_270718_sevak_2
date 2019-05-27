<?php

use Phalcon\Http\Response;
/**
 * MessageController
 *
 * Allows to authenticate users
 */
class MessageController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Message');
        parent::initialize();
    }
    public function deliveryAction()
    {
      $this->view->disable();
      $data = json_decode($this->request->getPost('data'),true);
      $ids='';
      $sql = "UPDATE `message` SET `status`= CASE id ";
              foreach ($data as $key => $value) { 
                  $sql .= "WHEN '".$value['id']."' THEN '".$value['status']."'";
                  $ids .="'".$value['id']."',";
              }
      $sql .= " END WHERE id IN (".rtrim($ids, ",").") AND status <>'Read'";
      //echo $sql;
      $this->db->query($sql);
    }
    public function sendAction()
    {  
    //    echo "<pre>"; 
    //print_r($_SESSION);
    //    print_r($_REQUEST);
    //    exit;
       $auth = $this->session->get('auth');
        $s_id = $this->db->query("SELECT text from senderID where user_id = '".$auth['id']."'")->fetch();
        // print_r($auth);
        // var_dump($s_id);
        // exit;
        if(!$s_id){
            $this->flash->notice('Please create your sender id (in your plan you can\'t update it later)');
            return $this->response->redirect("account/index");
        }else
            $sender_id=$s_id['text'];
        $start = microtime(true);        
        $request=$this->request;
        $response = new Response();
   
        if ($request->isPost()) {
            $this->view->disable();
            $option=$request->getPost('option');        
            $group_id=$request->getPost('group_id','int');
            $to_type_msg=$request->getPost('to_type_msg');
            $mobile_no=$request->getPost('mobile_no');
            $mobile_no=trim(str_replace(["\r\n","\r","\n"], ',', $mobile_no),",");
            $user_id=$auth['id'];     
            $user=User::findFirstById($user_id);
            $mobile_array=array();
            $total_msg_sent='';
            $linkapp_user_count='';
            $msg_obj=new Message();
            $message_type=$request->getPost('msg_field_type');
            $not_in_group_array=array();
            // echo $to_type_msg;exit; //single
                switch ($to_type_msg) {
                    case 'group':
                        $mobile_array=$msg_obj->getGroupNumbers($group_id);
                        break;
                    case 'excelfile':
                        if(is_uploaded_file($_FILES['excelfile']['tmp_name']))
                        {
                            $mobile_no=$msg_obj->getExcelNumbers($_FILES);
                            if($user->http_api_whitelist_status){
                                $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                            }else{
                                $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                            }
                            /*code to find contacts not in group*/
                            $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                            /*End code contacts*/
                        }
                        break;       
                    case 'pincode':
                            $active_radio = $request->getPost('public_service_radio');
                            $pincode_range_min=$request->getPost('pincode_range_min');
                            $pincode_range_max=$request->getPost('pincode_range_max');
                            $pincode_ids=$request->getPost($active_radio);
                            $mobile_array=$msg_obj->getPincodeNumbers($user_id,$active_radio,$pincode_range_min,$pincode_range_max,$pincode_ids);
                            $route_pin='Public_service';
                            break;
                    default:
                            if($user->http_api_whitelist_status && $to_type_msg=="single"){
                                $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                            }else{
                                $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                            }
                            /*code to find contacts not in group*/
                            
                            $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                        //    print_r($not_in_group_array);
                            // exit;
                            /*End code contacts*/
                        break;
                }
              
         /*       if(!count($mobile_array)){
                        $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group",'mob'=>$mobile_array));
                        return $response;
                }*/
                $user_permission = $user->getPermissions($auth['id']); 
               // print_r($user_permission);exit;
                $config = Configuration::findFirst();
             $app_access_days = $config->app_access_days;   

// if($user_permission['dnd']=='yes'){
//     echo json_encode(array('status' =>'dnd' ,'msg'=>"you can't send msg becouse of DND " ));
//     exit();
// }
            // echo $option;exit;
                //check for thirdparty sms api status************************************
if($option!='Multimedia'){
                    switch ($option) {
                            case 'SMS':
                            /*code to find contacts not in group*/
                            
                          //  if(!$not_in_group_array)
                            //    $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
            
                            /*End code contacts*/
                                $total_msg_sent=count($mobile_array);
                                $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/sortMobile_Numbers',"app_access_days=$app_access_days&mobile=".json_encode($mobile_array));
                                $result=json_decode($result,true);
                                
                                $sms_numbers=$result['sms'];
                                $mobile_array=$result['notification'];

                                if(count($sms_numbers)>0 && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){
                                    if($message_type=="text"){
                                        $message = $request->getPost('text');
                                    }else{
                                        $message = $msg_obj->getMultiMediaMessage($request->getPost('multimedia'));
                                    }
                                    $msg_obj->SMSHandler($user_id,$message,$sms_numbers,$request->getPost('message_type'));
                                }
                                           /////////////start number not in contacts
                                   $ntf_message = $request->getPost('multimedia');
                                   $sql = $this->db->query("SELECT MAX(bunch_id) as bunch_id from message")->fetch();
                                    if($sql['bunch_id'] == NULL)
                                        $bun_id = 1;
                                    else
                                        $bun_id = $sql['bunch_id']+1;
                                       if(count($not_in_group_array)>0 && $not_in_group_array!=""){
                                        $key=0;

                                            //for($arr_count=0;$arr_count<count($not_in_group_array);$arr_count++,$key++) {  
                                        foreach ($not_in_group_array as $key => $value1) {
                                          
                                                   $insert_arr[$key][]=$user_id;
                                                    $insert_arr[$key][]=$request->getPost('text');
                                                    $insert_arr[$key][]=$ntf_message;
                                                    $insert_arr[$key][]= date('Y-m-d H:i:s');
                                                    $insert_arr[$key][]=$value1;
                                                    $insert_arr[$key][]="Not in Contacts";   
                                                    $insert_arr[$key][]="SMS";
                                                    $insert_arr[$key][]=$sender_id;
                                                    $insert_arr[$key][]=$option;
                                                    $insert_arr[$key][]=$bun_id;
                                                    $insert_arr[$key][]=null;
                                            }
                                               if($insert_arr){
                                            $batch = new Batch('message');
                                            $batch->setRows(['user_id','text','multimedia','datetime','mobile','status','route','sender_id','option','bunch_id','priority'])
                                            ->setValues($insert_arr)->insert();
                                        }
                                        }
                                      if(!count($sms_numbers)){
                                               $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group",'mob'=>$mobile_array));
                                                return $response;
                                        }
                //////////////////////////////end number not in contacts
                                $response->setJsonContent(array('status' => "success","total_msg_sent"=>$total_msg_sent,"linkapp_user_count"=>"0",'is_unicode'=>$request->getPost('message_type')));
                                return $response;
                                break;
                            case 'Default':

                                $total_msg_sent=count($mobile_array);
                                $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/sortMobile_Numbers',"app_access_days=$app_access_days&mobile=".json_encode($mobile_array));
                                $result=json_decode($result,true);
                                
                                $sms_numbers=$result['sms'];
                                $mobile_array=$result['notification'];

                                if(count($sms_numbers)>0 && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){
                                    if($message_type=="text"){
                                        $message = $request->getPost('text');
                                    }else{
                                        $message = $msg_obj->getMultiMediaMessage($request->getPost('multimedia'));
                                    }
                                    $msg_obj->SMSHandler($user_id,$message,$sms_numbers,$request->getPost('message_type'));
                                }
                                //set option to multimedia so remaining app number send directly as multimedia
                                $option='Multimedia';
                                break;

                    
                    } 
                }

                $ntf_msg = $request->getPost('multimedia');
                if($total_msg_sent=='')
                    $total_msg_sent=count($mobile_array);
                    //take no min and add to current date 
                $min=$request->getPost('priority');
                $date =new DateTime('NOW');
                $time_intervals = explode(",",$user_permission['time_bound_delivery']);
                if($min==0 ||$min==""||$user_permission['time_bound_delivery']=='No'||in_array($min,$time_intervals)==false){
                    $priority=null;
                }else{
                    $date->add(new DateInterval('P0DT0H'.$min.'M0S'));
                    $priority=$date->format('Y-m-d H:i:s');
                }

                $arr = array();    
                $text = urlencode($request->getPost('text'));
                $multimedia = base64_encode(htmlentities($ntf_msg));
                $datetime = base64_encode(date('Y-m-d H:i:s'));
                $status="Pending";    
                $route="Notification";

                if($request->getPost('route'))
                    $route=$request->getPost('route');
                //$sender_id=$request->getPost('sender_id');
                $i=0;
                $count_arr=0;
                $mg_id=$user->mg_id;
                $count = $user->sms_quota;
                if($user_permission['text_message']!='unlimited'){
                    $sending_limit = explode("/", $user_permission['text_message']);
                    $msg_limit = $sending_limit[0];
                }else
                    $msg_limit = $user_permission['text_message'];
                $char_limit = $user_permission['text_message_size_limitation'];

                $insert_arr = array(); $mobile = array();
                $sql = $this->db->query("SELECT MAX(bunch_id) as bunch_id from message")->fetch();
                if($sql['bunch_id'] == NULL)
                  $bunch_id = 1;
                else
                  $bunch_id = $sql['bunch_id']+1;

                //   var_dump($sms_number);
              if(isset($sms_numbers)){
                        $mobile_array=$sms_numbers;
              }
                foreach ($mobile_array as $key => $value1) {  
                    if($option!="Multimedia" || ($option=="Multimedia" && ($msg_limit=="unlimited" || ($msg_limit!="unlimited" && ($count+($key+1))<=$msg_limit)))){
                        $insert_arr[$key][]=$user_id;
                        $insert_arr[$key][]=$request->getPost('text');
                        $insert_arr[$key][]=$ntf_msg;
                        $insert_arr[$key][]= date('Y-m-d H:i:s');
                        $insert_arr[$key][]=$value1;
                        $insert_arr[$key][]=$status;   
                        $insert_arr[$key][]=$route;
                        $insert_arr[$key][]=$sender_id;
                        $insert_arr[$key][]=$option;
                        $insert_arr[$key][]=$bunch_id;
                        $insert_arr[$key][]=$priority;
                        if($option=="Multimedia")
                            $i++;
                        $count_arr++;
                    }
                }
                // print_r(count($not_in_group_array));exit;
            if(count($not_in_group_array)>0){
            $key=$count_arr;
                for($arr_count=0;$arr_count<count($not_in_group_array);$arr_count++,$key++) {  
                       $insert_arr[$key][]=$user_id;
                        $insert_arr[$key][]=$request->getPost('text');
                        $insert_arr[$key][]=$ntf_msg;
                        $insert_arr[$key][]= date('Y-m-d H:i:s');
                        $insert_arr[$key][]=$not_in_group_array[$arr_count];
                        $insert_arr[$key][]="Not in Contacts";
                        $insert_arr[$key][]=$route;
                        $insert_arr[$key][]=$sender_id;
                        $insert_arr[$key][]=$option;
                        $insert_arr[$key][]=$bunch_id;
                        $insert_arr[$key][]=$priority;
                }
            }
                if($insert_arr){
                    $batch = new Batch('message');
                    $batch->setRows(['user_id','text','multimedia','datetime','mobile','status','route','sender_id','option','bunch_id','priority'])
                    ->setValues($insert_arr)->insert();
                    echo $route;
                    if($route=="Reply")
                    {
                        $query = $this->db->query("SELECT id, mobile from message where bunch_id = '".$bunch_id."' and status='Pending'")->fetchAll();

                    }else {
                        $query = $this->db->query("SELECT id, mobile from message where bunch_id = '".$bunch_id."' and status='Not in Contacts' OR status='Pending'")->fetchAll();
                    }
    // $query = $this->db->query("SELECT id, mobile from message where bunch_id = '".$bunch_id."' and status='Not in Contacts'")->fetchAll();
    // echo "SELECT id, mobile from message where bunch_id = '".$bunch_id."' and status='Not in Contacts'";
//    echo "SELECT id, mobile from message where bunch_id = '".$bunch_id."' and status='Not in Contacts'";
    // print_r($query);           
    foreach ($query as $key => $value) {
                        $mobile[$value['id']] = $value['mobile'];
                    }
                }
                $user->sms_quota += $i;
                $user->update();
                //  print_r(($mobile));
            //    echo count($mobile);exit;
                if(!count($mobile)){
                        $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group",'mob'=>$mobile_array));
                        return $response;
    //            file_put_contents('message_log.txt', __FUNCTION__.':'.round((microtime(true) - $start),3)."sec DT: ".date("D, d M y H:i:s O").'
    //', FILE_APPEND);
       
      //              $response->setJsonContent(array('status' => "success","total_msg_sent"=> $total_msg_sent,"linkapp_user_count"=>"0","not_in_group_array"=>$not_in_group_array));
        //            return $response;
          //          exit();
                }
                $mobile_str = json_encode($mobile);
                $sender_id=urlencode($sender_id);
                // print_r($mobile_str);exit;
                $param="mg_id=$mg_id&text=$text&multimedia=$multimedia&datetime=$datetime&status=$status&route=$route&sender_id=$sender_id&option=$option&app_access_days=$app_access_days&msg_limit=$msg_limit&sms_quota=$count&char_limit=$char_limit&sender_jid=".$auth['jid']."&sender_pass=".$auth['j_pass']."&"; 
                $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/send_msg',$param."mobile=$mobile_str");
                //  var_dump($result);
                //  exit();

                /*After Server Response Update Local Message table Status*/
                $result=json_decode($result,true);
                $result_counts = array_count_values($result);
                if($result){
                    $sql = "UPDATE `message` SET `status`= CASE id ";
                    $ids='';
                    foreach ($result as $id=>$data) {
                      $sql .= "WHEN '".$id."' THEN '".$data."'";
                      $ids .="'".$id."',";
                    }
                 /*store linkapp user count if already not set*/
                 if($result_counts['Sent']){
                    $linkapp_user_count=$result_counts['Sent'];
                }else
                {
                    $result_counts['Sent']=0;
                
                 /*END store linkapp user count if already not set*/
                }
                }
                $sql .= "END WHERE id IN (".rtrim($ids, ",").") AND status = 'Pending'";
                $this->db->execute($sql);
                /*END After Server Response*/

                /*Notification Code END*/
                file_put_contents('message_log.txt', __FUNCTION__.':'.round((microtime(true) - $start),3)."sec DT: ".date("D, d M y H:i:s O").'
    ', FILE_APPEND);
 if(empty($not_in_group_array)){$not_in_group_array=0;}
 if(empty($linkapp_user_count)){$linkapp_user_count=0;}
                $response->setJsonContent(array('status' => "success","total_msg_sent"=> $total_msg_sent,"linkapp_user_count"=>$linkapp_user_count,"not_in_group_array"=>$not_in_group_array));
                return $response;
        }

    }

    public function verifyAction(){    	
        $this->view->disable();
        $auth = $this->session->get('auth');
        $response = new Response();
        $request=$this->request;      
        if ($request->isPost()) { 
            $option=$request->getPost('option'); 
            $message=$request->getPost('multimedia');
            $mobile_count=$request->getPost('mobile_count');
            $msg=new Message();
            $response->setJsonContent($msg->verify($auth['id'],$option,$mobile_count,$message));
            return $response;
        }  
    }
    public function send_excelmsgAction(){
      $this->view->disable();
        try{
        if(is_uploaded_file($_FILES['excelfile']['tmp_name']))
        {
         require_once APP_PATH.'app/library/PHPExcel/Classes/PHPExcel.php';
            $unset_array=array();
            $dataFfile = $_FILES['excelfile']['tmp_name'];
            $path = $_FILES['excelfile']['name'];
            $msg_obj=new Message();
            $ext = pathinfo($path, PATHINFO_EXTENSION);
            unset($path);
            $allowedFile=array('xls','xlsx','txt');
            $total_msg_sent='';
            if (in_array($ext, $allowedFile)) {           
                $objPHPExcel = PHPExcel_IOFactory::load($dataFfile);
                unset($dataFfile);
                // Get the active sheet as an array
                $activeSheetData = $objPHPExcel->getActiveSheet()->toArray(null, true, true, true);                
                unset($objPHPExcel);
            }else{           
                  $this->flash->error('Invalid File');                  
            }
            $unset_array=array($ext,$allowedFile);
            unset($unset_array);
            $arr=array();  
            $keys=array();
            $mobile_no='';
              $message_ele=$this->getContents($_POST['message_val'], '<', '>');
                   $message_val1=$_POST['message_val'];
                   array_push($keys,$this->chkkey($activeSheetData));                                                  
                   for($i=1;$i<=sizeof($activeSheetData);$i++){
                            foreach($message_ele as $val){              
                             for($j=0;$j<sizeof($keys[0]);$j++){   
                                 if($keys[0][$j]==$val){    
                                        if(isset($activeSheetData[$i][$val])){             
                                                $message_val1=str_replace('<'.$val.'>',$activeSheetData[$i][$val] ,$message_val1);
                                        }else{     
                                                $message_val1=str_replace('<'.$val.'>','',$message_val1);
                                        }
                                }else{
                                        $message_val1=str_replace('<'.$val.'>','<'.$val.'>',$message_val1);
                            }
                            }                            
                        }           
                                                             
                        if(isset($activeSheetData[$i][$_POST['mob_select']])){     
                            $arr[$i]['mob']=$activeSheetData[$i][$_POST['mob_select']];
                        }else{
                            $arr[$i]['mob']='';
                        } 

                         if(is_numeric($arr[$i]['mob'])){                  
                                   $grouped_types[$arr[$i]['mob']] = $message_val1;    
                                   $mobile_no.=$arr[$i]['mob'].',';                        
                        }    

                            $message_val1=$_POST['message_val'];
                    }   
                   
                      $unset_array=array($activeSheetData,$arr,$keys,$message_ele,$message_val1);
                      unset($unset_array);   
                    $auth = $this->session->get('auth');
                    $s_id = $this->db->query("SELECT text from senderID where user_id = '".$auth['id']."'")->fetch();
                    if(!$s_id){
                        $this->flash->notice('Please create your sender id (in your plan you can\'t update it later)');
                        return $this->response->redirect("account/index");
                    }else
                        $sender_id=$s_id['text'];
                    unset($s_id);
                    $start = microtime(true);                
                    $request=$this->request;
                    $response = new Response();
                    $option=$request->getPost('option1');     
                    $user_id=$auth['id'];       
                    $user=User::findFirstById($user_id);
                    $user_permission = $user->getPermissions($auth['id']);
                    unset($auth);
                    $config = Configuration::findFirst();
                    $app_access_days = $config->app_access_days;   
                    $mobile_array = array();
                    $mobile_no=rtrim($mobile_no, ",");
                    $linkapp_user_count='';         

                    if($user->http_api_whitelist_status){
                        $smt=$this->db->query("SELECT DISTINCT s.mobile FROM `subscriber` s,`group` g,`user` u WHERE s.group_id=g.id AND g.user_id=u.id AND u.id=".$user->id." AND s.mobile IN (".$mobile_no.")");
                        $smt->setFetchMode(PDO::FETCH_COLUMN,0);
                        $mobile_array=$smt->fetchAll(); 
                    }
                    unset($smt);
                    /*if(!count($mobile_array)){
                        $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group"));
                        return $response;
                    }*/
                    $config = Configuration::findFirst();
                    $app_access_days = $config->app_access_days; 
                    unset($config);
                    $not_in_group_array=array();  
                    $mobile=array();      
                    $api = Api::findFirst("user_id=$user_id");
                   //check for thirdparty sms api status************************************
                    if($option!='Multimedia1'){//code of sms and defult are same 
                    switch ($option) {
                            case 'SMS'://in sms first execute sms code then multimedia code
                                    if($user->http_api_whitelist_status){
                                          $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                                           /*code to find contacts not in group*/   
                                           $mobileno=$msg_obj->sanitizeMobileNumbers($mobile_no);
                                          $not_in_group_array=array_values(array_diff($mobileno,$mobile_array));
                                    }else{
                                        $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                                        /*code to find contacts not in group*/
                                          $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                                    }
                                   
                                  
                                     unset($mobile_no);
                                    /*End code contacts*/
                                    if($api && $api->status=='Enable' && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){          
                                         $char_limit = $user_permission['text_message_size_limitation'];
                                         foreach ($grouped_types as $mobiles => $msg) {
                                                if($char_limit!="unlimited")
                                                    $msg[0]=substr($msg[0],0,$char_limit);
                                         }
                                         unset($api);
                                         $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/sortMobile_Numbers',"app_access_days=$app_access_days&mobile=".json_encode($mobile_array));
                                         $result=json_decode($result,true);       
                                         $sms_numbers=$result['sms'];
                                         $mobile_array=$result['notification'];        
                                         $linkapp_user_count=count($mobile_array);
                                         unset($result);               
                                         $total_msg_sent=count($sms_numbers);
                                   if(count($sms_numbers)>0 && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){
                                        foreach ($sms_numbers as $key => $mobiles) {   
                                             $msg_obj->SMSHandler($user_id,$grouped_types[$mobiles],array($mobiles),$request->getPost('message_types'));
                                    
                                              }
                                              unset($msg_obj);
                                         }
                                            /////////////start number not in contacts
                                          
                                   $ntf_message = $request->getPost('multimedia');
                                   $sql = $this->db->query("SELECT MAX(bunch_id) as bunch_id from message")->fetch();
                                    if($sql['bunch_id'] == NULL)
                                        $bun_id = 1;
                                    else
                                        $bun_id = $sql['bunch_id']+1;
                                       if(count($not_in_group_array)>0){
                                        $key=0;

                                            //for($arr_count=0;$arr_count<count($not_in_group_array);$arr_count++,$key++) {  
                                          foreach ($not_in_group_array as $key => $value1) {  
                                                   $insert_arr[$key][]=$user_id;
                                                    $insert_arr[$key][]=$grouped_types[$value1];
                                                    $insert_arr[$key][]=$ntf_message;
                                                    $insert_arr[$key][]= date('Y-m-d H:i:s');
                                                    $insert_arr[$key][]=$value1;
                                                    $insert_arr[$key][]="Not in Contacts";   
                                                    $insert_arr[$key][]="SMS";
                                                    $insert_arr[$key][]=$sender_id;
                                                    $insert_arr[$key][]=$option;
                                                    $insert_arr[$key][]=$bun_id;
                                                    $insert_arr[$key][]=null;
                                            }
                                        if($insert_arr){
                                            $batch = new Batch('message');
                                            $batch->setRows(['user_id','text','multimedia','datetime','mobile','status','route','sender_id','option','bunch_id','priority'])
                                            ->setValues($insert_arr)->insert();
                                        }
         
                                        }
                                  
                                        if(!count($sms_numbers)){
                                               $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group",'mob'=>$mobile_array));
                                                return $response;
                                        }
                //////////////////////////////end number not in contacts
                                         unset($sms_numbers);
                                    $response->setJsonContent(array('status' => "success","total_msg_sent"=>$total_msg_sent,"linkapp_user_count"=>$linkapp_user_count ,"not_in_group_array"=>$not_in_group_array));
                                        return $response;                                       
                                    }else{
                                        $response->setJsonContent(array('status' => "error","message"=>"Can not send message since you have not enabled third party api"));
                                                return $response;
                                        
                                    }  
                                  break;
                            case 'Default':       //in multimedia first execute default code then multimedia code                  
                                    if($user->http_api_whitelist_status){
                                        $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                                         /*code to find contacts not in group*/
                                         $mobileno=$msg_obj->sanitizeMobileNumbers($mobile_no);
                                    $not_in_group_array=array_values(array_diff($mobileno,$mobile_array));
                              
                                    /*End code contacts*/
                                    }else{
                                        $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                                         /*code to find contacts not in group*/
                                    $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                              
                                    /*End code contacts*/
                                    }
                                   
                                    if($api && $api->status=='Enable' && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){          
                                         $char_limit = $user_permission['text_message_size_limitation'];
                                         foreach ($grouped_types as $mobiles => $msg) {
                                                if($char_limit!="unlimited")
                                                    $msg[0]=substr($msg[0],0,$char_limit);
                                         }
                                         unset($api);
                                         $total_msg_sent=count($mobile_array);
                                         $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/sortMobile_Numbers',"app_access_days=$app_access_days&mobile=".json_encode($mobile_array));
                                         $result=json_decode($result,true);       
                                         $sms_numbers=$result['sms'];//separate sms and notification array chuncks
                                         $mobile_array=$result['notification'];               
                                         unset($result);
                                         if(count($sms_numbers)>0 && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){
                                               foreach ($sms_numbers as $key => $mobiles) {   
                                                       $msg_obj->SMSHandler($user_id,$grouped_types[$mobiles],array($mobiles),$request->getPost('message_types'));
                                              }
                                              unset($msg_obj);                                              
                                         }
                                      //   unset($sms_numbers);
                                   }                                    
                                   $option='Multimedia1';
                                   break;                    
                    }      
                  }
                if($total_msg_sent=='')
                    $total_msg_sent=count($mobile_array);
              
                $datetime = base64_encode(date('Y-m-d H:i:s'));
                $status="Pending";
                $route="Notification";
                 if($request->getPost('route'))
                    $route=$request->getPost('route');
                 
                 $i=0;
                $mg_id=$user->mg_id;
                $count = $user->sms_quota;
                $mobile_count=count($mobile_array);
                $msg=new Message();
                foreach ($mobile_array as $key=> $mobiles) {
                    $temp_message=$grouped_types[$mobiles][0];
                    $res=$msg->verify($user->id,$option,$mobile_count,$temp_message);   
                  if($res['status']!='success'){
                    echo $res['message'];
                    exit();
                }   
            }
            $unset_array=array($res,$msg,$mobile_count);
            unset($unset_array);
            //take no min and add to current date 
              
                $date =new DateTime('NOW');
                 $min=$request->getPost('priority2');
               
                $date =new DateTime('NOW');
                $time_intervals = explode(",",$user_permission['time_bound_delivery']);
                if($min==0 ||$min==""||$user_permission['time_bound_delivery']=='No'||in_array($min,$time_intervals)==false){
                    $priority=null;
                }else{
                    $date->add(new DateInterval('P0DT0H'.$min.'M0S'));
                    $priority=$date->format('Y-m-d H:i:s');
                }
                $unset_array=array($request,$time_intervals,$date,$min);
                unset($unset_array);
                if($user_permission['text_message']!='unlimited'){
                    $sending_limit = explode("/", $user_permission['text_message']);
                    $msg_limit = $sending_limit[0];
                }else
                    $msg_limit = $user_permission['text_message'];

                unset($sending_limit);
                $char_limit = $user_permission['text_message_size_limitation'];
                unset($user_permission);
                $insert_arr = array(); 
                $sql = $this->db->query("SELECT MAX(bunch_id) as bunch_id from message")->fetch();
                if($sql['bunch_id'] == NULL)
                  $bunch_id = 1;
                else
                  $bunch_id = $sql['bunch_id']+1;
                  $result1=array();
                  $key_arr=0;      
if($sms_numbers){
$mobile_array=$sms_numbers;
}
                foreach ($mobile_array as $key => $value1) {  
                        if($option!="Multimedia" || ($option=="Multimedia" && ($msg_limit=="unlimited" || ($msg_limit!="unlimited" && ($count+($key_arr+1))<=$msg_limit)))){
                            $insert_arr[$key_arr][]=$user_id;
                            $insert_arr[$key_arr][]=$grouped_types[$value1];
                            $insert_arr[$key_arr][]='';
                            $insert_arr[$key_arr][]= date('Y-m-d H:i:s');
                            $insert_arr[$key_arr][]=$value1;
                            $insert_arr[$key_arr][]=$status;   
                            $insert_arr[$key_arr][]=$route;
                            $insert_arr[$key_arr][]=$sender_id;
                            $insert_arr[$key_arr][]=$option;
                            $insert_arr[$key_arr][]=$bunch_id;
                            $insert_arr[$key_arr][]=$priority;                      
                            if($option=="Multimedia1")
                                $i++;
                }   
              $key_arr++;
             }  

               /*code to find contacts not in group*/
              if(!$not_in_group_array)
                 // $not_in_group_array=0;
                $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                                    /*End code contacts*/
                                     if(count($not_in_group_array)>0){
                                        $key=$key_arr;
                                            for($arr_count=0;$arr_count<count($not_in_group_array);$arr_count++,$key++) {  
                                                   $insert_arr[$key][]=$user_id;
                                                    $insert_arr[$key][]=$grouped_types[$not_in_group_array[$arr_count]];
                                                    $insert_arr[$key][]=$ntf_message;
                                                    $insert_arr[$key][]= date('Y-m-d H:i:s');
                                                    $insert_arr[$key][]=$not_in_group_array[$arr_count];
                                                    $insert_arr[$key][]="Not in Contacts";   
                                                    $insert_arr[$key][]="SMS";
                                                    $insert_arr[$key][]=$sender_id;
                                                    $insert_arr[$key][]=$option;
                                                    $insert_arr[$key][]=$bun_id;
                                                    $insert_arr[$key][]=null;
                                            }
                                        }
              
             $unset_array=array($key_arr,$mobile_array,$user_id); 
             unset($unset_array);

                if($insert_arr){    
                     $batch = new Batch('message');                    
                     $batch->setRows(['user_id','text','multimedia','datetime','mobile','status','route','sender_id','option','bunch_id','priority'])
                    ->setValues($insert_arr)->insert();          
                      
                      $query = $this->db->query("SELECT id, mobile from message where bunch_id = '".$bunch_id."'")->fetchAll();
                      $m=0;
                      $result_counts=0;
                       $sender_id=urlencode($sender_id); 
                      foreach ($query as $key => $value) {
                        $mobile[$value['id']] = $value['mobile'];
                        $text=$grouped_types[$value['mobile']];
                        $mobile_arr[$m][$value['id']]=$value['mobile'];
                        $mobile_str = json_encode($mobile_arr[$m]);
                        $param="mg_id=$mg_id&text=$text&datetime=$datetime&status=$status&route=$route&sender_id=$sender_id&option=$option&app_access_days=$app_access_days&msg_limit=$msg_limit&sms_quota=$count&char_limit=$char_limit&";                                         
                        $result1[$m]=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/send_msg',$param."mobile=$mobile_str");
                        $result1[$m]= json_decode($result1[$m],true);
                        if($result1[$m][$value['id']]=='Sent')
                              $result_counts++;//count sent result values
                           $m++;
                    }  
                    $unset_array=array($m,$param,$mobile_str,$text,$query,$msg_limit,$count,$mg_id,$status,$route,$datetime,$char_limit,$mobile,$app_access_days,$grouped_types,$option);
                    unset($unset_array);
                   // if(isset($result_counts)){
                  $linkapp_user_count=$result_counts;
                  unset($result_counts);
                  $user->sms_quota += $i;
                  $user->update();    
                  unset($user);
                } 
                if(!count($mobile_array)){
                        $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group",'mob'=>$mobile_array));
                        return $response;
                }
                $unset_array=array($sender_id,$bunch_id,$insert_arr,$priority,$i);
                unset($unset_array);
                 if($result1){
                    $sql = "UPDATE `message` SET `status`= CASE id ";
                    $ids='';
                    for($j=0;$j<count($result1);$j++){                  
                        foreach ($result1[$j] as $id=>$data) {
                              $sql .= "WHEN '".$id."' THEN '".$data."' ";
                              $ids .="'".$id."',";                                   
                        }                 
                    }
                 /*store linkapp user count if already not set*/
                
                 /*END store linkapp user count if already not set*/
             $sql .= "END WHERE id IN (".rtrim($ids, ",").") AND status = 'Pending'";
             $this->db->execute($sql);
                }  
                $unset_array=array($ids,$result1,$sql);
                unset($unset_array);
                /*END After Server Response*/

                /*Notification Code END*/
              file_put_contents('message_log.txt', __FUNCTION__.':'.round((microtime(true) - $start),3)."sec DT: ".date("D, d M y H:i:s O").'
    ', FILE_APPEND);
              if($not_in_group_array==""){$not_in_group_array=0;}
              
              $response->setJsonContent(array('status' => "success","total_msg_sent"=> $total_msg_sent,"linkapp_user_count"=>$linkapp_user_count,"not_in_group_array"=>$not_in_group_array));
                    return $response;
              $this->flash->success('Message Send');
                    //return $this->response->redirect("message/send"); 
        }else{
                  $response->setJsonContent(array('status' => "error","message"=>"Can not send message since you have not enabled third party api"));
                                                return $response;
                                        
                   // return $this->response->redirect("message/send"); 
        }         
      } catch(Exception $e) {
        echo 'error'.$e;
      }
      //added by poonam end
    }
      public function send_xlmsgAction(){
      $this->view->disable();
        try{
        if(is_uploaded_file($_FILES['excelfile']['tmp_name']))
        {
         require_once APP_PATH.'app/library/PHPExcel/Classes/PHPExcel.php';
            $unset_array=array();
            $dataFfile = $_FILES['excelfile']['tmp_name'];
            $path = $_FILES['excelfile']['name'];
            $msg_obj=new Message();
            $ext = pathinfo($path, PATHINFO_EXTENSION);
            unset($path);
            $allowedFile=array('xls','xlsx','txt');
            $total_msg_sent='';
            if (in_array($ext, $allowedFile)) {           
                $objPHPExcel = PHPExcel_IOFactory::load($dataFfile);
                unset($dataFfile);
                // Get the active sheet as an array
                $activeSheetData = $objPHPExcel->getActiveSheet()->toArray(null, true, true, true);                
                unset($objPHPExcel);
            }else{           
                  $this->flash->error('Invalid File');                  
            }
            $unset_array=array($ext,$allowedFile);
            unset($unset_array);
            $arr=array();  
            $keys=array();
            $mobile_no='';
              $message_ele=$this->getContents($_POST['text'], '<', '>');
                   $message_val1=$_POST['text'];
                   array_push($keys,$this->chkkey($activeSheetData));                                                  
                   for($i=1;$i<=sizeof($activeSheetData);$i++){
                            foreach($message_ele as $val){              
                             for($j=0;$j<sizeof($keys[0]);$j++){   
                                 if($keys[0][$j]==$val){    
                                        if(isset($activeSheetData[$i][$val])){             
                                                $message_val1=str_replace('<'.$val.'>',$activeSheetData[$i][$val] ,$message_val1);
                                        }else{     
                                                $message_val1=str_replace('<'.$val.'>','',$message_val1);
                                        }
                                }else{
                                        $message_val1=str_replace('<'.$val.'>','<'.$val.'>',$message_val1);
                            }
                            }                            
                        }           
                                                             
                        if(isset($activeSheetData[$i][$_POST['mob_select']])){     
                            $arr[$i]['mob']=$activeSheetData[$i][$_POST['mob_select']];
                        }else{
                            $arr[$i]['mob']='';
                        } 

                         if(is_numeric($arr[$i]['mob'])){                  
                                   $grouped_types[$arr[$i]['mob']] = $message_val1;    
                                   $mobile_no.=$arr[$i]['mob'].',';                        
                        }    

                            $message_val1=$_POST['text'];
                    }   
                    
                      $unset_array=array($activeSheetData,$arr,$keys,$message_ele,$message_val1);
                      unset($unset_array);   
                    $auth = $this->session->get('auth');
                    $s_id = $this->db->query("SELECT text from senderID where user_id = '".$auth['id']."'")->fetch();
                    if(!$s_id){
                        $this->flash->notice('Please create your sender id (in your plan you can\'t update it later)');
                        return $this->response->redirect("account/index");
                    }else
                        $sender_id=$s_id['text'];
                    unset($s_id);
                    $start = microtime(true);                
                    $request=$this->request;
                    $response = new Response();
                    $option=$request->getPost('option');     
                    $user_id=$auth['id'];       
                    $user=User::findFirstById($user_id);
                    $user_permission = $user->getPermissions($auth['id']);
                    unset($auth);
                    $config = Configuration::findFirst();
                    $app_access_days = $config->app_access_days;   
                    $mobile_array = array();
                    $mobile_no=rtrim($mobile_no, ",");
                    $linkapp_user_count='';         

                    if($user->http_api_whitelist_status){
                        $smt=$this->db->query("SELECT DISTINCT s.mobile FROM `subscriber` s,`group` g,`user` u WHERE s.group_id=g.id AND g.user_id=u.id AND u.id=".$user->id." AND s.mobile IN (".$mobile_no.")");
                        $smt->setFetchMode(PDO::FETCH_COLUMN,0);
                        $mobile_array=$smt->fetchAll(); 
                    }
                    unset($smt);
                    /*if(!count($mobile_array)){
                        $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group"));
                        return $response;
                    }*/
                    $config = Configuration::findFirst();
                    $app_access_days = $config->app_access_days; 
                    unset($config);
                    $not_in_group_array=array();  
                    $mobile=array();      
                    $api = Api::findFirst("user_id=$user_id");

                   //check for thirdparty sms api status************************************
                    if($option!='Multimedia'){//code of sms and defult are same 
                    switch ($option) {
                            case 'SMS'://in sms first execute sms code then multimedia code

                                    if($user->http_api_whitelist_status){
                                          $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                                           /*code to find contacts not in group*/   
                                           $mobileno=$msg_obj->sanitizeMobileNumbers($mobile_no);
                                          $not_in_group_array=array_values(array_diff($mobileno,$mobile_array));
                                    }else{
                                        $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                                        /*code to find contacts not in group*/
                                          $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                                    }
                                   
                                  
                                     unset($mobile_no);
                                    /*End code contacts*/
                                    if($api && $api->status=='Enable' && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){          
                                         $char_limit = $user_permission['text_message_size_limitation'];
                                         foreach ($grouped_types as $mobiles => $msg) {
                                                if($char_limit!="unlimited")
                                                    $msg[0]=substr($msg[0],0,$char_limit);
                                         }
                                         unset($api);
                                         $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/sortMobile_Numbers',"app_access_days=$app_access_days&mobile=".json_encode($mobile_array));
                                         $result=json_decode($result,true);       
                                         $sms_numbers=$result['sms'];
                                         $mobile_array=$result['notification'];        
                                         $linkapp_user_count=count($mobile_array);
                                         unset($result);               
                                         $total_msg_sent=count($sms_numbers);
                                   if(count($sms_numbers)>0 && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){
                                        foreach ($sms_numbers as $key => $mobiles) {   
                                             $msg_obj->SMSHandler($user_id,$grouped_types[$mobiles],array($mobiles),$request->getPost('message_types'));
                                    
                                              }
                                              unset($msg_obj);
                                         }
                                            /////////////start number not in contacts
                                          
                                   $ntf_message = $request->getPost('multimedia');
                                   $sql = $this->db->query("SELECT MAX(bunch_id) as bunch_id from message")->fetch();
                                    if($sql['bunch_id'] == NULL)
                                        $bun_id = 1;
                                    else
                                        $bun_id = $sql['bunch_id']+1;
                                       if(count($not_in_group_array)>0){
                                        $key=0;

                                            //for($arr_count=0;$arr_count<count($not_in_group_array);$arr_count++,$key++) {  
                                          foreach ($not_in_group_array as $key => $value1) {  
                                                   $insert_arr[$key][]=$user_id;
                                                    $insert_arr[$key][]=$grouped_types[$value1];
                                                    $insert_arr[$key][]=$ntf_message;
                                                    $insert_arr[$key][]= date('Y-m-d H:i:s');
                                                    $insert_arr[$key][]=$value1;
                                                    $insert_arr[$key][]="Not in Contacts";   
                                                    $insert_arr[$key][]="SMS";
                                                    $insert_arr[$key][]=$sender_id;
                                                    $insert_arr[$key][]=$option;
                                                    $insert_arr[$key][]=$bun_id;
                                                    $insert_arr[$key][]=null;
                                            }
                                        if($insert_arr){
                                            $batch = new Batch('message');
                                            $batch->setRows(['user_id','text','multimedia','datetime','mobile','status','route','sender_id','option','bunch_id','priority'])
                                            ->setValues($insert_arr)->insert();
                                        }
         
                                        }
                                  
                                        if(!count($sms_numbers)){
                                               $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group",'mob'=>$mobile_array));
                                                return $response;
                                        }
                //////////////////////////////end number not in contacts
                                         unset($sms_numbers);
                                    $response->setJsonContent(array('status' => "success","total_msg_sent"=>$total_msg_sent,"linkapp_user_count"=>$linkapp_user_count ,"not_in_group_array"=>$not_in_group_array));
                                        return $response;                                       
                                    }else{
                                          $response->setJsonContent(array('status' => "error","message"=>"Can not send message since you have not enabled third party api"));
                                                return $response;
                                        
                                    }  
                                  break;
                            case 'Default':       //in multimedia first execute default code then multimedia code                  
                                    if($user->http_api_whitelist_status){
                                        $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                                         /*code to find contacts not in group*/
                                         $mobileno=$msg_obj->sanitizeMobileNumbers($mobile_no);
                                    $not_in_group_array=array_values(array_diff($mobileno,$mobile_array));
                              
                                    /*End code contacts*/
                                    }else{
                                        $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                                         /*code to find contacts not in group*/
                                    $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                              
                                    /*End code contacts*/
                                    }
                                   
                                    if($api && $api->status=='Enable' && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){          
                                         $char_limit = $user_permission['text_message_size_limitation'];
                                         foreach ($grouped_types as $mobiles => $msg) {
                                                if($char_limit!="unlimited")
                                                    $msg[0]=substr($msg[0],0,$char_limit);
                                         }
                                         unset($api);
                                         $total_msg_sent=count($mobile_array);
                                         $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/sortMobile_Numbers',"app_access_days=$app_access_days&mobile=".json_encode($mobile_array));
                                         $result=json_decode($result,true);       
                                         $sms_numbers=$result['sms'];//separate sms and notification array chuncks
                                         $mobile_array=$result['notification'];               
                                         unset($result);
                                         if(count($sms_numbers)>0 && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){
                                               foreach ($sms_numbers as $key => $mobiles) {   
                                                       $msg_obj->SMSHandler($user_id,$grouped_types[$mobiles],array($mobiles),$request->getPost('message_types'));
                                              }
                                              unset($msg_obj);                                              
                                         }
                                      //   unset($sms_numbers);
                                   }                                    
                                   $option='Multimedia';
                                   break;    

                    }      
                  }
                if($total_msg_sent=='')
                    $total_msg_sent=count($mobile_array);
               
                $datetime = base64_encode(date('Y-m-d H:i:s'));
                $status="Pending";
                $route="Notification";
                 if($request->getPost('route'))
                    $route=$request->getPost('route');
                 
                 $i=0;
                $mg_id=$user->mg_id;
                $count = $user->sms_quota;
                $mobile_count=count($mobile_array);
                $msg=new Message();
                foreach ($mobile_array as $key=> $mobiles) {
                    $temp_message=$grouped_types[$mobiles][0];
                    $res=$msg->verify($user->id,$option,$mobile_count,$temp_message);   
                  if($res['status']!='success'){
                    echo $res['message'];
                    exit();
                }   
            }
            $unset_array=array($res,$msg,$mobile_count);
            unset($unset_array);
            //take no min and add to current date 
              
                $date =new DateTime('NOW');
                 $min=$request->getPost('priority2');
               
                $date =new DateTime('NOW');
                $time_intervals = explode(",",$user_permission['time_bound_delivery']);
                if($min==0 ||$min==""||$user_permission['time_bound_delivery']=='No'||in_array($min,$time_intervals)==false){
                    $priority=null;
                }else{
                    $date->add(new DateInterval('P0DT0H'.$min.'M0S'));
                    $priority=$date->format('Y-m-d H:i:s');
                }
                $unset_array=array($request,$time_intervals,$date,$min);
                unset($unset_array);
                if($user_permission['text_message']!='unlimited'){
                    $sending_limit = explode("/", $user_permission['text_message']);
                    $msg_limit = $sending_limit[0];
                }else
                    $msg_limit = $user_permission['text_message'];

                unset($sending_limit);
                $char_limit = $user_permission['text_message_size_limitation'];
                unset($user_permission);
                $insert_arr = array(); 
                $sql = $this->db->query("SELECT MAX(bunch_id) as bunch_id from message")->fetch();
                if($sql['bunch_id'] == NULL)
                  $bunch_id = 1;
                else
                  $bunch_id = $sql['bunch_id']+1;
                  $result1=array();
                  $key_arr=0;      
              /*    if($sms_numbers){
                        $mobile_array=$sms_numbers;
                  }*/
                  foreach ($mobile_array as $key => $value1) {  
                        if($option!="Multimedia" || ($option=="Multimedia" && ($msg_limit=="unlimited" || ($msg_limit!="unlimited" && ($count+($key_arr+1))<=$msg_limit)))){
                            $insert_arr[$key_arr][]=$user_id;
                            $insert_arr[$key_arr][]=$grouped_types[$value1];
                            $insert_arr[$key_arr][]='';
                            $insert_arr[$key_arr][]= date('Y-m-d H:i:s');
                            $insert_arr[$key_arr][]=$value1;
                            $insert_arr[$key_arr][]=$status;   
                            $insert_arr[$key_arr][]=$route;
                            $insert_arr[$key_arr][]=$sender_id;
                            $insert_arr[$key_arr][]=$option;
                            $insert_arr[$key_arr][]=$bunch_id;
                            $insert_arr[$key_arr][]=$priority;                      
                            if($option=="Multimedia")
                                $i++;
                  }   
              $key_arr++;
             }  

               /*code to find contacts not in group*/

               if(!$not_in_group_array)
                 // $not_in_group_array=0;
                $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                             //$not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
            
                                    /*End code contacts*/
                                     if(count($not_in_group_array)>0){
                                        $key=$key_arr;
                                            for($arr_count=0;$arr_count<count($not_in_group_array);$arr_count++,$key++) {  
                                                   $insert_arr[$key][]=$user_id;
                                                    $insert_arr[$key][]=$grouped_types[$not_in_group_array[$arr_count]];
                                                    $insert_arr[$key][]=$ntf_message;
                                                    $insert_arr[$key][]= date('Y-m-d H:i:s');
                                                    $insert_arr[$key][]=$not_in_group_array[$arr_count];
                                                    $insert_arr[$key][]="Not in Contacts";   
                                                    $insert_arr[$key][]="SMS";
                                                    $insert_arr[$key][]=$sender_id;
                                                    $insert_arr[$key][]=$option;
                                                    $insert_arr[$key][]=$bun_id;
                                                    $insert_arr[$key][]=null;
                                            }
                                        }
              
             $unset_array=array($key_arr,$mobile_array,$user_id); 
             unset($unset_array);

                if($insert_arr){    
                     $batch = new Batch('message');                    
                     $batch->setRows(['user_id','text','multimedia','datetime','mobile','status','route','sender_id','option','bunch_id','priority'])
                    ->setValues($insert_arr)->insert();          
                      
                      $query = $this->db->query("SELECT id, mobile from message where bunch_id = '".$bunch_id."'")->fetchAll();
                      $m=0;
                      $result_counts=0;
                       $sender_id=urlencode($sender_id); 
                      
                      foreach ($query as $key => $value) {
                        $mobile[$value['id']] = $value['mobile'];
                        $text=$grouped_types[$value['mobile']];
                        $mobile_arr[$m][$value['id']]=$value['mobile'];
                        $mobile_str = json_encode($mobile_arr[$m]);
                        $param="mg_id=$mg_id&text=$text&datetime=$datetime&status=$status&route=$route&sender_id=$sender_id&option=$option&app_access_days=$app_access_days&msg_limit=$msg_limit&sms_quota=$count&char_limit=$char_limit&";                                         
                        $result1[$m]=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/send_msg',$param."mobile=$mobile_str");
                        $result1[$m]= json_decode($result1[$m],true);
                        if($result1[$m][$value['id']]=='Sent')
                              $result_counts++;//count sent result values
                           $m++;
                    }  
                    
                    $unset_array=array($m,$param,$mobile_str,$text,$query,$msg_limit,$count,$mg_id,$status,$route,$datetime,$char_limit,$mobile,$app_access_days,$grouped_types,$option);
                    unset($unset_array);

                   // if(isset($result_counts)){
                  $linkapp_user_count=$result_counts;
                  
                  unset($result_counts);
                  $user->sms_quota += $i;
                  $user->update();    
                  unset($user);
                } 
                if(!count($mobile_array)){
                        $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group",'mob'=>$mobile_array));
                        return $response;
                }
                $unset_array=array($sender_id,$bunch_id,$insert_arr,$priority,$i);
                unset($unset_array);
                 if($result1){
                    $sql = "UPDATE `message` SET `status`= CASE id ";
                    $ids='';
                    for($j=0;$j<count($result1);$j++){                  
                        foreach ($result1[$j] as $id=>$data) {
                              $sql .= "WHEN '".$id."' THEN '".$data."' ";
                              $ids .="'".$id."',";                                   
                        }                 
                    }
                 /*store linkapp user count if already not set*/
                
                 /*END store linkapp user count if already not set*/
             $sql .= "END WHERE id IN (".rtrim($ids, ",").") AND status = 'Pending'";
             $this->db->execute($sql);
                }  
                $unset_array=array($ids,$result1,$sql);
                unset($unset_array);
                /*END After Server Response*/

                /*Notification Code END*/
              file_put_contents('message_log.txt', __FUNCTION__.':'.round((microtime(true) - $start),3)."sec DT: ".date("D, d M y H:i:s O").'
    ', FILE_APPEND);
    if(empty($not_in_group_array)){$not_in_group_array=0;}
              $response->setJsonContent(array('status' => "success","total_msg_sent"=> $total_msg_sent,"linkapp_user_count"=>$linkapp_user_count,"not_in_group_array"=>$not_in_group_array));
                    return $response;
              $this->flash->success('Message Send');
                    //return $this->response->redirect("message/send"); 
        }else{
       $response->setJsonContent(array('status' => "error","message"=>"Can not send message since you have not enabled third party api"));
                                                return $response;
                                        
                   // return $this->response->redirect("message/send"); 
        }         
      } catch(Exception $e) {
        echo 'error'.$e;
      }
      //added by poonam end
    }
public function verify_contactsAction()
{
     try{
        $this->view->disable();
        $auth = $this->session->get('auth');
        $msg_obj=new Message();
        $user_id=$auth['id'];     
        $user=User::findFirstById($user_id);
      
       // $to_type_msg='excelfile';
        $request=$this->request;
        $response = new Response();
        $to_type_msg=$this->request->getPost('to_type_msg');
     
        switch ($to_type_msg) {
                 case 'excelfile':
                        if(is_uploaded_file($_FILES['excelfile']['tmp_name']))
                        {
                           
                              require_once APP_PATH.'app/library/PHPExcel/Classes/PHPExcel.php';
                              $unset_array=array();
                              $dataFfile = $_FILES['excelfile']['tmp_name'];
                              $path = $_FILES['excelfile']['name'];
                              $msg_obj=new Message();
                              $ext = pathinfo($path, PATHINFO_EXTENSION);
                              unset($path);
                              $allowedFile=array('xls','xlsx','txt');
                              $total_msg_sent='';
                              
                              if (in_array($ext, $allowedFile)) {           
                                    $objPHPExcel = PHPExcel_IOFactory::load($dataFfile);
                                    unset($dataFfile);
                                    // Get the active sheet as an array
                                    $activeSheetData = $objPHPExcel->getActiveSheet()->toArray(null, true, true, true);                
                                    unset($objPHPExcel);
                              }else{           
                                    $response->setJsonContent(array('status' => "error","message"=>"Invalid File"));
                                    return $response;                  
                              }
                                 if(isset($_POST['mob_select'])){     
                                  $mobile_select=$_POST['mob_select'];
                                }else{
                                  $mobile_select='A';
                                }
                             for($i=1;$i<=sizeof($activeSheetData);$i++){
                                  if(isset($activeSheetData[$i][$mobile_select])){     
                                      $arr[$i]['mob']=$activeSheetData[$i][$mobile_select];
                                  }else{
                                      $arr[$i]['mob']='';
                                  } 
                                   if(is_numeric($arr[$i]['mob'])){                  
                                       $mobile_no.=$arr[$i]['mob'].','; 
                                  }  
                              } 
                        if(count($mobile_no)<=0){
                        $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group"));
                        return $response;
                        }   
                       $mobile_no=trim(str_replace(["\r\n","\r","\n"], ',', $mobile_no),",");
                       $unset_array=array($activeSheetData,$arr);
                       unset($unset_array); 
                       if($user->http_api_whitelist_status){
                            $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                            /*code to find contacts not in group*/
                            $not_in_group_array=array_values(array_diff($msg_obj->sanitizeMobileNumbers($mobile_no),$mobile_array));
                            /*End code contacts*/
          
                       }else{
                               $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                               /*code to find contacts not in group*/
                            $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                            /*End code contacts*/
          
                       }
                             
                            
                        }
                        break;       
                        case 'single':
                            $mobile_no=$this->request->getPost('mobile_no');
                            $mobile_no=trim(str_replace(["\r\n","\r","\n"], ',', $mobile_no),",");
                            if($user->http_api_whitelist_status && $to_type_msg=="single"){
                                $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                                  /*code to find contacts not in group*/
                            $not_in_group_array=array_values(array_diff($msg_obj->sanitizeMobileNumbers($mobile_no),$mobile_array));
                            /*End code contacts*/
                            }else{
                                $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                                   /*code to find contacts not in group*/
                            $not_in_group_array=array_values(array_diff(explode(",", $mobile_no),$mobile_array));
                            /*End code contacts*/
                            }
                         
                        break;
                         case 'group':
                          case 'pincode':
            
                            break;
                }       
                if(is_null($not_in_group_array)){$not_in_group_array=0;}
              $response->setJsonContent(array('status' => "success","not_in_group_array"=>$not_in_group_array));
                    return $response;
                  }catch(error $e){
                     $response->setJsonContent(array('status' => "error","msg"=>$e));
                    return $response;
                  }
}
 public function updatestatusAction()
    {
        $this->view->disable();
         try{
                 $request=$this->request;
                 $response = new Response();
                  if($this->request->isPost()){
            
                    $mobile=explode(',', $this->request->getPost('import_contacts'));

                    $g_id=$this->request->getPost('import_group_id');

                     if(count($mobile)<=0){ 
                          $response->setJsonContent(array('status' => 'error','message'=>"No contact(s) imported"));
                          return $response;
                     }else{
                          $group=new Group();
                          $auth = $this->session->get('auth');

                            /*create new group*/
                          if($this->request->getPost('import_type')=="import_group_name"){
                           
                                $group->name = $this->request->getPost('import_group_name', array('string', 'striptags'));
                                $group->user_id = $auth['id'];
                                $group->save();
                                $g_id=$group->id;
                          }
                         
                          /*END Create new group*/
                          $user=new User();
                          $user_permission = $user->getPermissions($auth['id']);
                          $smt=$this->db->query("SELECT DISTINCT mobile FROM `subscriber` s, `group` g WHERE g.user_id =".$auth['id']." AND s.group_id=g.id");
                          $smt->setFetchMode(PDO::FETCH_COLUMN,0);
                          $current_mobile_count=$smt->fetchAll();
                          $temp_count=count($current_mobile_count);
                          $count = 0;
                          $insert_arr = array();
                          $mobile = $group->filterMobile(array_unique($mobile),$g_id);   

                          for($i=0; $i < count($mobile); $i++) { 
                                        //check plan contact limit cross or not and whether it is existing contacts or new 
                                        if(is_numeric($mobile[$i]) && strlen((string) $mobile[$i])==10){
                                            if (in_array($mobile[$i], $current_mobile_count)||$user_permission['contact_limits']>$temp_count|| $user_permission['contact_limits']=="unlimited") { 
                                                  $insert_arr[$i][]=$mobile[$i];
                                                  $insert_arr[$i][]="No Names";
                                                  $insert_arr[$i][]=$g_id;
                                                  $count++;
                                               if(in_array($mobile[$i], $current_mobile_count)==false)
                                                  $temp_count++;           
                                            }else{
                                              $response->setJsonContent(array('status' => 'success','message'=>" Your contact limit is ".$user_permission['contact_limits']));
                                                  return $response;
                                            }
                                        }
                          }
                        //  print_r($insert_arr);
                          
                          if($insert_arr){
                            $group->import($insert_arr);
                          }//end for each
                           $response->setJsonContent(array('status' => 'success','message'=>$count." contact(s) successfully imported"));
                                  return $response;
                      }
                  }
            } catch(Exception $e) {
              echo 'error'.$e;
            }
  }
    public function getMembersAction()
    {
            $this->view->disable();
            $response = new Response();
            $request=$this->request;
            if ($request->isAjax() == true) {      
                $group_id = $request->getPost('group_id');           
                $members=Subscriber::find("group_id=".$group_id);
            }
            $response->setContent(count($members));
            return $response;
    }
    public function getPincodeMembersAction()
    {
            $this->view->disable();
            $response = new Response();
            $request=$this->request;
            if ($request->isAjax() == true) {      
                $pincode = $request->getPost('pincode');
                $members=$this->utils->curl_redirect('http://sancharapp.com/msg-api/getSubsciberByPincode',"pincode=$pincode");         
            }
            $response->setContent($members);
            return $response;
    }

    //http api balance (message credit)
    public function balanceAction()
    {
        $this->view->disable();
        $response = new Response();
        $username = $this->request->get('username');
        $password = $this->request->get('password');
        $user = User::findFirst(array(
                    "(email = :email:) AND password = :password: AND status = 'Active' AND type = 'Group Admin'",
                    'bind' => array('email' => $username, 'password' => sha1($password))
                ));
        if ($user != false){
            $user_obj=new User();
            $user_permission = $user_obj->getPermissions($user->id);
            $sms_limit=explode("/",$user_permission['text_message']);
  
            if($sms_limit[0]=="unlimited")
                $sms_remained = $sms_limit[0];
            else  
                $sms_remained = $sms_limit[0] - $user->sms_quota;

            $response->setContent($sms_remained);
        }else{
            $response->setContent("Unauthorized");
        }
        return $response;
    }
    //http api balance (message credit)
    public function reportsAction()
    {
        $this->view->disable();
        $response = new Response();
        $username = $this->request->get('username');
        $password = $this->request->get('password');
        $FromDate = $this->request->get('FromDate');
        $toDate= $this->request->get('toDate');
        $user = User::findFirst(array(
                    "(email = :email:) AND password = :password: AND status = 'Active' AND type = 'Group Admin'",
                    'bind' => array('email' => $username, 'password' => sha1($password))
                ));
        if ($user != false){
             $user_permission = $user->getPermissions($user->id);
             if($user_permission['read_report'] == 'No'){
                $response->setContent("You don't have permission to read report");
             }else{
                    if(!$FromDate){
                        $response->setContent("FromDate is required");
                        return $response;
                        exit();
                    }
                    if(!$toDate){
                        $response->setContent("toDate is required");
                        return $response;
                    }
                $phpl="SELECT m.id,m.text,m.multimedia,m.datetime,m.mobile,m.status,m.sender_id,m.priority FROM message m join user u ON m.user_id = u.id where m.user_id=".$user->id." AND date(m.datetime) between '".$FromDate."' and '".$toDate."' ORDER BY m.datetime DESC";
                $query = $this->db->query($phpl);
                $query->setFetchMode(Phalcon\Db::FETCH_ASSOC);
                $query = $query->fetchAll();
                $response->setJsonContent($query);
             }
        }else{
             $response->setContent("Unauthorized");
        }
        return $response;
    }
    //http api to send message 
    public function apiAction()
    {
        $this->view->disable();
        $start = microtime(true); 
        $response = new Response();
        $username = $this->request->get('username');
        $password = $this->request->get('password');
        $user = User::findFirst(array(
                    "(email = :email:) AND password = :password: AND status = 'Active' AND type = 'Group Admin'",
                    'bind' => array('email' => $username, 'password' => sha1($password))
                ));
        if ($user != false){
            $request=$this->request;
            /*authorized*/
            if(!$request->get('message')){
                $response->setContent("Message is required");
                return $response;
                exit();
            }
            if(!$request->get('mobile')){
                $response->setContent("Mobile is required");
                return $response;
                exit();
            }
            $option = $request->get('option');
            switch ($option) {
                case 2:
                    $option="SMS";
                    break;
                case 1:
                    $option="Multimedia";
                    break;
                default:
                    $option="Default";
                    break;
            }

                    /*main code*/
            $group_id=$request->get('group_id','int');
            $mobile_no = $request->get('mobile');
            $message_type=$request->get('message_type');
                //check where group message or , seperarted mobile no list
            $mobile_array=array();
            if($group_id){
                    $smt=$this->db->query("SELECT mobile FROM `subscriber` WHERE group_id=$group_id");
                    $smt->setFetchMode(PDO::FETCH_COLUMN,0);
                    $mobile_array=$smt->fetchAll();                       
            }else{
                //check for whitelisting option 
                if($user->http_api_whitelist_status){
                    $smt=$this->db->query("SELECT DISTINCT s.mobile FROM `subscriber` s,`group` g,`user` u WHERE s.group_id=g.id AND g.user_id=u.id AND u.id=".$user->id." AND s.mobile IN (".$mobile_no.")");
                    $smt->setFetchMode(PDO::FETCH_COLUMN,0);
                    $mobile_array=$smt->fetchAll();
                    $mobile_array =array_splice($mobile_array, 0, 99);
                }else{
                    //$mobile_array =array_unique(explode(",", $mobile_no));
                    $mobile_array =array_splice(array_unique(explode(",", $mobile_no)), 0, 99);
                }
            }
            $user_permission = $user->getPermissions($user->id); 
            $config = Configuration::findFirst();
            $app_access_days = $config->app_access_days;  
            
            if($user_permission['http_api']=='No'){
                $response->setContent("You can'\t use this feature");
                return $response;
                exit();
            }
                //check for thirdparty sms api status************************************
            if($option!='Multimedia'){
                switch ($option) {
                            case 'SMS':
                                $api = Api::findFirst("user_id=$user->id");
                                if(!$api || $api->status=='Disable'||$user_permission['http_sms_forwarding_(3rd_party)']=='No'){
                                      $response->setContent("You don't have configure/enable Third party SMS Api");
                                      return $response;
                                      exit();
                                }
                                $message =$request->get('message');
                                if($message_type=="image"){
                                   $message ="click the link to view image\n".$message; 
                                }
                              /*  if($message_type=="unicode")
                                    $parts = str_split($message,70);
                                else
                                    $parts = str_split($message,160);

                                $part_Count=count($parts); */
                                $msg = urlencode($message);
                                $base_url=trim($api->url); 
                                $chunk_mobile_array=array_chunk($mobile_array,intval($api->max_limit));
                                foreach ($chunk_mobile_array as $key => $value) {
                                    $implode_mob=implode(",",$value);
                             /*       for ($i=0; $i <$part_Count; $i++) { 
                                        $msg = urlencode($parts[$i]);*/
                                        $url="$base_url&$api->text=$msg&$api->to=".$implode_mob."";
                                        $result=$this->utils->call_msg_api($url);
                                 /*   } */
                                
                                }
                                $response->setJsonContent(array_fill_keys($mobile_array,"sent"));
                                return $response;
                                break;
                            case 'Default':
                                $api = Api::findFirst("user_id=$user->id");
                                $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/sortMobile_Numbers',"app_access_days=$app_access_days&mobile=".json_encode($mobile_array));
                                $result=json_decode($result,true);
                                 
                                $sms_numbers=$result['sms'];
                                $mobile_array=$result['notification'];

                                if(count($sms_numbers)>0 && $api && $api->status=='Enable' && $user_permission['http_sms_forwarding_(3rd_party)']=='Yes'){
                                    //file_put_contents('message_log.txt', __FUNCTION__.$request->getPost('text'), FILE_APPEND);  
                                    $message = $request->get('message');
                                    if($message_type=="image"){
                                        $message ="click the link to view image\n".$message; 
                                    }
                                    $base_url=trim($api->url);

                                   /* if($message_type=="unicode")
                                        $parts = str_split($message,70);
                                    else
                                        $parts = str_split($message,160);

                                    $part_Count=count($parts);*/
                                    $msg = urlencode($message);
                                    $chunk_mobile_array=array_chunk($sms_numbers,intval($api->max_limit));
                                    foreach ($chunk_mobile_array as $value) {
                                        $implode_mob=implode(",",$value);
                                        /*for ($i=0; $i <$part_Count; $i++) { 
                                            $msg = urlencode($parts[$i]);*/
                                            $url="$base_url&$api->text=$msg&$api->to=$implode_mob";
                                            $result=$this->utils->call_msg_api($url);
                                    /*    } */
                                        
                                    }
                                }
                                //set option to multimedia so remaining app number send directly as multimedia
                                $option='Multimedia';
                                break;
                    
                    } 
                }
                $s_id = $this->db->query("SELECT text from senderID where user_id = '".$user->id."'")->fetch();
                if(!$s_id){                           
                    $response->setContent("Please Create Sender ID");
                    return $response;
                    exit();
                }else{
                    $sender_id=$s_id['text'];
                }
                $mobile_count=count($mobile_array);
                if($message_type=="image"){
                    $ntf_msg ='<p><img data-url="'.$request->get('message').'" class="responsive-img" src="'.$request->get('message').'"></p>'; 
                    $text_msg='';
                    $temp_message=$ntf_msg;
                }else{
                    $text_msg = $request->get('message');
                    $ntf_msg ='';
                    $temp_message=$text_msg;
                }
                $msg=new Message();
                $res=$msg->verify($user->id,$option,$mobile_count,$temp_message);
                if($res['status']!='success'){
                    echo $res['message'];
                    exit();

                }
                //take no min and add to current date 
                $min=$user->default_msg_priority;
                $date =new DateTime('NOW');
                $time_intervals = explode(",",$user_permission['time_bound_delivery']);
                if($min==0 ||$min==""||$user_permission['time_bound_delivery']=='No'||in_array($min,$time_intervals)==false){
                    $priority=null;
                }else{
                    $date->add(new DateInterval('P0DT0H'.$min.'M0S'));
                    $priority=$date->format('Y-m-d H:i:s');
                }

                $arr = array();
        
                $text = urlencode($text_msg);
                $multimedia = base64_encode(htmlentities($ntf_msg));
                $datetime = base64_encode(date('Y-m-d H:i:s'));
                $status="Pending";
                $route="Notification";
          
                $i=0;
                $mg_id=$user->mg_id;
                $count = $user->sms_quota;
                if($user_permission['text_message']!='unlimited'){
                    $sending_limit = explode("/", $user_permission['text_message']);
                    $msg_limit = $sending_limit[0];
                }else
                    $msg_limit = $user_permission['text_message'];
                $char_limit = $user_permission['text_message_size_limitation'];

                $insert_arr = array(); $mobile = array();
                $sql = $this->db->query("SELECT MAX(bunch_id) as bunch_id from message")->fetch();
                if($sql['bunch_id'] == NULL)
                  $bunch_id = 1;
                else
                  $bunch_id = $sql['bunch_id']+1;

                foreach ($mobile_array as $key => $value1) {  
                    if($option!="Multimedia" || ($option=="Multimedia" && ($msg_limit=="unlimited" || ($msg_limit!="unlimited" && ($count+($key+1))<=$msg_limit)))){
                        $insert_arr[$key][]=$user->id;
                        $insert_arr[$key][]=$text_msg;
                        $insert_arr[$key][]=$ntf_msg;
                        $insert_arr[$key][]= date('Y-m-d H:i:s');
                        $insert_arr[$key][]=$value1;
                        $insert_arr[$key][]=$status; 
                        $insert_arr[$key][]=$route;
                        $insert_arr[$key][]=$sender_id;
                        $insert_arr[$key][]=$option;
                        $insert_arr[$key][]=$bunch_id;
                        $insert_arr[$key][]=$priority;
                        if($option=="Multimedia")
                            $i++;
                    }
                }
                if($insert_arr){
                    $batch = new Batch('message');
                    $batch->setRows(['user_id','text','multimedia','datetime','mobile','status','route','sender_id','option','bunch_id','priority'])
                    ->setValues($insert_arr)->insert();
                    $query = $this->db->query("SELECT id, mobile from message where bunch_id = '".$bunch_id."'")->fetchAll();
                    foreach ($query as $key => $value) {
                        $mobile[$value['id']] = $value['mobile'];
                    }
                }
                $user->sms_quota += $i;
                $user->update();
                $mobile_str = json_encode($mobile);
                $sender_id=urlencode($sender_id);
                $param="mg_id=$mg_id&text=$text&multimedia=$multimedia&datetime=$datetime&status=$status&route=$route&sender_id=$sender_id&option=$option&app_access_days=$app_access_days&msg_limit=$msg_limit&sms_quota=$count&char_limit=$char_limit&"; 
                $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/send_msg',$param."mobile=$mobile_str");
 
            /*    echo $result;
                exit();*/
           
                $result=json_decode($result,true);

                if($result){
                    $sql = "UPDATE `message` SET `status`= CASE id ";
                    $ids='';
                    foreach ($result as $id=>$data) {
                      $sql .= "WHEN '".$id."' THEN '".$data."'";
                      $ids .="'".$id."',";
                    }
                }
                $sql .= "END WHERE id IN (".rtrim($ids, ",").") AND status = 'Pending'";
                $this->db->execute($sql);

                file_put_contents('message_log.txt', __FUNCTION__.':'.round((microtime(true) - $start),3)."sec DT: ".date("D, d M y H:i:s O").'
    ', FILE_APPEND);
                if (!empty($mobile) && !empty($result)) { 
                    $response->setJsonContent(array_combine($mobile,$result));
                }
                else {
                    $response->setContent("failed");
                }
                return $response;
        
                    /*End main code*/

            /*----------*/
        }else{
            $response->setContent("Unauthorized");
            return $response;
        }
    }
 function getContents($str, $startDelimiter, $endDelimiter) {
  $contents = array();
  $startDelimiterLength = strlen($startDelimiter);
  $endDelimiterLength = strlen($endDelimiter);
  $startFrom = $contentStart = $contentEnd = 0;
  while (false !== ($contentStart = strpos($str, $startDelimiter, $startFrom))) {
    $contentStart += $startDelimiterLength;
    $contentEnd = strpos($str, $endDelimiter, $contentStart);
    if (false === $contentEnd) {
      break;
    }
    $contents[] = substr($str, $contentStart, $contentEnd - $contentStart);
    $startFrom = $contentEnd + $endDelimiterLength;
  }
  return $contents;
}
public function  chkkey($activeSheetData){   
 $result = array();
        $firstKeys = array_keys($activeSheetData);
        for($i=0;$i<count($firstKeys);$i++){
            $key = $firstKeys[$i];
            $result = array_merge(
                $result=array_keys($activeSheetData[$key]));
        }
        return $result;
    }
}
