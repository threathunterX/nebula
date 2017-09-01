 index = ""  //第几个路由
 selectWorkflowId = "" //选中的fw的id                
 WF = {'notActive':[],'active':[]};  //workflow的ID
 selectWorkflowId = "" // 选中的workflow id
 criterias = {}; //手机fw下不同router的规则字符串&&
 routesId = ""; //路由的ID


var factsmapName2Fact = {}



$.ajax({
  type: "GET", 
  url: "/management/data/rulefacts", 
  dataType:"json",
  success: function(data){
    if(data.status == 200){
      var factsdata = data.data;
      cbRule(factsdata);

      for (var i = 0; i < factsdata.length; i++) {
       factsmapName2Fact[factsdata[i].name] = factsdata[i].fact
      }
    }else{

    }
  }
});


$.ajax({ 
  type: "GET",
  url: "/management/data/ruleops", 
  dataType:"json",
  success: function(data){
    if(data.status == 200){
      var opList = data.data;
      cbOp(opList);
    }
  }
});
function cbOp(data){
  $(".selectBtn").html(data[0]['op']);
  for(var i in data){
    $(".dropdownCriteria .SelectableList").append(
      `<li> <a class="tran" href="javascript:;">${data[i]['op']}</a> </li>`
      )
  }
}
// 下拉框以及选项

// 显示workflows
function showWF(){
  $.ajax({ 
    type: "GET",
    url: "/management/data/workflows", 
    dataType:"json",
    success: function(data){
      console.log(data)
      if(data.status == 200){
        $(".notActive").empty();
        $(".run").empty();
        var data = data.data;
        showTemplate(data);
        data.forEach( function(element, index) {
          if(element['status']==0){
            console.log('ren')
            WF['notActive'].push(element["id"]);
          }else if(element['status']==1){
            WF['active'].push(element["id"]);
          }
          // WF.push(element["id"]);
        });
      }
      console.log(WF);
      $(".workTitle span").html( $(".run li").length );
      $(".Paused span").html( $(".notActive li").length );
    }
  });
}
showWF();

$(".showWf").on('click','.notActive li',function(){
  selectWorkflowId = WF['notActive'][$(this).index()];
  console.log(selectWorkflowId)
  $("#page1").hide(100);
  $("#page2").show(100);
  showRouter(selectWorkflowId);
})

$(".showWf").on('click','.run li',function(){
  selectWorkflowId = WF['active'][$(this).index()];
  console.log(selectWorkflowId)
  $("#page1").hide(100);
  $("#page2").show(100);
  showRouter(selectWorkflowId);
})

// 显示对应flow下的路由信息
function showRouter(selectWorkflowId){
  $.ajax({ 
  url: "/management/data/workflows/"+selectWorkflowId+"/routes", 
  type:"GET",
  contentType: 'application/json',
    success: function(data){
      if(data.status == 200){
        if(data.data==""){
          $(".addRoutes").trigger("click");
        }else{
          $(".routesList").empty();
            data.data.forEach( function(element, index) {
              $(".routesList").append(str);
              $(".routesModus:eq("+index+") .routesId").html(element.id)
              if(element.criterias !==""){
                var criArr = element.criterias.split("&&");
                for(var i in criArr){
                  $(".routesModus:eq("+index+") .criteriaUl").append(
                  `
                    <li>
                      <p>${criArr[i]}</p>
                      <span><i class="iconfont icon-del2"></i></span>
                    </li>
                  `
                  )
                }
              }
            }); 
        }   
      }
    }
  });
}

// 开始创建路线！
$(".apply").click(function(){
  // if( $("#status").html() ){}
  
  
  $.ajax({ 
  url: "/management/data/workflows", 
  type:"POST",
  data:JSON.stringify({'name':$('.page2Header h2').html(),'event':$("#states").val(),'affecting':'user'}),
  contentType: 'application/json;charset=UTF-8',
    success: function(data){
      // console.log(data.data);
        if(data.status == 201){
          createId = data.data.id;
          localStorage.setItem("createId",createId);
          selectWorkflowId = createId;
          $(".addRoutes").trigger("click");
        }
    }
  });
})

