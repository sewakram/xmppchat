<?php

use Phalcon\Forms\Form;
use Phalcon\Forms\Element\Text;
use Phalcon\Forms\Element\Password;
use Phalcon\Forms\Element\TextArea;
use Phalcon\Validation\Validator\PresenceOf;
use Phalcon\Validation\Validator\Email;
use Phalcon\Validation\Validator\StringLength;

class LoginForm extends Form
{

    public function initialize($entity = null, $options = null)
    {
        

        // Email
        if($options['signin']==true){
            $mobile = new Text('mobile');
            $mobile->setLabel('Mobile Number');
            $mobile->setFilters('int');
            $mobile->addValidators(array(
                new PresenceOf(array(
                    'message' => 'Mobile Number is required'
                )),
                
            ));
            $this->add($mobile);
            $password = new Password('password');
            $password->setLabel('Password');
            $password->addValidators(array(
            new PresenceOf(array(
                'message' => 'Password is required'
            ))
        ));
        $this->add($password);

        }else{

        $email = new Text('email');
        $email->setLabel('E-Mail');
        $email->setFilters('email');
        $email->addValidators(array(
            new PresenceOf(array(
                'message' => 'E-mail is required'
            )),
            new Email(array(
                'message' => 'E-mail is not valid'
            ))
        ));
        $this->add($email);

        // Password
        $password = new Password('password');
        $password->setLabel('Password');
        $password->addValidators(array(
            new PresenceOf(array(
                'message' => 'Password is required'
            ))
        ));
        $this->add($password);

        // Confirm Password
        $repeatPassword = new Password('repeatPassword');
        $repeatPassword->setLabel('Repeat Password');
        $repeatPassword->addValidators(array(
            new PresenceOf(array(
                'message' => 'Confirmation password is required'
            ))
        ));
        $this->add($repeatPassword);

        // Mobile
        $mobile = new Text('mobile');
        $mobile->setLabel('Mobile Number');
        $mobile->setFilters('int');
        $mobile->addValidators(array(
            new PresenceOf(array(
                'message' => 'Mobile Number is required'
            )),
            
        ));
        $this->add($mobile);

       
        }

    }
}
