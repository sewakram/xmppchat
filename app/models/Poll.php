<?php

use Phalcon\Mvc\Model;

class Poll extends Model
{
    public function initialize()
    {
       $this->setSource("poll");
    }
    public function onConstruct()
    {
      $this->db=$this->getDi()->getShared('db');
    }
    
    public function saveData($mg_id,$sender_id,$message,$datetime)
    {
      $poll = new Poll();
      $poll->mg_id=$mg_id;
      $poll->sender_id=$sender_id;
      $poll->message=$message;
      $poll->datetime=$datetime;
      $poll->read_status=0;
      if($poll->save() == false) {
        $errors = array();
        foreach ($poll->getMessages() as $message) {
            $errors[] = $message->getMessage();
        }
        return array('status' =>'error' ,'message'=>$errors,'poll'=>$poll);
      } else {
         return array('status' =>'success' ,'data'=>array('id' => $poll->id,'datetime'=>(new DateTime($poll->datetime))->format("d-m-y H:i")));    
      }      
    }
   
}
