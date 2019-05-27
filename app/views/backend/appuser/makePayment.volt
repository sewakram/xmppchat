<?php use Phalcon\Tag;
echo $this->getContent();
?>  
  {{ stylesheet_link('css/custom.css') }}
  {{ javascript_include('js/jquery.validate.min.js') }}
  {{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }} 
  {{ stylesheet_link('css/custom.css') }} 
<div id="deposit">
    <div class="page-header">
    <h2>Deposit</h2>
    </div>
    <ul class="pager">
    <li class="previous pull-left">
        <a href="/index">← Go Back</a>    </li>
    </ul>
<div align="center">
    
<div class="container">
<div id="showloader"></div>
<div class="form_wrapper">
    <div id="show_amount"><b>Amount : &#8377; <?php echo $amnt; ?></b></div><br/>
    <div id="message"></div>
    <div id="unregisteredCardData">
        <div class="pm-button"><a href="https://www.payumoney.com/paybypayumoney/#/1F30EAB7E940FA5A2663C226F5C2A21C"><img src="https://www.payumoney.com//media/images/payby_payumoney/buttons/113.png" /></a></div>
        <?php //$plan = Slabs::findFirst("amount='".$amnt."' AND status='active'");

            /*if($amnt==1500)
              echo '<div class="pm-button"><a href="https://www.payumoney.com/paybypayumoney/#/EA27D9759DDDE6E5381979CE7E65498E"><img src="https://www.payumoney.com//media/images/payby_payumoney/buttons/113.png" /></a></div>';
            else if($amnt==5000)
              echo '<div class="pm-button"><a href="https://www.payumoney.com/paybypayumoney/#/3702DA382FC3AFC76E0AC7D2666A7C67"><img src="https://www.payumoney.com//media/images/payby_payumoney/buttons/113.png" /></a></div>';
            else if($amnt==10000)
              echo '<div class="pm-button"><a href="https://www.payumoney.com/paybypayumoney/#/E991FB6BBBC150A99E2B7849888776B8"><img src="https://www.payumoney.com//media/images/payby_payumoney/buttons/113.png" /></a></div>';*/
         ?>
    </div>

</div>

</div>
</div>

</div>
<script type="text/javascript">
   // $(document).ready(function(){
         /*$('#showloader').html('<img src="/images/loading.gif" width="200" height="200">');
         $('#payu-payment-form').submit();*/
    //});
</script>