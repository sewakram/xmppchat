<?php


/**
 * SubscriberController
 *
 * Allows to contact the staff using a contact form
 */
class SubscriberController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Contacts');
        parent::initialize();
          //Get session info
        $auth = $this->session->get('auth');
    }
    public  function Check_Gid($id){
          if(!$id) {
            return $this->response->redirect("group/index");
          }
          $auth = $this->session->get('auth');
          $user_id=$auth['id'];
          $group = Group::findFirst("id=$id AND user_id=$user_id");
          if(!$group) {
            return $this->response->redirect("group/index");
          }
    }
                 


    public function indexAction($group_id)
    {

        $this->Check_Gid($group_id);
        $auth = $this->session->get('auth');
        $user_id=$auth['id'];
        $result = array();
        $subscriber = new Subscriber();
        $getdata = $subscriber->getSubscriberData($user_id,$group_id);
        //$users=$this->db->fetchAll("SELECT * FROM state", Phalcon\Db::FETCH_ASSOC);
        $users = SubscriberMsgApi::find("company_id= ".$user_id);
        $i=0;
        foreach($users  as $ik => $user) {
        $result[$i]['id'] = $user->id;
        $result[$i]['name'] = $user->name;
        $result[$i]['mobilee'] = $user->mobile;
        $i++;
        }
        $this->view->setVars(array("subscriber"=> json_encode($getdata),"users"=> json_encode($result),"group_id"  => $group_id));

    }

    /**
     * Edits a contact based on its id
     */
    public function editAction($group_id)
    {
              $this->view->disable();
              $sid = $this->request->get('sid');
              $this->Check_Gid($group_id);
              if(!$sid){
                  echo json_encode('error');
              }
              $subscriber=Subscriber::findFirst("id=$sid AND group_id=$group_id");

            $request=$this->request;

         if($this->request->isPost()){

            $mobile = $request->getPost('mobile', 'int');
            $name = $request->getPost('name');
            $subscriber->name = $name;
            $subscriber->mobile = $mobile;

            if ($subscriber->save() == false) {
              //Send errors to the client
              $errors = array();
              foreach ($subscriber->getMessages() as $message) {
                $errors[] = $message->getMessage();
              }
               echo json_encode(array('status'=>'error','msg'=>$errors));
            } else {
               echo json_encode('success');
            }
          }
    }

    /**
     * Deletes a Contact
     *
     * @param string $id
     */
    public function deleteAction($group_id)
    {
        $this->view->disable();
        $request=$this->request;

        $this->Check_Gid($group_id);
        $auth = $this->session->get('auth');
        $user_id=$auth['id'];
        $user=new User();
        $trash_permission = $user->getPermissions($user_id);
        if ($request->isAjax() == true) {
           $trash=new Trash();
           $count=Trash::count("user_id=".$user_id);

             if($count>=$trash_permission['trash_contact_limits']){
                    echo json_encode(array('status'=>'error','msg'=>'Trash is Full'));
                    return; exit;
             }else{
               $sid = $this->request->getPost('sid');
               $sub_group = Subscriber::findFirst("id=$sid AND group_id=$group_id");
               $trash->user_id=$user_id;
               $trash->contact_no=$sub_group->mobile;
               $trash->datetime=date('Y-m-d H:i:s');
                if(!$sub_group->delete()) {
                     $errors = array();
                        foreach ($sub_group->getMessages() as $message) {
                          $errors[] = $message->getMessage();
                        }
                      echo json_encode(array('status'=>'error','msg'=>$errors));
                      return;
                }else{
                      $trash->save();
                      echo json_encode('success');
                      return;
                }
              }
        }

    }

    /**
     * Saves the contact information in the database
     */
    public function newAction($group_id)
    {
        $this->view->disable();
        //check user permission to add contacts
        $this->Check_Gid($group_id);
        $request=$this->request;
        // echo"<pre>";print_r($_POST);exit;

        if ($this->request->isPost()) {
            $mobile = $request->getPost('mobile', 'int');
            $name = $request->getPost('name');
            $selectedData = $request->getPost('selectedData');
            // echo"<pre>";print_r($selectedData);exit;
            $auth = $this->session->get('auth');
            $user=new User();
            $user_permission = $user->getPermissions($auth['id']);
            if($user_permission['contact_limits']!="unlimited"){
              $smt=$this->db->query("SELECT DISTINCT mobile FROM `subscriber` s, `group` g WHERE g.user_id =".$auth['id']." AND s.group_id=g.id");
              $smt->setFetchMode(PDO::FETCH_COLUMN,0);
              $mobile_count=$smt->fetchAll();

              if (in_array($mobile, $mobile_count)==false && $user_permission['contact_limits']<=count($mobile_count)) {
                  echo json_encode(array('status'=>'error','msg'=>'You have cross allowed contacts limit'));
                  exit();
              }
            }
            
            foreach ($selectedData as $key => $value) {
              $subscriber = new Subscriber();
              // print_r($value['name']);
              $subscriber->mobile = $value['mobilee'];
              $subscriber->name = $value['name'];
              $subscriber->group_id=$group_id;
              // exit;
              if ($subscriber->save() == false) {
              $errors = array();
              foreach ($subscriber->getMessages() as $message) {
              $errors[] = $message->getMessage();
              }
              echo json_encode(array('status'=>'error','msg'=>$errors));
              }
              else
              echo json_encode(array('status'=>'success','subscriber'=>$subscriber));
            }
            



        }


}
}
