<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
include_once 'register.php';
$xmppObj = new xmpp();
$status=$xmppObj->register_user("67","Wg.12345","sancharapp.com");
print_r($status);
?>