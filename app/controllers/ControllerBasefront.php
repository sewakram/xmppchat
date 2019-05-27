<?php

use Phalcon\Mvc\Controller;

class ControllerBasefront extends Controller
{

    protected function initialize()
    {

        $this->tag->prependTitle('LinkApp : Social Service Network - The Social Networking with Organisations | ');
        // $this->view->setTemplateAfter('main');
        $this->view->setTemplateAfter('mainindex');
        $this->view->setVar('application', $this->config->application);
        $this->view->setVar('baseUri', $this->config->application->baseUri);
        require_once APP_PATH.'app/library/Batch.php';
        $this->assets->addCss("css/sachar_front.css");
    }
     
    protected function forward($uri)
    {
        $uriParts = explode('/', $uri);
        $params = array_slice($uriParts, 2);
    	return $this->dispatcher->forward(
    		array(
    			'controller' => $uriParts[0],
    			'action' => $uriParts[1],
                'params' => $params
    		)
    	);
    }

    protected function _getTemplate($name)
    {
       $this->view->setRenderLevel(\Phalcon\Mvc\View::LEVEL_ACTION_VIEW);
       $template = $this->view->getRender('emailTemplates', $name, null, function($view) {
       $view->setRenderLevel(Phalcon\Mvc\View::LEVEL_MAIN_LAYOUT);
       $view->setRenderLevel(Phalcon\Mvc\View::LEVEL_ACTION_VIEW);
       });
       $this->view->disable(); 
       //var_dump($template);
       return $template;
    }
}
