<?php use Phalcon\Tag;
echo $this->getContent();
$auth = $this->session->get('auth');
$login_type=$auth['login_type'];
$franchisees = Franchisee::find();
  foreach ($franchisees as $franchisee) { 
        $availableTags[]=$franchisee->email;
  }
 if(count($franchisees)>0)
  $availableTags=json_encode($availableTags);
 else
  $availableTags=array();
?>
   {{ stylesheet_link('SlickGrid/slick.grid.css') }}
  {{ stylesheet_link('SlickGrid/controls/slick.pager.css') }}
  {{ stylesheet_link('SlickGrid/css/smoothness/jquery-ui-1.8.16.custom.css') }}
  {{ stylesheet_link('SlickGrid/slick-default-theme.css') }}
  {{ stylesheet_link('SlickGrid/examples.css') }} 
  
  {{ javascript_include('SlickGrid/lib/jquery.event.drag-2.2.js')}}
  {{ javascript_include('SlickGrid/slick.core.js')}}
  {{ javascript_include('SlickGrid/slick.grid.js')}}
  {{ javascript_include('SlickGrid/controls/slick.pager.js')}}
  {{ javascript_include('SlickGrid/slick.dataview.js')}}
  {{ javascript_include('SlickGrid/slick.editors.js')}}
  <!--{{ stylesheet_link('bootstrap/css/bootstrap-responsive.min.css') }}-->
  {{ javascript_include('js/common.js')}}
  {{ javascript_include('js/bootbox.min.js')}}

  {{ javascript_include('js/jquery-ui.min.js')}}

  {{ javascript_include('js/jquery.validate.min.js') }}
  {{ javascript_include('js/jquery-validate.bootstrap-tooltip.min.js') }} 
  {{ stylesheet_link('css/custom.css') }}
  
<div class="col-md-12 user_list_admin">
  <div class="page-header">
  <h2>User List</h2>
  </div>
</div>
  <div class="row user_list_admin_row">
    <div class="" id="userGrid_Filter" >
      <input type="text" id="all" name="all" size="35" class="filter_input" placeholder="search name,email,mobile">
      <input class="filter_input" size="35" id="franchisee" name="franchisee" type="text"  placeholder="franchisee" autocomplete="off" />

       <div class="btn-group" id="status_id">
       <button data-toggle="dropdown" class="btn btn-primary dropdown-toggle">
       <span class="dropdown-label">Status</span>
       <span class="caret"></span>
       </button>
       <ul class="dropdown-menu" role="menu">
       <li onclick="FilterStatus('Active')" ><a href="#">Active</a></li>
       <li onclick="FilterStatus('Inactive')"><a href="#">Inactive</a></li>
       <li onclick="FilterStatus('Pending')" ><a href="#">Pending</a></li>
       <li onclick="FilterStatus('Blocked')" ><a href="#">Blocked</a></li>
       </ul>
       </div>


       <a class="btn btn-primary " href="#" id="clearbtn"><span class="glyphicon glyphicon-refresh"></span> Refresh</a>
       <a href="{{ baseUri }}/user/new" class="btn btn-primary" id="createbtn"><span class="glyphicon glyphicon-plus"></span> Add User</a>   
  </div>
