
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }}
<!-- {{ stylesheet_link('css/custom.css') }} -->
{{ content() }}
<!-- coco forgot page start-->
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
        <div class="full-content-center animated fadeInDownBig">
            <p class="text-center"><a href="#"><img src="{{url()}}assets/img/login-logo.png" alt="Logo"></a></p>
            <div class="login-wrap">
                <div class="login-block">
                   {{ form('id':'forgotForm','class': 'well form-search') }}
                        <div class="page-header">
                        <h2>Forgot Password?</h2>
                        </div>
                        <div class="form-group login-input">
                        <i class="fa fa-mobile overlay"></i>
                        {{ form.render('mobile', ['class': 'form-control text-input','placeholder':'Mobile']) }}
                        </div>
                        
                        <div class="row">
                            <div class="col-sm-6">
                            <!-- <button type="submit" class="btn btn-default btn-block">Register</button> -->
                            {{ form.render('Send',['class': 'btn btn-default btn-block']) }}
                            </div>
                            <div class="col-sm-6">
                            <!-- <button type="submit" class="btn btn-default btn-block">Register</button> -->
                            <a href="/connect/signin" class="btn btn-primary btn-block">← Go Back</a>
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

<!-- coco forget page end -->

<script>
$(document).ready(function(){
    $("#forgotForm").validate({
        rules: { 
           mobile:{minlength:10,maxlength:10},
        },
        messages: {
            mobile: "Enter Valid Mobile Number",
        },
        tooltip_options: {
          // first_name: { placement: 'right' }
        }
    });
});
</script>