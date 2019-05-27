<?php use Phalcon\Tag as Tag;
  echo $this->getContent();
  $auth = $this->session->get('auth');
  $login_type=$auth['login_type'];
  $tmp = array();
  // select default
  $sortDefault = 'id';

  // select array
  $sortColumns = array('email','sender_id','mobile','route','date','status');

  // define sortable query ASC DESC
  $sort = (isset($_GET['sort'])) && in_array($_GET['sort'], $sortColumns) ? $_GET['sort']: $sortDefault;
  $order = (isset($_GET['order']) && strcasecmp($_GET['order'], 'DESC') == 0) ? 'DESC' : 'ASC'; 
  $url = '/reports/index';
  if(isset($_GET['sort']) && isset($_GET['order'])){
      $url = '/reports/index?sort='.$_GET['sort'].'&order='.$_GET['order'];
  }
?>
  {{ javascript_include('js/common.js')}}
  {{ javascript_include('js/bootbox.min.js')}}
  {{ stylesheet_link('DateTimePicker/jquery.datetimepicker.css') }}
  {{ javascript_include('DateTimePicker/jquery.datetimepicker.js')}}
  {{ javascript_include('js/jquery-ui.min.js')}}
  {{ stylesheet_link('css/custom.css') }}
<script type="text/javascript">
  $(document).ready(function() {

   $('#start_date').datetimepicker({
        timepicker:false,
        scrollInput: false,
        format:'Y-m-d',
    });
    $('#end_date').datetimepicker({
        timepicker:false,
        scrollInput: false,
        format:'Y-m-d',
    });
  $("a#download").click(function (){
       JSON2CSV(window.tmp,"linkappMsgReports_"+ new Date().toJSON().slice(0,10),"xls");
  });
  });

</script>
<div class="col-md-12 message_report">
<div class="page-header">
  <h2>Message Reports</h2>
</div>
</div>
<div class="col-md-12 reportsgrid_filter_outer">
<div class="row">
  <form action="/reports/index" method="post">
    <div style="display: table;float:left;" class="" id="reportsGrid_Filter" >
      <div style="display:inline-block;" class="pull-left outer">
      <?php $display_user_filter=''; if($login_type=='Group Admin') $display_user_filter = 'hide' ;?>
      <?php echo Tag::textField(array("mobile", "size" => 13, "class"=>"filter_input", "placeholder"=>"mobile")) ?>
      <?php echo Tag::textField(array("user", "size" => 30, "class"=>"filter_input ".$display_user_filter, "placeholder"=>"User")) ?>
       <div class="btn-group" id="status_id">
          <?php echo Tag::select(array("status", array("Read" => "Read","Delivered" => "Delivered","Sent" => "Sent","Pending" => "Pending" ,"Failed" => "Failed", "Scheduled" => "Scheduled"), 'useEmpty' => true, 'emptyText' => 'Select Status', 'emptyValue' => '', "class" => "filter_input")) ?> 
       </div>
      <div class="btn-group" id="route">
          <?php echo Tag::select(array("route", array("SMS" => "SMS", "Notification" => "Sancharapp"), 'useEmpty' => true, 'emptyText' => 'Select Route', 'emptyValue' => '', "class" => "filter_input")) ?> 
      </div> 
      <a id="download" href="#" class="btn btn-primary "><span class="glyphicon glyphicon-download-alt"></span> Download</a>
      </div>
      <div class="range_btn pull-left">
        <div class="input-group">
         <span class="input-group-addon">From</span>
         <?php echo Tag::textField(array("start_date", "class"=>"form-control", "placeholder"=>"Start Date", "size"=>25)) ?>
         <span class="input-group-addon">To</span>
         <?php echo Tag::textField(array("end_date", "class"=>"form-control", "placeholder"=>"End Date", "size"=>25)) ?>
        </div>
      </div>      
      <div class="pull-left outer_third"><input type="submit" name="submit" value="Get Reports"/></div>
    </div>

  </form>
</div>
</div>
<div style="clear:both"></div>

