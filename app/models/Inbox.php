<?php

use Phalcon\Mvc\Model;

class Inbox extends Model
{
    public function initialize()
    {
       // $this->setSource("permissions");
    }
    public function onConstruct()
    {
      $this->db=$this->getDi()->getShared('db');
    }
    public function getData($mg_id,$user_id)
    {
     	 /* $inboxs=Inbox::find(array(
        "mg_id=$mg_id",
        "group" => "sender_id",
        "order" => "datetime",
        ));*/
        //$sql="SELECT id,sender_id,mg_id,message,read_status,MAX(datetime) as datetime FROM inbox WHERE mg_id=$mg_id  GROUP BY sender_id ORDER BY datetime";
        $sql="SELECT * FROM inbox WHERE id in (SELECT max(id) FROM inbox WHERE mg_id=$mg_id GROUP BY sender_id ) ORDER BY datetime DESC";
        $inboxs = $this->db->fetchAll($sql, Phalcon\Db::FETCH_ASSOC);
        $result = array();

/*        $mobiles = array_map(function($element) {return $element['sender_id'];}, $inboxs);
        $sql2="SELECT DISTINCT mobile,name from subscriber WHERE name<>'' AND mobile IN (".implode(',', $mobiles).")";
        $names = $this->db->fetchAll($sql2, Phalcon\Db::FETCH_KEY_PAIR);*/
        //print_r($names);
        foreach($inboxs  as $i => $inbox) {
            //$result[$i]['id'] = $inbox->id;
            $result[$i]['id'] =$inbox['sender_id'];
            $result[$i]['mg_id'] = $inbox['mg_id'];
   /*         if (array_key_exists($inbox['sender_id'], $names[0])){
              $result[$i]['sender_id'] =$names[0][$inbox['sender_id']];
            }else{*/
              $result[$i]['sender_id'] =$inbox['sender_id'];
    /*        }*/
            $result[$i]['message'] = str_replace(array("\n","\r"), " ", $inbox['message']);
            $result[$i]['read_status'] = $inbox['read_status'];
            $Date = new DateTime($inbox['datetime']);
            $result[$i]['datetime'] = $Date->format("d-m-y H:i");
            //$result[$i]['datetime'] = $inbox->datetime;
        }
        return json_encode($result);
    }
    public function updateStatus($mg_id)
    { 
      try{
        $sql="SELECT DISTINCT sender_id,msg_id FROM `inbox` WHERE `read_status`=false AND mg_id=$mg_id";
        $result1 = $this->db->query($sql);
        $result1->setFetchMode(PDO::FETCH_OBJ);
        $sql="UPDATE `inbox` SET `read_status`=true where `read_status`=false AND mg_id=$mg_id";
        // $result = $this->db->query($sql)->fetchAll(); // getting error in old
        $result2 = $this->db->query($sql);
        return $result1->fetchAll();
      }catch(Exception $e){
        var_dump($e);
      }
     
      exit;
    }
    public function saveData($mg_id,$sender_id,$message,$datetime,$msg_id)
    {
      $inbox = new Inbox();
      $inbox->mg_id=$mg_id;
      $inbox->sender_id=$sender_id;
      $inbox->message=$message;
      $inbox->datetime=$datetime;
      $inbox->msg_id=$msg_id;
      $inbox->read_status=0;
      if($inbox->save() == false) {
        $errors = array();
        foreach ($inbox->getMessages() as $message) {
            $errors[] = $message->getMessage();
        }
        return array('status' =>'error' ,'message'=>$errors,'inbox'=>$inbox);
      } else {
         return array('status' =>'success' ,'data'=>array('id' => $inbox->id,'datetime'=>(new DateTime($inbox->datetime))->format("d-m-y H:i")));    
      }      
    }
    public function getReportData($sender_id,$user_id)
    {
      $mobile=$sender_id;
      $user=User::findFirst($user_id);
      $sql="SELECT message,datetime from  `inbox` WHERE sender_id='".$sender_id."' AND mg_id=".$user->mg_id." ";
      $inbox =$this->db->fetchAll($sql, Phalcon\Db::FETCH_ASSOC);
      $sql2="SELECT text as message,datetime,route from  `message` WHERE route='Reply' AND user_id=$user_id AND mobile='".$mobile."' ";
      $messages =$this->db->fetchAll($sql2, Phalcon\Db::FETCH_ASSOC);
      $result= array_merge($inbox, $messages);
      usort($result, function($a, $b) {
        return strtotime($a['datetime']) - strtotime($b['datetime']);
      });
      return $result;
    }
}
