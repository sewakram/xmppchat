<?php use Phalcon\Tag; ?>

{{ stylesheet_link('css/custom.css') }}
{{ javascript_include('js/jssor.slider.mini.js')}}
{{ javascript_include('js/docs.min.js')}}
{{ javascript_include('js/ie10-viewport-bug-workaround.js')}}
{{ content() }}
<style>
.container {width:100%;padding:0;margin:0 auto;}
.navbar {margin-bottom:0;}
.navbar .container-fluid .navbar-header .image_outer {
    height: 42px;
    width: 200px;
}
.navbar .container-fluid .navbar-header .image_outer img {
  margin-top:0;
}
hr {display:none;}
footer {
    background-color: #ee3e41;
    padding-top: 20px;
}
footer p,footer .terms_link a{color: #fff;}
body{padding-top:5%;}
/*#myNavbar .nav-collapse .navbar-right {
    display: none;
}*/
</style>
<div class="slider_main">
        <div id="slider1_container" style="display: none; position: relative; margin: 0 auto; width: 1466px; height: 442px; overflow: hidden;">

            <!-- Loading Screen -->
            <div class="second_div" u="loading" style="position: absolute; top: 0px; left: 0px;">
                <div style="filter: alpha(opacity=70); opacity:0.7; position: absolute; display: block;

                background-color: #000; top: 0px; left: 0px;width: 100%; height:100%;">
                </div>
                <div style="position: absolute; display: block; background: url(/img/loading.gif) no-repeat center center;

                top: 0px; left: 0px;width: 100%;height:100%;">
                </div>
            </div>

            <!-- Slides Container -->
            <div u="slides" style="cursor: move; position: absolute; left: 0px; top: 0px; width: 1466px; height: 442px;
            overflow: hidden;">
                <div class="img_outer">
                    <img u="image" src2="/img/1920/slider_bg.png" />
                    <div class="carousel-caption mobile-caption">
                    <img class="mobile-img" u="image" src2="/img/1920/linkapp_spalsh_page_mobile.png" />
                    <h1>Welcome to <strong>linkapp&trade;</strong></h1>
                    <ul>
                    <li class="dot"><span>Easy & fast communication for the emerging world.</span></li>
                    <li class="dot"><span><strong>linkapp&trade;</strong> is a revolutionary app through which you can experience advanced way of communication.</span></li>
                    <li class="dot"><span>Get connected to all public & private agencies such as Schools, Colleges, RTO's, Police, Municipal Corporation, Hospitals, Banks, Consumer Brand with a clutter free interface. </span></li>
                    <li class="dot"><span>We bring you the world's first <strong>Social Service Network</strong> - The Social Networking with Organisations.</span></li>
                    <li class="dot"><span>Let's link-up with <strong>linkapp&trade;</strong> and communicate with them for whom we matter the most.</span></li>
                    </ul>
                    <a class="read_more" href="http://www.linkapp.in/features"> <!-- <img u="image" src2="/img/1920/read_more_btn.png" /> --> Read More </a>
                    </div>

                </div>
                <div class="img_outer">
                    <img u="image" src2="/img/1920/slider_bg.png" />
                    <div class="carousel-caption mobile-caption">
                    <img class="mobile-img" u="image" src2="/img/1920/service_list_mobile.png" />
                    <h1>One-Stop Communication</h1>
                    <ul>
                    <li class="dot"><span>Get important announcements from your local Municipal Corporation, Police, Traffic Department etc.</span></li>
                    <li class="dot"><span>Receive updates from your favorite Brands, Banks, Schools etc.</span></li>
                    <li class="dot"><span>Stay connected with your Organisations, Association & Clubs.</span></li>
                    <li class="dot"><span>Reply directly to all received announcement, update or message.</span></li>
                    </ul>
                    <a class="read_more" href="http://www.linkapp.in/features"> <!-- <img u="image" src2="/img/1920/read_more_btn.png" /> --> Read More </a>
                    </div>
                </div>
                <div class="img_outer">
                    <img u="image" src2="/img/1920/slider_bg.png" />
                    <div class="carousel-caption mobile-caption">
                    <img class="mobile-img" u="image" src2="/img/1920/feedback_mobile.png" />
                    <h1>View that counts</h1>
                    <p>You can respond to questions with specific answers from agencies.</p>
                    <a class="read_more" href="http://www.linkapp.in/features"> <!-- <img u="image" src2="/img/1920/read_more_btn.png" /> --> Read More </a>
                   </div>
               </div>
            </div>

            <!--#region Bullet Navigator Skin Begin -->
            <!-- Help: http://www.jssor.com/development/slider-with-bullet-navigator-jquery.html -->
            <style>
                /* jssor slider bullet navigator skin 05 css */
                /*
                .jssorb05 div           (normal)
                .jssorb05 div:hover     (normal mouseover)
                .jssorb05 .av           (active)
                .jssorb05 .av:hover     (active mouseover)
                .jssorb05 .dn           (mousedown)
                */
                .jssorb05 {
                    position: absolute;
                }
                .jssorb05 div, .jssorb05 div:hover, .jssorb05 .av {
                    position: absolute;
                    /* size of bullet elment */
                    width: 16px;
                    height: 16px;
                    background: url(/img/b05.png) no-repeat;
                    overflow: hidden;
                    cursor: pointer;
                }
                .jssorb05 div { background-position: -7px -7px; }
                .jssorb05 div:hover, .jssorb05 .av:hover { background-position: -37px -7px; }
                .jssorb05 .av { background-position: -67px -7px; }
                .jssorb05 .dn, .jssorb05 .dn:hover { background-position: -97px -7px; }
            </style>
            <!-- bullet navigator container -->
            <div u="navigator" class="jssorb05" style="bottom: 16px; right: 6px;">
                <!-- bullet navigator item prototype -->
                <div u="prototype"></div>
            </div>
            <!--#endregion Bullet Navigator Skin End -->

            <!--#region Arrow Navigator Skin Begin -->
            <!-- Help: http://www.jssor.com/development/slider-with-arrow-navigator-jquery.html -->
            <style>
                /* jssor slider arrow navigator skin 11 css */
                /*
                .jssora11l                  (normal)
                .jssora11r                  (normal)
                .jssora11l:hover            (normal mouseover)
                .jssora11r:hover            (normal mouseover)
                .jssora11l.jssora11ldn      (mousedown)
                .jssora11r.jssora11rdn      (mousedown)
                */
                .jssora11l, .jssora11r {
                    display: block;
                    position: absolute;
                    /* size of arrow element */
                    width: 37px;
                    height: 37px;
                    cursor: pointer;
                    background: url(/img/a11.png) no-repeat;
                    overflow: hidden;
                }
                .jssora11l { background-position: -11px -41px; }
                .jssora11r { background-position: -71px -41px; }
                .jssora11l:hover { background-position: -131px -41px; }
                .jssora11r:hover { background-position: -191px -41px; }
                .jssora11l.jssora11ldn { background-position: -251px -41px; }
                .jssora11r.jssora11rdn { background-position: -311px -41px; }
            </style>
            <!-- Arrow Left -->
            <span u="arrowleft" class="jssora11l" style="top: 123px; left: 8px;">
            </span>
            <!-- Arrow Right -->
            <span u="arrowright" class="jssora11r" style="top: 123px; right: 8px;">
            </span>
            <!--#endregion Arrow Navigator Skin End -->
            <a style="display: none" href="http://www.jssor.com">Bootstrap Slider</a>
        </div>
</div>

<div class="jumbotron" style="margin-bottom:0;">
<div class="container-fluid">
    <h1 style="color:#fff;">Download linkapp&trade;</h1>
   <!-- <p>linkapp&trade; is a revolutionary application to create invoices online for free. </p>
    <p>Receive online payments from your clients and improve your cash flow</p> -->

    <a href={{ config.play_store_link.link }} class="google_play_btn" target="_blank"><img src="../images/hereti_google.png" /></a>
</div>
</div>

<!--<div class="features_main">
<div class="container-fluid">
    <div class="col-md-4 one">
        <span class="img_outer"></span>
        <h2 class="features_title">Manage Invoices Online</h2>
        <p class="inner_text">Create, track and export your invoices online. Automate recurring invoices and design your own invoice using our invoice template and brand it with your business logo. </p>
    </div>
    <div class="col-md-4 two">
        <span class="img_outer"></span>
        <h2 class="features_title">Dashboards & Reports</h2>
        <p class="inner_text">Gain critical insights into how your business is doing. See what sells most, who are your top paying customers and the average time your customers take to pay.</p>
    </div>
    <div class="col-md-4 three">
        <span class="img_outer"></span>
        <h2 class="features_title">Invite, Share & Collaborate</h2>
        <p class="inner_text">Invite users and share your workload as invoice supports multiple users with different permissions. It helps your business to be more productive and efficient. </p>
    </div>
</div>
</div> -->

<?php
        $amount=array();
        $slab_ids=array();
         $slabs = Slabs::find(array(
                "status='Active'",
                "order" => "amount"
         ));
            
            foreach($slabs  as $i => $slab) {
                $amount[$i]=round($slab->amount); 
                $slab_ids[$i]=$slab->id;
            }
?>
<!-- <div class="plans_main">
<div class="container-fluid">
<h1>Plans</h1>
<div class="col-md-3 plans_common">
<div class="plans_content">
<h2 class="plan_title">Free</h2>
<div class="circle">
<span class="price">Rs. <?php echo $amount[0]?></span>
<span class="small-text">per month</span>
</div>
<div class="next-content">
<span class="one">Submit Report</span>
<span class="two">Invite Friends</span>
<span class="one">Encrypted Security</span>
</div>
<a class="btn_buy_now" href="/user/signup/<?php echo $slab_ids[0]?>">CHECK NOW</a>
</div>
</div>
<div class="col-md-3 plans_common">
<div class="plans_content">
<h2 class="plan_title">Silver</h2>
<div class="circle">
<span class="price">Rs. <?php echo $amount[1]?></span>
<span class="small-text">per month</span>
</div>
<div class="next-content">
<span class="one">Send SMS to non linkapp&trade; users using 3rd Party SMS Api "Send SMS to other users"</span>
<span class="two">Delivered Report</span>
<span class="one">Unicode Message "Indian Languages Support"</span>
<span class="two">Message Schedular</span>
<span class="one">Read Report</span>
<span class="two">Contact Groups</span>
<span class="two">Mobile sender App</span>
<span class="two">Email support</span>
</div>
<a class="btn_buy_now" href="/user/signup/<?php echo $slab_ids[1]?>">BUY NOW</a>
</div>
</div>
<div class="col-md-3 plans_common">
<div class="plans_content">
<h2 class="plan_title">Gold</h2>
<div class="circle">
<span class="price">Rs. <?php echo $amount[2]?></span>
<span class="small-text">per month</span>
</div>
<div class="next-content">
<span class="one">Image Message</span>
<span class="two">Excel Message Upload</span>
<span class="two">User Feedback</span>
<span class="one">Phone support</span>
</div>
<a class="btn_buy_now" href="/user/signup/<?php echo $slab_ids[2]?>">BUY NOW</a>
</div>
</div>
<div class="col-md-3 plans_common">
<div class="plans_content">
<h2 class="plan_title">Platinum</h2>
<div class="circle">
<span class="price">Rs. <?php echo $amount[3]?></span>
<span class="small-text">per month</span>
</div>
<div class="next-content">
</div>
<a class="btn_buy_now" href="/user/signup/<?php echo $slab_ids[3]?>">BUY NOW</a> 
</div>
</div>

</div>
</div> -->

<!-- <div class="clients_main">
<div class="container-fluid">
<h1>Clients</h1>
<div class="col-md-3 outer_class">
<img src="../images/brands_04.png" class="img_class"/>
</div>
<div class="col-md-3 outer_class">
<img src="../images/images.png" class="img_class"/>
</div>
<div class="col-md-3 outer_class">
<img src="../images/logo_1428087229.png" class="img_class"/>
</div>
<div class="col-md-3 outer_class">
<img src="../images/serif-mycompany.png" class="img_class"/>
</div>
<div class="col-md-3 outer_class">
<img src="../images/brands_04.png" class="img_class"/>
</div>
<div class="col-md-3 outer_class">
<img src="../images/images.png" class="img_class"/>
</div>
<div class="col-md-3 outer_class">
<img src="../images/logo_1428087229.png" class="img_class"/>
</div>
<div class="col-md-3 outer_class">
<img src="../images/serif-mycompany.png" class="img_class"/>
</div>
</div>
</div> -->

<!--<div class="trynow_main">
<div class="container-fluid">
<h1>Franchisee</h1>
<p class="text">Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.</p>
<p class="btn_outer">{{ link_to('franchisee/signup', 'Signup for Franchisee', 'class': 'btn btn-primary btn-large btn-success') }}</p>
</div>
</div> -->
    <script>

        jQuery(document).ready(function ($) {
            var options = {
                $AutoPlay: true,                                    //[Optional] Whether to auto play, to enable slideshow, this option must be set to true, default value is false
                $AutoPlaySteps: 1,                                  //[Optional] Steps to go for each navigation request (this options applys only when slideshow disabled), the default value is 1
                $AutoPlayInterval: 2000,                            //[Optional] Interval (in milliseconds) to go for next slide since the previous stopped if the slider is auto playing, default value is 3000
                $PauseOnHover: 1,                                   //[Optional] Whether to pause when mouse over if a slider is auto playing, 0 no pause, 1 pause for desktop, 2 pause for touch device, 3 pause for desktop and touch device, 4 freeze for desktop, 8 freeze for touch device, 12 freeze for desktop and touch device, default value is 1

                $ArrowKeyNavigation: true,   			            //[Optional] Allows keyboard (arrow key) navigation or not, default value is false
                $SlideEasing: $JssorEasing$.$EaseOutQuint,          //[Optional] Specifies easing for right to left animation, default value is $JssorEasing$.$EaseOutQuad
                $SlideDuration: 800,                                //[Optional] Specifies default duration (swipe) for slide in milliseconds, default value is 500
                $MinDragOffsetToSlide: 20,                          //[Optional] Minimum drag offset to trigger slide , default value is 20
                //$SlideWidth: 600,                                 //[Optional] Width of every slide in pixels, default value is width of 'slides' container
                //$SlideHeight: 300,                                //[Optional] Height of every slide in pixels, default value is height of 'slides' container
                $SlideSpacing: 0, 					                //[Optional] Space between each slide in pixels, default value is 0
                $DisplayPieces: 1,                                  //[Optional] Number of pieces to display (the slideshow would be disabled if the value is set to greater than 1), the default value is 1
                $ParkingPosition: 0,                                //[Optional] The offset position to park slide (this options applys only when slideshow disabled), default value is 0.
                $UISearchMode: 1,                                   //[Optional] The way (0 parellel, 1 recursive, default value is 1) to search UI components (slides container, loading screen, navigator container, arrow navigator container, thumbnail navigator container etc).
                $PlayOrientation: 1,                                //[Optional] Orientation to play slide (for auto play, navigation), 1 horizental, 2 vertical, 5 horizental reverse, 6 vertical reverse, default value is 1
                $DragOrientation: 1,                                //[Optional] Orientation to drag slide, 0 no drag, 1 horizental, 2 vertical, 3 either, default value is 1 (Note that the $DragOrientation should be the same as $PlayOrientation when $DisplayPieces is greater than 1, or parking position is not 0)

                $ArrowNavigatorOptions: {                           //[Optional] Options to specify and enable arrow navigator or not
                    $Class: $JssorArrowNavigator$,                  //[Requried] Class to create arrow navigator instance
                    $ChanceToShow: 2,                               //[Required] 0 Never, 1 Mouse Over, 2 Always
                    $AutoCenter: 2,                                 //[Optional] Auto center arrows in parent container, 0 No, 1 Horizontal, 2 Vertical, 3 Both, default value is 0
                    $Steps: 1,                                      //[Optional] Steps to go for each navigation request, default value is 1
                    $Scale: false                                   //Scales bullets navigator or not while slider scale
                },

                $BulletNavigatorOptions: {                                //[Optional] Options to specify and enable navigator or not
                    $Class: $JssorBulletNavigator$,                       //[Required] Class to create navigator instance
                    $ChanceToShow: 2,                               //[Required] 0 Never, 1 Mouse Over, 2 Always
                    $AutoCenter: 1,                                 //[Optional] Auto center navigator in parent container, 0 None, 1 Horizontal, 2 Vertical, 3 Both, default value is 0
                    $Steps: 1,                                      //[Optional] Steps to go for each navigation request, default value is 1
                    $Lanes: 1,                                      //[Optional] Specify lanes to arrange items, default value is 1
                    $SpacingX: 12,                                   //[Optional] Horizontal space between each item in pixel, default value is 0
                    $SpacingY: 4,                                   //[Optional] Vertical space between each item in pixel, default value is 0
                    $Orientation: 1,                                //[Optional] The orientation of the navigator, 1 horizontal, 2 vertical, default value is 1
                    $Scale: false                                   //Scales bullets navigator or not while slider scale
                }
            };

            //Make the element 'slider1_container' visible before initialize jssor slider.
            $("#slider1_container").css("display", "block");
            var jssor_slider1 = new $JssorSlider$("slider1_container", options);

            //responsive code begin
            //you can remove responsive code if you don't want the slider scales while window resizes
            function ScaleSlider() {
                var bodyWidth = document.body.clientWidth;
                if (bodyWidth)
                    jssor_slider1.$ScaleWidth(Math.min(bodyWidth, 1920));
                else
                    window.setTimeout(ScaleSlider, 30);
            }
            ScaleSlider();

            $(window).bind("load", ScaleSlider);
            $(window).bind("resize", ScaleSlider);
            $(window).bind("orientationchange", ScaleSlider);
            //responsive code end
        });
        </script>

{{ stylesheet_link('css/menu_responsive_outer.css') }}