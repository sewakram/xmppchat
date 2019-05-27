<?php

use Phalcon\Flash;
use Phalcon\Session;

class AppController extends ControllerBasefront
{
    public function initialize()
    {
        $this->tag->setTitle('App');
        parent::initialize();
        $this->view->setTemplateAfter('main');
        $this->view->setViewsDir('../app/views/materialview/');
    }

    public function indexAction()
    {     
    }
}
