<?php
/**
 * GroupController
 *
 * 
 */
use Phalcon\Http\Response;
class GroupController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Groups');
        parent::initialize();
    }
    public function indexAction()
    {
          //Get session info
        $auth = $this->session->get('auth');
        $user_id=$auth['id'];
        // print_r($auth);exit;
        if($auth['login_type']=='manager'){
          $user = User::findFirst($user_id);
          $groups = Group::find(array("user_id = $user->company_id" ,'order'=>'id DESC' ));
        }else{
          $groups = Group::find(array("user_id = $user_id" ,'order'=>'id DESC' ));
        }
        //$groups = Group::find(array("user_id = '".$user_id."'" ,'order'=>'id DESC' ));
        
        $result = array();
        // $i=0;
        foreach($groups as $i => $group) {
            $result[$i]['id'] = $group->id;
            $result[$i]['name'] = $group->name;
            $subscriber = Subscriber::find("group_id = ".$group->id."");
            $result[$i]['count'] = count($subscriber);
            // $i++;
        }
        //echo "<pre>";
        //print_r($result);
        //echo "</pre>"; 
        //exit();
        $user=new User();
        $user_permission = $user->getPermissions($auth['id']);
        $smt=$this->db->query("SELECT Count(DISTINCT mobile) FROM `subscriber` s, `group` g WHERE g.user_id =".$auth['id']." AND s.group_id=g.id");
        $smt->setFetchMode(PDO::FETCH_COLUMN,0);
        $mobile_count=$smt->fetchAll();
        $trash_count=Trash::count("user_id=".$user_id);
        $this->view->setVars(array("group"=> json_encode($result),
                             "contact_used"  => $mobile_count[0],
                             "allowed_limit" => $user_permission['contact_limits'],
                             "trash_contact_limits" => $user_permission['trash_contact_limits'],
                             "trash_used" => $trash_count
          ));
    }
    public  function Check_Id($id){
          if(!$id) {
            return $this->response->redirect("group/index"); 
          }
          $auth = $this->session->get('auth');
          $user_id=$auth['id'];
          $group = Group::findFirst("id=$id AND user_id=$user_id");  
          if(!$id || !$group) {
            return $this->response->redirect("group/index"); 
          }
    }
    
    /**
     * Edits a contact based on its id
     */
    public function editAction($id)
    {         
            $this->view->disable();
            $group = Group::findFirstById($id);
           // $this->view->setVar("group", $group);
              
            $request=$this->request;
         if ($this->request->isPost()){  
            $name = $request->getPost('name', array('string', 'striptags'));
            $group->name = $name;
            if ($group->save() == false) {
               echo json_encode('error');
            } else {
               echo json_encode('success');
            }

            
        }
        exit();
      
    }
  
    /**
     * Deletes a Contact
     *
     * @param string $id
     */
    public function deleteAction($id)
    {
        $this->Check_Id($id);
        $this->view->disable();
        $request=$this->request;

        $auth = $this->session->get('auth');
        $user_id=$auth['id'];
        $user=new User();
        $trash_permission = $user->getPermissions($user_id);
        $insert_arr = array();
        if ($request->isAjax() == true) {
              $group = Group::findFirstById($id);
              $count=Trash::count("user_id=".$user_id);
              $subscriber_count = Subscriber::count("group_id = ".$id."");
              $total_count=$count+$subscriber_count;
              $trash_permission['trash_contact_limits']=77070;
              if($total_count>=$trash_permission['trash_contact_limits']){
                    $limit= $trash_permission['trash_contact_limits']-$count;
                    $subscriber = Subscriber::find(array("group_id = ".$id." " ,'limit'=>"".$limit."" ));
                     $insert_arr=$this->getmobno($user_id,$subscriber,date('Y-m-d H:i:s'));
                    $subscriber->delete();
                    $limit_count=$subscriber_count-$limit;
                    echo json_encode(array('status'=>'error','limit_count'=>$limit_count,'msg'=>''.$limit.' contact(s) deleted because Trash is Full'));
              }else{
                    $subscriber = Subscriber::find("group_id = ".$id."");
                     $insert_arr=$this->getmobno($user_id,$subscriber,date('Y-m-d H:i:s'));
                    $subscriber->delete();
                    $group->delete();
                    /*delete schedule those belong to group*/
                    $this->db->execute("DELETE FROM `schedular` WHERE group_id= ".$id." ");
                    /*End*/
                    echo json_encode('success');
              }
              /*foreach ($subscriber as $key => $value) {
                $insert_arr[$key][]=$user_id;
                $insert_arr[$key][]=$value->mobile;
                $insert_arr[$key][]= date('Y-m-d H:i:s');
              }*/
              if($insert_arr){
                  $batch = new Batch('trash');
                  $batch->setRows(['user_id','contact_no','datetime'])
                  ->setValues($insert_arr)->insert();
              }
              return;

        }
    }
     public function getmobno($user_id,$subid,$date1){
      $arr=array();
      foreach ($subid as $key => $value) {
                $arr[$key][]=$user_id;
                $arr[$key][]=$value->mobile;
                $arr[$key][]= $date1;
              }
      return $arr;

    }
