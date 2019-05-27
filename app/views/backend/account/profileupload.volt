<?php use Phalcon\Tag; ?>
<!-- Image Crop -->
{{ stylesheet_link('ImageCropJs/croppie.css') }}
{{ javascript_include('ImageCropJs/croppie.js') }}

{{ stylesheet_link('ImageCropJs/sweetalert.css') }}
{{ javascript_include('ImageCropJs/sweetalert.min.js') }}

<!-- {{ stylesheet_link('ImageCropJs/style.css') }} -->
<!-- End image Crop -->
<div id="profile_upload" class="modal ">

    <div class="modal-dialog modal-lg">

        <div class="modal-content">

            <div class="modal-header">

                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

                <h4 class="modal-title">Upload Profile</h4>

            </div>

            <div class="modal-body">
            <div class="row">  
  <div class="col-lg-12" style="width:99%;overflow:auto;">
      <div style="border-radius:2px;">
            <!-- form -->
        <div class="demo-wrap upload-demo">
                    <div class="grid">
                        <div class="col-1-2">
                            <div class="actions">
                                <a class="btnn file-btn">
                                    <span>Browse Image</span>
                                    <input type="file" id="upload" value="Choose a file" accept="image/*" />
                                </a>
                                <button class="upload-result">Upload</button>
                            </div>
                        </div>
                        <div class="col-1-2">
                            <div class="upload-msg">
                                Browse a file to start cropping
                            </div>
                            <div id="upload-demo"></div>
                        </div>
                    </div>
      </div>
      <form action="/account/profileupload" id="form" method="post">
      <input type="hidden" id="imagebase64" name="imagebase64">
      </form>
    </div>
            <!-- END form -->
      </div>
  </div>
  <br />

</div>


            <div class="modal-footer">

                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>

            </div>

        </div>

    </div>

</div>
</div>
<script type="text/javascript">

    var $uploadCrop;

    function readFile(input) {
      if (input.files && input.files[0]) {
              var reader = new FileReader();
              
              reader.onload = function (e) {
                $uploadCrop.croppie('bind', {
                  url: e.target.result
                });
                $('.upload-demo').addClass('ready');
              }
              
              reader.readAsDataURL(input.files[0]);
          }
          else {
            swal("Sorry - you're browser doesn't support the FileReader API");
        }
    }

    $uploadCrop = $('#upload-demo').croppie({
      viewport: {
        width: 200,
        height: 200,
/*        type: 'circle'*/
      },
      boundary: {
        width: 300,
        height: 300
      },
      exif: true
    });

    $('#upload').on('change', function () { readFile(this); });

    $('.upload-result').on('click', function (ev) {
      console.log(ev);
      $uploadCrop.croppie('result', {
        type: 'canvas',
        size: 'viewport'
      }).then(function (resp) {
        $('#imagebase64').val(resp);
        popupResult({
          src: resp
        });
      });
    });
function popupResult(result) {

    var html;
    if (result.html) {
      html = result.html;
    }
    if (result.src) {
      html = '<img src="' + result.src + '" />';
    }
/*    swal({
      title: '',
      html: true,
      text: html,
      allowOutsideClick: true
    });*/
      console.log(html);
    
    swal({
      title: "",
      html: true,
      text: html,
      showCancelButton: true,
      confirmButtonColor: "#5cb85c",
      confirmButtonText: "Confirm",
      closeOnConfirm: false,
      allowOutsideClick: true
    },
    function(){
      $('#form').submit();
    });
    setTimeout(function(){
      $('.sweet-alert').css('margin', function() {
        var top = -1 * ($(this).height() / 2),
          left = -1 * ($(this).width() / 2);

        return top + 'px 0 0 ' + left + 'px';
      });
    }, 1);
  }
</script>