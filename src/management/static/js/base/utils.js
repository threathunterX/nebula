function table_add_default_operate(rows, fcols) {
     rows.data.forEach(function(row) {
                  row.op = '<button id="op_edit" class="btn btn-primary btn-xs">&nbsp;编辑</button>',
                  row.op += '&nbsp;&nbsp;<button id="op_del" class="btn btn-danger btn-xs">&nbsp;删除</button>';
      });

     fcols.push({"data":"op"})
}

function table_add_default_operate2(datas, fcols) {
     datas.forEach(function(row) {
                  row.op = '<button id="op_edit" class="btn btn-primary btn-xs">&nbsp;编辑</button>',
                  row.op += '&nbsp;&nbsp;<button id="op_del" class="btn btn-danger btn-xs">&nbsp;删除</button>';
      });

     fcols.push({"data":"op"})
}


function process_active_col(r) {
  r.data.forEach(function(row) {
    if ("1" == row.active) {
        row.active = '<a class="label label-success label-xs">激活</a>'
    } else if ("0" == row.active) {
        row.active = '<a class="label label-warning label-xs">失效</a>'
    } else {
        row.active = '<a class="label label-danger label-xs">unknown</a>'
    }

    if (row.ftype != null) {
      if ("1" == row.ftype) {
          row.ftype = '<a class="label label-warning label-xs">ip</a>'
      } else if ("2" == row.ftype) {
          row.ftype = '<a class="label label-warning label-xs">dev</a>'
      } else if ("3" == row.ftype) {
          row.ftype = '<a class="label label-warning label-xs">user</a>'
      } else {
          row.ftype = '<a class=" abel label-danger label-xs">unknown</a>'
      }
     
    }

  });
}

function clear_modal_item_vals(boxbody) {
  var boxchilrden = boxbody.children();
  var key2val = {};
  for (var i = 0; i < boxchilrden.length; i++) {
    var childval = $(boxchilrden[i]).find("input").val("");
  }  
}

function get_modal_all_item_vals(boxbody) {
  var boxchilrden = boxbody.children();
  var key2val = {};
  for (var i = 0; i < boxchilrden.length; i++) {
    var childval = $(boxchilrden[i]).find("input").val()
    var childid = $(boxchilrden[i]).find("input").attr('id')
    var key = childid.split("item_")[1]

    key2val[key] = childval;
  }  

  return JSON.stringify(key2val)
}

function get_modal_all_postc_vals(boxbody) {
  var postcs = boxbody.find(".postc");
  var key2val = {};
  for (var i = 0; i < postcs.length; i++) {
    var childval = $(postcs[i]).val()
    var childid = $(postcs[i]).attr('id')
    var key = childid.split("item_")[1]

    key2val[key] = childval;
  }  

  return JSON.stringify(key2val)
}


function sync_post_add_and_refresh(_url, json, refresh) {
    $.ajax({
      url: _url,
      type: 'POST',
      contentType: 'application/json',
      data: json,
      async:false,
      success: function(data) {
          var code = data.status;
          if(code == 200){
            refresh()
            alert('新增成功');
          }else{
              alert('新增失败:' + data.msg);
          }
      },
      error: function(jqXhr, textStatus, errorThrown) {
          alert('apply失败');
      }
  })
}


function sync_post_del_and_refresh(_url, json, refresh) {
    $.ajax({
      url: _url,
      type: 'POST',
      contentType: 'application/json',
      data: json,
      async:false,
      success: function(data) {
          var code = data.status;
          if(code == 200){
            refresh()
            alert('删除成功');
          }else{
              alert('删除失败:' + data.msg);
          }
      },
      error: function(jqXhr, textStatus, errorThrown) {
          alert('apply失败');
      }
  })
}


function sync_post_modify_and_refresh(_url, json, refresh) {
    $.ajax({
      url: _url,
      type: 'POST',
      contentType: 'application/json',
      data: json,
      async:false,
      success: function(data) {
          var code = data.status;
          if(code == 200){
            refresh()
            alert('修改成功');
          }else{
              alert('修改失败:' + data.msg);
          }
      },
      error: function(jqXhr, textStatus, errorThrown) {
          alert('apply失败');
      }
  })
}



function init_progressbar(progressbarid, ruleobjs, rulehittotal) {
  for (var x in ruleobjs ) {
    var ruleobj = ruleobjs[x]
    $('#' + progressbarid).append(
        generate_prevent_bar(Object.keys(ruleobj)[0],  Object.values(ruleobj)[0], rulehittotal)
      )
  }
}

function init_echarts(url, echartid, progressbarid, echartsflag) {
  if (echartsflag.has(echartid)) {
    return
  }

  echartsflag.add(echartid)
  var ele =  document.getElementById(echartid)
  if (ele == null) {
    return
  }

  var rc_rulesechart = echarts.init(ele);
  rc_rulesechart.showLoading();

  $.getJSON(url, function(data) {
      rc_rulesechart.hideLoading()
      // console.log(data.data)
      if (data.data.length == 0) {
        return;
      }
      
      option = mulit_line(data.data, rc_rulesechart)
      rc_rulesechart.setOption(option)
      rc_rulesechart.setOption({
        title : {
            text: 'Prevent Charts'
        },
        legend: {
          top: 40
        },
        grid: {
          top: 80
        },
      })

      var ruleobjs = []
      var rulehittotal = 0
      data.data.forEach(function (element){
        var rulename = Object.keys(element)[0]
        var earry = Object.values(element)[0]
        var rulehitcnt = 0
        for (var x in earry) {
          rulehitcnt += earry[x].value
        }
        var barobj = {}
        barobj[rulename] = rulehitcnt
        ruleobjs.push(barobj)
        rulehittotal += rulehitcnt
      })

      init_progressbar(progressbarid, ruleobjs, rulehittotal)
  });
}

// todo
// function convertcols(coldatas) {
  // var colobjs = []
  // var colnames = tb_white.getcolths();

  // if (coldatas.length != colnames.length) {
  //   return null;
  // }

  // for (var i = 0; i < colnames.length; i++) {
  //   var name = ($(colnames[i]).html());
  //   var colobj = {}
  //   colobj[name] = $(coldatas[i]).text()
  //   console.log(colobj)
  // }
// }
