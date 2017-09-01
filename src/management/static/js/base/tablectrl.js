var TableCtrl = {
  create : function(url, tableid, preparefunc, mapdatafunc) {
    var tablectrl = {};
    tablectrl.tableid = tableid;
    tablectrl._datatable = null;
    tablectrl.preparefunc = preparefunc

    tablectrl.refresh = function() {
      $.getJSON(url, function(r) {
          var tbid = "#" + tablectrl.tableid;
          var tbtrid = "#" + tablectrl.tableid + "_tr";
            
          if (r == null || r.data.length == 0) {
            return;
          }

          var fcols = $.map(Object.keys(r.data[0]), function(i){
            return {"data": i}
          })

          var newth = null;
          if (tablectrl.preparefunc == null) {
            newth = table_add_default_operate( r, fcols)
          } else {
            newth = tablectrl.preparefunc(r, fcols);
          }

          // init <th>
          if (tablectrl._datatable == null) {
            $.map(Object.keys(r.data[0]), function(i){
              $(tbtrid).append("<th>"+i+"</th>")
            })

            // console.log(newth)
            // if (newth != null) {
            //   $.map(Object.keys(newth), function(i){
            //     $(tbtrid).append("<th>"+i+"</th>")
            //     console.log(i)
            //   })
            // }
          }

          if (mapdatafunc != null) {
            mapdatafunc(r)
          }
         
          if (tablectrl._datatable != null) {
              tablectrl._datatable.destroy();
          }

          tablectrl._datatable = $(tbid).DataTable({
                  "data": r.data,
                  "columns": fcols,
                  "paging": true,
                  "pageLength": 50,
                  "lengthChange": false,
                  "searching": true,
                  "ordering": true,
                  "order": [[0, "asc"]],
                  "info": true,
                  "autoWidth": false,
                  "fnDrawCallback": function() {
                      $(tbid+ " tbody tr").hover(function() { // enter
                          $(this).addClass("onhover");
                      }, function() { // exit
                          $(this).removeClass("onhover");
                      }).click(function() {
                          $(tbid).find(".onselect").each(function() {
                              $(this).removeClass("onselect");
                          });
                          $(this).addClass("onselect");
                      });
                  },
              });

          }).fail(function(event, XMLHttpRequest, ajaxOptions, thrownError) {
              if(event.status == 401){  // (UNAUTHORIZED)
                window.location.href = "/management/login.html";
              }
          });  ; // end of $.getJSON

    };

    tablectrl.getcolths = function() {
      if (tablectrl._datatable != null) {
        return tablectrl._datatable.columns().header()
      }

      return null;
    };

    return tablectrl;
  },

  create2 : function(url, tableid, preparefunc, mapdatafunc) {
    var tablectrl = {};
    tablectrl.tableid = tableid;
    tablectrl._datatable = null;
    tablectrl.preparefunc = preparefunc

    tablectrl.refresh = function() {
      $.getJSON(url, function(r) {
          var tbid = "#" + tablectrl.tableid;
          var tbtrid = "#" + tablectrl.tableid + "_tr";
            
          // if (r == null || r.data.length == 0) {
          //   return;
          // }

          var fcols = $.map(r.data.cols, function(i){
            return {"data": i}
          })

          var newth = null;
          if (tablectrl.preparefunc == null) {
            newth = table_add_default_operate2( r.data.datas, fcols)
          } else {
            newth = tablectrl.preparefunc(r.data.datas, fcols);
          }

          // init <th>
          if (tablectrl._datatable == null) {
            $.map(fcols, function(i){
              $(tbtrid).append("<th>"+i.data+"</th>")
            })

            // console.log(newth)
            // if (newth != null) {
            //   $.map(Object.keys(newth), function(i){
            //     $(tbtrid).append("<th>"+i+"</th>")
            //     console.log(i)
            //   })
            // }
          }

          if (mapdatafunc != null) {
            mapdatafunc(r)
          }
         
          if (tablectrl._datatable != null) {
              tablectrl._datatable.destroy();
          }

          tablectrl._datatable = $(tbid).DataTable({
                  "data": r.data.datas,
                  "columns": fcols,
                  "paging": true,
                  "pageLength": 50,
                  "lengthChange": false,
                  "searching": true,
                  "ordering": true,
                  "order": [[0, "asc"]],
                  "info": true,
                  "autoWidth": false,
                  "fnDrawCallback": function() {
                      $(tbid+ " tbody tr").hover(function() { // enter
                          $(this).addClass("onhover");
                      }, function() { // exit
                          $(this).removeClass("onhover");
                      }).click(function() {
                          $(tbid).find(".onselect").each(function() {
                              $(this).removeClass("onselect");
                          });
                          $(this).addClass("onselect");
                      });
                  },
              });

          }).fail(function(event, XMLHttpRequest, ajaxOptions, thrownError) {
              if(event.status == 401){  // (UNAUTHORIZED)
                window.location.href = "/management/login.html";
              }
          });  ; // end of $.getJSON

    };

    tablectrl.getcolths = function() {
      if (tablectrl._datatable != null) {
        return tablectrl._datatable.columns().header()
      }

      return null;
    };

    return tablectrl;
  }
}