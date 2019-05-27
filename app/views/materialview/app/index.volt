<?php use Phalcon\Tag;
echo $this->getContent();
$auth = $this->session->get('auth');
$user_id=$auth['id'];
$user=User::findFirst($user_id);
// print_r($auth);exit;
/*--------*/
$SenderID=new SenderID();
$sender_id=$SenderID->getSenderID($user_id);
$imageProfile='/profile/'.stristr($auth['jid'],"@",true).'.jpg?lastmod='.uniqid();
/*--------*/
/*Message History*/
$msg_obj=new Message();
$messages=$msg_obj->getRecentMessage($user_id,5);
/*END Message History*/
/*INBOX MESSAGE*/
$inbox = new Inbox();
$inboxs=json_decode($inbox->getData($user->mg_id,$user->id),true);
/*END INBOX MESSAGE*/
/*Follow MESSAGE*/
$joint = new Joint();
$joints=$joint->getRecentSent($user_id,5);
/*END Follow MESSAGE*/
/*Feedback MESSAGE*/
$feedbacks = Feedback::find(array("user_id = $user_id" ,'order'=>'id DESC',"limit" => 5 ));
/*END Follow MESSAGE*/

$user_permission = $user->getPermissions($user_id);
$char_limit = $user_permission['text_message_size_limitation'];

$api_status=false;
$api =Api::findFirst("user_id='".$user_id."'");
if($api){
  if($api->status!="Disable")
    $api_status=true;
}
?>

<script type="text/javascript">
<?php if($user_id){echo "var user_id=$user_id;";}?>
</script>
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
{{ javascript_include('ckfinder/ckfinder.js') }}
{{ javascript_include('js/common.js') }}
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/app.js') }}

{{ javascript_include('Pillbox/pillbox.js') }}
{{ stylesheet_link('Pillbox/pillbox.css') }}

{{ javascript_include('materialize/js/materialize.clockpicker.js') }}
{{ stylesheet_link('materialize/css/materialize.clockpicker.css') }}

{{ javascript_include('js/bootbox.min.js')}}
<!--Message Tab-->
<div id="MESSAGE" class="app_design">
<div class="row margin-none">
<div class="col s4 padding-none left-side-box">
<div class="recent-message-box">
    <div class="box-head">
        <h5 class="left font-size16 text_grey-color title"><i class="material-icons text_grey-color">history</i> Recent Messages</h5> <a class="right view-all-recent-messages" href="/reports">View All</a>
    </div>
             <div class="recent-message-box-inner">
             <ul id="message-recent" class="collection">
              <?php
              foreach ($messages as $key => $value) {
                $msg='';
                if($value['text']){
                  $msg=$value['text'];
                }else{
                  $msg="Image";
                }
                echo '<li class="collection-item avatar">
                  <img src="../images/1new-connect-logo-3-plain.png" alt="" class="circle">
                  <span class="title font-size16 ellipsify">'.$value["mobile"].'</span>
                  <p class="emojitext ellipsify ellipsis multiline font-size14">'.$msg.'</p>
                  <span class="date-time font-size12">'.$value["datetime"].'</span>
                  <a href="#!" class="dropdown-button secondary-content" data-activates="dropdown3"><i class="material-icons">keyboard_arrow_down</i></a>
                  </li>';
              }
              ?>
              </ul>
            </div>
</div>
</div>

<div class="col s8 padding-none right-side-box">
<div class="right-side-bg-image">
  <div id="compose">
    <!-- Compose Form -->
      <?php $this->partial("app/composeoption") ?>
    <!--END Compose Form -->
    </div>
        <!-- Compose Form 1-->
<!--     <div style="display:none;" id="composedynamic">
      <?php //$this->partial("app/composedynamicoption") ?>
    </div> -->
    <!--END Compose Form -->  
  
</div>
</div>
</div>
</div>

