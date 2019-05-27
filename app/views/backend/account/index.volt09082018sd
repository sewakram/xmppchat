<?php use Phalcon\Tag;
echo $this->getContent();
/*var_dump($this->getContent());
exit();*/
$auth = $this->session->get('auth');
$login_type=$auth["login_type"];
if($login_type=='Group Admin'){
  $users = new User();
  $user_permission = $users->getPermissions($auth['id']);
  $senderid = SenderID::findFirst("user_id=".$auth['id']);
}
?>
{{ stylesheet_link('css/custom.css') }}
{{ javascript_include('js/bootbox.min.js')}}
{{ javascript_include('js/jquery.validate.min.js') }}
{{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }}
{{ javascript_include('js/common.js') }}
<div id="acc_update">
    <div class="col-md-12">
    <div class="page-header">
            <h2>My Profile</h2>
    </div>
    </div>
<div class="row">
      <div id="btn_group" class="col-md-12">
            <a class='btn btn-primary btn-large' href='/account/update'><span class='glyphicon glyphicon-pencil'></span> Edit Profile</a>
             <a id="changebtn" class='btn btn-primary btn-large' href='/account/changePassword'><span class='glyphicon glyphicon-edit'></span> Change Password</a>
            <?php if($login_type=='Group Admin'){
                    /*echo "<a class='btn btn-primary btn-large' id='upgrade' onclick='upgrade($user->id);' href='#'><span class='glyphicon glyphicon-repeat'></span> Renew/Upgrade Plan</a> <a class='btn btn-primary btn-large' href='#plans' data-toggle='modal'><span class='glyphicon glyphicon-info-sign'></span> Plans</a>";*/
                    //if($user_permission['http_sms_forwarding_(3rd_party)']=='Yes')
                      //echo " <a class='btn btn-primary btn-large' href='/account/api'><span class='glyphicon glyphicon-envelope'></span> ThirdParty SMS API</a>";
                    //if($user_permission['image_message']=='Yes')
                      //echo "<a class='btn btn-primary btn-large' id='uploadbtn' href='/account/upload'><span class='glyphicon glyphicon-picture'></span> My Images</a> ";
                    if($user_permission['http_api']=='Yes')
                      echo "<a class='btn btn-primary btn-large' id='httpapibtn' href='/account/httpapi'><span class='glyphicon glyphicon-folder-open'></span>  HTTP API Docu.</a> ";
                    if(!$senderid)
                      echo ' <a id="createbtn" class="btn btn-primary" onclick="get_name();" href="#"><span class="glyphicon glyphicon-plus"></span> Create SenderID</a>';
                       }
                     ?>
      </div> <br/>

</div>

