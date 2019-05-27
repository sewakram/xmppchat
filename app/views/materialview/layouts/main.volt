<?php use Phalcon\Tag;
?>
<div id="main_wrapper">
<div class="container-fluid nevyblue-bg header-min-height">
<header id="header" class="container">
  <?php                
                $auth = $this->session->get('auth');
                $msg_count='';
                $bell_class='';
                if($auth)
                    $page = '/dashboard';
                else
                    $page = '/';
                $login_type = $auth['login_type'];
             //added webgile               
                  $user = new User();
                  $user_permission = $user->getPermissions($auth['id']);
                  $menu_array=array('MESSAGE' => 'message', 
                                                  'FEEDBACK' =>    'mode_edit', 
                                                  'FOLLOW' =>    'group');
                switch ($login_type) {
                    case "Group Admin":
                        $user = User::findFirst($auth['id']);
                        $logo=Logo::findFirst($user->franchisee_id);
                        $count_temp =count(Inbox::find("read_status='false' AND mg_id=".$user->mg_id.""));
                        if($count_temp!= 0){$bell_class='red-text';$msg_count="(".$count_temp.")";}
                         if($user_permission['user_feedback'] == 'No')
                        unset($menu_array['FEEDBACK']);
                        if($user_permission['joint'] == 'No')
                        unset($menu_array['FOLLOW']);
                        break;
                    /*case "franchisee":
                        $user = Franchisee::findFirst($auth['id']);
                        //$user_logo=UserLogo::findFirst("user_id=$user->parent_id AND login_type='$login_type'");
                        $logo=Logo::findFirst($user->logo_id);
                        break;*/
                    default:
                        $user = User::findFirst("type='Super Admin'");
                        $count_temp =count(Inbox::find("read_status='false' AND mg_id=".$user->mg_id.""));
                        if($count_temp!= 0){$bell_class='red-text';$msg_count="(".$count_temp.")";}
                        $logo=Logo::findFirst($user->id);
                }
            ?>
<div class="row" style="margin-bottom:0;">
<div class="logo_wrap col s2">
<a class="logo" href="/app/"><img  src="/images/connect-logo.png" class="img" width="180px" alt="logo"></a>
</div>

<div class="menu_wrapp col s7">
<div class="row" style="margin-bottom:0;">
<div class="col s12">
            <ul class="tabs main_menu_ul">
           <?php foreach($menu_array as $key=>$value){?>
             <li class="tab col s3 list">
         
            <a href="<?php echo '#'.$key?>" class="active font-size16 text_color-white">                      
            <i class="header-menu-icon material-icons"><?php echo $value?></i>
            <span class="header-menu-text"><?php echo $key?></span>         
               </a>
             </li>
              <?php } ?>
            <li class="tab col s3 list">
            <a href="#INBOX" class="font-size16 text_color-white">
            <i id="inbox-bell" class="<?php echo $bell_class; ?> header-menu-icon material-icons">notifications</i>
            <span class="header-menu-text">INBOX <span id="inbox-count" class="inbox_badge badge white-text font-size16"><?php echo $msg_count; ?></span></span>
            </a>
            </li>
            </ul>
</div>
</div>
</div>
<div class="right_dropdown_wrapp col s2 right">
            <ul class="right_side_menu">
            <li class="right"><a class="dropdown-button text_color-white right-menu-text menu_icon_right waves-effect circle" href="#!" data-activates="dropdown1">
            <i class="material-icons">more_vert</i>
            </a>
                <ul id="dropdown1" class="dropdown-content">
                  <li><a href="/account" class="common font-size14 text_grey-color waves-effect">My Profile</a></li>
                  <li><a href="/transaction" class="common font-size14 text_grey-color waves-effect">Transactions</a></li>
                  <li>
                    <a href="#" data-activates='sms_sub_menu'  data-hover="true" class="dropdown-button common font-size14 text_grey-color waves-effect">SMS Settings</a>
                  </li>
                  <li><a href="/invite" class="common font-size14 text_grey-color waves-effect">Invite</a></li>
                  <li><a href="/user/logout" class="common font-size14 text_grey-color waves-effect">Logout</a></li>
                </ul>
            </li>
                <ul id='sms_sub_menu' class='dropdown-content'>
                    <li><a href="/account/logic_both">Logic</a></li>
                    <li><a href="/account/api">Others</a></li>
                    <li><a href="/account/uni_api">Unicode</a></li>
                </ul>
           </ul>
