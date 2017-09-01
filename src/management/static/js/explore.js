var totalData = [];//json总数据
   maxNum = 10;//一页显示最大条数
  var page = 1;//第一页
  // 旋转按钮
  $(".conList").on('click',".toggleBtn",function(e){
    $(this).parent().parent().siblings().toggle(500);
    $(this).find('span').toggleClass("show");
  })

  $(".conList").on('click',".select",function(e){
    selectedId = parseInt($(this).parent().parent().parent().siblings().find(".user-info-container").find("div").find("#idNum").html());
    var keys = Object.keys(totalData[selectedId]["riskinfo"]);
    $(this).find("ul").empty();
    diffArr(keys,lineArr);
    console.log(myArr)
    for(var i in myArr){
      var li = $("<li>"+myArr[i]+"</li>");
      $(".selectBox").append(li)
    }
  })

  function diffArr(arr1,arr2){
     myArr = arr1;
     var arr = [];
      for(var j=0;j<arr1.length;j++){
        if(arr2.indexOf(arr1[j]) !==-1 ){  //arr2与arr1有相同元素
          arr.push(arr1[j])
        }
      }
      
      for(var i in arr){
        myArr.splice(myArr.indexOf(arr[i]),1)
      }
      return myArr
  }

  //显示新的attribute列表
  $(".conList").on('click',".select a",function(e){
    $(this).parent().find("ul").show(200);
  })

  $(".conList").on('mouseleave',".select",function(e){
      $(this).find(".selectBox").hide(500);
  })

  //关闭attribute  
  $(".conList").on('click',".attribute>span",function(e){
    $(this).parent().css("display","none");
    // myArr.push( $(this).parent().find("p").eq(0).html() )
    lineArr.splice(lineArr.indexOf( $(this).parent().find("p").eq(0).html() ),1)

    console.log( lineArr )
    for(var i=0;i<totalData.length;i++){
      for(var y=0;y< $(".labeled:eq(0) .attribute").length;y++ ){
        if($(".labeled:eq("+i+") .attributeBox .attribute:eq("+y+") p:eq(0)").html() == $(this).parent().find("p").eq(0).html() ){
            $(".labeled:eq("+i+") .attributeBox .attribute:eq("+y+")").css("display","none");
        }
      }
    }
  })

  //选中新添加的attribute
  $(".conList").on('click',".select li",function(e){
      $(this).parent().hide(500);
      console.log($(this).html());
      lineArr.push( $(this).html() )
      for(var i=0;i<totalData.length;i++){
        $(".labeled").eq(i).find(".labeled-inn").find(".labled-msg").find(".attributeBox").prepend(
      ` 
        <div class="attribute">
          <p>${$(this).html()}</p>
          <p>${totalData[i]['riskinfo'][$(this).html()]}</p>
          <span>
            <img src='/management/static/img/close.png' style='width:16px;height:16px;display:block;color:#666;' />
          </span>
        </div>
        `
        )

      }
  })

  $(".conList").on('mouseenter',".select li",function(e){
      $(this).css('font-size','16px')
  })
  $(".conList").on('mouseout',".select li",function(e){
      $(this).css('font-size','12px');
  })


  $(".next").click(function(){
    if(page <  (totalData.length%maxNum==0 ? parseInt(totalData.length/maxNum) : parseInt(totalData.length/maxNum)+1) ){
      page++;
      toOtherPage()
    }
  })
  $(".pref").click(function(){
    if(page>1){
      page--
      toOtherPage()
    }
  })

  $.getJSON("/management/data/userlog", function(data){
    totalData = data.data;
    callback()
  })

  function addAttribute(x,y){
    var str = "";
     lineArr = [];
    for(var i=0;i<x.length &&i<=7                ;i++){
      if(x[i]){
        lineArr.push( Object.keys(totalData[y]['riskinfo'])[i] );
        str+=
          `
          <div class="attribute">
            <p>${Object.keys(totalData[y]['riskinfo'])[i]}</p>
            <p>${totalData[y]['riskinfo'][Object.keys(totalData[y]['riskinfo'])[i]]}</p>
            <span>
              <img src='/management/static/img/close.png' style='width:16px;height:16px;display:block;color:#666;' />
            </span>
          </div>
          `
      }
    }
    return str;
  }

function callback(){
  $("#page .start").html( (page-1)*maxNum+1 )
  $("#page .end").html( (page-1)*maxNum+maxNum )
  $("#page .maxTotal").html(totalData.length)
  $("#page .num").html(page);
  
   //做表 
  for(var i=0;i< totalData.length;i++){
    var y = (page-1)*maxNum+i;//第几个数据
    $(".conList").append(
      `<li class="labeled">
                <div class="labeled-head clear">
                  <div class="user-info-region">
                    <div class="user-info-container clear">
                      <div class="mark1">
                           <img src='/management/static/img/risk.png'  style='width:30px;height:30px;display:inline-block;' />
                        <span>${totalData[y]['scores']}</span>
                      </div>
                      <div class="baseinfo">
                        <p class="baseinfoName">${totalData[y]['baseinfo']['name']}</p>
                        <p>${totalData[y]['baseinfo']['email']}</p>
                        <p>${totalData[y]['baseinfo']['activity_time']}</p>
                        <p style="display:none" id="idNum">${y}</p>
                      </div>
                      
                    </div>
                  </div>
                  <div class="actions-region clear">
                    <div class="toggleBtn">
                        <span class="tran">
                          
                        </span>            
                    </div>
                  </div>
                </div>
                <div class="labeled-inn clear">
                  <div class="labled-msg">
                    <div class="attributeBox clear">
                    ${addAttribute(Object.keys(totalData[y]['riskinfo']),y)}
                     <div class="select">
                       <a href="javascript:;">+新增属性</a> 
                       <ul class='selectBox'>

                       </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </li>
`
      );
  }
  toOtherPage();
}
function toOtherPage(){
  $("#page .start").html( (page-1)*maxNum+1 );
  $("#page .end").html( (page-1)*maxNum+maxNum );
  $(".labeled").css("display","none")
  for(var i = (page-1)*maxNum;i<(page-1)*maxNum+maxNum;i++){
    $(".labeled").eq(i).css("display","block")
  }
  $('body,html').animate({ scrollTop: 0 }, 500);
}