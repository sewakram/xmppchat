<?php

use Phalcon\Mvc\Model;
use Phalcon\Mvc\Model\Validator\Email as EmailValidator;
use Phalcon\Mvc\Model\Validator\Uniqueness as UniquenessValidator;

class User extends Model
{

    public $id;

    public function initialize()
    {
       $this->setSource("user");
      // $this->hasMany('id', 'Group', 'user_id');
    }
    public function onConstruct()
    {
      $this->db=$this->getDi()->getShared('db');
    }
    public function validation()
    {
        /*$this->validate(new EmailValidator(array(
            'field' => 'email'
        )));
        $this->validate(new UniquenessValidator(array(
            'field' => 'email',
            'message' => 'Sorry, The email was registered by another user'
        )));
        $this->validate(new UniquenessValidator(array(
            'field' => 'username',
            'message' => 'Sorry, That username is already taken'
        )));*/
        if ($this->validationHasFailed() == true) {
            return false;
        }
    }
    public function getBlocklist($mg_ids){
        $phql ="SELECT u.mg_id,s.text as name FROM user u,senderID s where mg_id IN(".rtrim($mg_ids, ",").") AND u.id=s.user_id";
        $sub  = $this->db->query($phql);
        $sub->setFetchMode(Phalcon\Db::FETCH_ASSOC);
        $result=$sub->fetchAll();
        return $result;
    }
    public function getAppuserMessage($user_id,$count)
    {
        //Getting all robots with associative indexes only
         $appusermessages = $this->db->fetchAll("SELECT m.id,m.text,m.multimedia,m.mg_id,m.submit_datetime,m.status,m.mobile as aumobile,u.mobile as wumobile FROM sanchr5m_messaging_db.message m,senderID s,user u WHERE m.subscriber_id='".$user_id."' AND m.sender_id=s.text AND s.user_id=u.id GROUP By m.src_msg_id ORDER BY m.submit_datetime DESC LIMIT $count", Phalcon\Db::FETCH_ASSOC);
          // echo "<pre>";print_r($appusermessages);
        return $appusermessages;
        
    } 
     public function getUserMessage($user_id,$count)
    {
        //Getting all robots with associative indexes only
         $usermessages = $this->db->fetchAll("SELECT DISTINCT i.message,i.mg_id,u.mobile as wumobile,i.read_status,i.datetime,m.mobile as aumobile FROM sanchr5m_messaging_db.message m,inbox i,senderID s,user u WHERE m.subscriber_id='".$user_id."' AND m.mg_id=i.mg_id AND m.sender_id=s.text AND s.user_id=u.id ORDER BY i.id DESC LIMIT $count", Phalcon\Db::FETCH_ASSOC);
         // print_r($messages);
        return $usermessages;
        
    }
    public function getDefaultMessages($subscriber_id,$blocklist){
        // public service message
        $pincodes=explode(",", $pincodes);
        $phql ="SELECT u.mg_id,s.text as name ,p.welcome_msg,p.pincode FROM user u,senderID s,public_service p where u.status!='Blocked' AND u.id=s.user_id AND p.user_id=u.id AND p.welcome_msg IS NOT NULL AND p.pincode IS NOT NULL";
        $sub  = $this->db->query($phql);
        $sub->setFetchMode(Phalcon\Db::FETCH_ASSOC);
        $res=$sub->fetchAll();
        $result = array();
        $key=0;
        foreach ($res as $value) {
            $pincode=explode("=",$value['pincode']);
            if(isset($pincode[1]) && $pincode[1]!="null"){
                $pincode_ids=implode(",", json_decode($pincode[1]));
                switch ($pincode[0]) {
                    case 'district':
                            $smt = $this->db->query("SELECT p.pin FROM pincode p,taluka t,district d WHERE d.id=t.dist_id AND t.id=p.tq_id AND d.id IN (".$pincode_ids.")");
                            break;
                    case 'taluka':
                            $smt = $this->db->query("SELECT p.pin FROM pincode p,taluka t WHERE t.id=p.tq_id AND t.id IN (".$pincode_ids.")");
                            break;
                    case 'pincode':
                            $smt = $this->db->query("SELECT pin FROM pincode WHERE id IN (".$pincode_ids.")");
                            break;
                    default:
                            $smt = $this->db->query("SELECT p.pin FROM pincode p,taluka t,district d,state s WHERE s.id=d.state_id AND d.id=t.dist_id AND t.id=p.tq_id AND s.id IN (".$pincode_ids.")");
                            break;
                }
            }
            $smt->setFetchMode(PDO::FETCH_COLUMN,0);
            $temp_pin_array=$smt->fetchAll();
            if(count($temp_pin_array)>0 && in_array($value['mg_id'], $blocklist)!=1){
                if(in_array($pincodes[0], $temp_pin_array) || in_array($pincodes[1],$temp_pin_array)){
                    $result[$key]['mg_id'] = $value['mg_id'];
                    $result[$key]['name'] = $value['name'];
                    $result[$key]['welcome_msg'] = "<p>".$value['welcome_msg']."</p>";
                    $key++;
                }
            }
        }

        //default admin message
        // $phql2 ="SELECT u.mg_id,s.text as name,c.welcome_msg FROM user u,configuration c,senderID s where u.type='Super Admin' AND u.id=s.user_id";
        $phql2 ="SELECT u.mobile,c.app_name as name,c.welcome_msg FROM user u,configuration c,sanchr5m_messaging_db.subscriber sub where sub.id='".$subscriber_id."' AND sub.company_id=c.company_id AND sub.company_id=u.id";
        $sub2  = $this->db->query($phql2);
        $sub2->setFetchMode(Phalcon\Db::FETCH_ASSOC);
        $result2=$sub2->fetchAll();

        return array_merge($result, $result2);
    }
    public function getPermissions($userid){
        $this->db=$this->getDi()->getShared('db');
        $user_permission = array();
        $user = $this->db->query("select slab_id from user where id = '".$userid."'")->fetch();
        /*$str = 'plan_'.$user['slab_id'];
        $permission = $this->db->query("select feature, $str as plan from permissions")->fetchAll();
        foreach ($permission as $key => $value) {
            $user_permission[$value['feature']] = $value['plan'];
        }*/
        $permissions = $this->db->fetchAll("SELECT sp.value,p.feature FROM permissions p ,slab_permissions sp WHERE p.id=sp.permission_id AND sp.slab_id=".$user['slab_id']."", Phalcon\Db::FETCH_ASSOC);
        foreach ($permissions as $key => $value) {
            $user_permission[$value['feature']] = $value['value'];
        }
        return $user_permission;
    }

}
