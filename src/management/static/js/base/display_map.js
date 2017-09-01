var actmap = {'0': '失效',    
             '1': '激活',    
             }

var ftypemap = {'1': 'ip',    
             '2': 'dev',
             '3': 'user',    
             }

function getkeybyvalue(val, map) {
  thek = -1; // -1 means unknown
  for (var k in map) {
    if (map[k] == val) {
      thek = k;
      break;
    }
  }

  return thek;
}

var DisplayMap = {
  get_active_val : function(val) {
    return getkeybyvalue(val, actmap)
  },
  get_ftype_val : function(val) {
    return getkeybyvalue(val, ftypemap)
  }
}