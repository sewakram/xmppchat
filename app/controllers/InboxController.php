<?php

class InboxController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Inbox');
        parent::initialize();
    }
    public function indexAction()
    {
      $auth = $this->session->get('auth');
      $user=User::findFirst($auth['id']);
      $inbox = new Inbox();
      $result=$inbox->getData($user->mg_id,$user->id);
//$result=$inbox->findFirst("sender_id");
      $this->view->setVars(array("messages"=>$result,"user"=>$user));

      if(count($result)==0)
        $this->flash->notice("Inbox is empty");

    }
    public function saveAction()
    {         
      $this->view->disable();
    //   print_r($_REQUEST);exit;
      $request=$this->request;
      if($this->request->isPost()){  
          $inbox = new Inbox();
          $auth = $this->session->get('auth');
          $user=User::findFirst($auth['id']);
          $sender_id=$request->getPost('sender_id');
          $message=$request->getPost('message');
          $datetime=$request->getPost('datetime');
          $msg_id=$request->getPost('msg_id');

          $result=$inbox->saveData($user->mg_id,$sender_id,$message,$datetime,$msg_id);
          echo json_encode($result);       
      }
    }
    public function updateStatusAction()
    {

      $this->view->disable();
      $request=$this->request;
      if($this->request->isPost()){
          $inbox = new Inbox();
          $auth = $this->session->get('auth');
          $user=User::findFirst($auth['id']);
          $result=$inbox->updateStatus($user->mg_id);
          if(count($result))
          {
            // $param="mg_id=$mg_id&text=$text&multimedia=$multimedia&datetime=$datetime&status=$status&route=$route&sender_id=$sender_id&option=$option&app_access_days=$app_access_days&msg_limit=$msg_limit&sms_quota=$count&char_limit=$char_limit&sender_jid=".$auth['jid']."&sender_pass=".$auth['j_pass']."&"; 
            // $this->makeDeliveryAction($result,$auth['jid'],$auth['j_pass']);
          }
          echo json_encode($result);
      }
    }

    // ganesh make delivery to all once msg get read
    //requires array of object 
  private  function makeDeliveryAction($result,$jid,$pass){
        // echo 'ganesh';
        $datetime = base64_encode(date('Y-m-d H:i:s'));
  $param=urlencode("datetime=$datetime&&sender_jid=".$jid."&sender_pass=".$pass."&mobile=".json_encode($result));  
  // $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/makeDelivery',$param);
  echo json_encode($result);
exit;  
}


    public function reportAction()
    {  
      $this->view->disable();
      $request=$this->request;
      if($this->request->isPost()){
         $auth = $this->session->get('auth');
         $sender_id=$request->getPost('senderid');
         $inbox=new Inbox();
         $res=$inbox->getReportData($sender_id,$auth['id']);
         echo json_encode($res);    
      }
    }
}
