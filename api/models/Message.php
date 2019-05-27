<?php

use Phalcon\Mvc\Model;
use Phalcon\Mvc\Model\Validator\Uniqueness as UniquenessValidator;

class Message extends Model
{
   
  public function initialize()
    {
       $this->setSource("message");
    }
  public function onConstruct()
    {
      $this->db=$this->getDi()->getShared('db');
    }
     
}
