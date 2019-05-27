<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
// file_put_contents("../../public/php-error.log", "\n testing send 1");

class xmpp{


        public function send_msg($msg){
            require_once 'jaxl.php';
file_put_contents("../../public/php-error.log", "\n testing send 10");
           
            $this->client = new JAXL(array(
                // (required) credentials
				'jid' => 'admin@sancharapp.com',
				'pass' => 'Wg.12345',
				
				// (optional) srv lookup is done if not provided
				//'host' => '192.99.212.88',

				// (optional) result from srv lookup used by default
				'port' => 5280,

				// (optional) defaults to false
				//'force_tls' => true,

				// (optional)
				//'resource' => 'resource',
				
				// (optional) defaults to PLAIN if supported, else other methods will be automatically tried
				'auth_type' => 'DIGEST-MD5',
				
				'log_level' => JAXL_INFO,
				'priv_dir'=>'priv_dir'
            ));         
            $this->msg = $msg;
            $this->client->require_xep(array(
              	'0199'	// XMPP Ping
            ));     
            $thisClassObject =& $this;
			file_put_contents("../../public/php-error.log", "\n testing send11");

            $this->client->add_cb('on_auth_success', function() use(&$thisClassObject) {
file_put_contents("../../public/php-error.log", "\n testing send2");
				_info("got on_auth_success cb, jid ".$thisClassObject->client->full_jid->to_string());
				$thisClassObject->client->send_chat_msg('98@sancharapp.com', 'XMPP message send from website');
				//echo "sucess";
				$thisClassObject->client->send_end_stream();
				return;
            });

            $this->client->start();     

            return;
        } 
   }

   $xmpp=new xmpp();
   $xmpp->send_msg('hello');
?>
