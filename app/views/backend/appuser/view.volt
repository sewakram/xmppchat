<?php use Phalcon\Tag;
echo $this->getContent();
$auth = $this->session->get('auth');
?>
{{ stylesheet_link('css/custom.css') }}
<div id="useredit">
    <div class="page-header">
    <h2>User Details</h2>
    </div>
<ul class="pager">
    <li class="previous pull-left">
        <a href="/user/index">← Go Back</a>    </li>
</ul>
              <div style="min-width: 275px;width: 50%;" class="list_wrapper">
                  <div class="list-group">

                    <div class="list-group-item"><span id="lbl">First Name</span><span class="pull-right"><span class="lbl"><?php echo $user->firstname?></span></span></div>

                    <div class="list-group-item"><span id="lbl">Last Name</span> <span class="pull-right"><span class="lbl"><?php echo $user->lastname;?></span></span></div>

                    <div class="list-group-item"><span id="lbl">Mobile</span><span class="pull-right"><span class="lbl"><?php echo $user->mobile;?>  </span></span></div>


                    <div class="list-group-item"><span id="lbl">Email </span><span class="pull-right"><span class="lbl"> <?php echo $user->email;?></span></span></div>

                    <div class="list-group-item"><span id="lbl">Plan</span><span class="pull-right"> <span class="lbl"> <?php echo $slabs->name;?></span></span></div>


                    <div class="list-group-item"><span id="lbl">Expire on</span><span class="pull-right"> <span class="lbl"> <?php echo 
                      (new DateTime($user->expiry_date))->format("d-m-Y"); ?></span></span></div>


                    <div class="list-group-item"><span id="lbl">Organization</span><span class="pull-right"> <span class="lbl"> <?php echo $user->organization; ?></span></span></div>
                    
                    <div style="height:80px;" class="list-group-item"><span id="lbl">Address</span><span class="pull-right"> <span class="lbl"> <?php echo $user->address; ?></span></span></div>

                    <div class="list-group-item"><span id="lbl">State</span><span class="pull-right"><span class="lbl"> <?php echo $user->state; ?></span></span></div>


                    <div class="list-group-item"><span id="lbl">City</span><span class="pull-right"> <span class="lbl"> <?php echo $user->city; ?></span></span></div>

                    <div class="list-group-item"><span id="lbl">Pincode</span><span class="pull-right"> <span class="lbl"> <?php echo $user->pincode; ?></span></span></div>

                    <div class="list-group-item"><span id="lbl">Phone</span><span class="pull-right"> <span class="lbl"> <?php if($user->phone!=0) echo $user->phone; ?></span></span></div>

                  </div>
             </div>

 
</div>


