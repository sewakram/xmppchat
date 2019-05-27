<?php

/**
 * AdminController
 *
 * Allows to authenticate users
 */
class SettingController extends ControllerBase
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
        $auth = $this->session->get('auth'); 
        $config = Configuration::findFirst();
        if(!$config){
            return $this->response->redirect("setting/index"); 
         }
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
            
            $config->server_sms_processing_status=($request->getPost('server_sms_processing_status')=='on') ? 1 : 0;
            if ($config->update() == false) {
                foreach ($config->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
            } else {
                $this->flash->success('Configuration updated');
                return $this->response->redirect("setting/configuration");  
            }

            
        }
         $this->view->setVar("config", $config);

    }
}