<div id="reportsGrid">
  <table class="table table-bordered table-striped" align="center">
    <thead>
        <tr>
          <?php if($login_type!="Group Admin"){?>
            <th><a href='?sort=email&order=<?php echo $order == 'DESC' ? 'ASC' : 'DESC' ?>'>User
            <?php if(isset($_GET['sort']) && isset($_GET['order'])){
                    if($_GET["order"]=="ASC" && $_GET["sort"]=="email"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/asc.gif" width="20px" height="6px">';
                    }elseif($_GET["order"]=="DESC" && $_GET["sort"]=="email"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/desc.gif" width="20px" height="6px">';
                    }else
                      echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  }else{
                    echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  }
            ?></a></th>
            <?php } ?>
            <th><a href='?sort=sender_id&order=<?php echo $order == 'DESC' ? 'ASC' : 'DESC' ?>'>Sender Id
            <?php if(isset($_GET['sort']) && isset($_GET['order'])){
                    if($_GET["order"]=="ASC" && $_GET["sort"]=="sender_id"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/asc.gif" width="20px" height="6px">';
                    }elseif($_GET["order"]=="DESC" && $_GET["sort"]=="sender_id"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/desc.gif" width="20px" height="6px">';
                    }else
                      echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  }else{
                    echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  } 
            ?></a></th>
            <th><a href='?sort=mobile&order=<?php echo $order == 'DESC' ? 'ASC' : 'DESC' ?>'>Mobile
            <?php if(isset($_GET['sort']) && isset($_GET['order'])){
                    if($_GET["order"]=="ASC" && $_GET["sort"]=="mobile"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/asc.gif" width="20px" height="6px">';
                    }elseif($_GET["order"]=="DESC" && $_GET["sort"]=="mobile"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/desc.gif" width="20px" height="6px">';
                    }else
                      echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  }else{
                    echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  } 
            ?></a></th>
            <th>Message</th>
             <th><a href='?sort=route&order=<?php echo $order == 'DESC' ? 'ASC' : 'DESC' ?>'>Route
            <?php if(isset($_GET['sort']) && isset($_GET['order'])){
                    if($_GET["order"]=="ASC" && $_GET["sort"]=="route"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/asc.gif" width="20px" height="6px">';
                    }elseif($_GET["order"]=="DESC" && $_GET["sort"]=="route"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/desc.gif" width="20px" height="6px">';
                    }else
                      echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  }else{
                    echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  } 
            ?></a></th>
            <th><a href='?sort=datetime&order=<?php echo $order == 'DESC' ? 'ASC' : 'DESC' ?>'>Date
            <?php if(isset($_GET['sort']) && isset($_GET['order'])){
                    if($_GET["order"]=="ASC" && $_GET["sort"]=="datetime"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/asc.gif" width="20px" height="6px">';
                    }elseif($_GET["order"]=="DESC" && $_GET["sort"]=="datetime"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/desc.gif" width="20px" height="6px">';
                    }else
                      echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  }else{
                    echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  } 
            ?></a></th>
            <th><a href='?sort=status&order=<?php echo $order == 'DESC' ? 'ASC' : 'DESC' ?>'>Status
            <?php if(isset($_GET['sort']) && isset($_GET['order'])){
                    if($_GET["order"]=="ASC" && $_GET["sort"]=="status"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/asc.gif" width="20px" height="6px">';
                    }elseif($_GET["order"]=="DESC" && $_GET["sort"]=="status"){
                      echo '<IMG id="IMG0" name="IMG0" src="/images/desc.gif" width="20px" height="6px">';
                    }else
                      echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  }else{
                    echo '<IMG id="IMG0" name="IMG0" src="/images/bg.gif" width="20px" height="9px">';
                  } 
            ?></a></th>
        </tr>
    </thead>
    <tbody>
    <?php
        if(!empty($page->items)){
            foreach($page->items as $i => $report){
              $tmp[$i]['sender_id'] = $report['sender_id'];
              $tmp[$i]['mobile'] = $report['mobile'];
              $tmp[$i]['text'] = $report['text'];
              $tmp[$i]['datetime'] = $report['datetime'];
              $tmp[$i]['status'] = $report['status'];
              
              $route_current=$report['route'];
              if($route_current!="SMS")
                $route_current="Sancharapp";

               $tmp[$i]['route'] = $route_current;
              $arr = array();
              $arr['text'] = $report['text']; 
              $arr['multimedia'] = base64_encode($report['multimedia']);
              $user = User::findFirstById($report['user_id']); ?>
        <tr>
            <?php if($login_type=="Super Admin"){
              echo '<td><b><a href="/user/edit/'.$report['user_id'].'" style="color: #666666;">'.$report['email'].'</a></b></td>';
              }
            ?> 
            <td contenteditable><b><?php echo $report['sender_id']; ?></b></td>
            <td contenteditable><b><?php echo $report['mobile']; ?></b></td>
            <td>
             <?php if($report['text']==""){
              $short_desc="Image";
             }else{
              $short_desc=substr($report['text'],0,30);
             }
             echo "<span>$short_desc</span>";
             ?>
            <b><a class="pull-right" href="#" onclick='show_msg(<?php echo json_encode($arr) ?>)'>View Details</a></b></td>
            <td contenteditable><b><?php echo $route_current ?><b></td>
            <td contenteditable><b><?php echo date("d-m-y H:i:s",strtotime($report['datetime'])); ?></b></td>
            <td contenteditable><span class="<?php echo $report['status'] ?>"><b><?php echo $report['status'] ?></b></span></td>
        </tr>

    <?php }
      $tmp2= json_encode($tmp);
        }else{ ?>
          <tr><td colspan="7" align="center"><b>
            No Reports are recorded
          </b></td></tr>
        <?php } ?>
    </tbody>
    <tbody>
        <tr>
            <td colspan="7" align="right">
                <div class="btn-group">
                    <?php if(isset($_GET['sort'])) $append = $url."&"; else $append = $url."?"; ?>
                    <!-- <select>
                      <option value="10"><a href="">10</option>
                      <option value="20">20</option>
                      <option value="50">50</option>
                      <option value="100">100</option>
                      <option value="all">All</option>
                    </select> -->
                    <a href="<?php echo $append.'page='.$page->first ?>" class="btn"><i class="icon-fast-backward"></i> First</a>
                    <a href="<?php echo $append."page=".$page->before ?>" class="btn"><i class="icon-step-backward"></i> Previous</a>
                    <a href="<?php echo $append."page=".$page->next ?>" class="btn"><i class="icon-step-forward"></i> Next</a>
                    <a href="<?php echo $append."page=".$page->last ?>" class="btn"><i class="icon-fast-forward"></i> Last</a>
                    <span class="help-inline"><b><?php echo $page->current, " of ", $page->total_pages ?></b></span>
                </div>
            </td>
        </tr>
    <tbody>
  </table>
</div>
<script type="text/javascript">
  tmp=<?php echo $tmp2 ?>;
</script>