// 删除wf
$("#page2 .delWf").click(function(){
  $("#delModal").modal("show")
})
$("#delWorkFlow").click(function(){
   $.ajax({ 
    url: "/management/data/workflows/"+selectWorkflowId, 
    type:"DELETE",
      success: function(data){
        if (data.status==200) {
          $("#page2").hide(100);
          $("#page1").show(100);
          showWF();
        }
       }
    });
})

// 点击确认增加规则
$(".confirm").click(function(){
  if( $(".selNum input").val()=="" ){
    $(".worryTxt").show(150);
    $(".selNum input").addClass("redBorder");
  }else{
    $.ajax({ 
    url: "/management/data/workflows/"+selectWorkflowId+"/routes", 
    type:"GET",
    contentType: 'application/json;charset=UTF-8',
      success: function(data){
            if(data.status == 200){
                console.log(data.data)
                data.data.forEach( function(element, index) {
                  if(element["criterias"] !==""){
                    criterias[ element["id"] ] = "";
                    criterias[ element["id"] ] += element["criterias"] + " && ";
                  }else{
                    criterias[ element["id"] ] = element["criterias"]
                  }
                  console.log( criterias );
                  if(element.id==routesId){
                    var userStr = factsmapName2Fact[$(".dropP2Container .strong").html()]  + $(".dropP2Container .selectBtn").text() +$(".dropP2Container input").val()
                    var str = JSON.stringify({'workflowid':selectWorkflowId,'criterias':criterias[routesId]+ userStr});
                    console.log(str);
                    console.log(userStr);
                    $.ajax({ 
                    url: "/management/data/routes/"+routesId, 
                    type:"PUT",
                    data:str,
                    contentType: 'application/json;',
                      success: function(data){
                        if(data.status == 200){
                          $(".dropdownCriteria").hide(150);
                          var tmp = `
                            <li>
                              <p>${factsmapName2Fact[$(".strong").html()]+$(".selBox1 a").html()+$(".selNum input").val()}</p>
                              <span><i class="iconfont icon-del2"></i></span>
                            </li>
                          `

                          $(".routesModus:eq("+index+") .criteriaUl").append(tmp
                          
                          )
                          $(".selNum input").val("");
                          $(".dropP2 a").trigger("click");

                        }
                       }
                    })
                  }
                });      
              }
        }
    });
  }
})

$(".publish").click(function(){ 
  console.log(selectWorkflowId)
  $.ajax({ 
    url: "/management/data/workflows/"+selectWorkflowId, 
    type:"PUT",
    data:JSON.stringify({status:1}),
    contentType: 'application/json;',
      success: function(data){
        console.log(data);
       }
    })
})

// 切换页面
$(".page1Header>a").click(function(){
  $("#page1").hide(100);
  $("#page2").show(100);
  $(".routesList").empty();
  console.log(6699)
})

  $(".toPage1").click(function(){
    $("#page2").hide(100);
    $("#page1").show(100);
    showWF();
  })

// 编辑名字
  $("#page2").on('click','.editWF',function(){       
    var text = $(this).siblings("input").val();
    $(this).siblings("h2").css("display","none");
    $(this).siblings("input").css("display","inline-block").val("").focus().val(text);
    $(this).css("display","none");
    
  })
  $("#page2").on('blur','.name',function(){
      edit($(this));
  })
  $("#page2").on('keydown','.name',function(){
    if(event.keyCode==13){
      edit($(this));
    }
  })

  function edit(that){
    that.css("display","none");
    that.siblings(".editWF").css("display","inline-block");
    that.siblings("h2").css("display","inline-block").html( that.val() );
  }

  $(".stepTwo").on('click',".addCriteria",function(){
    $(".dropdownCriteria").css({"top":$(this).offset().top+30,"left":$(this).offset().left}).show(150);
    index = $(this).parents(".routesModus").index();
    routesId = $(this).parents(".routesModus").find(".routesId").html();
  })

  $(".colseDropDown").click(function(){
    $(".dropdownCriteria").hide(150)
  })

  $(".dropdownCriteria").on('click',".dropP1 ul li a",function(e){
    $(".dropP2").animate({left:0},150);
    $(".dropP2 .strong").html( $(this).html() );
    $(".worryTxt").hide(150);
    $(".selNum input").removeClass("redBorder");
    $('.selNum input').trigger('focus');
  })

  $(".toBack").click(function(){
    $(".dropP2").animate({left:500},150);
  })

  $(".selectBtn").click(function(){
    $(".SelectableList").show(150);
  })

  $(".dropP2").on('click',".SelectableList li a",function(){
    $(".selectBtn").html( $(this).html() );
    $(".SelectableList").hide(150);
  });
  
