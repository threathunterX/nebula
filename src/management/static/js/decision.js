var tb_decision = null;

function refresh_and_hide_modal() {
    if (tb_decision != null) {
      tb_decision.refresh();
    }

  $("#edit_modal").modal('hide'); 
}

$("#edit_modal_apply_add").click(function() {
  sync_post_modify_and_refresh("/management/data/decisioncols?a=add", 
  get_modal_all_item_vals($("#edit_modal_box_body")), 
  refresh_and_hide_modal)
})


$("#edit_modal_apply_del").click(function() {
  sync_post_del_and_refresh("/management/data/decisioncols?a=del", 
    get_modal_all_item_vals($("#edit_modal_box_body")), 
    refresh_and_hide_modal)
})

$("#edit_modal_apply_modify").click(function() {
  sync_post_modify_and_refresh("/management/data/decisioncols?a=mdf", 
    get_modal_all_item_vals($("#edit_modal_box_body")), 
    refresh_and_hide_modal)
})


$('#edit_modal').on('show.bs.modal', function (e) {
  var coldatas = e.relatedTarget.coldatas
  var addnew = e.relatedTarget.addnew
  var filter = e.relatedTarget.filter
  var del = e.relatedTarget.del;

  if (coldatas != null) {
    $("#edit_modal_item_id").val($(coldatas[0]).text())
    $("#edit_modal_item_name").val($(coldatas[1]).text())
    $("#edit_modal_item_category").val($(coldatas[2]).text())
    
    
    
  } else {
    clear_modal_item_vals($("#edit_modal_box_body"))
  }

  $("#edit_modal_apply_add").hide()
  $("#edit_modal_apply_modify").hide()
  $("#edit_modal_apply_del").hide()

  if (del == true) {
    $("#edit_modal_apply_del").show()
  }  else if (addnew == true) {
    $("#edit_modal_apply_add").show()
  } else {
    $("#edit_modal_apply_modify").show()
  }
})


$(function() {
  
  tb_decision = TableCtrl.create2("/management/data/decisioncols", "decision_table", null);
  tb_decision.refresh();


  $('#decision_table').on("click", '#op_edit', function()   {
      var row = $($("#decision_table tr.onselect")[0])
      var cols = row.find('td')

      $('#edit_modal').modal({show:true}, {
        addnew : false,
        coldatas : $(cols)
      });
  });

  $('#decision_table').on("click", '#op_del', function()   {
      var row = $($("#decision_table tr.onselect")[0])
      var cols = row.find('td')

      $('#edit_modal').modal({show:true}, {
        del : true,
        addnew : false,
        coldatas : $(cols)
      });
  });

  $("#decision_table_add").click(function(){
    $('#edit_modal').modal({show:true}, {
        addnew : true
    });
})



});