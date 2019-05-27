<?php

/**
 * AdminController
 *
 * Allows to authenticate users
 */
class SlabsController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Slabs');
        parent::initialize();
    }
    public function getSlabAction($amount){
        $this->view->disable();
        $request=$this->request;
        if ($request->isAjax() == true) {
              $obj = new Slabs();
              $slabs=$obj->getslabs($amount);
                    if($slabs[0]['id']){
                        echo json_encode(array('status'=>'success','slabs'=>$slabs));
                        return;
                    }
        }

    }
    public function indexAction()
    {
        $auth = $this->session->get('auth');
        $user_id=$auth['id'];
        $result = array();

        $slabss = Slabs::find(array("order" => "id DESC"));
        foreach($slabss  as $i => $slabs) {
            $result[$i]['id'] = $slabs->id;
            $result[$i]['name'] = $slabs->name;          
            $result[$i]['amount'] = $slabs->amount;
            $result[$i]['validity'] = $slabs->validity;
            $result[$i]['display'] = $slabs->display;
            $result[$i]['status'] = $slabs->status;
        }
        $this->view->setVar("slabs", json_encode($result));
    }
    public function newAction()
    {          

        $auth = $this->session->get('auth');
        $request=$this->request;

        $permissions=Permissions::find(array("order" => "id DESC"));        
        if ($this->request->isPost()) {     
            $slabs = new Slabs();
            $slabs->name = $request->getPost('name','string');
            $slabs->amount =$request->getPost('amount','float');
            $slabs->validity =$request->getPost('validity','int');  
            if($request->getPost('display','string'))
                $slabs->display = 1;

            if($request->getPost('status','string'))
                $slabs->status = 'Active';
            if ($slabs->save() == false) {
                foreach ($slabs->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
            } else { 
                foreach ($permissions as $key => $value) {
                    $perm = new SlabPermissions();
                    $perm->slab_id=$slabs->id;
                    $perm->permission_id=$value->id;
                   
                    $str = 'plan_'.$value->id;
                    if($request->getPost($str))                    
                        $perm->value =str_replace(' ','_',strtolower($request->getPost($str)));
                    else if($request->getPost($value->id))
                        $perm->value = $request->getPost($value->id);
                    else
                       $perm->value= 'No';

                    $perm->save();
                }
                $this->flash->success('Plan Added');
                return $this->response->redirect("slabs/index");            
            }
        }
        $this->view->setVar("permissions", $permissions);
   }
    public function editAction($id)
    {
        
        $auth = $this->session->get('auth');
         if(!$id) {
            return $this->response->redirect("slabs/index"); 
          }

         $slabs = Slabs::findFirst($id);
         if(!$slabs){
            $this->flash->error("Slab not found");
            return $this->response->redirect("slabs/index"); 
         }
         $request=$this->request;
         $permissions=$this->db->query("SELECT sp.value,p.id,p.feature FROM permissions p ,slab_permissions sp WHERE p.id=sp.permission_id AND sp.slab_id=$slabs->id");
         $permissions->setFetchMode(Phalcon\Db::FETCH_ASSOC);
         $permissions=$permissions->fetchAll();  
         if ($request->isPost()){  
            $slabs->name = $request->getPost('name','string');
            $slabs->amount =$request->getPost('amount','float');
            $slabs->validity =$request->getPost('validity','int');  
            if($request->getPost('status','string'))
                $slabs->status = 'Active';
            else
                $slabs->status = 'Inactive';
            
            if($request->getPost('display'))
                $slabs->display = 1;
            else
                $slabs->display = 0;

            if ($slabs->save() == false) {
                foreach ($slabs->getMessages() as $message) {
                    $this->flash->error((string) $message);
                }
            } else {
                foreach ($permissions as $key => $value) {
                    $perm = SlabPermissions::findFirst("slab_id=".$slabs->id." AND permission_id=".$value['id']."");
      
                    $str = 'plan_'.$value['id'];
                    if($request->getPost($str))                    
                        $perm->value =str_replace(' ','_',strtolower($request->getPost($str)));
                    else if($request->getPost($value['id']))
                        $perm->value = $request->getPost($value['id']);
                    else
                       $perm->value = 'No';

                    $perm->update();
                }
                $this->flash->success('Plan updated');
                return $this->response->redirect("slabs/index"); 
            }            
        }
         $this->view->setVars(array("slabs"=> $slabs,"permissions"=>$permissions));

    }

    public function deleteAction($id)
    {
        $this->view->disable();
        $request=$this->request;
        if ($request->isAjax() == true) {
            $slabs = Slabs::findFirst($id);

            if (!$slabs->delete()) {
                   $errors = array();
                      foreach ($slabs->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                    echo json_encode(array('status'=>'error','msg'=>$errors));
                    return;
                }else{
                    $this->db->query("delete from slab_permissions where slab_id=$id"); 
                    echo json_encode('success');
                    return;
                }

        }
    }
    public function change_statusAction($id)
    {         
            $this->view->disable();
            $slabs = Slabs::findFirstById($id);  
            $request=$this->request;
            if($this->request->isPost()){  
                $status = $request->getPost('status');
                $slabs->status = $status;
                if ($slabs->save() == false) {
                     $errors = array();
                      foreach ($slabs->getMessages() as $message) {
                        $errors[] = $message->getMessage();
                      }
                    echo json_encode(array('status'=>'error','msg'=>$errors));
                } else {
                    echo json_encode('success');
                }
            
            }
        exit();
      
    }       

}