/*    public function deleteAction($id)
    {
        $this->view->disable();
        $request=$this->request;
        $this->Check_Id($id);
        $auth = $this->session->get('auth');
        
        $user_id=$auth['id'];
        $user=new User();
        $trash_permission = $user->getPermissions($user_id);

        if ($request->isAjax() == true) {
              $group = Group::findFirstById($id);
                if (!$group->delete()) {
                 $errors = array();
                      foreach ($group->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                    echo json_encode(array('status'=>'error','msg'=>$errors));
                    return;
                }else{
                    foreach (Subscriber::find("group_id = ".$id."") as $sub) {
                     $subscriber = Subscriber::findFirst("group_id = ".$id."");
                     $sid = $subscriber->id;
                     $trash=new Trash;
                     $mobile=$trash->setmobtrash($sid);
                      if (!$sub->delete()) {
                               echo json_encode("Sorry, we can't delete the mobile right now: \n");
                      }else{
                          $count=Trash::count("user_id=".$user_id);
                          if($count<$trash_permission['trash_contact_limits']){
                               $trash->user_id=$user_id;  // echo "<br>";
                               $trash->contact_no=$mobile;//echo "<br>";
                               $trash->datetime= date('Y-m-d H:i:s');
                             $trash->save();
                          }
                          if($count==$trash_permission['trash_contact_limits'] || ! Subscriber::findFirst("group_id = ".$id."")){
                                      echo json_encode('success');
                          }
                      }
                   }
                }

                }

      
    }*/

    /**
     * Saves the contact information in the database
     */
    public function newAction()
    {
        
        $this->view->disable();
        $auth = $this->session->get('auth');
        $request=$this->request;
        if ($this->request->isPost()) {

            $name = $request->getPost('name', array('string', 'striptags'));
            $user_id=$auth['id'];
            $group = new Group();
            
            $group->name = $name;
            $group->user_id = $user_id;
          
            if ($group->save() == false) {
                echo json_encode('error');
            } else {
              echo json_encode(array('status'=>'success','group'=>$group));       
            }
        }
        exit();

     
    }
    public function exportAction($id)
    {    
        $this->Check_Id($id); 
        $group=new Group();
        $result=$group->export($id);
        if ($group==false) {
                foreach ($group->getMessages() as $message) {
                    $this->flash->error((string) $message);
                    
                }
            } else {
                //$this->flash->success("Group Exported");
                $response = new Response();
                $groups=Group::findFirst($id);

                $response->setJsonContent(array('data'=>$result,'group_name'=>$groups->name));
                return $response;
            }

    }
     public function importAction($id)
    {
       $this->Check_Id($id);
       if($this->request->isPost()){
          if ($this->request->isAjax()) {
              $this->view->disable();

              $response = new Response();
              $mobile=array();
              $g_id=$id;
              $count = 0;
              $mobile= $this->request->getPost('mobile');
              $name= $this->request->getPost('name');

            if(count($mobile)<=0){ 
              echo "invalid".count($mobile);
              $response->setJsonContent("invalid");
              $this->flash->success("No contact(s) imported");
              return $response;       
            }
            else{
              $group=new Group();
              $auth = $this->session->get('auth');
              $user=new User();
              $user_permission = $user->getPermissions($auth['id']);
              
              $smt=$this->db->query("SELECT DISTINCT mobile FROM `subscriber` s, `group` g WHERE g.user_id =".$auth['id']." AND s.group_id=g.id");
              $smt->setFetchMode(PDO::FETCH_COLUMN,0);
              $current_mobile_count=$smt->fetchAll();
              $temp_count=count($current_mobile_count);
              $insert_arr = array();
              $mobile = $group->filterMobile(array_unique($mobile),$g_id);
              for($i=0; $i < count($mobile); $i++) { 
                            //check plan contact limit cross or not and whether it is existing contacts or new 
                            if(is_numeric($mobile[$i]) && strlen((string) $mobile[$i])==10){
                                if (in_array($mobile[$i], $current_mobile_count)||$user_permission['contact_limits']>$temp_count|| $user_permission['contact_limits']=="unlimited") { 
                                      $insert_arr[$i][]=$mobile[$i];
                                      $insert_arr[$i][]=$name[$i];
                                      $insert_arr[$i][]=$g_id;
                                      $count++;
                                   if(in_array($mobile[$i], $current_mobile_count)==false)
                                      $temp_count++;           
                                }
                            }
              }
              if($insert_arr){
                $group->import($insert_arr);
              }
              $this->flash->success($count." contact(s) successfully imported");
              }
              echo "success";
              $response->setJsonContent("success");
              return $response;
         }   
       }   
     
          
       if(is_uploaded_file($_FILES['csvimport']['tmp_name']))
       {
            if ($_FILES['csvimport']['size'] > 0) {
           
            $file = file_get_contents($_FILES['csvimport']['tmp_name'],"r");
            $data = array_map("str_getcsv", preg_split('/\r*\n+|\r+/', $file));
            clearstatcache();
            $this->view->setVars(array("csvdata"=>$data,
                                       "group_id"=>$id));
            $this->flash->notice('Select Mobile field to Import');
            
            return;
            } 
       }
       
    }
    public function quickimportAction()
    {
      if($this->request->isPost()){
        $mobile=explode(',', $this->request->getPost('import_contacts'));
        $g_id=$this->request->getPost('import_group_id');
         if(count($mobile)<=0){ 
              $this->flash->error("No contact(s) imported");
              return $this->response->redirect("group/index");      
         }
        else{
            $group=new Group();
            $auth = $this->session->get('auth');
              /*create new group*/
              if($this->request->getPost('import_type')=="import_group_name"){
                  $group->name = $this->request->getPost('import_group_name', array('string', 'striptags'));
                  $group->user_id = $auth['id'];
                  $group->save();
                  $g_id=$group->id;
              }
              /*END Create new group*/
              $user=new User();
              $user_permission = $user->getPermissions($auth['id']);
              
              $smt=$this->db->query("SELECT DISTINCT mobile FROM `subscriber` s, `group` g WHERE g.user_id =".$auth['id']." AND s.group_id=g.id");
              $smt->setFetchMode(PDO::FETCH_COLUMN,0);
              $current_mobile_count=$smt->fetchAll();
              $temp_count=count($current_mobile_count);
              $count = 0;
              $insert_arr = array();
              $mobile = $group->filterMobile(array_unique($mobile),$g_id);   
              for($i=0; $i < count($mobile); $i++) { 
                            //check plan contact limit cross or not and whether it is existing contacts or new 
                            if(is_numeric($mobile[$i]) && strlen((string) $mobile[$i])==10){
                                if (in_array($mobile[$i], $current_mobile_count)||$user_permission['contact_limits']>$temp_count|| $user_permission['contact_limits']=="unlimited") { 
                                      $insert_arr[$i][]=$mobile[$i];
                                      $insert_arr[$i][]="No Names";
                                      $insert_arr[$i][]=$g_id;
                                      $count++;
                                   if(in_array($mobile[$i], $current_mobile_count)==false)
                                      $temp_count++;           
                                }
                            }
              }
              if($insert_arr){
                $group->import($insert_arr);
              }//end for each
              //$this->flash->success($count." out of ".count($mobile)." contact(s) successfully imported");
              $this->flash->success($count." contact(s) successfully imported");
              return $this->response->redirect("group/index");
          }
      }
    }
}
