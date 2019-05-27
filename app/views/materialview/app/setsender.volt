<?php use Phalcon\Tag; ?>
  <!-- Modal Structure -->
  <div id="getsenderModal" class="modal bottom-sheet">
    <div class="modal-content">
         <form action="#">
            <p>
            <label class="col-md-4 control-label" for="sender_id">Enter SenderID (max 50 char)</label>
            </p>
             <p>
             <input type="text" name="sender_id" id="sender_id">
            </p>
    </form>
    </div>
    <div class="modal-footer">
      <a href="#!" class="modal-action modal-close waves-effect waves-green btn-flat "  onclick="new_senderID();">Agree</a>
    </div>
  </div>
  <script type="text/javascript">
function new_senderID()
{
  var name = $( "#sender_id" ).val();

  var dataString="name="+name;
   $.ajax({
      cache: false,
      type: "POST",
      dataType: 'json',
      url: "/senderid/new",
      data:dataString,
      success:  function(response){
       
        if(response['status']==='success'){

            $("a#createbtn").hide();
            $(".modal-content .modal-footer .btn-primary").removeAttr("disabled");
             Materialize.toast('SenderID Created', 3000);
                $("html, body").animate({ scrollTop: 0 }, "slow");
            $("#senderid span#senderid_value").text(response['senderID']['text']);
        }else{
             Materialize.toast('SenderID Not Created', 3000);
                $("html, body").animate({ scrollTop: 0 }, "slow");
        }
      }
    });
}
  </script>