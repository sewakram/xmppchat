<?php
error_reporting(E_ALL);
ini_set("log_errors", 1);
ini_set("error_log", "php-error.log");
error_log( "Hello, errors!" );
use Phalcon\Http\Response;
/**
 * AdminController
 *
 * Allows to authenticate users
 */
/*include __DIR__ . "/../library/Mail/mail.php";*/
class AppuserController extends ControllerBase
{

    public function initialize()
    {
        $this->tag->setTitle('Users');
        parent::initialize();
       
    }
     public function onConstruct()
    {
      
    }
       public function mobile_verificationAction($slab_id=NULL){
         
            if(!$slab_id){
            $slab_zero = Slabs::findFirst("amount=0");
            $slab_id=$slab_zero->id;
            //return $this->response->redirect("test/logic_both/$slab_id");  
        }
               if(isset($_GET["result"]))
              {  
                    $result_google = json_decode($_GET["result"], true);
                    $result['email']=$result_google['email'];
                    $result['familyname']=$result_google['familyname'];
                    $result['givenname']=$result_google['givenname'];
             }
             if(isset($_GET['access_token'])){

            $access_token=$_GET["access_token"];
             $this->session->remove("access_token");
           
              $fields ='id,name,first_name,last_name,email,birthday,gender';

              $url='https://graph.facebook.com/me/?fields='.$fields.'&access_token='.$access_token;
   
              $ch = curl_init();
            // Enable SSL verification
            //curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, $enable_ssl);
            // Will return the response, if false it print the response
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            // Set the url
            curl_setopt($ch, CURLOPT_URL,$url);
            // Execute
            $result=curl_exec($ch);
            // Closing
            curl_close($ch);

            $result = json_decode($result, true);
          }
            
          $email=null;
          if(!empty($result)){$email=$result['email'];}
           $aluser = User::findFirst(array(
                    "(email = :email:)",
                    'bind' => array('email' =>$email)
                ));
               if ($aluser != false){
                $login_type="Group Admin";
                $this->_registerSession($aluser,$login_type);
                  $days=$this->_reminder($user->expiry_date);
                if($days<7 && $days>=0){
                    if($days==0)
                        $this->flash->error("<div class='expire_validity'>Your Credit validity will expire today</div>");
                    else
                        $this->flash->error("<div class='expire_validity'>Your Credit validity will expire after <b> $days </b> Days</div>");
                }
                elseif($days<0)
                    $this->flash->error("<div class='expire_validity'>Your credit validity was expired</div>");

                if ($this->request->getPost('redirect_url')!="/connect/signin" && $this->request->getPost('redirect_url')!='')
                    return $this->response->redirect($this->request->getPost('redirect_url'));    
                
                //$this->flash->success('Welcome ' . $user->firstname." ".$user->lastname);
                //return $this->response->redirect("message/send"); 
                return $this->response->redirect("app"); 
              }

 ///////////////////////////////
        $auth = $this->session->get('auth');
      

           /////////////////////////
        if(isset($_SESSION['access_token'])){
            $access_token=$_SESSION["access_token"];
             $this->session->remove("access_token");
           
              $fields ='id,name,first_name,last_name,email,birthday,gender';

              $url='https://graph.facebook.com/me/?fields='.$fields.'&access_token='.$access_token;
   
              $ch = curl_init();
            // Enable SSL verification
            //curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, $enable_ssl);
            // Will return the response, if false it print the response
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            // Set the url
            curl_setopt($ch, CURLOPT_URL,$url);
            // Execute
            $result=curl_exec($ch);
            // Closing
            curl_close($ch);

            $result = json_decode($result, true);
        
          }else{

            if(isset($_SESSION["result"]))

            $result=$_SESSION['result'];
          $this->session->remove('result');
          }

        $request=$this->request;
        if ($this->request->isPost()) {
               
              $OTP_session = $this->session->get("OTP");
              $OTP=$request->getPost('OTP');
              if($OTP!=$OTP_session) {
                $this->flash->error('Your OTP is incorrect. Please try again.');
                return $this->response->redirect("connect/signup");
                exit();
              }
            $user = new User();
            $user->type = "Group Admin";
            $user->registered_on = date('Y-m-d H:i:s');
            $user->status = "Active";
            $user->mobile =  $request->getPost('mobile', 'int');
           
            if(isset($access_token)){
                $joint_handle=str_replace(array("@"," "),"",$result['first_name']);
               $user->firstname=$result['first_name'];
               $user->lastname=$result['last_name'];
               $user->email=$result['email'];
            }else{
              $joint_handle=$result['givenname'];
              $user->firstname=$result['givenname'];
                $user->lastname=$result['familyname'];
                 $user->email=$result['email'];
          }
            $user->joint_handle="@".$joint_handle;           
             $user->password=base64_encode($request->getPost('mobile'));
            $user->mluc = 0;
            $slab = Slabs::findFirst("amount=0");
            $user->slab_id=$slab->id;
            $user->sms_quota = 0;
            $user->expiry_date =$this->utils->getExpiryDate("NOW",$slab->validity,"add");
 
            $msg_result=$this->utils->curl_redirect('http://sancharapp.com/msg-api/web_register','name='.$user->firstname.'&type=LinkApp');
            $msg_result=json_decode($msg_result,true);

            if(array_key_exists("result",$msg_result)){
                $user->mg_id=$msg_result['result']['mg_id'];
                $user->jid=$msg_result['result']['jid'];
                $user->j_pass=$msg_result['result']['j_pass'];
            }else{
                $this->flash->error('Sorry try after some time');
                //return $this->response->redirect("connect/signup");    
            }

            if ($user->save() == false) {
                  foreach ($user->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
             } else {
                 copy('profile/default.jpg','profile/'.$user->mg_id.'.jpg');
                /*Code to create sender id*/
                $senderID = new SenderID();
                $senderID->text = $request->getPost('senderid');//str_replace(' ', '-', $name );
                $senderID->user_id = $user->id;
                $senderID->status = 'Approved';
                $senderID->save();
                /*End*/
                $password=base64_encode($request->getPost('mobile'));
                $plan = Slabs::findFirstById($request->getPost('slab_id','int'));
                $this->welcomeMailSMS($user,$password);
                if($plan->amount != 0){
                    $this->flash->success('Signup successfully. After completing your Payment Process you get an activation message on your mobile.');
                    return $this->response->redirect("user/makePayment/".$user->id."/".$plan->amount); 
                }else{
                    $this->postlogin($user);
                }
            }
        }
        $this->view->setVar("url_param",$slab_id); 
    }
    public function postlogin($aluser){
   $login_type="Group Admin";
                $this->_registerSession($aluser,$login_type);
                  $days=$this->_reminder($user->expiry_date);
                if($days<7 && $days>=0){
                    if($days==0)
                        $this->flash->error("<div class='expire_validity'>Your Credit validity will expire today</div>");
                    else
                        $this->flash->error("<div class='expire_validity'>Your Credit validity will expire after <b> $days </b> Days</div>");
                }
                elseif($days<0)
                    $this->flash->error("<div class='expire_validity'>Your credit validity was expired</div>");

                if ($this->request->getPost('redirect_url')!="/connect/signin" && $this->request->getPost('redirect_url')!='')
                    return $this->response->redirect($this->request->getPost('redirect_url'));    
                
                //$this->flash->success('Welcome ' . $user->firstname." ".$user->lastname);
                //return $this->response->redirect("message/send"); 
                return $this->response->redirect("app");
    }
    private function _registerSession($user,$login_type)
    {
        $this->session->set('auth', array(
            'id' => $user->id,
            'name' => $user->firstname,
            'login_type' => $login_type,
            'jid' =>  $user->jid,
            'j_pass' =>  $user->j_pass,
        ));
        $this->_log($user);
    }
    private function _log($user)
    {
        $ip=$this->request->getClientAddress();
        $datetime=date('Y-m-d H:i:s');
        //store in db
        $login_log=new LoginLog();
        $login_log->user_id=$user->id;
        $login_log->ip=$ip;
        $login_log->datetime=$datetime;
        $login_log->save();
        //store in log file
        $sPath = '../public/log/login/login_' . date('Y-m-d') . '.log';
        file_put_contents($sPath, "\n".$user->mobile." ".$user->id." ".$ip." ".$this->request->getUserAgent()." ".$datetime,FILE_APPEND);
    }
    // Function to get the client IP address
/*    private function get_client_ip() {
        $ipaddress = '';
        if (isset($_SERVER['HTTP_CLIENT_IP']))
            $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
        else if(isset($_SERVER['HTTP_X_FORWARDED_FOR']))
            $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
        else if(isset($_SERVER['HTTP_X_FORWARDED']))
            $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
        else if(isset($_SERVER['HTTP_FORWARDED_FOR']))
            $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
        else if(isset($_SERVER['HTTP_FORWARDED']))
            $ipaddress = $_SERVER['HTTP_FORWARDED'];
        else if(isset($_SERVER['REMOTE_ADDR']))
            $ipaddress = $_SERVER['REMOTE_ADDR'];
        else
            $ipaddress = 'UNKNOWN';
        return $ipaddress;
    }*/
    /*private function _reminder($slab_id)
    {
        $slabs = Slabs::findFirstById($slab_id);
        $datetime1 = new DateTime(null);
        $datetime2 = new DateTime($slabs->end_date);
        $interval = $datetime1->diff($datetime2);
        $days=$interval->format('%R%a');
        return $days;
    }*/
    private function _reminder($expiry_date)
    {
        $datetime1 = new DateTime(null);
        $datetime2 = new DateTime($expiry_date);
        $interval = $datetime1->diff($datetime2);
        $days=$interval->format('%a');
        return $days;
    }
  
    public function logoutAction()
    {

        $this->session->remove('auth');
        //$this->flash->success('Goodbye!');
        $this->response->redirect("/connect"); 
        $this->view->disable();
        return; 
    } 
    public function signinAction()
    {
        $auth=$this->session->get('auth');
        if($auth)
            //return $this->response->redirect("dashboard"); 
            return $this->response->redirect("app"); 
        $this->tag->setTitle('Sign In');
        if ($this->request->isPost()) {
            //if($this->security->checkToken()) {
            $mobile = $this->request->getPost('mobile');
            $password = $this->request->getPost('password');

            $user = User::findFirst(array(
                    "(mobile = :mobile:) AND password = :password: AND status = 'Active' AND type = 'Group Admin'",
                    'bind' => array('mobile' => $mobile, 'password' => sha1($password))
                ));
           
            if ($user != false){
                $login_type="Group Admin";
                $this->_registerSession($user,$login_type);
                
                $days=$this->_reminder($user->expiry_date);
                if($days<7 && $days>=0){
                    if($days==0)
                        $this->flash->error("<div class='expire_validity'>Your Credit validity will expire today</div>");
                    else
                        $this->flash->error("<div class='expire_validity'>Your Credit validity will expire after <b> $days </b> Days</div>");
                }
                elseif($days<0)
                    $this->flash->error("<div class='expire_validity'>Your credit validity was expired</div>");

                if ($this->request->getPost('redirect_url')!="/connect/signin" && $this->request->getPost('redirect_url')!='')
                    return $this->response->redirect($this->request->getPost('redirect_url'));    
                
                //$this->flash->success('Welcome ' . $user->firstname." ".$user->lastname);
                //return $this->response->redirect("message/send"); 
                return $this->response->redirect("app"); 
            }

            $this->flash->error('Wrong Mobile/password');
          //}
          return $this->response->redirect("connect/signin"); 
        }            
    }

    public function indexAction()
    {
        $auth=$this->session->get('auth');
        $user_id=$auth['id'];
        // $slabs = Slabs::minimum(array("column" => "amount"));
       
        $result = array();
        // print_r($auth);
        if($auth['login_type']=="Super Admin"){
        //     $user_bal=Franchisee::findFirst($user_id);
        //     $bal1=$user_bal->balance;
            $users = SubscriberMsgApi::find();
        }else if($auth['login_type']=="Manager"){
            $muser=User::findFirst($user_id);
            $users = SubscriberMsgApi::find("company_id= ".$muser->company_id);
        }
        else{
            // $user_bal=User::findFirst($user_id);
            // $bal1=$user_bal->balance ;
            $users = SubscriberMsgApi::find("company_id= ".$user_id);
        }

            $i=0;
        foreach($users  as $ik => $user) {

            // if($user->franchisee_id)
            //     $franchisee=Franchisee::findFirst($user->franchisee_id);
            // $slab=Slabs::findFirst($user->slab_id);
            $username=User::findFirst($user->company_id);
            
            $result[$i]['id'] = $user->id;
            $result[$i]['name'] = $user->name;
            $result[$i]['mobile'] = $user->mobile;
            $result[$i]['status'] = $user->ustatus;
            $result[$i]['adminname'] = $username->firstname." ".$username->lastname;
            // if($user->franchisee_id)
            //     $result[$i]['franchisee'] = $franchisee->email;
            // else
            //     $result[$i]['franchisee'] = '';
            // $result[$i]['slab_id'] = $slab->name;
            // if($user->expiry_date==null ||$user->expiry_date=="0000-00-00 00:00:00")
            //     $result[$i]['expiry_date'] = '00-00-0000';
            // else
            //     $result[$i]['expiry_date']=(new DateTime($user->expiry_date))->format("d-m-Y");
            
            $i++;
        }
       // echo "<pre>";print_r($result);
     
        $this->view->setVars(array("user"=>json_encode($result)));
    }
    public function deleteAction($id)
    {
        $this->view->disable();
        $request=$this->request;
        if ($request->isAjax() == true) {
            $user = SubscriberMsgApi::findFirstById($id);
                if (!$user->delete()) {
                    $errors = array();
                      foreach ($user->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                    echo json_encode(array('status'=>'error','msg'=>$errors));
                    return;
                }
                // else{
                //     $senderid = SenderID::findFirst("user_id=".$id);
                //     if($senderid)
                //         $senderid->delete();
                //     $api = Api::findFirst("user_id=".$id);
                //     if($api)
                //         $api->delete();
                //     $group = Group::find('user_id='.$id);
                //     $arr = array();
                //     if($group){
                //         foreach ($group as $key => $value) {
                //             $arr[] = $value->id;
                //             $value->delete();
                //         }                       
                //     }                   
                //     if(!empty($arr)){
                //         $subscriber = Subscriber::find('group_id IN ('.implode(",", $arr).')');                     
                //         if($subscriber){
                //             foreach ($subscriber as $key1 => $value1) 
                //                 $value1->delete();
                //         }
                //     }                   
                    echo json_encode('success');
                    return;
                //}

        }
    }

     public function viewAction($id)
    {
        $auth = $this->session->get('auth');
         if(!$id) {
            return $this->response->redirect("user/index"); 
          }

         $user = SubscriberMsgApi::findFirst($id);
         // $slabs=Slabs::findFirstById($user->slab_id);
         if(!$user){
            $this->flash->error("User was not found");
            return $this->response->redirect("user/index"); 
         }
         $this->view->setVars(array("user"=> $user));


    }
    public function update_terms_statusAction()
    {
        $this->view->disable();
        $auth = $this->session->get('auth');
        $user = User::findFirst($auth['id']);
        $request=$this->request;
        $response = new Response();
   
        if ($this->request->isPost()){  
                if($user){
                    if($request->getPost('checkbox1') && $request->getPost('checkbox2')){
                            $user->agree_terms_of_service=1;
                            if ($user->save()) {
                                $this->flash->success('Thank you !'); 
                                      $response->setJsonContent(array('status' => "success","message"=>"Thank you !"));
                                      return $response;
                            }
                    }else{
                        $this->flash->error("Please check both option");
                              $response->setJsonContent(array('status' => "error","message"=>"Please check both option"));
                              return $response;
                    }
                }
        }

     //   return $this->response->redirect("message/send");
    }
    public function editAction($id)
    {
        $auth = $this->session->get('auth');
         if(!$id) {
            return $this->response->redirect("appuser/index"); 
          }

         $user = SubscriberMsgApi::findFirst($id);
         // $slabs=Slabs::findFirstById($user->slab_id);
         if(!$user){
            $this->flash->error("User not found");
            return $this->response->redirect("appuser/index"); 
         }
         $this->view->setVars(array("user"=> $user));

            $request=$this->request;
         if ($this->request->isPost()){  

            // if($auth['login_type']=="Franchisee"){
            //     $this->flash->success('You Can\'t Edit User Details');
            //     return $this->response->redirect("user/index"); 
            // }

            $user->name = $request->getPost('firstname', array('string', 'striptags','trim'));
            // $user->lastname = $request->getPost('lastname', array('string', 'striptags','trim'));
            // $user->email = $request->getPost('email', 'email');
            $user->mobile = $request->getPost('mobile', 'int');
            // $user->address = $request->getPost('address');
            // $user->city= $request->getPost('city');
            // $user->state= $request->getPost('state');
            $user->pincode= $request->getPost('pincode','int');
            // $user->phone= $request->getPost('phone','int');
            $user->dob = $request->getPost('dob');
            /*$user->details= $request->getPost('details');  */          
            $user->ustatus= $request->getPost('status');
            $repeatPassword = $request->getPost('confirm_password');
            $password      =$request->getPost('password');
            // $user->http_api_whitelist_status = $request->getPost('http_api_whitelist_status');  
            // print_r($user);exit; 

            // $senderid = SenderID::findFirst("user_id=".$id);
            // if($senderid){
            //     $senderid->text=$request->getPost('senderid');
            //     $senderid->save();
            // }
            if($request->getPost('pass_status')=="true"){
                if($password != $repeatPassword) {
                    $this->flash->error('Passwords are diferent');
                    return false;
                }else{
                   
                    $user->password = sha1($password);            
                }
            }
                // $obj = new User();
                // $user_permission = $obj->getPermissions($id); 
                // if($user_permission['pincode_message'] == 'Yes'){
                //   $public_service= PublicService::findFirst("user_id=".$id."");
                //   if(!$public_service)
                //     $public_service= new PublicService();
               
                //   $public_service->user_id=$user->id;
                //   $public_service->pincode=$request->getPost('service_pincode_val');
                //   $public_service->save();
                // }
            if ($user->save() == false) {
                foreach ($user->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
            } else {
                $this->flash->success('User updated');
                return $this->response->redirect("appuser/index"); 
            }            
        }
    }
    public function newAction()
    {
        //Get session info

        $auth = $this->session->get('auth');
        // echo "<pre>";
// print_r($_REQUEST);
// print_r($auth);exit;
        $request=$this->request;
        if ($this->request->isPost()) {
            $password = $request->getPost('password');
            $repeatPassword = $request->getPost('repeatPassword'); 
            if($password != $repeatPassword) {
                $this->flash->error('Passwords are diferent');
                return false;
            }

            $user = new SubscriberMsgApi();
            /*$user->username = $request->getPost('username', 'alphanum');*/
            $user->password = sha1($password);
            $user->name = $request->getPost('first_name', array('string', 'striptags','trim'));
            // $user->lastname = $request->getPost('last_name', array('string', 'striptags','trim'));
            // $user->email = $request->getPost('email', 'email');
            // $user->type = "Group Admin";
            // $user->registered_on = date('Y-m-d H:i:s');
            //$user->status = "Pending";
            $user->ustatus =$request->getPost('status');
            $user->mobile =  $request->getPost('mobile', 'int');
            // $user->organization = $request->getPost('organization');

            if($auth['login_type']=="Manager"){
                $usercid = User::findFirst($auth['id']);
               $user->company_id = $usercid->company_id; 
             }else{
                $user->company_id = $auth['id'];
             }
            
            $user->dob = $request->getPost('dob');
            $user->pincode_home= $request->getPost('pincode');
            $user->type= 'LinkApp';
            $user->app_type= 'Web';


            // $user->state= $request->getPost('state');
            //$user->pincode= $request->getPost('pincode','int');
            // $user->phone= $request->getPost('phone','int'); 
            /*$user->credit_validity= 0;
            $user->details=$request->getPost('details');
            $user->delivery_return_sms= 'Yes';
            $user->delivery_return_notification='Yes';*/

            //$slabs=Slabs::findFirst("amount=".Slabs::minimum(array('column' => 'amount'))."");
            // $slab = Slabs::findFirst("amount=0");
            // $user->slab_id=$slab->id;
            // $user->sms_quota = 0;
            // $user->expiry_date =$this->utils->getExpiryDate("NOW",$slab->validity,"add");
            //$user->slab_id=$request->getPost('slab_id','int');
            $msg_result=$this->utils->curl_redirect('http://sancharapp.com/msg-api/webappuser_register','name='.$user->name.'&type=LinkApp&mobile='.$user->mobile);
              // print_r($msg_result);exit;
            $msg_result=json_decode($msg_result,true);
            if(array_key_exists("result",$msg_result)){

                $user->mg_id=$msg_result['result']['mg_id'];
                $user->jid=$msg_result['result']['jid'];
                $user->j_pass=$msg_result['result']['j_pass'];
            }else{
                // echo "<pre>";print_r($user);exit;
                $this->flash->error('Sorry try after some time');
                return $this->response->redirect("appuser/index");    
            }
            
            if ($user->save() == false) {
                foreach ($user->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
                return $this->response->redirect("appuser/new");
            } else {
                copy('profile/default.jpg','profile/'.$user->mg_id.'.jpg');
                /*Configure SMS API if User insert succsfully*/
                if (isset($_POST['configure_status'])) {
                    $api=new Api();  
                    $api->user_id =$user->id;  
                    $api->url = $request->getPost('url');
                    $api->to= $request->getPost('to');
                    $api->text = $request->getPost('text');
                    $api->max_limit = $request->getPost('max_limit', 'int');
                    $api->is_logic=$request->getPost('is_logic');
                    $api->status ='Enable';
                    $api->save();
                }
                /*-------------------------------------------*/
                $this->welcomeMailSMS($user,$password);
                $this->flash->success('User Created');
                return $this->response->redirect("appuser/index"); 
            
            }
        }
        $form = new RegisterForm;
        $this->view->form = $form;
    }
    public function signupAction($slab_id)
    {
// echo $slab_id;
// print_r($_POST);
// exit();
        // Get session info
        if(!$slab_id){
            $slab_zero = Slabs::findFirst("amount=0");
            $slab_id=$slab_zero->id;
            return $this->response->redirect("connect/signup/$slab_id");  
        }

        $auth = $this->session->get('auth');
        if($auth)
        {
            // print_r($auth);exit();
            return $this->response->redirect("app");
        }
            
         //   return $this->response->redirect("dashboard"); 
              
        $form = new RegisterForm;
        $request=$this->request;
        if ($this->request->isPost()) {
              $OTP_session = $this->session->get("OTP");
              $OTP=$request->getPost('OTP');
              if($OTP!=$OTP_session) {
                $this->flash->error('Your OTP is incorrect. Please try again.');
                return $this->response->redirect("connect/signup");
            
              }
            if (isset($_POST['terms'])) {
            $password = $request->getPost('password');
            $repeatPassword = $request->getPost('repeatPassword'); 
            if($password != $repeatPassword) {
                // echo'sewak3';exit();
                $this->flash->error('Passwords are diferent');
                return false;
                // echo'sewak4';
            }
                // echo'sewak4';exit();

            //$slab = Slabs::findFirst("amount=0");
            $user = new User();
            //$user->username = $request->getPost('username', 'alphanum');
            $user->password = sha1($password);
            $user->firstname = $request->getPost('first_name', array('string', 'striptags','trim'));
            
            $user->lastname = $request->getPost('last_name', array('string', 'striptags','trim'));
            $user->email = $request->getPost('email', 'email');
            $user->type = "Group Admin";
            $user->registered_on = date('Y-m-d H:i:s');
            $user->status = "Active";
            $user->mobile =  $request->getPost('mobile', 'int');
            $joint_handle=str_replace(array("@"," "),"",$request->getPost('joint_handle'));
            $user->joint_handle="@".$joint_handle;
            //$user->organization = $request->getPost('organization');
            //$user->address = $request->getPost('address');
            //$user->city = $request->getPost('city');
            //$user->state = $request->getPost('state');
            //$user->pincode = $request->getPost('pincode','int');
            //$user->phone = $request->getPost('phone','int');
            //$user->details = $request->getPost('details');
            
            //$slab = Slabs::findFirst($request->getPost('slab_id','int'));
            $slab = Slabs::findFirst("amount=0");
            $user->slab_id=$slab->id;
            $user->sms_quota = 0;
            $user->expiry_date =$this->utils->getExpiryDate("NOW",$slab->validity,"add");
            // echo '<pre>';print_r($user);die();
            $msg_result=$this->utils->curl_redirect('http://sancharapp.com/msg-api/web_register','name='.$user->firstname.'&mobile='.$user->mobile.'&type=LinkApp');
            // print_r($msg_result);exit();            
            $msg_result=json_decode($msg_result,true);
            if(array_key_exists("result",$msg_result)){
                $user->mg_id=$msg_result['result']['mg_id'];
                $user->jid=$msg_result['result']['jid'];
                $user->j_pass=$msg_result['result']['j_pass'];
            }else{
                $this->flash->error('Sorry try after some time');
                return $this->response->redirect("connect/signup");    
            }
          
            if ($user->save() == false) {
                foreach ($user->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
               return $this->response->redirect("connect/signup");   
            } else {
                copy('profile/default.jpg','profile/'.$user->mg_id.'.jpg');
                /*Code to create sender id*/
                $senderID = new SenderID();
                $senderID->text = $request->getPost('senderid');//str_replace(' ', '-', $name );
                $senderID->user_id = $user->id;
                $senderID->status = 'Approved';
                $senderID->save();
                /*End*/
                $plan = Slabs::findFirstById($request->getPost('slab_id','int'));
                $this->welcomeMailSMS($user,$password);
                if($plan->amount != 0){
                    $this->flash->success('Signup successfully. After completing your Payment Process you get an activation message on your mobile.');
                    return $this->response->redirect("user/makePayment/".$user->id."/".$plan->amount); 
                }else{
                    $this->flash->success('Signup successfully. Please wait till you get an activation message on your mobile.');
                    return $this->response->redirect("connect/signin"); 
                }
            }
        }else{
             $this->flash->error('In order to use our services, you must agree to linkapp\'s <a href="/index/terms" target="_blank"><b>Terms of Service</b></a>.');
             return $this->response->redirect("connect/signup");
        }

        }
        $this->view->setVar("url_param",$slab_id); 
        $this->view->form = $form;
    }
    private function welcomeMailSMS($user,$password)
    {
        $base_url=$this->config->application->base_url.'connect/signin';
        $message="Hello $user->mobile, Thank You For Registering. After getting activation email you can login with following details. URL: $base_url; Username: $user->mobile; Password: $password";
        $mobile_message="Hello $user->mobile, Your login details are URL:$base_url; Username:$user->mobile; Password:$password";
        /*Mail--------*/
        $template=$this->_getTemplate('newUser');
        $template=str_replace("welcome_message", $message, $template);
        $mail = $this->utils->sendMail($user->email,"Welcome to linkapp",$template);
        /*END Mail*/
        /*SMS---------*/
        $this->utils->sendAPISMS($user->mobile,$mobile_message);
        /*END SMS*/
    }
/*    public function getcityAction()
    {
        $this->view->disable();
        if ($this->request->isPost()) {
            $state = $this->request->getPost('state', array('string', 'striptags'));
            $city = $this->db->query("SELECT * FROM  city where state_id = '".$state."'")->fetchAll();
            $city_arr = array();
            if($city){
                foreach ($city as $key => $value) {
                    $city_arr[$key]['id'] = $value['id'];
                    $city_arr[$key]['name'] = $value['name'];
                }            
            }
            echo json_encode($city_arr);
            exit;
        }
    }*/
    public function depositAction($user_id)
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {
                $transaction= new Transactions();
                $user=User::findFirst($user_id);

                $transaction->user_id =$user_id;
               
                $transaction->type ='Credit';       
                $transaction->franchisee_id=$user->franchisee_id;
                $transaction->amount=$request->getPost('amount','float');
                $transaction->status="Pending"; 
                $transaction->datetime= date('Y-m-d H:i:s');
                $transaction->details=$request->getPost('details');           
                $transaction->mode=$request->getPost('mode'); 

               
                if ($transaction->save() == false) {
                    $errors = array();
                      foreach ($transaction->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                    echo json_encode(array('status'=>'error','msg'=>$errors));      
                    return;
                       
                } else {
                   echo json_encode(array('status'=>'success'));
                   return;
                }
            
            }
    }
    public function update_planAction($user_id)
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {
                
                $user=User::findFirst($user_id);
                $user->slab_id=$request->getPost('slab_id'); 

                if ($user->save() == false) {
                    $errors = array();
                      foreach ($user->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                    echo json_encode(array('status'=>'error','msg'=>$errors));      
                    return;
                       
                } else {
                   $slab=Slabs::findFirst($user->slab_id);
                   echo json_encode(array('status'=>'success','name'=>$slab->name));
                   return;
                }
            
            }
    }
    public function makePaymentAction($user_id,$amount)
    {
        $token =$this->security->getToken(); //md5(uniqid(mt_rand($time), true));
        $this->session->set("token",$token); 
        $this->session->set("user_id",$user_id);
        $this->session->set("amount",$amount);
        $this->view->setVar('amnt', round($amount));
    }
    public function successAction()
    {
        $token = $this->session->get("token"); 
        $user_id = $this->session->get("user_id");
        if($token){
            $user=User::findFirst($user_id);
            $transaction = new Transactions();
            $transaction->user_id =$user_id;               
            $transaction->type ='Credit';       
            $transaction->franchisee_id=$user->franchisee_id;
            $transaction->amount=$_POST["amount"];
            $transaction->status="Completed"; 
            $transaction->datetime= date('Y-m-d H:i:s');  
            $transaction->details="Transaction Id : ".$_POST["txnid"];       
            $transaction->mode='online';
            if($transaction->save()){
                $this->session->remove("token");
                $this->session->remove("user_id");
                $this->session->remove("amount");
            }
        }else{
            return $this->response->redirect("user/error"); 
        }
    }
    public function errorAction()
    {
    }
    public function change_statusAction($id)
    {         
            $this->view->disable();
            $user = User::findFirstById($id);  
            $request=$this->request;
            if($this->request->isPost()){  
                $status = $request->getPost('status');
                $user->status = $status;
                if ($user->save() == false) {
                    $errors = array();
                    foreach ($user->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                    }
                    echo json_encode(array('status'=>'error','msg'=>$errors));
                } else {
                    if($status=="Blocked")
                        $template=$this->_getTemplate('userBlocked');
                    else
                        $template=$this->_getTemplate('userStatus');

                    $template=str_replace("status_value", $status, $template);
                    $mail = $this->utils->sendMail($user->email,"Your Current Status",$template);
                    if($mail)
                        echo json_encode('success');
                }
            
            }
        exit();      
    } 
    public function sendOTPAction()
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {
                $mobile = $request->getPost('mobile');
                if($mobile){
                   // $result=$this->utils->curl_redirect('http://sancharapp.com/msg-api/sendOTPWeb','mobile='.$mobile.'');
                    $security_code=substr(str_shuffle('0123456789') , 0 , 4 );
                    $this->utils->sendAPISMS($mobile,"Your LinkApp OTP is $security_code");
                    $this->session->set('OTP',$security_code);
                    echo json_encode(array('status'=>'success','message'=>'You will get the SMS shortly ','code'=>$security_code));      
                    return;
                } else {
                    echo json_encode(array('status'=>'error','message'=>'Mobile is invalid'));
                    return;
                }
            
            }
    }
    public function verifyOTPAction()
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {

                $OTP = $request->getPost('OTP');
                $OTP_session = $this->session->get("OTP");
                if($OTP==$OTP_session) {

                    echo json_encode(array('status'=>'success')); 
                    // echo 'verify';exit;     
                    return;
                } else {
                    echo json_encode(array('status'=>'error','message'=>'Your OTP is incorrect. Please try again.'));
                    return;
                }
            
            }
    }
    public function getDistrictAction()
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {
                $state_ids = $request->getPost('state_ids');
                $state_ids=implode(",", json_decode($state_ids));
                $result = $this->db->fetchAll("SELECT * FROM district WHERE state_id IN (".$state_ids.")", Phalcon\Db::FETCH_ASSOC);
                if($result) {
                    echo json_encode($result);      
                    return;
                }
            
            }
    }
    public function getTalukaAction()
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {
                $district_ids = $request->getPost('district_ids');
                $district_ids=implode(",", json_decode($district_ids));
                $result = $this->db->fetchAll("SELECT * FROM taluka WHERE dist_id IN (".$district_ids.")", Phalcon\Db::FETCH_ASSOC);
                if($result) {
                    echo json_encode($result);      
                    return;
                }
            
            }
    }
    public function getPincodeAction()
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {
                $taluka_ids = $request->getPost('taluka_ids');
                $taluka_ids=implode(",", json_decode($taluka_ids));
                $result = $this->db->fetchAll("SELECT * FROM pincode WHERE tq_id IN (".$taluka_ids.")", Phalcon\Db::FETCH_ASSOC);
                if($result) {
                    echo json_encode($result);      
                    return;
                }
            
            }
    }
    public function getstateAction()
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {
                $result = $this->db->fetchAll("SELECT * FROM state", Phalcon\Db::FETCH_ASSOC);
                if($result) {
                    echo json_encode($result);      
                    return;
                }
            
            }
    }
    public function getAjaxPincodeAction()
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {
            $q = $_POST['data']['q'];
            $results = array();
            if ($this->session->has("pincode_sql")) {
                $sql = $this->session->get("pincode_sql");
                $result = $this->db->fetchAll("$sql AND pin LIKE '".$q."%'",Phalcon\Db::FETCH_ASSOC);
                foreach($result as $i => $val){
                        $results[] = array('id' => $val['id'], 'text' => $val['pin']);
                }
            }
            echo json_encode(array('q' => $q, 'results' => $results));
            }
    }
    public function checkAlreadyExitsAction()
    {   
        $this->view->disable();
        $request=$this->request;
        if($request->isGet()){  
            $res = true;
            $query_string='';
            switch($_GET){
                case !empty($_GET['mobile']):
                    $query_string="mobile='".$request->get('mobile')."'";
                break;

                case !empty($_GET['joint_handle']):
                    $query_string="joint_handle='@".str_replace("@","",$request->get('joint_handle'))."'";
                break;
                case !empty($_GET['email']):
                    $query_string="email='".$request->get('email')."'";
                break;    
            }
            $result=User::findFirst($query_string);
            if ($result) {
                $res= false;
            }
            echo json_encode($res);
        }   
    }
    public function forgotPasswordAction()
     {
        $this->tag->setTitle('forgot password');

        $form = new ForgotPasswordForm;
         
        if ($this->request->isPost()) {
                $mobile=$this->request->getPost('mobile');

                $user = User::findFirstByMobile($mobile);

                if (!$user) {
                    $this->flash->error('There is no account associated to this mobile');
                } else {
                    $password =substr(str_shuffle('abcdefghijklmnopqrstuvwxyz0123456789') , 0 , 6 );
                    $user->password = sha1($password);
                    if ($user->save()) {
                        $mobile_message="Hello $user->firstname,Your linkapp New Password is ".$password;
                        $this->utils->sendAPISMS($user->mobile,$mobile_message);
                        $this->flash->success('Success! Please check your mobile for new password');
                    }else{
                        $this->flash->error('Sorry ! try again later');
                    }
                    return $this->response->redirect("user/forgotPassword");
                } 
        }

        $this->view->form = $form;
     }
  public function upcreditAction($id){
            $this->view->disable();
            $auth = $this->session->get('auth');
            $user_id=$auth['id'];
            $request=$this->request;
            if ($request->isAjax() == true) {
                $transaction= new Transactions();
                if($auth['login_type']=='Franchisee'){
                    $franchisee = Franchisee::findFirst($id);
                    $transaction->franchisee_id=$user_id;
                }else{
                      $user = User::findFirst($user_id);
                       $transaction->user_id=$user_id;
                }
                $transaction->type ='Debit';
                $amount=$request->getPost('amount','float');
                $transaction->amount=$amount;
                $transaction->status="Completed"; 
                $transaction->datetime= date('Y-m-d H:i:s');
                $transaction->details=$request->getPost('details');         
                $transaction->mode=$request->getPost('mode'); 

                if ($transaction->save() == false) {
                    $errors = array();
                      foreach ($transaction->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                      echo json_encode(array('status'=>'success','msg'=>'Debit Transactions saved'));
                    return;
                } else {

                $transaction1= new Transactions();
                $user = User::findFirst($id);
                $transaction1->type ='Credit';
                $transaction1->user_id=$id;
                $amount=$request->getPost('amount','float');
                $transaction1->amount=$amount;
                $transaction1->status="Completed"; 
                $transaction1->datetime= date('Y-m-d H:i:s');
                $transaction1->details=$request->getPost('details');         
                $transaction1->mode=$request->getPost('mode'); 
                  if ($transaction1->save() == false) {
                    $errors = array();
                      foreach ($transaction1->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                      echo json_encode(array('status'=>'success','msg'=>'Debit and Credit Transactions saved'));
                    return;
                }else{  
                if($auth['login_type']=='Franchisee'){
                   $franchisee1 = Franchisee::findFirst($user_id);
                   if($franchisee1->balance<=$amount){
                            echo json_encode(array('status'=>'errors','msg'=>$franchisee1->balance."Balance available to credit."));
                            return;
                   }else{
                            $user->balance+=$amount;
                            $franchisee1->balance-=$amount;
                            $user->save(); 
                             $franchisee1->save(); 
                            echo json_encode(array('status'=>'success','msg'=>'Transfer Completed','balance'=>$user->balance));
                            return;
                   }
               }else{
                 $user1 = User::findFirst($user_id);
                 $user2 = User::findFirst($id);
                   if($user1->balance<=$amount){
                            echo json_encode(array('status'=>'errors','msg'=>$user1->balance."Balance available to credit."));
                            return;
                   }else{
                            $user2->balance+=$amount;
                            $user1->balance-=$amount;
                            $user1->save(); 
                             $user2->save(); 
                            echo json_encode(array('status'=>'success','msg'=>'Transfer Completed','balance'=>$user2->balance));
                            return;
                   }
               }
               }                 
                }
            
            }
    }
}
