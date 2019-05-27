<?php

class PollController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Poll');
        parent::initialize();
    }
    public function indexAction()
    {
      

    }
    public function saveAction()
    {         
      $this->view->disable();
      // print_r($_REQUEST);exit;
      $request=$this->request;
      if($this->request->isPost()){ 

          $poll = new Poll();
          $auth = $this->session->get('auth');
          // $user=User::findFirst($auth['id']);
          $option = array();

          $txtOpt1=$request->getPost('txtOpt1');
          $txtOpt2=$request->getPost('txtOpt2');
          $txtOpt3=$request->getPost('txtOpt3');
          $txtOpt4=$request->getPost('txtOpt4');
          array_push($option,$txtOpt1,$txtOpt2,$txtOpt3,$txtOpt4);
          $options=json_encode($option);
          $poll->userid=$auth['id'];
          $poll->questions=$request->getPost('txtQue');
          $poll->options=$options;
          // print_r($poll);exit;
          // try{
          //     if($poll->save() ==true){
          //     echo "save";
          //   }
          // }
          // catch(Exception $e){
          // var_dump($e->getMessage());
          // echo " Line=".$e->getLine(), "\n";
          // }
          if($poll->save() == false) {
          $errors = array();
          foreach ($poll->getMessages() as $message) {
          $errors[] = $message->getMessage();
          }
          return array('status' =>'error' ,'message'=>$errors,'poll'=>$poll);
          } else {
          return json_encode(array('status' =>'success' ,'data'=>array('id' => $poll->id)));    
          }
          // $result=$inbox->saveData($auth['id'],$sender_id,$message,$datetime);
          // echo json_encode($result);       
      }
    }
    public function updateStatusAction()
    {
      
    }
    public function ratingAction()
    {  
      $this->view->disable();
      // print_r($_REQUEST);exit;
      $request=$this->request;
      if($this->request->isPost()){
        $feedback = new Feedback();
        $auth = $this->session->get('auth');
      }
    }
}
