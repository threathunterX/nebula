
function init_log_echart(url, echartid) {
  url = '/management/data/analyze/actionlogs/chart'
  echartid = 'analyze_echart'
 
  var ele =  document.getElementById(echartid)
  if (ele == null) {
    return
  }

  var rc_echart = echarts.init(document.getElementById(echartid));
  rc_echart.showLoading();

  $.getJSON(url, function(data) {
      rc_echart.hideLoading()
      // console.log(data.data)
      if (data.data.length == 0) {
        return;
      }
      
      option = mulit_line(data.data, rc_echart)
      rc_echart.setOption(option)
      rc_echart.setOption({
        title : {
            text: 'Decision命中曲线'
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

      init_log_progressbar(ruleobjs, rulehittotal)
  });
}

function init_log_progressbar(ruleobjs, rulehittotal) {
  progressbarid = 'analyze_progressbar'

  for (var x in ruleobjs ) {
    var ruleobj = ruleobjs[x]
    $('#' + progressbarid).append(
        generate_prevent_bar(Object.keys(ruleobj)[0],  Object.values(ruleobj)[0], rulehittotal)
      )
  }
}


const map_user2detail = new Map()

$(function() {
    init_log_echart()

    tb_decision = TableCtrl.create2("/management/data/analyze/actionlogs", "analyze_table", function(datas, fcols){
      datas.forEach(function(row) {
          var detail = row.detail
          map_user2detail.set(row.user, detail)
          row.detail = '<button id="op_detail" class="btn btn-primary btn-xs">&nbsp;detail</button>';
      });
    });

    tb_decision.refresh();

    $('#analyze_table').on("click", '#op_detail', function()   {
              var row = $($("#analyze_table tr.onselect")[0])
              var cols = row.find('td')

              $('#analyze_detail_modal').modal({show:true}, {
                addnew : false,
                coldatas : $(cols)
              });
          });
})

$('#analyze_detail_modal').on('show.bs.modal', function (e) {
  var coldatas = e.relatedTarget.coldatas

  if (coldatas != null) {
    var res = map_user2detail.get($(coldatas[1]).text())
    var detail_json = JSON.stringify(res, null, 2)
    $("#analyze_detail_modal_box_body").children().remove()
    $("#analyze_detail_modal_box_body").append(`<code>${detail_json}</code>`)
  } else {
    $("#analyze_detail_modal_box_body").children().remove()
  }
})
