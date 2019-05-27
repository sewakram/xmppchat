<?php use Phalcon\Tag;
?>
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }}
<!-- style="width: 15%!important;height: 100%;" -->
<nav class="navbar navbar-inverse navbar-fixed-top nav-left">
  <div class="container-fluid">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>                        
      </button>
      <?php
                $auth = $this->session->get('auth');
                if($auth)
                    $page = '/dashboard';
                else
                    $page = '/';
                $login_type = $auth['login_type'];

                switch ($login_type) {
                    case "Group Admin":
                        $user = User::findFirst($auth['id']);
                        $logo=Logo::findFirst($user->franchisee_id);
                        break;
                    /*case "franchisee":
                        $user = Franchisee::findFirst($auth['id']);
                        //$user_logo=UserLogo::findFirst("user_id=$user->parent_id AND login_type='$login_type'");
                        $logo=Logo::findFirst($user->logo_id);
                        break;*/
                    default:
                        $user = User::findFirst("type='Super Admin'");
                       // $user_logo=UserLogo::findFirst("user_id=$user->id");
                       // echo $user->id;
                        $logo=Logo::findFirst($user->id);
                }
            ?>
          <div class="image_outer ">
          <a href="<?php echo $page; ?>" >
          <img class="hidden-xs pull-left img-responsive img-rounded" style="" src='/logos/<?php echo $logo->img_src; ?>'/>
          <img class="visible-xs pull-left img-responsive img-rounded" src='/logos/<?php echo $logo->img_src; ?>'/>
          </a></div>
          <!--<a style="margin-left:0px;" class="navbar-brand" href="<?php echo $page; ?>"></a>-->
    </div>
    <div class="collapse navbar-collapse" id="myNavbar">
      {{ elements.getMenu() }}
    </div>
  </div>
</nav>
<div class="container">
    {{ flash.output() }}
    {{ content() }}
</div>
    <footer id="footer-section" class="footer-section">
    <div class="container-fluid wrapper-for-border">
    <div class="row">
    <div class="col-md-4">
    <h2 class="main-title">Facebook</h2>
    <div class="fb-page" data-width="296" data-href="https://www.facebook.com/sancharapp.com" data-tabs="timeline" data-height="316" data-small-header="false" data-adapt-container-width="true" data-hide-cover="false" data-show-facepile="true"><blockquote cite="https://www.facebook.com/facebook" class="fb-xfbml-parse-ignore"><a href="https://www.facebook.com/facebook">Facebook</a></blockquote></div>
    </div>
    <div class="col-md-4">
    <h2 class="main-title">Twitter</h2>
    <a class="twitter-timeline" data-height="320" data-width="300" data-link-color="#0f3355" href="https://twitter.com/linkappin">Tweets by linkappin</a> <script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
    </div>
    <div class="col-md-4">
    <h2 class="main-title">Contact Us</h2>
    <div class="inner-contact-form-wrapper">
    <!--<p class="normal-text">Send us a message and let us know how we can help. Please be as descriptive as possible as it will help us serve you better.</p>-->
    <form onsubmit="return grecaptcha.getResponse();" method="post" id="contactForm" role="form" action="/contact/send">
    <div class="form-group">
    <label for="name">Name</label>
    <input type="text" class="form-control" name="name" id="name">
    </div>
    <div class="form-group">
    <label for="email">E-Mail</label>
    <input type="text" class="form-control" name="email" id="email">
    </div>
    <div class="form-group">
    <label for="comments">Message</label>
    <textarea class="form-control" name="comments" id="comments"></textarea>
    </div>
    <div style="transform:scale(0.88);transform-origin:0 0;margin-top: 8px;" class="g-recaptcha" data-sitekey="6LfJNAcUAAAAAMNQFHjz2C1PTNQlI_xdm3A1sqQp"></div>
    <div class="form-group">
    <input type="submit" class="mobile-btn btn btn-primary btn-large" value="Send">
    </div>
    </form>
    </div>
    </div>
    </div>
    </div>
        <p class="copy-right">&copy; Sancharapp&trade; {{ date("Y") }} |
        <span class="text-right terms_link"><a href="/terms" target="_blank">Terms of Service</a></span> <br><br><!--<span class="text-right terms_link"><a href="https://www.facebook.com/sancharapp.com" target="_blank"><img id="fb" src="/images/fb.png"> </a><a href="https://twitter.com/linkappin" target="_blank"><img id="twit" src="/images/twit.png"></a></span>-->
        </p>
    </footer>
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_GB/sdk.js#xfbml=1&version=v2.7";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));
// A $( document ).ready() block.
$( document ).ready(function() {
    console.log( "ready!" );
    $("#contactForm").validate({
      submitHandler: function (form) {
        var response = grecaptcha.getResponse();
        //recaptcha failed validation
        if (response.length == 0) {
          $('#recaptcha-error').show();
          return false;
        }
          //recaptcha passed validation
        else {
          $('#recaptcha-error').hide();
          return true;
        }
      }
    });
});
</script>
