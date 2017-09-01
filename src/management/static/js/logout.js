$(function() {
    if($.cookie("username")){
        $("#admin_user_profile").html($.cookie("username"));
        
         $.getJSON("/management/data/logininfo", function(r) {
            var user_info = r.data.email + "<small>Member since  " + r.data.confirmed_at + "</small>";
            $("#admin_user_profile_header").html(user_info);
         }).fail(function(event, XMLHttpRequest, ajaxOptions, thrownError) {
            if(event.status == 401){  // (UNAUTHORIZED)
                window.location.href = "/management/login.html";
            }
         }); // end of $.getJSON;
    }

    $("#management_logout").click(function(){
        console.log('logout btn click')
        $.ajax({
            url: "/management/login/logout/",
            type: "post",
            dataType: "json",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({"optype":"logout"}),
            success: function(data) {
                if(data.meta.code == 200){
                    $.cookie("username", null, { expires: 0 });
                    window.location.href = "login.html"       
                }
            }
        })
    });
});
