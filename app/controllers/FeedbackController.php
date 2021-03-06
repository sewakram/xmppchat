<?php
/**
 * GroupController
 *
 * 
 */
use Phalcon\Http\Response;
class FeedbackController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Feedback');
        parent::initialize();
    }
    public function indexAction()
    {
          //Get session info
        $auth = $this->session->get('auth');
        $user_id=$auth['id'];
  
        $feedbacks = Feedback::find(array("user_id = $user_id" ,'order'=>'id DESC' ));
        $result = array();
        foreach($feedbacks as $i => $feedback) {
            $result[$i]['id'] = $feedback->id;
            $result[$i]['user_id'] = $feedback->user_id;
            $result[$i]['question'] = $feedback->question;
            $result[$i]['datetime'] = $feedback->datetime;
            $result[$i]['display_date'] = (new DateTime($feedback->datetime))->format("d-m-y H:i");
        }
    
        $this->view->setVar("feedback", json_encode($result));
    }
    public function resultsAction($feed_id)
    {
      
        $feedback=new Feedback();
        $result=$feedback->results($feed_id);
        $this->view->setVars($result);
    }
    /**
     * Deletes a Contact
     *
     * @param string $id
     */
    public function deleteAction($id)
    {
        $this->view->disable();
        $request=$this->request;
        if ($request->isAjax() == true) {
              $feedback = Feedback::findFirstById($id);
              $feedback_results = FeedbackResults::find("feed_id = ".$id."");
                if (!$feedback->delete()) {
                   $errors = array();
                      foreach ($feedback->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                    echo json_encode(array('status'=>'error','msg'=>$errors));
                    return;
                }else{
                    $feedback_results->delete();
                    echo json_encode('success');
                    return;
                }
        }
      
    }
    public function exportAction($feed_id)
    {   $this->view->disable();
        $request=$this->request;
        $response = new Response();
        if($request->isAjax() == true) {
          $feedback=new Feedback();
          $result=$feedback->export($feed_id);
          $response->setJsonContent($result);
       }else{
         $response->setJsonContent(array('status'=>'error','message'=>'This is not ajax call'));
       }           
        return $response;
    }
    /**
     * Saves the contact information in the database
     */
    public function newAction()
    {


    }
    public function sendAction()
    {
      try{
        $start = microtime(true);  
        $this->view->disable();
        $auth = $this->session->get('auth');
        $s_id = $this->db->query("SELECT text from senderID where user_id = '".$auth['id']."'")->fetch();
        if(!$s_id){
          $this->flash->notice('Please create your sender id (in your plan you can\'t update it later)');
              return $this->response->redirect("account/index");
        }else
          $sender_id=$s_id['text'];

        $response = new Response();
        $request=$this->request;
        if ($this->request->isPost()) {

            $question =str_replace("?","",$request->getPost('question'));
            $question =$question."?";
            $answers = $request->getPost('answers');

            $user_id=$auth['id'];
            $feedback = new Feedback(); 
            $feedback->question = $question;
            $feedback->user_id = $user_id;
            //$feedback->group_id = $group_id;
            $feedback->answers = $answers;
            $feedback->datetime = date('Y-m-d H:i:s');
            $feedback->save();
            $mobile_array=array();

            $to_type_msg=$request->getPost('to_type_msg');
            $mobile_no=$request->getPost('mobile_no');
            $mobile_no=trim(str_replace(["\r\n","\r","\n"], ',', $mobile_no),",");
            $group_id = $request->getPost('group_id');
            $user=User::findFirstById($user_id);
            $config = Configuration::findFirst();
            $app_access_days = $config->app_access_days;    
            $msg_obj=new Message();
            switch ($to_type_msg) {
                    case 'group':
                        $mobile_array=$msg_obj->getGroupNumbers($group_id);
                        break;
                    case 'joint':
                        $mobile_array=Joint::getFollowersNumbers($user->mg_id);
                        break;
                    case 'excelfile':
                        if(is_uploaded_file($_FILES['excelfile']['tmp_name']))
                        {
                            $mobile_no=$msg_obj->getExcelNumbers($_FILES);
                            if($user->http_api_whitelist_status){
                                $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                            }else{
                                $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                            }
                        }
                        break;
                    case 'pincode':
                            $active_radio = $request->getPost('public_service_radio');
                            $pincode_range_min=$request->getPost('pincode_range_min');
                            $pincode_range_max=$request->getPost('pincode_range_max');
                            $pincode_ids=$request->getPost($active_radio);
                            $mobile_array=$msg_obj->getPincodeNumbers($user_id,$active_radio,$pincode_range_min,$pincode_range_max,$pincode_ids);
                            break;
                    default:
                            if($user->http_api_whitelist_status && $to_type_msg=="single"){
                                $mobile_array=$msg_obj->getWhiteListNumbers($user_id,$mobile_no); 
                            }else{
                                $mobile_array=$msg_obj->sanitizeMobileNumbers($mobile_no);
                            }
                        break;
                }
            if(!count($mobile_array)){
                $response->setJsonContent(array('status' => "error","message"=>"Number not found in any group"));
                return $response;
            }
            $user_permission = $user->getPermissions($auth['id']);
            $arr = array();
            $i=0;
            $mg_id=$user->mg_id;
            $count = $user->sms_quota;
            if($user_permission['text_message']!='unlimited'){
                $sending_limit = explode("/", $user_permission['text_message']);
                $msg_limit = $sending_limit[0];
            }else
                $msg_limit = $user_permission['text_message'];

            $insert_arr = array(); $mobile = array();
            foreach ($mobile_array as $key => $value1) {  
                if((($msg_limit=="unlimited" || ($msg_limit!="unlimited" && ($count+($key+1))<=$msg_limit)))){
                    $insert_arr[$key][]=$value1;
                    $insert_arr[$key][]=null;
                    $insert_arr[$key][]=$feedback->id;
                    $insert_arr[$key][]=null;   
                    $insert_arr[$key][]='Pending';
                    $i++;
                }
            }
            if($insert_arr){
                  $batch = new Batch('feedback_results');
                  $batch->setRows(['mobile','answers','feed_id','datetime','ustatus'])
                  ->setValues($insert_arr)->insert();
                  $query = $this->db->query("SELECT id, mobile from feedback_results where feed_id = ".$feedback->id."")->fetchAll();
                  foreach ($query as $key => $value) {
                      $mobile[$value['id']] = $value['mobile'];
                  }
            }
                $user->sms_quota += $i;
                $user->update();
                $mobile_str = json_encode($mobile);
                $datetime = base64_encode(date('Y-m-d H:i:s'));
                $option='';
                $answers=json_decode($answers,true);
                for($i=0; $i <count($answers); $i++) { 
                      $option.='<label class="opt"><input value="'.$answers[$i].'" name="option" type="radio" id="radio_'.$feedback->id.'_'.$i.'" /><label for="radio_'.$feedback->id.'_'.$i.'">'.$answers[$i].'</label></label><br/>';
                }
                $temp_msg='<span class="'.$feedback->id.'" id="feedback"><label class="que">'.$question.'</label><br/>'.$option.'<a class="btn-flat waves-effect waves-light center" id="submit" onclick="confirm_feed_model('.$feedback->id.');">Submit</a></span>';
                $multimedia = base64_encode(htmlentities($temp_msg));
                $sender_id=urlencode($sender_id);
                //sewak
                $sender_jid=$user->jid;
                $sen_pass=$user->j_pass;
                // sewak
                $param="mg_id=$mg_id&multimedia=$multimedia&datetime=$datetime&sender_id=$sender_id&app_access_days=$app_access_days&msg_limit=$msg_limit&sms_quota=$count&sender_jid=$sender_jid&sen_pass=$sen_pass&"; 
                // echo $param."mobile=$mobile_str";
                $result=$this->utils->curlPOST_redirect('http://sancharapp.com/msg-api/send_feedback',$param."mobile=$mobile_str");
                    // try{
                    // if(!empty($result)){
                    // echo "sent";
                    // }
                    // }
                    // catch(Exception $e){
                    // var_dump($e->getMessage());
                    // echo " Line=".$e->getLine(), "\n";
                    // }
                // print_r($result);
                // exit();
           
                $result=json_decode($result,true);

                if($result){
                $sql = "UPDATE `feedback_results` SET `ustatus`= CASE id ";
                $ids='';
                foreach ($result as $id=>$data) {
                    $sql .= "WHEN '".$id."' THEN '".$data."'";
                    $ids .="'".$id."',";
                  }
              }
              $sql .= "END WHERE id IN (".rtrim($ids, ",").") AND ustatus = 'Pending'";
              $this->db->execute($sql);

              file_put_contents('message_log.txt', __FUNCTION__.':'.round((microtime(true) - $start),3)."sec DT: ".date("D, d M y H:i:s O").'
    ', FILE_APPEND);

             $response->setJsonContent(array('status'=>'success','feedback'=>$feedback,'display_date'=>  $result[$i]['display_date'] = (new DateTime($feedback->datetime))->format("d-m-y H:i")));
             return $response;

        }  
           }
        //catch exception
        catch(Exception $e) {
          echo 'catch Error Message: ' .$e->getMessage();
        }
    }

}