<!--END Message Tab-->
<!--Feedback Tab-->
  <?php if($user_permission['user_feedback'] == 'Yes'){ ?>
<div id="FEEDBACK" class="app_design">
<div class="row margin-none">
<div class="col s4 padding-none left-side-box">
<div class="recent-message-box">
    <div class="box-head">
        <h5 class="left font-size16 text_grey-color title"><i class="material-icons text_grey-color">history</i> Recent Feedback</h5> <a class="right view-all-recent-messages" href="/feedback">View All</a>
    </div>
             <div class="recent-message-box-inner">
             <ul id="feedback-recent" class="collection">
              <?php
              foreach ($feedbacks as $key => $value) {
                echo '<li id="'.$value->id.'" class="collection-item avatar">
                  <img src="../images/1new-connect-logo-3-plain.png" alt="" class="circle">
                  <p class="emojitext ellipsify ellipsis multiline font-size14">'.$value->question.'</p>
                  <span class="date-time font-size12">'.$value->datetime.'</span>
                  <a href="#!" class="dropdown-button secondary-content" data-activates="dropdown3"><i class="material-icons">keyboard_arrow_down</i></a>
                  </li>';
              }
              ?>
              </ul>
            </div>
</div>
</div>

<div class="col s8 padding-none right-side-box">
<div class="right-side-bg-image">
  <div>
    <!-- Compose Form -->
      <?php $this->partial("app/feedback") ?>
    <!--END Compose Form -->
  </div>
</div>
</div>
</div>
</div>
<?php } ?>
<!--END Feedback Tab-->
<!--Follow Tab-->
<?php if($user_permission['joint'] == 'Yes'){ ?>
<div id="FOLLOW" class="app_design">
<div class="row margin-none">
<div class="col s4 padding-none left-side-box">
<div class="recent-message-box">
    <div class="box-head">
        <h5 class="left font-size16 text_grey-color title"><i class="material-icons text_grey-color">history</i> Recent Update</h5><a class="right view-all-recent-messages" href="/joint">View All</a>
    </div>
             <div class="recent-message-box-inner">
             <ul id="follow-recent-sent" class="collection">
              <?php
              foreach ($joints as $key => $value) {
                $msg='';
                if($value['text']){
                  $msg=$value['text'];
                }else{
                  $msg=$value['multimedia'];
                }
                echo '<li class="collection-item avatar">
                  <img src="../images/1new-connect-logo-3-plain.png" alt="" class="circle">
                  <p class="emojitext ellipsify ellipsis multiline font-size14">'.$msg.'</p>
                  <span class="date-time font-size12">'.$value["datetime"].'</span>
                  <a href="#!" class="dropdown-button secondary-content" data-activates="dropdown3"><i class="material-icons">keyboard_arrow_down</i></a>
                  </li>';
              }
              ?>
              </ul>
            </div>
</div>
</div>

<div class="col s8 padding-none right-side-box">
<div class="right-side-bg-image">
  <div>
    <!-- Compose Form -->
      <?php $this->partial("app/follow") ?>
    <!--END Compose Form -->
  </div>
</div>
</div>
</div>
</div>
<?php } ?>
<!--END Follow Tab-->
<!--INBOX Tab-->
<div id="INBOX" class="app_design">
<div class="row margin-none">
<div class="col s4 padding-none left-side-box">
<div class="recent-message-box">
  <div class="box-head">
        <h5 class="font-size16 text_grey-color title"><i class="material-icons text_grey-color">history</i> Recent Reply</h5>
  </div>
    <div class="recent-message-box-inner">
       <ul id="inbox-recent-message" class="collection">
        <?php
        foreach ($inboxs as $key => $value) {
          echo '<li id="'.$value["id"].'" class="collection-item avatar">
            <img src="../images/1new-connect-logo-3-plain.png" alt="" class="circle">
            <span class="title font-size16 ellipsify">'.$value["sender_id"].'</span>
            <span class="emojitext ellipsify ellipsis multiline font-size14">'.$value["message"].'</span>
            <span class="date-time font-size12">'.$value["datetime"].'</span>
            <a href="#!" class="dropdown-button secondary-content" data-activates="dropdown3"><i class="material-icons">keyboard_arrow_down</i></a>
            </li>';
        }
        ?>
        </ul>
    </div>
</div>
</div>

