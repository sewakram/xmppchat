<?php
use Phalcon\Tag as Tag,
Phalcon\Mvc\Model\Criteria;
use Phalcon\Mvc\Model\Query;

/**
 * AdminController
 *
 * Allows to authenticate users
 */
class ReportsController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Reports');
        parent::initialize();
    }
    
    public function indexAction()
    {
        //echo $_GET['sort']."  ".$_GET['order'];
        $auth = $this->session->get('auth');
        $user_id=$auth['id'];
        $login_type=$auth['login_type'];
        $parameters = array();
        $numberPage = 1;
        $query = "SELECT m.*, u.email FROM message m join user u ON m.user_id = u.id";
        //$where = ' where m.route!="Joint" AND DATEDIFF(m.datetime,NOW()) >= -30';
        $where = ' where m.route!="Joint"';
        if($login_type=='Group Admin')
            $where .= " AND m.user_id= ".$user_id;
        if ($this->request->isPost()) {
            $this->session->set('mobile',$this->request->getPost('mobile'));
            $this->session->set('user',$this->request->getPost('user'));
            $this->session->set('status',$this->request->getPost('status'));
            $this->session->set('route',$this->request->getPost('route'));
            $this->session->set('start_date',$this->request->getPost('start_date'));
            $this->session->set('end_date',$this->request->getPost('end_date'));
        } else {
            $numberPage = $this->request->getQuery("page", "int");
            if ($numberPage <= 0) {
                $numberPage = 1;
            }
            $this->session->remove("mobile");
            $this->session->remove("user");
            $this->session->remove("status");
            $this->session->remove("route");
            $this->session->remove("start_date");
            $this->session->remove("end_date");
        }
        if($this->session->get('mobile')){
            $where .= " AND m.mobile= ".$this->session->get('mobile');
            Tag::displayTo("mobile", $this->session->get('mobile'));
        }
        if($this->session->get('user')){
            $where .= " AND u.email= '".$this->session->get('user')."'";
            Tag::displayTo("user", $this->session->get('user'));
        }
        if($this->session->get('status')){
            $where .= " AND m.status= '".$this->session->get('status')."'";
            Tag::displayTo("status", $this->session->get('status'));
        }
        if($this->session->get('route')){
            $where .= " AND m.route= '".$this->session->get('route')."'";
            Tag::displayTo("route", $this->session->get('route'));
        }
        if($this->session->get('start_date') && $this->session->get('end_date')){
            $where .= " AND date(m.datetime) between '".$this->session->get('start_date')."' and '".$this->session->get('end_date')."'";
            Tag::displayTo("start_date", $this->session->get('start_date'));
            Tag::displayTo("end_date", $this->session->get('end_date'));
        }
        $orderby = " ORDER BY m.datetime DESC";
        if(isset($_GET['sort']) && isset($_GET['order'])) {
            $orderby = " ORDER BY ".$_GET['sort']." ".$_GET['order']; 
        }
        $reports = $this->db->query($query.$where.$orderby)->fetchAll();
        if (count($reports) == 0) {
            $this->flash->notice("The search did not find any report");
        }

        $paginator = new Phalcon\Paginator\Adapter\NativeArray(array(
            "data" => $reports,
            "limit" => 20,
            "page" => $numberPage
        ));       

        $page = $paginator->getPaginate();
        //echo "<pre/>"; print_r($page); exit;

        $this->view->setVar("page", $page);
    }
    
}
