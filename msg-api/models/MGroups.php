<?php

use Phalcon\Mvc\Model;
use Phalcon\Mvc\Model\Validator\Email as EmailValidator;
use Phalcon\Mvc\Model\Validator\Uniqueness as UniquenessValidator;

class MGroups extends Model
{

    public $id;

    public function initialize()
    {
       $this->setSource("MGroups");
      // $this->hasMany('id', 'Group', 'user_id');
    }
    public function validation()
    {
        if ($this->validationHasFailed() == true) {
            return false;
        }
    }
}
