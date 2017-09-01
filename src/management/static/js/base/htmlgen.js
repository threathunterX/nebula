function generate_rule_node(rule) {
  var node = ''
  node += '<div class="box box-success" style="display: table-caption;padding-right: 20px;margin-bottom: 3px;white-space: nowrap;">'
  node += '<div class="box-header">'
  node += '<h3 class="box-title">' + rule + '</h3>' 
  node += '<div class="box-tools pull-right" style="right: -12px">'
  node += '<button type="button" class="btn btn-box-tool" data-widget="remove"><i class="fa fa-times"></i></button>'
  node += '</div>'
  node += '</div>'
  node += '</div>'

  return node
}

var colors = ['aqua', 'red','green','yellow']
var colori = 0;
function get_prevent_bar_color() {
  if (colori >= colors.length) {
    colori = 0;
  }
  return colors[colori++]
};

function generate_prevent_bar(rulename, rulehit, ruletoal) {
  var str = '<div class="progress-group">'
  str += '<span class="progress-text">' + rulename + '</span>'
  str += '<span class="progress-number"><b>'+ rulehit + '</b>/' + ruletoal + '</span>'
  str += '<div class="progress sm">'
  str += '<div class="progress-bar progress-bar-' + get_prevent_bar_color() + '" style="width: ' + (rulehit / ruletoal * 100) +'%"></div>'
  str += '</div>'
  str += '</div>'
  return str;
}

function generate_business_tab(index, busstr, busnamestr, echartid, progressbarid, ruleliststr, tablistid, tabcontentid) {
  var busitab = ''
  if (index == 0) {
    busitab = '<li role="presentation" class="active">'
  } else {
    busitab = '<li role="presentation">'
  }
  busitab += '<a href="#' + busstr + '" aria-controls="' + busstr + '" role="tab" data-toggle="tab">'
  busitab += busnamestr + '</a></li>'
  $('#' + tablistid).append(busitab)

  var busitab_content = ''
  if (index == 0) {
    busitab_content += '<div role="tabpanel" class="tab-pane fade in active" id="' + busstr + '">'
  } else {
    busitab_content += '<div role="tabpanel" class="tab-pane fade" id="' + busstr + '">'
  }
  busitab_content += '<div class="box-header">'
  busitab_content += '<button type="button" class="btn btn-primary pull-right" id="' + ruleliststr + '_add">'
  busitab_content += '<i class="fa fa-plus"></i> 添加检测规则</button>'
  busitab_content += '</div>'
  busitab_content += '<div class="box-body" style="padding-top: 2px">'
  busitab_content += '<table id="' + ruleliststr + '" class="table table-bordered table-striped">'
  busitab_content += '<thead>'                              
  busitab_content += '<tr id="' + ruleliststr + '_tr">'
  busitab_content += '</tr>'
  busitab_content += '</thead> '                             
  busitab_content += '</table>'
  busitab_content += '</div>'
  busitab_content += '<div class="box box-info" style="padding: 20px">'
  // busitab_content += '<div id="' + echartid + '" style="width: 100%;height:300px;"></div>'
  busitab_content += '<div class="row">'
  busitab_content += '<div class="col-md-8">'
  busitab_content += '<div id="' + echartid + '" style="width: 100%;height:500px;"></div>'
  busitab_content += '</div>'
  busitab_content += '<div class="col-md-4" style="overflow: scroll;height:500px;margin-top: 10px;" >'

  busitab_content += '<p class="text-center"><strong>Global Prevent</strong></p>'
  busitab_content += '<div id="' + progressbarid + '">'


  busitab_content += '</div>'
  busitab_content += '</div>'
  busitab_content += '</div>'
  busitab_content += '</div>'
  busitab_content += '</div>'
  $('#' + tabcontentid).append(busitab_content)

}