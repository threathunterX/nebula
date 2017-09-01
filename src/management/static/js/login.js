$(function() {
    $("#errorhint").css("display", "none");

    $('#loginBtn').on('click', function() {
        // todo
        var loginStr = JSON.stringify({ "email": $("#loginName").val(), "password": $("#loginPsw").val() });

        $.ajax({
        url: "/management/login/login/",
        type: 'POST',
        contentType: 'application/json',
        data: loginStr,
        success: function(data) {
            var code = data.meta.code;
            console.log(code)
            console.log(data)
            switch(code) {
                case 200:
                    $("#errorhint").css("display", "none");
                    $.cookie("username", $("#loginName").val(), { expires: 7 });
                    window.location.href = "/management/explore.html";
                    break;
                case 201:
                    $.cookie("username", $("#loginName").val(), { expires: 7 });
                    $("#errorhint").html("已登录").css("display", "block");
                    window.location.href = "/management/explore.html";
                    break;
                default:
                    $.cookie("username", null, { expires: -1 });
                    $("#errorhint").html("Invalid user or password").css("display", "block");
            }
        },
        error: function(jqXhr, textStatus, errorThrown) {
            $("#loginBtn").siblings("span").html("Invalid user or password").css("display", "block");
        }
    })
    });
});