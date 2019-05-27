<?php use Phalcon\Tag; ?>

<div id="plans" class="modal ">

    <div class="modal-dialog modal-lg">

        <div class="modal-content">

            <div class="modal-header">

                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>

                <h4 class="modal-title">Plans</h4>

            </div>

            <div class="modal-body">



            <div class="row">  
  <!--Responsive table section-->
  <div class="col-lg-12" style="width:99%;overflow:auto;">
      <div style="border-radius:2px;">
          <div class="table-responsive">
              <table class="table table-striped b-t b-light text-sm table-bordered ">
                <thead>


            <!--<div class="row">
            <table>-->
            <?php
               $slabs = Slabs::find(array(
                "status='Active' AND display=1",
                "order" => "amount"
            ));
                $slab_arr = array();
                foreach($slabs  as $i => $slab) {
                    $slab_arr[$i]['id'] = $slab->id;
                    $slab_arr[$i]['name'] = $slab->name;
                    $slab_arr[$i]['amount'] = $slab->amount;
                    $slab_arr[$i]['validity'] = $slab->validity;
                }
                ?>
                <tr class="danger">
                    <th>Feature</th>
                    <?php foreach($slab_arr as $plan){
                        echo '<th>'.$plan['name'].'</th>';
                    } ?>
                </tr>
                </thead>

                <tbody style="font-weight:500; font-size:12px">
                <tr>
                <th>Pricing</th>
                    <?php foreach($slab_arr as $plan){
                        if($plan['validity']==1)
                            $validity = '/month';
                        else
                            $validity = '/'.$plan['validity'].'month';
                        echo '<td><strong><span class="text-warning">&#8377;'.$plan['amount'].$validity.'</span></strong></td>';
                } ?>
                </tr>

                <?php $permissions = Permissions::find(array("display = 'Yes'"));
                  foreach($permissions as $permission){
                ?>
                <tr>
                    <td><b><?php echo ucfirst(str_replace('_',' ',$permission->feature)) ?></b></td>
                    <?php foreach($slab_arr as $plan){
                        $slab_value = SlabPermissions::findFirst("slab_id=".$plan['id']." AND permission_id=".$permission->id."");
                        switch ($permission->feature) {
                            case 'time_bound_delivery':
                                $arr=explode(',', $slab_value->value);
                                if($slab_value->value!="Yes" && $slab_value->value!="No")
                                    echo '<td class='.$slab_value->value.'>'.current($arr).' to '.end($arr).' (min)</td>';
                                else
                                    echo '<td class='.$slab_value->value.'>'.ucfirst(str_replace('_',' ',$slab_value->value)).'</td>';
                                break;
                            
                            default:
                               echo '<td class='.$slab_value->value.'>'.ucfirst(str_replace('_',' ',$slab_value->value)).'</td>';
                                break;
                        }
                        
                    } ?>
                </tr>                
            <?php } ?>
            </tbody>
            <!--</table>                

            </div>-->

            </table>
          </div>
      </div>
  </div>
  <br />
  <!--Responsive table section-->   
</div>








            <div class="modal-footer">

                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>

            </div>

        </div>

    </div>

</div>
</div>
<script type="text/javascript">
function change_plan(slab_id){
$('select#slab_id').val(slab_id);
$('#plans').modal('toggle');
}
</script>