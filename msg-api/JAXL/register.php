<?php
class xmpp{

        public function register_user($username, $password,$domain){
            require_once 'jaxl.php';
           
            $this->client = new JAXL(array(
                'jid' =>$domain,
                'log_level' => JAXL_ERROR
            ));         
            $this->username = $username;
            $this->password = $password;

            $this->client->require_xep(array(
                '0077'  // InBand Registration  
            ));     
            $thisClassObject =& $this;

            $this->client->add_cb('on_stream_features', function($stanza) use(&$thisClassObject) {
                $thisClassObject->client->xeps['0077']->get_form('$domain');
                return array($thisClassObject, 'wait_for_register_form');
            });

            $this->client->start();     

            return;
        }

        public function wait_for_register_response($event, $args) {


           if($event == 'end_stream') {
                return;
            }
            else if($event == 'stanza_cb') {
                $stanza = $args[0];
               if($stanza->name == 'iq') {
                if($stanza->attrs['type'] == 'result') {
                    //echo "registration successful";
                    echo "success";
                    $this->client->end_stream();
                    return 'logged_out';
                }
                else if($stanza->attrs['type'] == 'error') {
                    $error = $stanza->exists('error');
                    //echo "registration failed with error code: ".$error->attrs['code']." and type: ".$error->attrs['type'].PHP_EOL;
                    echo $error->exists('text')->text.PHP_EOL;
                    //echo "shutting down...".PHP_EOL;
                    $this->client->end_stream();
                    return "logged_out";
                }
            }
        }
    }

         public function wait_for_register_form($event, $args) {

            $stanza = $args[0];
            $query = $stanza->exists('query', NS_INBAND_REGISTER);
            if($query) {
                $form = array();
                $instructions = $query->exists('instructions');
                if($instructions) {
                //echo $instructions->text.PHP_EOL;
            }

            $this->client->xeps['0077']->set_form($stanza->attrs['from'], array('username' => $this->username, 'password' => $this->password));
            return array($this, "wait_for_register_response");
        }
        else {
            $this->client->end_stream();
            return "logged_out";
        }
       }    
   }

$mobile=$_GET["mobile"];
$j_pass=$_GET["j_pass"];
$domain=$_GET["domain"];


$xmppObj = new xmpp();
$xmppObj->register_user("$mobile","$j_pass","$domain");
   ?>

   <!-- http://sancharapp.com/msg-api/JAXL/register.php?mobile=98&j_pass=Wg.12345&domain=sancharapp.com -->