</div>
  <div id="userGrid" ></div>
  <div id="pager" style="width:100%;height:20px;"></div>
  <div id="loader" style="display:none;"><img src='/images/loading.gif' style='width: 150px;position: fixed;left: 42%;z-index: 1;top:40%;'></div>
  <script>
  var current_key="",current_status="",current_franchisee="";//,edit_status=false;
  var dataView,grid;
  var data=<?php echo $user; ?>;
  var login_type="<?php echo $login_type;?>";
  /*if(login_type=="Franchisee")
    $('input#franchisee').remove();
  else
    $('a#createbtn').remove();*/

  var availableTags =<?php print_r($availableTags);?>;

  /*if (login_type=='Super Admin')
    edit_status=true;*/
  
  $(document).ready(function() {
   
    var options = {
      enableCellNavigation:true,
      enableColumnReorder: false,
      multiColumnSort: true,
      autoHeight: true,
      //editable:edit_status,
      editable:true,
      autoEdit: false
    };

    function FilterAll(key){
    current_key =key;
    dataView.setPagingOptions({pageNum:0});
    dataView.refresh();
    }
    
    function FilterStatus(status){
    current_status = status;
    dataView.setPagingOptions({pageNum:0});
    dataView.refresh();
    }
    function FilterFranchisee(franchisee){
    current_franchisee = franchisee;
    dataView.setPagingOptions({pageNum:0});
    dataView.refresh();
    }
    function myFilter(item) {
    if (item["name"].toLowerCase().indexOf(current_key.toLowerCase()) == -1 && String(item["mobile"]).indexOf(String(current_key)) == -1 && item["email"].toLowerCase().indexOf(current_key.toLowerCase()) == -1){
        return false;
      }
    if (item["franchisee"].toLowerCase() != current_franchisee.toLowerCase() && current_franchisee != "") {
      return false;
    }   
    if (item["status"] != current_status && current_status != "") {
      return false;
    }
      return true;
  }

   var columns = [
    /*{id: "username", name:"Username", field:"username", cssClass:"username_class", sortable:true,headerCssClass:'username_header',  formatter:FormatterFirstname},*/
    {id: "lastname", name:"Name", field:"name", cssClass:"lastname_class", sortable:true,headerCssClass:'lastname_header',  formatter:FormatterLastname},    
    {id: "email", name:"Email", field:"email", cssClass:"email_class", sortable:true,headerCssClass:'email_header',  formatter:FormatterEmail, editor: Slick.Editors.Text},
    {id: "mobile", name:"Mobile", field:"mobile", cssClass:"mobile_class", sortable:false,headerCssClass:'mobile_header',  formatter:FormatterMobile, editor: Slick.Editors.Text},
    {id: "slab_id", name:"Plan", field:"slab_id", cssClass:"slab_id_class", sortable:true,headerCssClass:'slab_id_header',  formatter:FormatterSlab_id, editor: Slick.Editors.Text},
    {id: "expiry_date", name:"Expiry Date", field:"expiry_date", cssClass:"expiry_date_class", sortable:true,headerCssClass:'expiry_date_header',  formatter:FormatterExpiryDate, editor: Slick.Editors.Text},
    /*{id: "status", name:"Status", field:"status", cssClass:"status_class", sortable:true,headerCssClass:'status_header',  formatter:FormatterStatus,options: "Pending,Active,Blocked",editor:Slick.Editors.SelectCellStatusEditor, editor: Slick.Editors.Text},
    {id: "id", name:"", field:"id", cssClass:"id_class", sortable:false,headerCssClass:'id_header',  formatter:FormatterId}*/
    
  ];

  if (login_type=='Super Admin')
    var item1 = {id: "status", name:"Status", field:"status", cssClass:"status_class", sortable:true,headerCssClass:'status_header',  formatter:FormatterStatus,options: "Pending,Active,Blocked",editor:Slick.Editors.SelectCellStatusEditor};
  else
    var item1 = {id: "status", name:"Status", field:"status", cssClass:"status_class", sortable:true,headerCssClass:'status_header',  formatter:FormatterStatus,options: "Pending,Active,Blocked",editor:Slick.Editors.SelectCellStatusEditor, editor: Slick.Editors.Text};
  columns.push(item1);
  var cr_bal={id: "Crbalance", name:"Cr Balance", field:"balance", cssClass:"crbalanceclass", sortable:true,headerCssClass:'crbalance_header',  formatter:FormatterCrBalance};
  columns.push(cr_bal);

  var col_id = {id: "id", name:"", field:"id", cssClass:"id_class", sortable:false,headerCssClass:'id_header',  formatter:FormatterId};
  columns.push(col_id);
  
  /*function FormatterFirstname(row, cell, value, columnDef, dataContext) {
  return "<div class="+value+"><b>"+value+"</b></div>";
  }*/
  function FormatterLastname(row, cell, value, columnDef, dataContext) {
    var user = "<div class='lastname'><b>";
    if (login_type=='Super Admin')
        user += "<a href='/user/edit/"+dataContext['id']+"'>"+value+"</a>";
    else if (login_type=='Franchisee')
        user += "<a href='/user/view/"+dataContext['id']+"'>"+value+"</a>";
    user += "</b></div>";
    return user;
  }
  function FormatterMobile(row, cell, value, columnDef, dataContext) {
  return "<div class="+value+"><b>"+value+"</b></div>";
  }
  function FormatterExpiryDate(row, cell, value, columnDef, dataContext) {
  return "<div class="+value+"><b>"+value+"</b></div>";
  }
 /* function FormatterCredit_validity(row, cell, value, columnDef, dataContext) {
    var date=value.split(" ");
  return "<div class="+value+"><b>"+date[0]+"</b></div>";
  }*/
  function FormatterEmail(row, cell, value, columnDef, dataContext) {
    if(!value){
      value='';
    }
  return "<div class="+value+"><b>"+value+"</b></div>";
  }
  function FormatterSlab_id(row, cell, value, columnDef, dataContext) {
  return "<div><b>"+value+"</b></div>";
  }
  function FormatterStatus(row, cell, value, columnDef, dataContext) {
    if (login_type=='Super Admin')
        return "<div><span class="+value+" style='cursor:pointer;'><b>"+value+"</b></span></div>";
    else if (login_type=='Franchisee')
        return "<div><span class="+value+"><b>"+value+"</b></span></div>";  
  }
   function FormatterCrBalance(row, cell, value, columnDef, dataContext) {
  return "<div class="+value+"balance><b>"+value+"</b></div>";
  }
  function FormatterId(row, cell, value, columnDef, dataContext) {
    if(login_type=="Super Admin")
        return "<div class='btn-group'><a id='editbtn' onclick='updatecredit("+dataContext['id']+");' class='btn btn-success'>Credit</a><a  id='updatebtn' onclick='deposit("+value+");' href='#' class='btn btn-info'><i class='glyphicon glyphicon-arrow-up'></i></a><a id='editbtn' href=/user/edit/"+value+" class='btn btn-success'><i class='glyphicon glyphicon-pencil'></i></a><a onclick='return ConfirmDel("+value+");' id='cancelbtn' href='#' class='btn btn-danger'><i class='glyphicon glyphicon-remove'></i></a></div>";
    else
        return "<div class='btn-group'><a id='editbtn' onclick='updatecredit("+dataContext['id']+");' class='btn btn-success'>Credit</a><a id='listbtn' data-id="+value+" class='btn btn-primary'  href='/user/view/"+value+"'><i class='glyphicon glyphicon-list'></i> View</a><a  id='updatebtn' onclick='deposit("+value+");' href='#' class='btn btn-info'><i class='glyphicon glyphicon-arrow-up'></i></a></div>";
      /*onclick='update_plan("+value+");'*/
  }
  
    dataView = new Slick.Data.DataView({ inlineFilters: true });
    dataView.beginUpdate();
    dataView.setItems(data);
    dataView.setPagingOptions({pageSize:20});
    dataView.setFilter(myFilter);
    dataView.setFilterArgs(0);
    dataView.endUpdate();
    dataView.onRowCountChanged.subscribe(function (e, args) {
      grid.updateRowCount();
      grid.render();
    });
    dataView.onRowsChanged.subscribe(function (e, args) {
      grid.invalidateRows(args.rows);
      grid.render();
    });


   
    grid = new Slick.Grid("#userGrid", dataView, columns, options);
    var pager = new Slick.Controls.Pager(dataView, grid, $("#pager"));

     grid.onSort.subscribe(function (e, args) {
      var cols = args.sortCols;
      dataView.sort(function (dataRow1, dataRow2) {
        for (var i = 0, l = cols.length; i < l; i++) {
          var field = cols[i].sortCol.field;
          var sign = cols[i].sortAsc ? 1 : -1;
          var value1 = dataRow1[field], value2 = dataRow2[field];
          var result = (value1 == value2 ? 0 : (value1 > value2 ? 1 : -1)) * sign;
          if (result != 0) {
            return result;
          }
        }
        return 0;
      });
      grid.invalidate();
      grid.render();
    });

    grid.onBeforeEditCell.subscribe(function (e,args) { 
        old_status=args['item']['status'];
    });

    grid.onCellChange.subscribe(function (e,args) { 
          var id=args['item']['id'];
        bootbox.confirm("<h3 class='boot_dialog text-danger'>Are you sure?</h3>", function(stat) {
           if (stat){
                var result=args['item']['status'];
                if(result != null && result!=''){
                  var dataString=args['item'];
     
                  $.ajax({
                      cache:false,
                      type: "POST",
                      url: "/user/change_status/"+id,
                      data:dataString,
                      dataType: "json",
                      success:  function(response){
                      if(response=='success')
                        bootbox.alert('<h3 class="boot_dialog">Status Updated<h3>');
                        else
                        bootbox.alert('<h3 class="boot_dialog">Status Not Updated<h3>');
                      }
                  });
                
                }
          }else{
            var item = dataView.getItemById(id);
            item['status'] =old_status;
            dataView.updateItem(id, item);
          }
        });          
    });
    
      if(data.length===0){
        $('.grid-canvas').html('<div>No result found.</div>');
        $('.grid-canvas').css('height','50px');//380px
      }

     $("input#all").keyup(function(){
          var name = $(this).val();
          if(current_key != name || current_key != "" )
              FilterAll(name);
          });

    
          $('input#franchisee').autocomplete({
              source: availableTags,
              select: function(event, ui) {
                      //var name = $("input#franchisee").val();
                      var name = ui.item.value;
                      if(current_franchisee != name || current_franchisee != "" )
                          FilterFranchisee(name);
                          }
          });
    
     $("a#clearbtn").click(function(){
             $("input#all").val('');
             $("input#franchisee").val('');
             FilterAll("");
             FilterStatus("");
             FilterFranchisee("");
    });
  
  });
  /********************end document.ready***********************************************************/
