<?php use Phalcon\Tag;
echo $this->getContent();
$auth = $this->session->get('auth');
$user_id= $auth['id'];
/*echo "<pre>";
print_r($permissions);
exit();*/
?>
  {{ javascript_include('js/jquery.validate.min.js') }}
  {{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }} 
  {{ javascript_include('js/common.js') }}
  {{ stylesheet_link('css/custom.css') }} 

<div id="slabs_edit">
<div class="col-md-12">
    <div class="col-md-6 page-header">
    <h2>Set Permission</h2>
    </div>
<div class="col-md-6 page-header">
    <ul class="pager">
    <li class="previous pull-right">
        <a href="/manager/index">← Go Back</a>    </li>
    </ul>
</div>
</div>
<div class="container">
<div class="form_wrapper">
  <form name="form1" id="form1" method="post" autocomplete="off" action="" class="form-horizontal" role="form">


<div class="col-sm-12 margin_bottom">
  <h3 class="text-left">Update permission for the Plans</h3><hr>
       <?php foreach ($permissions as $key => $value) { ?>
         <div class="form-group col-md-4">
        <label class="control-label" for="<?php echo $value['id'];?>"> <?php echo ucfirst(str_replace('_',' ',$value['feature']));?></label>
         <div class="input-outer pull-left">
          <span class="pull-left check_box" style="clear:left;">
            <input class="input_checkbox" type="checkbox" name="<?php echo $value['id']; ?>" id="<?php echo $value['id']; ?>" value="Yes"
            <?php if($value['value']=='Yes') echo "checked"; ?> >
            <span class="plan_value<?php echo $value['id']; ?> common">
              <?php if($value['value']!='Yes' && $value['value']!='No'){ ?>
                <span class="input_<?php echo $value['id']; ?>">
                  <input type="text" name="plan_<?php echo $value['id']; ?>" id="plan_<?php echo $value['id']; ?>" value="<?php echo ucfirst(str_replace('_',' ',$value['value'])); ?>" /><a href="#!" onclick="hideInput('<?php echo $value['id']; ?>')">X</a>
                </span>
              <?php }else{ ?>              
                  <a href="#!" onclick="showInput('<?php echo $value['id']; ?>')" class="link'<?php echo $value['id']; ?>'">Add Value</a>
              <?php } ?>  
            </span>
          </span>
          </div></div>
      <?php } ?>
</div>
<div class="col-sm-12 margin_bottom">
     <button type="submit" class="btn btn-success btn-lg blue"><span class="glyphicon glyphicon-ok"></span> Update</button>
     <a href="/slabs/index" class='btn btn-primary btn-lg red'><span class='glyphicon glyphicon-remove-sign'></span>  Cancel</a>
  </div>
</form>
</div>

</div>

</div>
</div>
<SCRIPT TYPE="text/javascript">
  //$("[name='status'],[name='display']").bootstrapSwitch();
  $(document).ready(function() {
    $("#form1").validate({
        rules: {  
         amount:{number:true},
         validity:{digits:true},
        },
        tooltip_options: {
           '_all_': { placement: 'right' }
        }
    });
  });
</SCRIPT>