// 对应的wf添加路由
  $(".stepTwo").on('click',".addRoutes",function(e){
    $(".routesList").append(str);
    // console.log( selectWorkflowId )
    $.ajax({ 
      url: "/management/data/routes", 
      type:"POST",
      data:JSON.stringify({'workflowid':selectWorkflowId,'criterias':"",'decisionid':666}),
      contentType: 'application/json;charset=UTF-8',
      success: function(data){
        // console.log(data);
        if(data.status == 201){
          $(".routesModus:last-child").css("border","1px solid red");
          $(".routesModus:last-child .routesId").html(data.data.id);
        }
      }
    });
  })

  //删除路由下的规则
  $(".stepTwo").on('click',".criteriaUl span",function(e){
    // console.log( $(this).parents(".routesModus").index() );
    thata = $(this)
    index = $(this).parents(".routesModus").index();  //第几个路由
    routesId = $(this).parents(".routesModus").find(".routesId").html(); 
    // $(".routesModus:eq("+index+") .criteriaUl li:eq("+ $(this).parents("li").index() +")").remove();
    var target = $(this).siblings("p").text();
    console.log(target);
    $.ajax({ 
    url: "/management/data/workflows/"+selectWorkflowId+"/routes", 
    type:"GET",
    contentType: 'application/json',
      success: function(data){
        if(data.status == 200){
            data.data.forEach( function(element, index) {
              criterias[element["id"]] = element["criterias"]
              if(element.id==routesId){
                var routesList = criterias[routesId].split("&&");
                for(var i in routesList){
                  if(routesList[i]==target){
                    routesList.splice(i,1);
                    console.log(i);
                  }
                }
                var str = routesList.join("&&");
                console.log( routesList );
                // console.log( str );
                $.ajax({ 
                url: "/management/data/routes/"+routesId, 
                type:"PUT",
                data:JSON.stringify({'workflowid':selectWorkflowId, 'criterias':str}),
                contentType: 'application/json;',
                success: function(data){
                  if(data.status == 200){
                    console.log(thata)
                    // $(".routesModus:eq("+index+") .criteriaUl li:eq("+ $(this).parents("li").index() +")").remove();
                    thata.parent("li").remove();
                  }
                }
              })
              
              }
            });      
        }
      }
});


  })

  $(".selNum input").blur(function(){
    console.log(678)
    if( !$(this).val() ){
      $(".worryTxt").show(150);
      $(".selNum input").addClass("redBorder");
    }else{
      $(".worryTxt").hide(150);
      $(".selNum input").removeClass("redBorder");
    }
  })

  $(".stepTwo").on('click',".delStandard",function(e){
    $(this).parent().parent().hide(150);
    $(this).parent().parent().siblings().show(150);
  })
  
  $(".stepTwo").on('click',".delRoutesModus",function(e){
    // console.log($(this).parent().parent().parent().index());
    var index = $(this).parent().parent().parent().index()
    $(".routesList .routesModus").eq(index).remove();
      $.ajax({ 
        url: "/management/data/routes/"+$(this).siblings(".routesId").html(), 
        type:"DELETE",
        success: function(data){
          if (data.status==200) {
            
          }  
        }
      });
  })

  $(".stepTwo").on('click',".setDecision",function(e){
    index = $(this).parent().parent().parent().index();
    // console.log(index);
    $(".dropdownDection").css({top:$(this).offset().top+40,left:$(this).offset().left}).show(150);
  })
  
  $(".dropdownDection li").click(function(){
    $(".dropdownDection").hide(150);
  })

  $(".dropdownDection li:first-child").click(function(){
    $("#edit_modal2").modal('show');
  })

  $(".dropdownDection li:not(first-child)").click(function(){
    $(".routesModus:eq("+index+") .standardName").html( $(this).html() );
    $(".routesModus:eq("+index+") .setDecision").hide(150);
    // $(".routesModus:eq("+index+") .setDecision").siblings("p").hide(150);
    $(".routesModus:eq("+index+") .standard" ).show(150);
  })

   $(".dropdownDection").mouseleave(function(){
      $(".dropdownDection").hide(150);
   })

   $("#states").click(function(){
    $(".dropdownStatus").css({top:$(this).offset().top+40,left:$(this).offset().left}).show(150);
   })

   $(".dropdownStatus li").click(function(){
      $("#states").val( $(this).html() );
      $(".dropdownStatus").hide(150);
   })

    $(document).on('mousedown',function(e){
        if( !($(e.target).is($('.dropdownStatus')) || $(e.target).is($('.dropdownStatus ul')) || $(e.target).is($('.dropdownStatus ul li')))  ){
          if( $(".dropdownStatus").css("display") == "block" ){
             $(".dropdownStatus").hide(150);
          }
        }

        if( !($(e.target).is($('.dropdownDection')) || $(e.target).is($('.dropdownDection ul')) || $(e.target).is($('.dropdownDection ul li')))  ){
          if( $(".dropdownDection").css("display") == "block" ){
             $(".dropdownDection").hide(150);
          }
        }

    });

