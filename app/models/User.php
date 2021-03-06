<?php

use Phalcon\Mvc\Model;
use Phalcon\Validation;
use Phalcon\Validation\Validator\Confirmation;
use Phalcon\Validation\Validator\PresenceOf;
use Phalcon\Validation\Validator\Email as EmailValidator;
use Phalcon\Validation\Validator\Uniqueness as UniquenessValidator;
// use Phalcon\Mvc\Model\Validator\StringLength as StringLengthValidator;
use Phalcon\Validation\Validator\StringLength as StringLengthValidator;

class User extends Model
{
    public function validation()
    {
        // try{
        $validator = new Validation();
      
        $validator->add(
            'email',
            new EmailValidator([
            'message' => 'Invalid email given'
        ]));
        $validator->add(
            'email',
            new PresenceOf([
            'message' => 'Email is required'
        ]));
        $validator->add(
            'email',
            new UniquenessValidator([
            'message' => 'Sorry, The email was registered by another user'
        ]));
        $validator->add(
            'mobile',
            new UniquenessValidator([
            'message' => 'Sorry, The mobile number already exists'
        ]));
        $validator->add(
            'mobile',
            new StringLengthValidator([

            'max' => 10,
            'min' => 10,
            'messageMaximum' => 'Enter Valid Mobile Number',
            'messageMinimum' => 'Enter Valid Mobile Number'
        ]));
        
        $validator->add(
            'password',
            new StringLengthValidator([

            'min' => 8,
            'messageMinimum' => 'Enter (minimum 8 characters) Password'
            
        ]));
        
        // $validator->add(
        // "password",
        // new Confirmation(
        // [
        //     "message" => "Password doesn't match confirmation",
        //     "with"    => "repeatPassword",
        // ]
        // ));

        // $validator->add(
        //     'repeatPassword',
        //     new StringLengthValidator([

        //     'min' => 8,
        //     'messageMinimum' => 'Enter (minimum 8 characters) Password',
            
        // ]));
        return $this->validate($validator);

    }

    public function getPermissions($userid){
        $this->db=$this->getDi()->getShared('db');
        $user_permission = array();
        ////////////////
                $user = $this->db->query("select * from user where type = 'manager' AND id = '".$userid."'")->fetch();

                if($user)
                {
                //this is manager
                $permissions = $this->db->fetchAll("SELECT sp.value,p.feature FROM permissions p ,manager_permissions sp WHERE p.id=sp.permission_id AND sp.manager_id=".$userid."", Phalcon\Db::FETCH_ASSOC);
                
                foreach ($permissions as $key => $value) {
                $user_permission[$value['feature']] = $value['value'];
                }
                }else{


                $user = $this->db->query("select slab_id from user where type = 'Group Admin' OR type = 'Super Admin' AND id = '".$userid."'")->fetch();

                /*$str = 'plan_'.$user['slab_id'];
                $permission = $this->db->query("select feature, $str as plan from permissions")->fetchAll();
                foreach ($permission as $key => $value) {
                $user_permission[$value['feature']] = $value['plan'];
                }*/
                $permissions = $this->db->fetchAll("SELECT sp.value,p.feature FROM permissions p ,slab_permissions sp WHERE p.id=sp.permission_id AND sp.slab_id=".$user['slab_id']."", Phalcon\Db::FETCH_ASSOC);
                foreach ($permissions as $key => $value) {
                $user_permission[$value['feature']] = $value['value'];
                }

                }
        //////////////
        return $user_permission;
    }
    /*Pass slab id to get all permissions*/
    public function getPermissionsFromSlab($slab_id){
        $this->db=$this->getDi()->getShared('db');
        $user_permission = array();
        $permissions = $this->db->fetchAll("SELECT sp.value,p.feature FROM permissions p ,slab_permissions sp WHERE p.id=sp.permission_id AND sp.slab_id=".$slab_id."", Phalcon\Db::FETCH_ASSOC);
        foreach ($permissions as $key => $value) {
            $user_permission[$value['feature']] = $value['value'];
        }
        return $user_permission;
    }
    public function getData($userid){
        $this->db=$this->getDi()->getShared('db');
        $user = $this->db->query("select slab_id,sms_quota from user where id = '".$userid."'")->fetch();
        $result = array();
        /*$str = 'plan_'.$user['slab_id'];
        $permission = $this->db->query("select feature, $str as plan from permissions")->fetchAll();
        foreach ($permission as $key => $value) 
            $result[$value['feature']] = $value['plan'];  */ 
            
        $permissions = $this->db->fetchAll("SELECT sp.value,p.feature FROM permissions p ,slab_permissions sp WHERE p.id=sp.permission_id AND sp.slab_id=".$user['slab_id']."", Phalcon\Db::FETCH_ASSOC);       
        foreach ($permissions as $key => $value) 
            $result[$value['feature']] = $value['value'];     
        $result['sms_quota'] = $user['sms_quota'];
        return $result;
    }

    public function checkPermissions($multimedia,$unicode_message,$image_message){
        if ((strlen($multimedia) != strlen(utf8_decode($multimedia))) && $unicode_message=="No" ){
            $msg = "You don't have permission to send unicode message with this plan. For sending unicode message please upgrade your plan.";
            return $msg;
        }
        preg_match_all('/<img[^>]+>/i',$multimedia, $img); 
        if(count($img[0])>0 && $image_message == 'No'){                    
            $msg = "You don't have permission to send image message with this plan. For sending image message please upgrade your plan.";
            return $msg;
        }
        // return true;
    }
    public function initialize()
    {
/*        $this->hasMany('id', 'Message', 'user_id', array(
            'foreignKey' => array(
                'message' => 'User cannot be deleted because it\'s used on Message'
            )
        ));*/
    }
}