<?php use Phalcon\Tag; ?>
  <!-- Modal Structure -->
  <div id="myModal" class="modal">
    <div class="modal-content">
    <h4>Terms of service</h4>
         <form action="#">
            <p>
                <input  value="true" type="checkbox" id="checkbox1" name="checkbox1" />
                <label for="checkbox1"> I agree to the sancharapp <a target="_blank" href="/terms">Terms of Service</a></label>
            </p>
             <p>
                <input value="true" id="checkbox2" name="checkbox2" type="checkbox" />
                <label for="checkbox2">Enjoy premium features for limited period.</label>
            </p>
    </form>
    </div>
    <div class="modal-footer">
      <button class="waves-green btn-flat " onclick="submit_mefor_now();">Agree</button>
    </div>
  </div>
  <?php  $chk="user_id=".$auth['id'];
     $sender = SenderID::findFirst($chk);
     $sender_text=0;
if(count($sender)>0)
{
    if(isset($sender->text)){
        $sender_text=1;
     }
}
//echo "val=".$sender_text;
 
       ?>
  <script type="text/javascript">
  var sender_text=<?php echo $sender_text ?>;
function submit_mefor_now(){
    console.log('text');
    if($("#checkbox2").is(':checked') && $("#checkbox1").is(':checked')){

        console.log('text2');
        $.ajax({
        cache: false,
        type: "POST",
        data:"checkbox1="+$("#checkbox1").val()+"&checkbox2="+$("#checkbox2").val(),
        url: "/user/update_terms_status",
        success: function(response){
          response=JSON.parse(response);
          console.log(response);
          if(response['status'] == 'success')
            $('#myModal').closeModal();
          Materialize.toast(response["message"], 3000);
                $("html, body").animate({ scrollTop: 0 }, "slow");
            if(sender_text==false){
                 $('#getsenderModal').openModal();
            }      
         }
      });
     }else{
           Materialize.toast("Please check both option", 3000);
                $("html, body").animate({ scrollTop: 0 }, "slow");
     }
   }
</script>