<div class="col s8 padding-none right-side-box">
<div class="right-side-bg-image">
    <!-- Compose Form -->
      <?php $this->partial("app/inbox") ?>
    <!--END Compose Form -->
</div>
</div>
</div>
</div>
<!-- /////////// -->
  <!-- Modal Trigger -->
  

  <!-- Modal Structure -->
  <div id="poll" class="modal modal-fixed-footer">
    <div class="modal-content">
      <!-- <h4>Modal Header</h4>
      <p>A bunch of text</p> -->
        <div class="container">
          <center><span class="body-header">Unlimited Votes and Polls!</span></center>
          <div class="row">
            <div class="grid-example col m7 l7">
              <div class="col s12">
                <ul class="tabs">
                  <li class="tab col s3"><a class="active" href="#test1">Question</a></li>
                  <!-- <li class="tab col s3"><a href="#test2">Theme</a></li>
                  <li class="tab col s3"><a href="#test3">Settings</a></li>
                  <li class="tab col s3"><a href="#test4">Share</a></li> -->
                </ul>
                <div class="poll-body">
                  <div class="wrap-form">
                    <form id="poll_form">
                      <div class="input-field col s12">
                      <textarea name="txtQue" id="txtQue" class="materialize-textarea"></textarea>
                      <label for="textarea1">Type your question here</label>
                      </div>
                      <!-- <textarea name="txtQue" id="txtQue" rows="2" class="textarea-que" placeholder="Type your question here"> </textarea> -->
                      <div class="input-field col s12">
                      <input name="txtOpt1" class="validate" id="txtOpt1" type="text">
                      <label for="input_text">Type your first option</label>
                      </div>
                      <div class="input-field col s12">
                      <input name="txtOpt2" id="txtOpt2" type="text">
                      <label for="input_text">Type your second option</label>
                      </div>
                      <div class="input-field col s12">
                      <input name="txtOpt3" id="txtOpt3" type="text" class="validate">
                      <label for="input_text">Type your third option</label>
                      </div>
                      <div class="input-field col s12">
                      <input name="txtOpt4" id="txtOpt4" type="text">
                      <label for="input_text">Type your fourth option</label>
                      </div>
                      <!-- <input type="text" name="txtOpt1" id="txtOpt1" placeholder="Type your option">
                      <input type="text" name="txtOpt1" id="txtOpt1" placeholder="Type your option">
                      <input type="text" name="txtOpt1" id="txtOpt1" placeholder="Type your option">
                      <input type="text" name="txtOpt1" id="txtOpt1" placeholder="Type your option"> -->
                    </form>
                      
                  </div>
                </div>
              </div>
            </div>
            <!-- <div class="grid-example col m5 l5 table-bordered"><span class="flow-text">hi</span></div> -->
          </div>
        </div>
      <!-- end -->
    </div>
    <div class="modal-footer">
       <a href="#!" class="modal-action modal-close waves-effect waves-green btn-flat">Close</a>
      <a href="#!" class="modal-action modal-close waves-effect waves-light btn " id="subpoll">Submit</a>
    </div>
  </div>
  
<!-- ///////// -->
<!-- END INBOX Tab -->
<script type="text/javascript">
  var char_limit = "<?php echo $char_limit ?>";
$(".ellipsify.multiline p, .ellipsify.multiline").text(function(index, currentText) {
  if(currentText.length>125){
        return currentText.substr(0, 125)+ '...';
  }else{
        return currentText.substr(0, 125);
  }

});

</script>
<?php $this->partial("app/image") ?>

<!-- Image Crop -->
{{ stylesheet_link('ImageCropJs/croppie.css') }}
{{ javascript_include('ImageCropJs/croppie.js') }}

{{ stylesheet_link('ImageCropJs/sweetalert.css') }}
{{ javascript_include('ImageCropJs/sweetalert.min.js') }}

{{ stylesheet_link('ImageCropJs/style.css') }}

{{ javascript_include('chosen_v1.5.1/chosen.jquery.min.js') }}
{{ stylesheet_link('chosen_v1.5.1/chosen.min.css') }}
{{ javascript_include('chosen_v1.5.1/ajax-chosen.min.js') }}
<!-- End image Crop -->
