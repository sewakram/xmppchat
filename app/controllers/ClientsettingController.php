<?php

/**
 * AdminController
 *
 * Allows to authenticate users
 */
class ClientsettingController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Setting');
        parent::initialize();
    }
    
    public function indexAction()
    {

    }
     public function configurationAction()
    {   
        // echo"sewak";exit;
        $auth = $this->session->get('auth'); 
        $config = Configuration::findFirst("company_id= ".$auth['id']);
        // if(!$config){
        //     return $this->response->redirect("manager/index"); 
        //  }
         $request=$this->request;

         if ($request->isPost()){
            if($this->request->hasFiles() == true)
            {
                 //checking if file exsists
                 $img_path='profile/' .stristr($auth['jid'],"@",true).'.jpg';
                 //if(file_exists($img_path)) unlink($img_path);
                 foreach($this->request->getUploadedFiles() as $file) {
                    $file->moveTo($img_path);
                 }
            }//end if file  
            $config->app_access_days = $request->getPost('app_access_days');
            $config->welcome_msg = "<p>".$request->getPost('welcome_msg')."</p>";
            $config->sms_request_limit = $request->getPost('sms_request_limit');
            $config->app_name = $request->getPost('app_name');
            $config->server_sms_processing_status=($request->getPost('server_sms_processing_status')=='on') ? 1 : 0;
            if ($config->save() == false) {
                foreach ($config->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
            } else {
                $this->flash->success('Configuration updated');
                return $this->response->redirect("clientsetting/configuration");  
            }

            
        }
         $this->view->setVar("config", $config);

     }
}
