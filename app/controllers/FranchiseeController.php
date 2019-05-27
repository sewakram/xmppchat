<?php


/**
 * SubscriberController
 *
 * Allows to contact the staff using a contact form
 */
class FranchiseeController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('franchisee');
        parent::initialize();
    }
    private function _registerSession($user,$login_type)
    {
        $this->session->set('auth', array(
            'id' => $user->id,
            'name' => $user->firstname,
            'login_type' => $login_type
        ));
    }
    public function logoutAction()
    {
        $this->session->remove('auth');
        //$this->session->destroy();
        //$this->flash->success('Goodbye!');
        $this->response->redirect("index"); 
        $this->view->disable();
        return; 
    }
    public function signinAction()
    {
        $auth = $this->session->get('auth');
        if(!$auth){
            $this->tag->setTitle('Sign In');
            if ($this->request->isPost()) {
                //if($this->security->checkToken()) {
                $email = $this->request->getPost('email');
                $password = $this->request->getPost('password');

                $user = Franchisee::findFirst(array(
                        "(email = :email:) AND password = :password: AND status = 'Active'",
                        'bind' => array('email' => $email, 'password' => sha1($password))
                    ));
               
                if ($user != false){
                    $login_type="Franchisee";
                    $this->_registerSession($user,$login_type);
                
                    $this->flash->success('Welcome ' . $user->firstname." ".$user->lastname);
                    return $this->response->redirect("dashboard"); 
                }

                $this->flash->error('Wrong email/password');
              //}
              return $this->response->redirect("franchisee/signin"); 
            }
        }else  
            $this->response->redirect('dashboard');    
            
    } 
    public function indexAction()
    {
       
        $auth = $this->session->get('auth');
        $user_id=$auth['id'];
        $franchisee = new Franchisee();
        if($auth['login_type']=="Franchisee"){ 
                $getdata = $franchisee->getparentfranchiseeData($user_id);
                 $this->view->setVars(array("franchisee"=> json_encode($getdata),
                                   "group_id"  => '',"login_type"=>'Franchisee'
          ));
        }
        else{
             $getdata = $franchisee->getfranchiseeData();
              $this->view->setVars(array("franchisee"=> json_encode($getdata),
                                   "group_id"  => ''
          ));
        }
       
    }    
    
     public function deleteAction($f_id)
    {
        $this->view->disable();
        $request=$this->request;
        if ($request->isAjax() == true) {
            $franchisee = Franchisee::findFirstById($f_id);

            if (!$franchisee->delete()) {
                   $errors = array();
                      foreach ($franchisee->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                    echo json_encode(array('status'=>'error','msg'=>$errors));
                    return;
                }else{
                    echo json_encode('success');
                    return;
                }

        }
    }

    public function depositAction($id)
    {
        $this->view->disable();
        $request=$this->request;
            if ($request->isAjax() == true) {
                $transaction= new Transactions();
                $franchisee = Franchisee::findFirst($id);
                $transaction->type ='CommisionReleased';
                $transaction->franchisee_id=$id;
                $amount=$request->getPost('amount','float');
                $transaction->amount=$amount;
                if($transaction->amount > $franchisee->commission_balance){
                    echo json_encode(array('status'=>'error','msg'=>'Amount Cant Released more than '.$franchisee->commission_balance.''));      
                    return;
                }
               
                $transaction->status="Completed"; 
                $transaction->datetime= date('Y-m-d H:i:s');
                $transaction->details=$request->getPost('details');         
                $transaction->mode=$request->getPost('mode'); 

                $franchisee->commission_balance -= $amount;  

               
                if ($transaction->save() == false) {
                    $errors = array();
                      foreach ($transaction->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                    echo json_encode(array('status'=>'error','msg'=>$errors));      
                    return;
                       
                } else {
                   $franchisee->save(); 
                   echo json_encode(array('status'=>'success','franchisee_bal'=>$franchisee->commission_balance));
                   return;
                }
            
            }
    }
    public function newAction()
    {
        //Get session info
        $auth = $this->session->get('auth');
        $user_id=$auth['id'];
        $form = new RegisterForm;
        $request=$this->request;

        if ($this->request->isPost()) {

            $password = $request->getPost('password');
            $repeatPassword = $request->getPost('repeatPassword');
            if ($password != $repeatPassword) {
                $this->flash->error('Passwords are diferent');
                return false;
            }

            $franchisee = new Franchisee();
            $logo = new Logo();
            /*$franchisee->username = $request->getPost('username', 'alphanum');*/
            $franchisee->password = sha1($password);
            $franchisee->firstname = $request->getPost('first_name', array('string', 'striptags'));
            $franchisee->lastname = $request->getPost('last_name', array('string', 'striptags'));
            $franchisee->commission_balance = 0;
            $franchisee->registered_on = date('Y-m-d H:i:s');
            $franchisee->organization = $request->getPost('organization');
            $franchisee->mobile = $request->getPost('mobile', 'int');
            $franchisee->address = $request->getPost('address');
            $franchisee->city = $request->getPost('city');
            $franchisee->state = $request->getPost('state');
            $franchisee->pincode = $request->getPost('pincode', 'int');
            $franchisee->email = $request->getPost('email', 'email');
            $franchisee->phone = $request->getPost('phone');
            $franchisee->status = "Pending";
            $franchisee->commission_percetage =$request->getPost('commission_percetage');
            if($auth['login_type']=="Franchisee"){ 
                $franchisee->parent_franchisee=$user_id;
            }
            if ($franchisee->save() == false) {
                foreach ($franchisee->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
            } else {
                $admin=User::findFirst("type='Super Admin'");
                $logo_temp=Logo::findFirst($admin->id);

                $logo->id=$franchisee->id;
                $logo->img_src=$logo_temp->img_src;
                $logo->save();
                $this->welcomeMailSMS($franchisee,$password);
                $this->flash->success('Franchisee Created');
                return $this->response->redirect("franchisee"); 
            
            }
        }

        $this->view->form = $form;
    }
    
    public function editAction($id)
    {
        //$this->Check_Id($id);
        if(!$id) {
            return $this->response->redirect("franchisee"); 
          }

        $franchisee = Franchisee::findFirst($id);
        if(!$franchisee) {
            $this->flash->success('Franchisee Not Found');
            return $this->response->redirect("franchisee"); 
          }

        $this->view->setVar("franchisee", $franchisee);

        $request=$this->request;
        if ($this->request->isPost()){  
            
            $franchisee->firstname =  $request->getPost('firstname', array('string', 'striptags'));
            $franchisee->lastname = $request->getPost('lastname', array('string', 'striptags'));

            $franchisee->organization = $request->getPost('organization');
            $franchisee->mobile = $request->getPost('mobile', 'int');
            $franchisee->address =$request->getPost('address');
            $franchisee->city = $request->getPost('city');
            $franchisee->state = $request->getPost('state');
            $franchisee->pincode = $request->getPost('pincode', 'int');
            $franchisee->email = $request->getPost('email', 'email');
            $franchisee->phone = $request->getPost('phone');
            $franchisee->status = $request->getPost('status');
            $franchisee->commission_percetage = $request->getPost('commission_percetage');
            if($request->getPost('pass_status')=="true"){
                $franchisee->password = sha1($request->getPost('password'));
            }

            if ($franchisee->save() == false) {
                foreach ($franchisee->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
            } else {
                $this->flash->success('Franchisee updated');
                return $this->response->redirect("franchisee"); 
            }

            
        }
    }

    public  function Check_Id($id){
          if(!$id) {
            return $this->response->redirect("franchisee"); 
          }
          $auth = $this->session->get('auth');
          $franchisee_id=$auth['id'];
          $franchisee = Franchisee::findFirstById($franchisee_id);  
          if(!$franchisee) {
            return $this->response->redirect("franchisee"); 
          }
    }

    public function signupAction()
    {

        $auth = $this->session->get('auth');
        if($auth)
            $this->response->redirect('dashboard');  

            $form = new RegisterForm;
            $request=$this->request;

            if ($this->request->isPost()) {

                $password = $request->getPost('password');
                $repeatPassword = $request->getPost('repeatPassword');
                if ($password != $repeatPassword) {
                    $this->flash->error('Passwords are diferent');
                    return false;
                }
                $franchisee = new Franchisee();
                $logo = new Logo();
                $franchisee->password = sha1($password);
                $franchisee->firstname = $request->getPost('first_name', array('string', 'striptags'));
                $franchisee->lastname = $request->getPost('last_name', array('string', 'striptags'));
                $franchisee->commission_balance = 0;
                $franchisee->registered_on = date('Y-m-d H:i:s');
                $franchisee->organization = $request->getPost('organization');
                $franchisee->mobile = $request->getPost('mobile', 'int');
                $franchisee->address = $request->getPost('address');
                $franchisee->city = $request->getPost('city');
                $franchisee->state = $request->getPost('state');
                $franchisee->pincode = $request->getPost('pincode', 'int');
                $franchisee->email = $request->getPost('email', 'email');
                $franchisee->phone = $request->getPost('phone');
                $franchisee->status = "Pending";
                $franchisee->commission_percetage = 0;

                if ($franchisee->save() == false) {
                    foreach ($franchisee->getMessages() as $message) {
                        $this->flash->error((string) $message);
                    }

                    return $this->response->redirect("franchisee/signup"); 
                } else {
                    $admin=User::findFirst("type='Super Admin'");
                    $logo_temp=Logo::findFirst($admin->id);

                    $logo->id=$franchisee->id;
                    $logo->img_src=$logo_temp->img_src;
                    $logo->save();
                    $this->welcomeMailSMS($franchisee,$password);
                    $this->flash->success('Signup successfully');
                    return $this->response->redirect("franchisee/signin"); 
                
                }

            }

            $this->view->form = $form;

            
    }
    private function welcomeMailSMS($user,$password)
    {
        $base_url=$this->config->application->base_url.'franchisee/signin';
        $message="Hello $user->firstname, Thank You For Registering. After getting activation email you can login with following details. URL: $base_url; Username: $user->email; Password: $password";
        $mobile_message="Hello $user->firstname, Your login details are URL:$base_url; Username:$user->email; Password:$password";
        /*Mail--------*/
        $template=$this->_getTemplate('newUser');
        $template=str_replace("welcome_message", $message, $template);
        $mail = $this->utils->sendMail($user->email,"Welcome to linkapp",$template);
        /*END Mail*/
        /*SMS---------*/
        $this->utils->sendAPISMS($user->mobile,$mobile_message);
        /*END SMS*/
    }
}
