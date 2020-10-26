({
    deleteCookie: function (cname) {
        document.cookie = cname +'=; path=/; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    },

    handleForgotPassword: function (component, event, helpler) {
        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var action = component.get("c.forgotPassword");
        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }
            else {
              this.deleteCookie("startUrl");
            }
       });
        $A.enqueueAction(action);
    }
})