<div class="list_wrapper">
                  <div class="col-md-10 list-group">

                    <div class="list-group-item">
                    <span class="col-md-3" id="lbl">First Name</span>
                    <span class="col-md-9 lbl">
                    <?php echo $user->firstname?>
                    </span>
                    </div>

                    <div class="list-group-item">
                    <span class="col-md-3" id="lbl">Last Name</span>
                    <span class="col-md-9 lbl">
                    <?php echo $user->lastname;?>
                    </span>
                    </div>

                    <div class="list-group-item">
                    <span class="col-md-3" id="lbl">Mobile</span>
                    <span class="col-md-9 lbl">
                    <?php echo $user->mobile;?>
                    </span>
                    </div>

                    <div class="list-group-item">
                    <span class="col-md-3" id="lbl">Email </span>
                    <span class="col-md-9 lbl email_lbl">
                    <?php echo $user->email;?>
                    </span>
                    </div>

                    <?php if($login_type=="Franchisee"){ ?>
                    <div class="list-group-item admin group_admin">
                    <span class="col-md-3" id="lbl">Balance</span>
                    <span class="col-md-9 lbl"> &#8377;
                    <?php
                     echo $user->commission_balance;

                     ?>
                    </span>
                    </div>
                    <?php }?>

                     <?php  if($login_type=="Group Admin"){?>
                    <div class="list-group-item admin franchisee">
                    <span class="col-md-3" id="lbl">Plan</span>
                    <span class="col-md-9 lbl plan_lbl">
                    <?php if($user->expiry_date==null ||$user->expiry_date=="0000-00-00 00:00:00")
                        $expiry_date= '00-00-0000';
                    else
                        $expiry_date=(new DateTime($user->expiry_date))->format("d-m-Y");
                        echo $slabs->name."  <span class='text-danger'>(Expire on:".$expiry_date.")</span>";?></span>
                    </div>
                    <?php }?>


                    <?php if($login_type=='Group Admin'){ ?>
                    <div class="list-group-item" id="senderid">
                    <span class="col-md-3" id="lbl">Sender name </span>
                    <span class="col-md-9 lbl" id="senderid_value">
                    <?php if($senderid)
                        echo $senderid->text;
                    ?>
                    </span>
                    </div>

                    <div class="list-group-item" id="balance">
                    <span class="col-md-3" id="lbl">Balance</span>
                    <span class="col-md-9 lbl" id="balance_value">
                    <?php if($user->balance)
                        echo $user->balance;
                    ?>
                    </span>
                    </div>
                    <?php } ?>

                    <div class="list-group-item">
                    <span class="col-md-3" id="lbl">Organization</span>
                    <span class="col-md-9 lbl">
                    <?php echo $user->organization; ?>
                    </span>
                    </span>
                    </div>

                    <div style="height:80px;" class="list-group-item">
                    <span class="col-md-3" id="lbl">Address</span>
                    <span class="col-md-9 lbl">
                    <?php echo $user->address; ?>
                    </span>
                    </span>
                    </div>
                    <div class="list-group-item">
                    <span class="col-md-3" id="lbl">State</span>
                    <span class="col-md-9 lbl">
                    <?php echo $user->state; ?>
                    </span>
                    </span>
                    </div>


                     <div class="list-group-item">
                     <span class="col-md-3" id="lbl">City</span>
                     <span class="col-md-9 lbl">
                     <?php echo $user->city; ?>
                     </span>
                     </div>


                    <div class="list-group-item">
                    <span class="col-md-3" id="lbl">Pincode</span>
                    <span class="col-md-9 lbl">
                    <?php if($user->pincode!=0)echo $user->pincode; ?>
                    </span>
                    </div>

                    <div class="list-group-item">
                    <span class="col-md-3" id="lbl">Phone</span>
                    <span class="col-md-9 lbl">
                    <?php if($user->phone!=0)echo $user->phone; ?>
                    </span>
                    </div>

                    <?php if($login_type=='Group Admin'){
                          if($user_permission['pincode_message'] == 'Yes'){
                            $public_service= PublicService::findFirst("user_id=".$auth['id']."");
                     ?>
                    <div class="list-group-item" id="service_pincode">
                    <span class="col-md-3" id="lbl">Service Pincode</span>
                    <span class="col-md-9 lbl">
                    <?php if($public_service){ if($public_service->pincode){
                      $pincode=explode("=",$public_service->pincode);
                      if(isset($pincode[1]) && $pincode[1]!="null"){
                        $pincode_ids=implode(",", json_decode($pincode[1]));
                              switch ($pincode[0]) {
                                case 'district':
                                        $smt = $this->db->query("SELECT name FROM district WHERE id IN (".$pincode_ids.")");
                                    break;
                                case 'taluka':
                                        $smt = $this->db->query("SELECT name FROM taluka WHERE id IN (".$taluka_ids.")");
                                    break;
                                case 'pincode':
                                        $smt = $this->db->query("SELECT pin FROM pincode WHERE id IN (".$pincode_ids.")");
                                    break;
                                default:
                                    $smt= $this->db->query("SELECT name FROM state WHERE id IN (".$pincode_ids.")");
                                    break;
                            }

                        $smt->setFetchMode(PDO::FETCH_COLUMN,0);
                        $pincode=$smt->fetchAll();
                        $pincode_str=implode(",",$pincode);
                        echo "<p onclick='show_dataLocal(this);'> ".$pincode_str."</p>";
                    }
                    }}?>
                    </span>
                    </div>
                    <div class="list-group-item" id="welcome_msg">
                    <span class="col-md-3" id="lbl">Welcome Message</span>
                    <span class="col-md-9 lbl public_service_lbl">
                    <?php if($public_service){ echo "<p onclick='show_dataLocal(this);'>".$public_service->welcome_msg."</p>";}?>
                    </span>
                    </div>
                    <?php }} ?>
                    <!--for joint strat-->
                     <?php if($login_type=='Group Admin'){
                          if($user_permission['joint'] == 'Yes'){
                            ?>
                     <div class="list-group-item" id="joint">
                    <span class="col-md-3" id="lbl">Sancharapp id</span>
                    <span class="col-md-9 lbl">
                    <?php 
                        if($user->joint_handle){
                            echo "<p> ". $user->joint_handle."</p>";         
                        }
                    ?>
                    </span>
                    </div>
                    <?php }} ?>
                    <!--for joint end-->

             </div>
             <div class="col-md-2 logos">
              <div class="logo-admin">
                <?php if($login_type=='Manager') {
                  echo '<a href="#profile_upload" data-toggle="modal"><img class="img-responsive img-thumbnail" src="/profile/'.stristr($auth['jid'],"@",true).'.jpg?lastmod='.uniqid().'"/><span class="glyphicon glyphicon-pencil"></span></a>';
                }else 
                {
                  echo '<a href="#profile_upload" data-toggle="modal"><img class="img-responsive img-thumbnail" src="/logos/'.$logo->img_src.'?lastmod='.uniqid().'"/><span  class="glyphicon glyphicon-pencil"></span></a>';
                }
                ?>
              </div>
             </div>
            </div>