</div>
</div>
</header>
</div>
<div class="container app_new_wraaper box-shadow">
<div class="app_design_header">
<div class="row margin-none">
<div class="col s4 padding-none left-side-box-header">
<header class="cream-bg">
          <div class="row" style="margin-bottom:0;">
          <div class="col s7">
          <div class="aside-img left">
          <a href="#!" data-activates="slide-profile" class="button-collapse"><img class="circle responsive-img userimg" src="<?php echo $imageProfile;?>" alt="user image"></a>
          </div>
          <div class="left aside-user">
          <h5 class="font-size16"><a data-activates="slide-profile" class="button-collapse text_color-black cursor">
           {{sender_id}}</a></h5>
            <div id="slide-profile" class="side-nav">
              <header class="slide-nav-header">
              <a class="left back-btn cursor" onclick="$('.button-collapse').sideNav('hide');"><i class="material-icons white-text">keyboard_backspace</i></a>
              <span class="title-slide left white-text font-size18">Edit Profile</span>
              </header>
              <div class="col s12 upload-image-wrap">

              <div class="image-wrap upload-demo">
              <input type="file" name="fileupload" id="upload" value="Choose a file" accept="image/*">
              <div id="firstupload">
              <a class="circle hover-over" href="#!"><img class="circle responsive-img userimg" src='<?php echo $imageProfile;?>' alt="user image"></a>
              <a href="#!" class="font-size14 circle center change-profile-photo-on-hover white-text" id="profileimage"><i class="material-icons white-text">photo_camera</i><br>CHANGE PROFILE PHOTO</a>
              </div>
              <div id="demoupload">
                
              </div>
               </div>
               <div id="button">
                <button id="upload-result" type="submit" class="smart_btn circle right send_text compose_common waves-effect waves-light relative"><i class="center material-icons">done</i>
                </button>
                <button id="upload-cancel" type="button" class="smart_btn circle right waves-effect waves-light relative"><i class="center material-icons">close</i>
                </button>
                </div>
              </div>
              <div class="col s12 profile-info">
              <div><a href="#!"><span class="left">{{user.firstname}} {{user.lastname}}</span><span class="right">( {{user.mobile}} )</span></a></div>
              <div><a href="#!"><span>Credit Balance <strong>({{user.balance}})</strong></span></a></div>
              <div><a href="#!"><span>Sancharapp id <strong>({{user.joint_handle}})</strong></span></a></div>
              <div><a href="#!"><span>Sender id <strong>({{sender_id}})</strong></span></a></div>
              </div>
              <form action="#" id="myform" method="post">
                 <input type="hidden" id="imagebase64" name="imagebase64">
              </form>
            </div>
          </div>
          </div>
          <div class="col s5">
          <div class="aside-options right">
          <ul class="second-header-options">
          <li class="right"><a class="inner-header-menu dropdown-button waves-effect circle text_grey-color" data-activates="dropdown2"><i class="material-icons">more_vert</i></a>
                 <ul id="dropdown2" class="dropdown-content">
                  <li><a href="/group/" class="common font-size14 text_grey-color waves-effect">Contacts</a></li>
                </ul>
          </li>
          <li class="left">
          <a data-activates="slide-out" class="button-collapse inner-header-message waves-effect circle text_grey-color">
          <i class="material-icons">group_add</i></a>
            <div id="slide-out" class="side-nav">
            <header class="slide-nav-header">
            <a class="left back-btn cursor" onclick="$('.button-collapse').sideNav('hide');"><i class="material-icons white-text">keyboard_backspace</i></a>
            <span class="title-slide left white-text font-size18">Add New Group</span>
            </header>
            <div class="col s12 upload-image-wrap add-new-group-image-wrap">

            <div class="image-wrap" >
              <a class="circle hover-over" href="#!"><img class="circle responsive-img userimg" src='../images/add_new_group.png' alt="user image"></a>
              <a href="#!" class="font-size14 circle center change-profile-photo-on-hover white-text"><i class="material-icons white-text">photo_camera</i><br>ADD GROUP ICON</a>

             </div>


            </div>
            <div class="col s12">
            <span><a href="#!">First Sidebar Link</a></span>
            <span><a href="#!">Second Sidebar Link</a></span>
            </div>
            </div>
          </li>
          </ul>
          </div>
          </div>
          </div>
</header>
<script type="text/javascript">
/*function dynamicsmsform(){
  
$('#MESSAGE #compose').hide();
 $("#MESSAGE #composedynamic").show();
  $("#MESSAGE #compose .inputapi-transliterate-language-menu").hide();
}*/
function composeform(){
  
$('#MESSAGE #compose').show();
 $("#MESSAGE #composedynamic").hide();
  $("#MESSAGE #composedynamic .inputapi-transliterate-language-menu").hide();
}
</script>
<div id="xmpp-con-div" class="hide con-disconnected"><i onclick="reConnectXMPP();" class="material-icons">refresh</i> Trying to reconnect...</div>
</div>
<div class="col s8 padding-none right-side-box-header">
<div class="right-side-bg-image">
 <header class="cream-bg">
 <div class="page_title_wrapp">
 <div id="message_title" class="common page_title_inner">
  <span class="title font-size16 ellipsify">Compose</div>
 <div id="feedback_title" class="hide common page_title_inner">
  <span class="title font-size16 ellipsify">Feedback</span>
 </div>
 <div id="follow_title" class="hide common page_title_inner">
  <span class="title font-size16 ellipsify">Follow</span>
 </div>
 <div id="inbox_title" class="hide common page_title_inner"></div>
 </div>
 </header>
 </div>
 </div>
 </div>
 </div>
    {{ flash.output() }}
    {{ content() }}
</div>
    <footer id="footer" class="container-fluid">
    <div class="container">
      <div class="center footer-copyright">
        <p class="left">&copy; Sancharapp {{ date("Y") }} </p>
        <p class="right"><span class="text-right terms_link"><a href="/terms" target="_blank">Terms of Service</a></span>
        |
        <span class="text-right terms_link"><a href="/connect/support" target="_blank">Support</a></span>
        </p>
      </div>
      </div>
    </footer>

</div>
