<?php

use Phalcon\Mvc\Model;
use Phalcon\Mvc\Model\Validator\Email as EmailValidator;
use Phalcon\Mvc\Model\Validator\Uniqueness as UniquenessValidator,
    Phalcon\Mvc\Model\Validator\StringLength as StringLengthValidator;
use Phalcon\Mvc\Model\Relation;
use Phalcon\Http\Response;

class Message extends Model
{
    public function onConstruct()
    {
      $this->db=$this->getDi()->getShared('db');
      $this->utils=$this->getDi()->getShared('utils');
    }
    public function call_msg_server($url,$param)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url.'?'.$param); 
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);   
        $response = curl_exec($ch);
        curl_close($ch);
        return $response;
    }
     public function call_msg_api($url)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url); 
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);   
        $response = curl_exec($ch);
        curl_close($ch);
        return $response;
    }
    public function verify($user_id,$option,$mobile_count,$message)
    {
        //pram user_id,option,mobile_count,message
            $user = new User();
            $data = $user->getData($user_id); 
            $char_limit = $data['text_message_size_limitation'];
            if($data['text_message']!='unlimited'){
                $sending_limit = explode("/", $data['text_message']);
                $msg_limit = $sending_limit[0];
            }else
                $msg_limit = $data['text_message'];

            switch ($option) {
                case 'Multimedia':
                    $other_permissions = $user->checkPermissions($message,$data['unicode_message'],$data['image_message']);
                    if($other_permissions){
                        return (array('status' => 'failed', 'message' => "<div class='alert alert-danger'>".$other_permissions."</div>"));
                        exit;
                    }                    
                    if($char_limit!='unlimited' && strlen($message) > $char_limit){                    
                        $msg = "<div class='alert alert-danger'>Can not send message since it exceeds message size limitation</div>";
                        return(array('status' => 'failed', 'message' => $msg));
                        exit;
                    }else if($msg_limit!='unlimited' && $data['sms_quota'] >= $msg_limit){                    
                        $msg = "<div class='alert alert-danger'>Can not send message since your message quota is completed</div>";
                        return(array('status' => 'failed', 'message' => $msg));
                        
                        exit;
                    }else if($msg_limit!='unlimited' && ($data['sms_quota']+$mobile_count) > $msg_limit){             
                        $msg = "<div class='alert alert-danger'>Can not send message since it exceeds your message quota</div>";
                        return(array('status' => 'failed', 'message' => $msg));
                        
                        exit;
                    }else                    
                        $msg = '<div class="alert alert-success">Message sent</div>';
                    return(array('status' => 'success', 'message' => $msg, 'mult_str' => $message));
                    break;
                case 'SMS':
                    return(array('status' => 'success', 'message' => '<div class="alert alert-success">Message sent</div>'));
                    break;
                case 'Default':
                    return(array('status' => 'success', 'message' => '<div class="alert alert-success">Message sent</div>', 'mult_str' => $message));
                    break;
            }
    }
    public function shedular_status($user_id,$count)
    {    
        $user=User::findFirst($user_id);
        $rates=$this->get_rates($user_id,$user->balance,$user->slab_id);
        if($rates!=false){
           $final_sms=$rates[0]['sms'];
           $final_not=$rates[0]['notification'];

           $total_amount=$count*$final_sms;

           if($user->balance>=$total_amount)
           return true; 
        }
        return false;
           
    }
    public function initialize()
    {
        $this->belongsTo('user_id', 'User', 'id', array(
        'reusable' => true
        ));
    }
    public function getUser($parameters=null)
    {
        return $this->getRelated('User', $parameters);
    }
    /*
    *Function to get Mobile array for sending message call from(message/send)
    *
    ***************************/
    public function getPincodeNumbers($user_id,$active_radio,$pincode_range_min,$pincode_range_max,$pincode_ids_post)
    {
        if($active_radio=="pincode_range"){
            $public_service= PublicService::findFirst("user_id=".$user_id."");
            if($public_service){
                $pincode=explode("=",$public_service->pincode);
                if(isset($pincode[1]) && $pincode[1]!="null"){
                    $pincode_ids=implode(",", json_decode($pincode[1]));
                    switch ($pincode[0]) {
                        case 'district':
                             $sql ="SELECT p.pin FROM pincode p,taluka t,district d WHERE d.id=t.dist_id AND t.id=p.tq_id AND d.id IN (".$pincode_ids.")";
                             break;
                             case 'taluka':
                             $sql = "SELECT p.pin FROM pincode p,taluka t WHERE t.id=p.tq_id AND t.id IN (".$pincode_ids.")";
                             break;
                             case 'pincode':
                             $sql = "SELECT pin FROM pincode WHERE id IN (".$pincode_ids.")";
                             break;
                             default:
                             $sql = "SELECT p.pin FROM pincode p,taluka t,district d,state s WHERE s.id=d.state_id AND d.id=t.dist_id AND t.id=p.tq_id AND s.id IN (".$pincode_ids.")";
                             break;
                    }
                    $min_range = str_pad($pincode_range_min,  6, "0");
                    $max_range = str_pad($pincode_range_max,  6, "0");
                    $smt = $this->db->query("$sql AND pin BETWEEN ".$min_range." AND ".$max_range."");
                }
            }
        }else{
            $pincode_ids = $pincode_ids_post;
            $pincode_ids =implode(",",$pincode_ids);
            $smt = $this->db->query("SELECT pin FROM pincode WHERE id IN (".$pincode_ids.")");
        }
        $smt->setFetchMode(PDO::FETCH_COLUMN,0);
        $pincode=$smt->fetchAll();
        $pincode=json_encode($pincode);
        $mobile_array=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/getSubsciberByPincode',"pincode=$pincode");         
        $mobile_array= json_decode($mobile_array,true);
        return $mobile_array;
    }
    /*
    *Function to get Mobile array for group id(message/send)
    *
    ***************************/
     public function getGroupNumbers($group_id)
    {
        $smt=$this->db->query("SELECT mobile FROM `subscriber` WHERE group_id=$group_id");
        $smt->setFetchMode(PDO::FETCH_COLUMN,0);
        $mobile_array=$smt->fetchAll();
        return $mobile_array;
    }
    /*
    *Function to get Mobile array for excel file(message/send)
    *
    ***************************/
    public function getExcelNumbers($files)
    {
        $mobile_no='';
        require_once APP_PATH.'app/library/PHPExcel/Classes/PHPExcel.php';
        $dataFfile = $files['excelfile']['tmp_name'];
        $path = $files['excelfile']['name'];
        $ext = pathinfo($path, PATHINFO_EXTENSION);
        $allowedFile=array('xls','xlsx','txt');
        if (in_array($ext, $allowedFile)) {
            $objPHPExcel = PHPExcel_IOFactory::load($dataFfile);
            $activeSheetData = $objPHPExcel->getActiveSheet()->toArray(null, true, true, true);
        }
        foreach($activeSheetData as $type){
            if(is_numeric($type['A']))
                $mobile_no.=$type['A'].',';
        }
        $mobile_no=rtrim($mobile_no, ",");
        return $mobile_no;
    }
    /*
    *Function to get Mobile array for excel file(message/send) $mobile string , comma sepated cont mobiles
    *
    ***************************/
    public function getWhiteListNumbers($user_id,$mobile_no)
    {
        $smt=$this->db->query("SELECT DISTINCT s.mobile FROM `subscriber` s,`group` g,`user` u WHERE s.group_id=g.id AND g.user_id=u.id AND u.id=".$user_id." AND s.mobile IN (".$mobile_no.")");
        $smt->setFetchMode(PDO::FETCH_COLUMN,0);
        $mobile_array=$smt->fetchAll();
        return $mobile_array;
    }
    /*
    *Function to get sanitize Mobile Numbers
    *
    ***************************/
    public function sanitizeMobileNumbers($mobile_no)
    {
        $mobile_array =array_unique(explode(",", $mobile_no));
        $mobile_array = array_filter($mobile_array, function($val){return (preg_match('/^[0-9]{10}+$/', $val));});
        return $mobile_array;
    }
    /*
    *Function to sent SMS 
    *
    ***************************/
    public function SMSHandler($user_id,$message,$mobile_array,$is_unicode=NULL)
    {
      /*  $api = Api::findFirst("user_id=$user_id");
        if(!$api || $api->status=='Disable'){
            $this->flash->notice('You don\'t have configure/enable Third party SMS Api');
            return $this->response->redirect("message/send");
            exit;
        }
        $msg = urlencode($message); 
        $base_url=trim($api->url); 
        $chunk_mobile_array=array_chunk($mobile_array,intval($api->max_limit));
        foreach ($chunk_mobile_array as $key => $value) {
            $implode_mob=implode(",",$value);
            $url="$base_url&$api->text=$msg&$api->to=".$implode_mob."";
            $result=$this->utils->call_msg_api($url);
        }*/
        /*Store Record in Message Table*/
        //$this->batchStoreSMSMessage($user_id,$message,$mobile_array);

         if($is_unicode=='unicode'){
            ////////////////////
            
                   $api = Api::findFirst("user_id=$user_id and is_unicode=1");
                        if(!$api || $api->status=='Disable'){
                            $this->flash->notice('You don\'t have configure/enable Third party SMS Api');
                            return $this->response->redirect("message/send");
                            exit;
                        }
               // $msg = urlencode($message); 
                        $msg ="";
$string = mb_convert_encoding($message, 'UCS-2', 'utf8');
for($i =0; $i < strlen($string); $i++)
    $msg=$msg.strtoupper(bin2hex($string[$i]));

                $base_url=trim($api->url); 
                $chunk_mobile_array=array_chunk($mobile_array,intval($api->max_limit));
                foreach ($chunk_mobile_array as $key => $value) {
                    $implode_mob=implode(",",$value);
                    $pieces=$this->seturl($base_url,'~',$implode_mob);
                    $url=$this->seturl($pieces,'*',$msg);
                   // $url="$base_url&$api->text=$msg&$api->to=".$implode_mob."";
                    $result=$this->utils->call_msg_api($url);
                }
                /*Store Record in Message Table*/
                $this->batchStoreSMSMessage($user_id,$message,$mobile_array);
            /////////////////
          
        }else{
                $api = Api::findFirst("user_id=$user_id and is_unicode=0");
            if(!$api || $api->status=='Disable'){
                    $this->flash->notice('You don\'t have configure/enable Third party SMS Api');
                    return $this->response->redirect("message/send");
                    exit;
            }
            $msg = urlencode($message); 
            $base_url=trim($api->url); 
            $chunk_mobile_array=array_chunk($mobile_array,intval($api->max_limit));
            foreach ($chunk_mobile_array as $key => $value) {
                    $implode_mob=implode(",",$value);
                   // $url="$base_url&$api->text=$msg&$api->to=".$implode_mob."";
                    $pieces=$this->seturl($base_url,'~',$implode_mob);
                    $url=$this->seturl($pieces,'*',$msg);
                    $result=$this->utils->call_msg_api($url);
            }
            /*Store Record in Message Table*/
            $this->batchStoreSMSMessage($user_id,$message,$mobile_array);
            } 
    } 
    /*
    *Function to get Message Format 
    *
    ***************************/
    public function getMultiMediaMessage($multimedia)
    {
        preg_match('/(data-url=["\'](.*?)["\'])/', $multimedia, $match);  //find src="X" or src='X'
        $split = preg_split('/["\']/', $match[0]); // split by quotes
        $src = $split[1]; // X between quotes
        $message ="click the link to view image\n".$src;
        return $message;
    }
    /*
    *Function to get Message Format app controller
    *
    ***************************/
    public function getRecentMessage($user_id,$count)
    {
        //Getting all robots with associative indexes only
        $messages = $this->db->fetchAll("SELECT id,text,multimedia,datetime,mobile FROM message WHERE user_id=$user_id GROUP By bunch_id ORDER BY datetime DESC LIMIT $count", Phalcon\Db::FETCH_ASSOC);
        return $messages;
    }
    /*
    *Function to store Message IN message table as
    *
    ***************************/
    public function batchStoreSMSMessage($user_id,$message,$mobile_array)
    {
        $insert_arr = array();
        $sql = $this->db->query("SELECT MAX(bunch_id) as bunch_id from message")->fetch();
        if($sql['bunch_id'] == NULL)
            $bunch_id = 1;
        else
            $bunch_id = $sql['bunch_id']+1;
        foreach ($mobile_array as $key => $value) {
            $insert_arr[$key][]=$user_id;
            $insert_arr[$key][]=$message;
            $insert_arr[$key][]="";
            $insert_arr[$key][]=date('Y-m-d H:i:s');
            $insert_arr[$key][]=$value;
            $insert_arr[$key][]="Sent";   
            $insert_arr[$key][]="SMS";
            $insert_arr[$key][]="#";
            $insert_arr[$key][]="SMS";
            $insert_arr[$key][]=$bunch_id;
            $insert_arr[$key][]=null;
        }
        if($insert_arr){
            $batch = new Batch('message');
            $batch->setRows(['user_id','text','multimedia','datetime','mobile','status','route','sender_id','option','bunch_id','priority'])
                ->setValues($insert_arr)->insert();
        }
    }
    public function send_SMSHandler($user_id,$message,$mobile_array,$is_unicode=NULL)
    {
         $this->batchStoreSMSMessage($user_id,$is_unicode.$message,$mobile_array);
if(is_null($is_unicode) ||isset($is_unicode)=='text'){
        $api = Api::findFirst("user_id=$user_id and is_unicode=0");
        if(!$api || $api->status=='Disable'){
            $this->flash->notice('You don\'t have configure/enable Third party SMS Api');
            return $this->response->redirect("message/send");
            exit;
        }
        $msg = urlencode($message); 
        $base_url=trim($api->url); 
        $chunk_mobile_array=array_chunk($mobile_array,intval($api->max_limit));
        foreach ($chunk_mobile_array as $key => $value) {
            $implode_mob=implode(",",$value);
            $url="$base_url&$api->text=$msg&$api->to=".$implode_mob."";
            $result=$this->utils->call_msg_api($url);
        }
        /*Store Record in Message Table*/
        $this->batchStoreSMSMessage($user_id,'if'.$message,$mobile_array);
    }else{
       if(isset($is_unicode)=='unicode'){
   $api = Api::findFirst("user_id=$user_id and is_unicode=1");
        if(!$api || $api->status=='Disable'){
            $this->flash->notice('You don\'t have configure/enable Third party SMS Api');
            return $this->response->redirect("message/send");
            exit;
        }
        $msg = urlencode($message); 
        $base_url=trim($api->url); 
        $chunk_mobile_array=array_chunk($mobile_array,intval($api->max_limit));
        foreach ($chunk_mobile_array as $key => $value) {
            $implode_mob=implode(",",$value);
            $pieces=$this->seturl($base_url,'~',$implode_mob);
            $url=$this->seturl($pieces,'$',$msg);
           // $url="$base_url&$api->text=$msg&$api->to=".$implode_mob."";
            $result=$this->utils->call_msg_api($url);
        }
        /*Store Record in Message Table*/
        $this->batchStoreSMSMessage($user_id,'else'.$message,$mobile_array);
    } 
}

}
function seturl($url,$niddle,$val){
$pieces=explode($niddle,$url);
return $newval=$pieces[0].$val.$pieces[1];

}
}