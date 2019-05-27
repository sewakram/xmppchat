<?php

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of GCM
 *
 * @author Ravi Tamada
 */
//include_once './smppclass.php';
global $config;
$config = $app->config;

/*****************SMPP****************************************/
//global $smpp;
//$smpp_config=$config->smpp2;//$smpp_config=$config->smpp;
//$smpp = new SMPPClass();
//$smpp->SetSender($smpp_config->from);
//$smpp->Start($smpp_config->smpphost,$smpp_config->smppport, $smpp_config->systemid, $smpp_config->password, $smpp_config->system_type);

/*****************End SMPP****************************************/
class GCM {
    //put your code here
    // constructor 
    function __construct() {
        
    }
     /**
     * Sending Single Push Notification
     */
    public function sendAndroid_notificationSingle($registation_ids,$message,$sender_id,$message_attr) {
        global $config;      
        $GOOGLE_API_KEY=$config->android->GOOGLE_API_KEY;
        $headers = array(
            'Authorization: key=' .$GOOGLE_API_KEY,
            'Content-Type: application/json'
            //'Content-Type:application/x-www-form-urlencoded;charset=UTF-8'
        );
        foreach ($registation_ids as $key => $value){
            $fields = array( 
            'registration_ids' => array($value), 
            'data' => array("attributes"=> $message_attr,"message" => $message,'title'=>$sender_id,'msgcnt'=>"1","msg_id"=>"".$key."","content-available"=>1), 
            );          
        // Open connection
        $ch = curl_init();

        // Set the url, number of POST vars, POST data
        curl_setopt($ch, CURLOPT_URL,'https://android.googleapis.com/gcm/send');

        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        // Disabling SSL Certificate support temporarly
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
        //curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);

        // Execute post
        $result = curl_exec($ch);
        
        // Close connection
        curl_close($ch);
        }
       // file_put_contents("../public/message_log.txt", "\n".json_encode($registation_ids),FILE_APPEND);    
    }
    /**
     * Sending Push Notification
     */
    public function sendAndroid_notification($registation_ids,$message,$sender_id) {
        global $config;      
        $GOOGLE_API_KEY=$config->android->GOOGLE_API_KEY;
        $fields = array( 
            'registration_ids' => $registation_ids, 
            'data' => array("message" => $message,'title'=>$sender_id,'msgcnt'=>"1","content-available"=>1), 
            );

        $headers = array(
            'Authorization: key=' .$GOOGLE_API_KEY,
            'Content-Type: application/json'
            //'Content-Type:application/x-www-form-urlencoded;charset=UTF-8'
        );
        // Open connection
        $ch = curl_init();

        // Set the url, number of POST vars, POST data
        curl_setopt($ch, CURLOPT_URL,'https://android.googleapis.com/gcm/send');

        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        // Disabling SSL Certificate support temporarly
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
        //curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);

        // Execute post
        $result = curl_exec($ch);
        
        // Close connection
        curl_close($ch);
       // file_put_contents("../public/message_log.txt", "\n".json_encode($registation_ids),FILE_APPEND);    
    }
     public function sendXMPP_notification($jids,$message,$sender_id,$xmpp_msg_attribute,$sender_jid,$sender_pass) {
     /**********************************************************/
        global $client,$config;
        $xmpp_config=$config->xmpp;
        $this->message = $message;
        $this->sender_id=$sender_id;
        $this->jids=$jids;  
        $this->xmpp_msg_attribute=$xmpp_msg_attribute;
        $this->sender_jid=$sender_jid;
        $this->sender_pass=$sender_pass;

    // return print_r($sender_id);exit;
    // print_r($message);
    // print_r($sender_id);
    // return print_r($this->xmpp_msg_attribute);exit;
        require_once 'JAXL/jaxl.php';
        $client = new JAXL(array('jid' =>$this->sender_jid,'pass' =>$this->sender_pass,'auth_type' => 'DIGEST-MD5','log_level' => JAXL_INFO,'priv_dir'=>'priv_dir'));
        $client->require_xep(array('0199'));
        $client->add_cb('on_auth_success', function(){
            global $client;
            foreach ($this->jids as $key => $value){
                //$client->send_chat_msg($this->jid,$this->message);
                $client->send_msg($value,$this->message,$this->sender_id,$key,$this->xmpp_msg_attribute);
                // file_put_contents("../public/Croncache.txt", "\n".$this->xmpp_msg_attribute,FILE_APPEND);
            }
            $client->send_end_stream(); 
        });
        $client->start();
        /**********************************************************/
    }
    public function sendiOS_notification($device_tokens,$message,$sender_id) {
         global $config;
        /*$cert = 'AppCert.pem';

        $fields = array(
            'device_tokens' => $device_tokens,
            'aps' => $message,
        );

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL,'https://gateway.sandbox.push.apple.com:2195');
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_HEADER, 1);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array("Content-Type: application/json"));
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_SSLCERT, $cert);
        curl_setopt($ch, CURLOPT_SSLCERTPASSWD, "passphrase");
        //curl_setopt($ch, CURLOPT_POSTFIELDS, '{"device_tokens": ["458e5939b2xxxxxxxxxxx3"], "aps": {"alert": "test message one!"}}');
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
         // Execute post
        $result = curl_exec($ch);
        if ($result === FALSE) {
            die('Curl failed: ' . curl_error($ch));
            $result['error'] = curl_error($ch);
        }//else{*/
            $result['route'] = 'Notification';
        //}

        // Close connection
        //curl_close($ch);
        return $result;
       
    }
    public function send_SMS($mobile,$message,$senderID){ 
        //global $smpp;
        //$status=$smpp->Send('+91'.$mobile.'', "$message", true);
        //$result['msg_id'] = $smpp->GetMessageID();
        $status=1;
        if($status)
            $result['route'] = 'SMS';
        else
            $result['error'] = $status;
        
        return $result;
    }
    public function send_SecurityCode($mobile,$message){
        global $config;      
        $Username= $config->smsapi->Username;
        $Password= $config->smsapi->Password;
        $senderid= $config->smsapi->senderid;
        $message=urlencode("Your SancharApp OTP is $message");
        $url= 'http://logic.bizsms.in/SMS_API/sendsms.php?username='.$Username.'&password='.$Password.'&mobile='.$mobile.'&sendername='.$senderid.'&message='.$message.'&routetype=1';
    	/**********************using SMS API********************************/
		$ch = curl_init();
	    curl_setopt($ch, CURLOPT_URL,$url); 
	    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);   
	    $response = curl_exec($ch);
	    curl_close($ch);

        /**********************using SMPP********************************/
        //SMPP details
        /*global $config;
        $smpp_config=$config->smpp2;

        $smpp = new SMPPClass();
        $smpp->SetSender($smpp_config->from);
        $smpp->Start($smpp_config->smpphost,$smpp_config->smppport, $smpp_config->systemid, $smpp_config->password, $smpp_config->system_type);
        $smpp->Send('+91'.$mobile.'', "$message", true);
        $smpp->End();*/

    }
   
}
