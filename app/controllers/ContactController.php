<?php

/**
 * ContactController
 *
 * Allows to contact the staff using a contact form
 */
class ContactController extends ControllerBase
{
    public function initialize()
    {
        $this->tag->setTitle('Contact us');
        parent::initialize();
    }

    public function indexAction()
    {
        $this->view->form = new ContactForm;
    }

    /**
     * Saves the contact information in the database
     */
    public function sendAction()
    {
        if ($this->request->isPost() != true) {
            return $this->forward('contact/index');
        }

        $form = new ContactForm;
        $contact = new Contact();

        // Validate the form
        $data = $this->request->getPost();
        if (!$form->isValid($data, $contact)) {
            foreach ($form->getMessages() as $message) {
                $this->flash->error($message);
            }
             return $this->response->redirect("contact/index");
        }

      /*  if ($contact->save() == false) {
            foreach ($contact->getMessages() as $message) {
                $this->flash->error($message);
            }
            return $this->response->redirect("contact/index");
        }*/
         $request=$this->request;

         $datetime = date("d-m-Y H:i");
         $template=$this->_getTemplate('contactUs');
         $template=str_replace("Name", $request->getPost('name'), $template);
         $template=str_replace("Email", $request->getPost('email'), $template);
         $template=str_replace("Comments", $request->getPost('comments'), $template);
         $template=str_replace("Datetime", $datetime, $template);

        $this->utils->sendMail("dhiraj.ingole@webgile.com","Contact Form",$template);
        $this->flash->success('Thanks, we will contact you in the next few hours');
        return $this->response->redirect("index/index");
    }

}