function cbRule(data){
  for(var i in data){
    $(".dropdownCriteria .factList").append(
      `<li> <a class="tran" href="javascript:;">${data[i]['name']}</a> </li>`
      )
  }
}

function showTemplate(data){
  for(var i in data){
    if(data[i]["status"] == 1){
      // 激活了
      $(".activation").css("display","none");
      $(".run").append(
        `<li class="tran">
           <div class="runHead clear">
             <h3 class="workflowName">${data[i]["name"]}</h3>
             <span>运行中</span>
           </div>
           <div class="runContain">
             <p>event：<span class="event">${data[i]["event"]}</span> </p>
             <p>affecting：<span class="affecting">${data[i]["affecting"]}</span> </p>
           </div>
         </li>
        `
        )
    }else if(data[i]["status"] == 0){
      //未激活
      $(".noPaused").css("display","none");
      $(".notActive").append(
        `
        <li class="tran">
          <div class="runHead clear">
            <h3 class="workflowName">${data[i]["name"]}</h3>
            <span>未运行</span>
          </div>
          <div class="runContain">
            <p>event：<span class="event">${data[i]["event"]}</span> </p>
            <p>affecting：<span class="affecting">${data[i]["affecting"]}</span> </p>
          </div>
        </li>
        `
        )
    }
  }
}

var str =`
    <div class="routesModus">
       <div class="routesModusHead">
         <div class="routesName">
         <h2>Route 1</h2>
         <input class="name" type="text" name="" value='Route 1'>
         <span class="editWF"><i class="iconfont icon-hricon10"></i></span>
         <span class="delRoutesModus"><i class="iconfont icon-el-icon-delete"></i></span>
         <span class="routesId" style="display:none"></span>
         </div>
       </div>
       <div class="routesInn clear">
         <div>
          <h5>IF USER MATCHES</h5>
          <div class="criteriaList">
            <ul class="criteriaUl clear">
            </ul>
            <button class="addCriteria">+ Add Criteria</button>
          </div>
         </div>
         <div>
           <p>THEN:</p>
           <a class="setDecision" href="javascript:;">设定标准</a>
           <div class="standard">
             <p><span class="standardName">mdgd</span><span class="delStandard"><i class="iconfont icon-del3"></i></span></p>
           </div>
           <ul>
           </ul>
         </div>
       </div>
     </div>
  `