<?php use Phalcon\Tag;
echo $this->getContent();
?>
<!-- {{ stylesheet_link('css/custom.css') }} -->
<!-- always add for responsive menu outer page-->
<!-- {{ stylesheet_link('css/menu_responsive_outer.css') }} -->
<!-- {{ javascript_include('js/jquery.validate.min.js') }} -->
<!-- {{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }} -->

<!-- new login template start -->
<!-- Modal Start -->
          <!-- Modal Task Progress -->  
  <div class="md-modal md-3d-flip-vertical" id="task-progress">
    <div class="md-content">
      <h3><strong>Task Progress</strong> Information</h3>
      <div>
        <p>CLEANING BUGS</p>
        <div class="progress progress-xs for-modal">
          <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style="width: 80%">
          <span class="sr-only">80&#37; Complete</span>
          </div>
        </div>
        <p>POSTING SOME STUFF</p>
        <div class="progress progress-xs for-modal">
          <div class="progress-bar progress-bar-warning" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style="width: 65%">
          <span class="sr-only">65&#37; Complete</span>
          </div>
        </div>
        <p>BACKUP DATA FROM SERVER</p>
        <div class="progress progress-xs for-modal">
          <div class="progress-bar progress-bar-info" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style="width: 95%">
          <span class="sr-only">95&#37; Complete</span>
          </div>
        </div>
        <p>RE-DESIGNING WEB APPLICATION</p>
        <div class="progress progress-xs for-modal">
          <div class="progress-bar progress-bar-primary" role="progressbar" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100" style="width: 100%">
          <span class="sr-only">100&#37; Complete</span>
          </div>
        </div>
        <p class="text-center">
        <button class="btn btn-danger btn-sm md-close">Close</button>
        </p>
      </div>
    </div>
  </div>
    
  <!-- Modal Logout -->
  <div class="md-modal md-just-me" id="logout-modal">
    <div class="md-content">
      <h3><strong>Logout</strong> Confirmation</h3>
      <div>
        <p class="text-center">Are you sure want to logout from this awesome system?</p>
        <p class="text-center">
        <button class="btn btn-danger md-close">Nope!</button>
        <a href="login.html" class="btn btn-success md-close">Yeah, I'm sure</a>
        </p>
      </div>
    </div>
  </div>        <!-- Modal End -->    
  <!-- Begin page -->
  <div class="container">
    <div class="full-content-center">
      <p class="text-center"><a href="#"><img src="{{url()}}assets/img/login-logo.png" alt="Logo"></a></p>
      <div class="login-wrap animated flipInX">
        <div class="login-block">
          <img src="{{url()}}images/users/default-user.png" class="img-circle not-logged-avatar">
          {{ form('user/signin', 'role': 'form', 'id': 'loginForm','onbeforesubmit': 'return false') }}
            <div class="form-group login-input">
            <i class="fa fa-user overlay"></i>
            <!-- <input type="text" class="form-control text-input" placeholder="Username"> -->
            {{ text_field('mobile', 'class': "form-control text-input",'placeholder':'Username') }}
            </div>
            <div class="form-group login-input">
            <i class="fa fa-key overlay"></i>
            <!-- <input type="password" class="form-control text-input" placeholder="********"> -->
            {{ password_field('password', 'class': "form-control text-input",'placeholder':'********') }}
            </div>
            
            <div class="row">
              <div class="col-sm-12">
              <button type="submit" class="btn btn-success btn-block">LOGIN</button>
              </div>
              <!-- <div class="col-sm-6">
              <a href="register.html" class="btn btn-default btn-block">Register</a>
              </div> -->
            </div>
            <div class="row">
              <div class="col-sm-6">
              <!-- <a href="{{url()}}connect/signup" class="btn btn-default btn-block">Register</a> -->
              <a href="{{url()}}user/signup/4" class="btn btn-default btn-block">Register</a>
              </div>
              <div class="col-sm-6">
              <a href="{{url()}}user/forgotPassword" class="btn btn-default btn-block">Forgot password</a>
              </div>
            </div>
          </form>
        </div>
      </div>
      
    </div>
  </div>
  <!-- the overlay modal element -->
  <div class="md-overlay"></div>
  <!-- End of eoverlay modal -->
<!-- new login template end -->

{{ javascript_include('assets/libs/jquery/jquery-1.11.1.min.js') }}
<script type="text/javascript">
  $(document).ready(function() { $('body').addClass("login-page"); });
</script>