function deposit(id)
{
  bootbox.dialog({
                title: "Upgrade Plan.",
                message: '<div id="deposit" class="row">  ' +
                    '<div class="col-md-12"> ' +
                    '<form method="POST" id="form2" name="form2" class="form-horizontal"> ' +

                    '<div class="form-group"> ' +
                    '<label class="control-label col-md-4" for="amount">Plan</label>' +
                    '<div class="col-md-5"> ' +
                    '<select class="input-md form-control" name="amount" id="amount">'+
                    <?php
                        $ss = Slabs::find(array(
                        "status='Active' AND amount!=0",
                        "order" => "amount"
                        ));
                       foreach ($ss as $s) {
                        if($s->validity==1)
                            $validity = '/month';
                        else
                            $validity = '/'.$s->validity.'month';
                        ?>
                      '<option value="<?php echo $s->amount;?>"><?php echo $s->name." (".$s->amount.") ".$validity;?></option>'+
                    <?php } ?>
                    '</select> <a href="#plans"  data-toggle="modal">View Plans</a>'+
                    '</div> ' +     
                    '</div> ' +  

                    '<div class="form-group"> ' +
                    '<label class="col-md-4 control-label" for="mode">Mode</label> ' +
                    '<div class="col-md-5"> ' +
                    '<select class=" input-md form-control" name="mode" id="mode">'+
                        '<option value="Cash">Cash</option>'+
                        '<option value="Cheque">Cheque</option>'+
                        '<option value="Online">Online</option>'+
                        '<option value="DD">DD</option>'+
                     '</select>' +

                    '</div> ' +     
                    '</div> ' +
                   
                    '<div class="form-group"> ' +
                    '<label class="control-label col-md-4" for="details">Details</label> ' +
                    '<div class="col-md-5"> ' +
                    '<input id="details" name="details" type="text" class="form-control input-md"> ' +
                    '</div> ' +     
                    '</div>' +

                               
                    '</form> </div>  </div>',
                buttons: {
                    success: {
                        label: "Upgrade",
                        className: "btn-success btn-lg",
                        callback: function () {
          
                           /**************************************************************************/
                          // console.log($('#form2').valid());
                          if($('#form2').valid()){
                               var item={};
                        
                               item['amount'] = $('#amount').val();
                               item['details'] = $('input#details').val();
                               item['mode'] = $('select#mode').val();
                            
                               $.ajax({
                                      type: "POST",
                                      url:"deposit/"+id,
                                      data:item,
                                      dataType: "json",
                                      success:  function(response){
                                             if(response['status']==='success')
                                                bootbox.alert('<h3 class="boot_dialog">Amount Deposited<h3>');
                                             else
                                                bootbox.alert('<h3 class="boot_dialog">Amount Not Deposited<h3><br><h4 class="text-danger boot_dialog">'+response['msg']+'<h4>');
                                    
                                      }
                                    });
                          }
                           /**************************************************************************/
                        }
                    },
                     danger: {
                    label: "Cancel",
                    className: "btn-danger btn-lg",
                    callback: function() {
                    $('.modal-dialog').modal('hide');
                    }
                    }, 
                }
            });
       
       valid_result=$("#form2").validate({
                  rules: {     
                   amount:{required:true,number:true,min:0},
                  },
                  tooltip_options: {
                     '_all_': { placement: 'right' }
                  }
              });   
    $("#deposit").css("z-index","9997");
    $("#plans").css("z-index","9998");
  }
  function update_plan(id)
{
  bootbox.dialog({
                title: "Update Plan.",
                message: '<div id="update_plan"class="row">  ' +
                    '<div class="col-md-12"> ' +
                    '<form method="POST" id="form3" name="form3" class="form-horizontal"> ' +

                    '<div class="form-group"> ' +
                    '<label class="col-md-4 control-label" for="slab_id">Plan</label> ' +
                    '<div class="col-md-6"> ' +
                    '<select class="input-md form-control" name="slab_id" id="slab_id">'+
                    <?php
                        $slabs = Slabs::find(array(
                        "status='Active' AND amount!=0",
                        "order" => "amount"
                        ));
                       foreach ($slabs as $slab) {?>
                        '<option value="<?php echo $slab->id;?>"><?php echo $slab->name." (".$slab->amount.")";?></option>'+
                    <?php } ?>
                    '</select> <a href="#plans"  data-toggle="modal">View Plans</a>'+

                    '</div> ' +     
                    '</div> ' +
                               
                    '</form> </div>  </div>',
                buttons: {
                    success: {
                        label: "Update",
                        className: "btn-success btn-lg",
                        callback: function () {
          
                           /**************************************************************************/
                               var slab_id= $('#slab_id').val();
                               $.ajax({
                                      type: "POST",
                                      url:"/user/update_plan/"+id,
                                      data:'slab_id='+slab_id,
                                      dataType: "json",
                                      success:  function(response){
                                             if(response['status']==='success'){
                                                 var item = dataView.getItemById(id);
                                                 item['slab_id'] =response['name'];
                                                 dataView.updateItem(item['id'], item);

                                                bootbox.alert('<h3 class="boot_dialog">Plan Updated<h3>');
                                             }else
                                                bootbox.alert('<h3 class="boot_dialog">Plan Not Updated<h3><br><h4 class="text-danger boot_dialog">'+response['msg']+'<h4>');
                                    
                                      }
                                    });
                         /**************************************************************************/
                        }
                    },
                     danger: {
                    label: "Cancel",
                    className: "btn-danger btn-lg",
                    callback: function() {
                    $('.modal-dialog').modal('hide');
                    }
                    }, 
                }
            });
    $("#update_plan").css("z-index","9997");
    $("#plans").css("z-index","9998");

  }
  function ConfirmDel(url)
    {
    bootbox.confirm("<h3 class='boot_dialog text-danger'>Are you sure?</h3>", function(result) {
           if (result){
            $.ajax({
                  type: "POST",
                  url:"/user/delete/"+url,
                  dataType: "json",
                  success:  function(response){
                    //console.log(response); return false;
                          if(response==='success'){
                          dataView.deleteItem(url);
                          bootbox.alert('<h3 class="boot_dialog">User Deleted<h3>');
                         }else{
                          bootbox.alert('<h3 class="boot_dialog">User Not Deleted<h3><br><h4 class="text-danger boot_dialog">'+response['msg']+'<h4>');
                         }
                
                  }
                });
          } 
        });
    }
    $.ajaxSetup({ 
      beforeSend: function(jqXHR,setting) { 
         $('#loader').show();
      },
      complete: function(xhr, status, error) {
        $('#loader').hide();
      } 
    });  
     function updatecredit(id)
{
 bootbox.dialog({
                title: "Credit Balance.",
                message: '<div id="franchisee_updatecredit"class="row">  ' +
                    '<div class="col-md-12"> ' +
                    '<form method="POST" id="form2" name="form2" class="form-horizontal"> ' +

                    '<div class="form-group"> ' +
                    '<label class="control-label col-md-4" for="time">Amount</label>' +
                    '<div class="col-md-4"> ' +
                    '<input id="amount" name="amount" type="text" class="form-control input-md" > ' +
                    '</div> ' +     
                    '</div> ' +  
                    '</form> </div>  </div>',
                buttons: {
                    success: {
                        label: "Transfer",
                        className: "btn-success",
                        callback: function () {
           
                           /*************************************************************************/
                          // console.log($('#form2').valid());
                          if($('#form2').valid()){
                             
                        var item={};
                               item['amount'] = $('input#amount').val();
                               item['details'] = "";
                               item['mode'] = "Online";
                               
                          $.ajax({
                                      type: "POST",
                                      url:"/user/upcredit/"+id,
                                      data:item,
                                      dataType: "json",
                                      success:  function(response){
                                        
                                             if(response['status']==='success'){ 
                                                var item = dataView.getItemById(id);
                                                item['balance'] =response['balance'];
                                                dataView.updateItem(item['id'],item); 
                                                bootbox.alert('<h3 class="boot_dialog">'+response['msg']+'<h3>');
                                               }else
                                                bootbox.alert('<h3 class="boot_dialog">Balance Not Transfer<h3><br><h4 class="text-danger boot_dialog">'+response['msg']+'<h4>');
                                    
                                      }
                                    });
                          }else{
                            return false;
                          }
                           /**************************************************************************/
                        }
                    },
                     danger: {
                    label: "Cancel",
                    className: "btn-danger",
                    callback: function() {
                    $('.modal-dialog').modal('hide');
                    }
                    }, 
                }
            });  

          var bal=<?php echo $balance; ?>;
           $("#form2").validate({
            rules: {     
             amount:{required:true,number:true,max:parseFloat(bal),min:0},
            },
            messages:{
             //amount:'Can\'t Withdraw more than',
            },
            tooltip_options: {
               '_all_': { placement: 'right' }
            }
        });  
}
  
  </script>
  

<?php $this->partial("modal/plans") ?>