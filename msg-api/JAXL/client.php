<?php


// Run as:
// php examples/echo_bot.php root@localhost password
// php examples/echo_bot.php root@localhost password DIGEST-MD5
// php examples/echo_bot.php localhost "" ANONYMOUS
//
// initialize JAXL object with initial config
//
require_once 'jaxl.php';
$client = new JAXL(array(
	// (required) credentials
	'jid' => 'admin@sancharapp.com',
	'pass' => 'Wg.12345',
	
	// (optional) srv lookup is done if not provided
	//'host' => '192.99.212.88',

	// (optional) result from srv lookup used by default
	//'port' => 5280,

	// (optional) defaults to false
	//'force_tls' => true,

	// (optional)
	//'resource' => 'resource',
	
	// (optional) defaults to PLAIN if supported, else other methods will be automatically tried
	'auth_type' => 'DIGEST-MD5',
	
	'log_level' => JAXL_INFO,
	'priv_dir'=>'priv_dir'
));

//
// required XEP's
//
$client->require_xep(array(
	'0199'	// XMPP Ping
));

//
// add necessary event callbacks here
//

$client->add_cb('on_auth_success', function() {
	global $client;
	_info("got on_auth_success cb, jid ".$client->full_jid->to_string());
	$client->send_chat_msg('dhiraj@localhost', 'send 6.13');
	//echo "sucess";
	$client->send_end_stream();
	
});


$client->add_cb('on_auth_failure', function($reason) {
	global $client;
	_info("got on_auth_failure cb with reason $reason");
	$client->send_end_stream();
});
//
// finally start configured xmpp stream
//

$client->start(array(
	'--with-debug-shell' => true,
	'--with-unix-sock' => true
));
echo "done\n";

?>