</div>


<script type="text/javascript">
    function upgrade(user_id)
{
  bootbox.dialog({
                title: "Renew/Upgrade Plan.",
                message: '<div id="upgrade" class="row">  ' +
                    '<div class="col-md-12"> ' +
                    '<form method="POST" id="form2" name="form2" class="form-horizontal"> ' +

                    '<div class="form-group"> ' +
                    '<label class="col-md-4 control-label" for="user_id">Plans</label> ' +
                    '<div class="col-md-6"> ' +
                    '<select class="input-md form-control" name="slab_id" id="slab_id">' +

                     "<?php
                     $slabs = Slabs::find(array("status='Active' AND display=1 AND amount!=0",'order' => 'amount'));
                          foreach ($slabs as $slab) {
                            if($slab->validity==1)
                              $validity = '/month';
                            else
                              $validity = '/'.$slab->validity.'month';
                            echo "<option value=$slab->amount>$slab->name  (&#8377; $slab->amount $validity)</option>";
                            echo "+";
                          } ?> "

                    +'</select></div> ' +
                    '<a href="#plans"  data-toggle="modal"><span class="glyphicon glyphicon-info-sign"></span> View Plans</a></div> ' +
                    '</form> </div>  </div>',
                buttons: {
                    success: {
                        label: "Upgrade",
                        className: "btn-success",
                        callback: function () {

                           /**************************************************************************/
                          var amount=$('#slab_id').val();
                          window.location.href="/user/makePayment/"+user_id+"/"+amount;
                        }
                           /**************************************************************************/

                    },
                    danger: {
                    label: "Cancel",
                    className: "btn-danger",
                    callback: function() {
                    $('.modal-dialog').modal('hide');
                    }
                    },
                }
            }
        );
 $("#upgrade").css("z-index","9997");
 $("#plans").css("z-index","9998");
}

function get_name()
{
  bootbox.prompt("Enter SenderID (max 50 char)", function(result) {
      if(result != null && result!=''){
        //var regex = /\d/g;
        //if(result.length <= 50 && regex.test(result)==false)
        if(result.length <= 50)
        new_senderID(result);
        else
        bootbox.alert('<h3 class="boot_dialog">Enter Valid SenderID<h3>');

      }
  });
}
function new_senderID(name)
{
  $(".modal-content .modal-footer .btn-primary").attr("disabled", "disabled");
  var dataString="name="+name;
  $.ajax({
      cache: false,
      type: "POST",
      url: "/senderid/new",
      dataType: "json",
      data:dataString,
      success:  function(response){
        if(response['status']==='success'){
            $("a#createbtn").hide();
            $(".modal-content .modal-footer .btn-primary").removeAttr("disabled");
            bootbox.alert('<h3 class="boot_dialog">SenderID Created<h3>');
            $("#senderid span#senderid_value").text(response['senderID']['text']);
        }else{
            bootbox.alert('<h3 class="boot_dialog">SenderID Not Created<h3>');
        }
      }
    });
}
function show_dataLocal(this_val){
  var html=$(this_val).text();
  show_data2(html);
}
</script>


<?php $this->partial("modal/plans") ?>
<?php $this->partial("account/profileupload") ?>