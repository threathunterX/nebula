function mulit_line(data, chart)
{
  option = {
    tooltip : {
      trigger: 'axis',
      formatter: function(params){
        //by函数接受一个成员名字符串做为参数
        //并返回一个可以用来对包含该成员的对象数组进行排序的比较函数
        var by = function(name){
            return function(o, p){
                var a, b;
                if (typeof o === "object" && typeof p === "object" && o && p) {
                    a = o[name];
                    b = p[name];
                    if (a === b) {
                        return 0;
                    }
                    if (typeof a === typeof b) {
                        return a > b ? -1 : 1;
                    }
                    return typeof a > typeof b ? -1 : 1;
                }
                else {
                    throw ("error");
                }
            }
        }

        // 每行5个
        var eachrow = 5
        var res = params[0].name + '<br>';
        for (var i = 0; i < params.length; i++) {
          res += '<span style="display:inline-block;margin-right:5px;border-radius:10px;width:9px;height:9px;background-color:' + params[i].color + '"></span>';
          res += params[i].seriesName + ' : ';
          res += params[i].value + ' ';
          if ((i + 1) % eachrow == 0) {
            res += '<br>'
          }
        }
        if (params.length > 10) {
          if (params.length % eachrow != 0) {
            res += '<br>'
          }
          res += '-------------------(数量排序)-------------------<br>'
          params.sort(by("value"))
          for (var i = 0; i < params.length; i++) {
            res += '<span style="display:inline-block;margin-right:5px;border-radius:10px;width:9px;height:9px;background-color:' + params[i].color + '"></span>';
            res += params[i].seriesName + ' : ';
            res += params[i].value + ' ';
            if ((i + 1) % eachrow == 0) {
              res += '<br>'
            }
          }
        }
        return res;  
      }
    },
    legend: {
      data: $.map(data, function(value, idx){
        return Object.keys(value)
      })
    },
    toolbox: {
      show: true,
      feature: {
        my_showall: {
          show: true,
          title: '全选',
          icon: 'path://M432.45,595.444c0,2.177-4.661,6.82-11.305,6.82c-6.475,0-11.306-4.567-11.306-6.82s4.852-6.812,11.306-6.812C427.841,588.632,432.452,593.191,432.45,595.444L432.45,595.444z M421.155,589.876c-3.009,0-5.448,2.495-5.448,5.572s2.439,5.572,5.448,5.572c3.01,0,5.449-2.495,5.449-5.572C426.604,592.371,424.165,589.876,421.155,589.876L421.155,589.876z M421.146,591.891c-1.916,0-3.47,1.589-3.47,3.549c0,1.959,1.554,3.548,3.47,3.548s3.469-1.589,3.469-3.548C424.614,593.479,423.062,591.891,421.146,591.891L421.146,591.891zM421.146,591.891',
          onclick: function (){
            var op = chart.getOption().legend[0].data
            selectall = {}
            for (var i in op)
              selectall[op[i]] = true
            chart.setOption({
              legend: {
                selected: selectall
              }
            })
          }
      },

      my_shownone: {
          show: true,
          title: '全不选',
          icon: 'image://http://echarts.baidu.com/images/favicon.png',
          onclick: function (){
            var op = chart.getOption().legend[0].data
            selectall = {}
            for (var i in op)
              selectall[op[i]] = false
            chart.setOption({
              legend: {
                selected: selectall
              }
            })
          }
        }
      }
    },

    calculable : true,
    xAxis : [
      {
        type : 'category',
        boundaryGap : false,
        data : data[0][Object.keys(data[0])].map(function (item) {
                 return item.time;
               }),
      }
    ],
    yAxis : [
      {
        type : 'value'
      }
    ],
    series : $.map(data, function(value, idx){
      item = {
        type : 'line',
        smooth : true,
      }
      item.name = Object.keys(value)
      item.data = value[Object.keys(value)]
      return item
    })
  };
  return option;
}
