<?php
/**
 * Jaxl (Jabber XMPP Library)
 *
 * Copyright (c) 2009-2012, Abhinav Singh <me@abhinavsingh.com>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 *
 * * Neither the name of Abhinav Singh nor the names of his
 * contributors may be used to endorse or promote products derived
 * from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRIC
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 */

// TODO: support for php unit and add more tests
error_reporting(E_ALL);
ini_set("log_errors", 1);
ini_set("error_log", "php-error.log");
error_log( "Hello, errors!" );
// require_once('../web/a.php');
// require_once ("/var/www/html/msg-api/JAXL/jaxl.php");
require_once "../jaxl.php";
$client = new JAXL(array('jid' =>'1@localhost','pass' =>'Wg.12345','auth_type' => 'DIGEST-MD5','log_level' => JAXL_INFO,'priv_dir'=>'priv_dir'));
        $client->require_xep(array('0199'));
        echo 'sewak';
                // file_put_contents("../public/afterClientCroncache.txt", "\n".$this->xmpp_msg_attribute,FILE_APPEND);
        $client->add_cb('on_auth_success', function(){
                // file_put_contents("../public/on_auth_success.txt", "\n".$this->xmpp_msg_attribute,FILE_APPEND);
            global $client;
            //foreach ($this->jids as $key => $value){
            $xmpp_msg_attribute=json_encode(array("route" => "Notification","mg_id" => 6,"submit_datetime" => '2018/06/13'));
               // file_put_contents("../public/send_chat_msg.txt", "\n".$xmpp_msg_attribute,FILE_APPEND);
                // $client->send_chat_msg($this->jid,$this->message);
                // echo 'ganesh';exit();
                
                $client->send_msg("0@localhost","sewak ganedfgdfgdfgdfshaaaa",'Dev',1,$xmpp_msg_attribute);
                //file_put_contents("../public/send_msg.txt", "\n".$xmpp_msg_attribute,FILE_APPEND);

                //file_put_contents("../public/Croncache.txt", "\n".$this->xmpp_msg_attribute.' \n value: '.$value.' \n message: '.$this->message.' \n sender id: '.$this->sender_id.$key,FILE_APPEND);
            //}
            //$client->send_end_stream(); 
        });
        $client->start();