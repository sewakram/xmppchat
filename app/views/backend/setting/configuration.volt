<?php use Phalcon\Tag;
echo $this->getContent();
$auth = $this->session->get('auth');
?>
  {{ javascript_include('js/jquery.validate.min.js') }}
  {{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }} 
  {{ stylesheet_link('css/custom.css') }}
<div id="configuration">
  <div class="col-md-12">
    <div class="col-md-6 page-header">
    <h2>Configuration</h2>
    </div>
  </div>
    <form name="form1" id="form1" method="post" autocomplete="off" action="" class="form-horizontal" enctype="multipart/form-data" role="form">
<div class="container">
  <div class="col-md-12 form_wrapper" >
    <div class="col-md-5">
  <div class="form-group">
    <label class="control-label col-sm-4" for="app_access_days">App Access Days</label>
    <div class="col-sm-4">
      <input type="text" name="app_access_days" class="form-control" id="app_access_days" value="<?php echo $config->app_access_days;?>" required>
    </div>
  </div>
  <div class="form-group">
    <label class="control-label col-sm-4" for="welcome_msg">App Welcome Message</label>
    <div class="col-sm-12">
      <textarea style="height: 175px;" row="5" class="new-class form-control" placeholder="required" name="welcome_msg" id="welcome_msg" required><?php echo strip_tags($config->welcome_msg);?></textarea>
    </div>
  </div>
  <div class="form-group">
    <label class="control-label col-sm-4" for="icon">App Profile Icon</label>
    <div class="col-sm-4 text-left">
       <?php 
        echo '<img class="img-responsive img-thumbnail" src="/profile/'.stristr($auth['jid'],"@",true).'.jpg"/><input type="file" id="logo" accept="image/*" name="logo" alt="logo">';
       ?>
    </div>
  </div>
   </div>
   <div class="col-md-2"></div>
<div class="col-md-5">
  <div class="form-group">
    <label class="control-label col-sm-4" for="app_access_days">Last local Server Access Datetime</label>
    <div class="col-sm-8">
      <input type="text" name="last_local_access_datetime" class="form-control" id="last_local_access_datetime" value="<?php echo (new DateTime($config->last_local_access_datetime))->format("d-m-Y h:i A");?>" readonly>
    </div>
  </div>
  <div class="form-group">
    <label class="control-label col-sm-4" for="sms_request_limit">SMS request limit</label>
    <div class="col-sm-8">
      <input type="text" name="sms_request_limit" class="form-control" id="sms_request_limit" value="<?php echo $config->sms_request_limit;?>">
    </div>
  </div>
      <div class="form-group">
            <label class="control-label" for="status" class="control-label">Server sms processing status</label><div class="input-outer pull-left">
               <input data-on-text="Enable" data-off-text="Disable" data-on-color="success" data-off-color="danger" data-handle-width='70' data-animate="true" type="checkbox" id="server_sms_processing_status" name="server_sms_processing_status" 
               <?php if($config->server_sms_processing_status=="1") echo 'checked';?>/>              
     </div>
     </div>
    </div>
  <div class="col-sm-10">
    <button type="submit" class="btn btn-success btn-lg"><span class="glyphicon glyphicon-ok"></span> Update</button>
  </div>
</div>
</div>
</form>
</div>
<SCRIPT TYPE="text/javascript">
 $(document).ready(function() {
   
        $("#form1").validate({
        rules: {     
           app_access_days:{digits:true},
        },
        tooltip_options: {
           '_all_': { placement: 'right' }
        }
    });
});

</SCRIPT>