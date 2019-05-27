<?php use Phalcon\Tag;
echo $this->getContent();
$auth = $this->session->get('auth');
$login_type=$auth['login_type'];
?>
  {{ stylesheet_link('css/custom.css') }}
  {{ javascript_include('js/jquery.validate.min.js') }}
  {{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }} 
<div id="deposit">
    <div class="page-header">
    <h2>Deposit</h2>
    </div>
    <ul class="pager">
    <li class="previous pull-left">
        <a href="/user/index">← Go Back</a>    </li>
    </ul>
<div align="center">
    
<div class="container">
<div class="form_wrapper">
 <form name="form1" id="form1" method="post" autocomplete="off" action="" class="form-horizontal" role="form">
  
  <!-- <div id="franchisee" class="form-group">
    <label class="control-label col-sm-3" for="franchisee">Franchisee</label>
    <div class="col-sm-8">
      <select class="form-control" name="franchisee" id="franchisee">
           <?php $franchisees = Franchisee::find();
                foreach ($franchisees as $franchisee) { 
                echo "<option value=".$franchisee->id.">".$franchisee->username."</option>";   
                 } ?> 
         </select>
    </div>
  </div> -->
 

 
           
  <div class="form-group">
    <label class="control-label col-sm-3" for="time">Amount</label>
    <div class="col-sm-8">
      <input type="text" name="amount" class="form-control" id="amount" required>
    </div>
  </div>

  <div class="form-group">
         <label class="control-label col-sm-3" for="mode">Mode</label>
         <div class="col-sm-8">
         <select class="form-control" name="mode" id="mode">
            <option value="Cash">Cash</option>
            <option value="Cheque">Cheque</option>
            <option value="Online">Online</option>
            <option value="DD">DD</option>
         </select>
         </div>
    </div>
    
    <div class="form-group">
    <label class="control-label col-sm-3" for="details">Details</label>
    <div class="col-sm-8">
      <input type="text" name="details" class="form-control" id="details">
    </div>
  </div>

<input type="submit" class="btn btn-success" value="Deposit" form="form1">
<input type="reset" class="btn btn-primary" value="Cancel">
</form>
</div>

</div>
</div>

</div>
<SCRIPT TYPE="text/javascript">
/*var login_type="<?php echo $login_type;?>";
  if(login_type !='Super Admin')
    $("div#franchisee").remove();*/
var min_slabs="<?php echo $slabs;?>";
 $(document).ready(function() {
    
    /*$("select#franchisee ").change(function(){
        fran_id=$(this).val();
        $("select#user option").hide();
        $("select#user option[data-id='"+fran_id+"']").show();
        $("select#user").prepend("<option disabled selected>select user</option>");
     });*/

   
    $("#form1").validate({
        rules: {     
         amount:{number:true,min:parseFloat(min_slabs)},
        },
        messages:{
         //amount:'Enter Valid Amount',
        },
        tooltip_options: {
           '_all_': { placement: 'right' }
        }
    });
});

</SCRIPT>