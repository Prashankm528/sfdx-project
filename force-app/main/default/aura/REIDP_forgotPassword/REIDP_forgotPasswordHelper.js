({
    handleForgotPassword: function (component, event, helper) {
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var actionPhone = component.get("c.forgotPasswordPhone");
        var actionEmail = component.get("c.forgotPassword");
        var tab = component.get("v.tabId");
        
        if (tab == 'email') {
            var email = component.get("v.emailInput");
            
            actionEmail.setParams({username:email, checkEmailUrl:checkEmailUrl});
            actionEmail.setCallback(this, function(a){
                var rtnValue = a.getReturnValue();
                if (rtnValue !== null) {
                    component.set("v.errorMessage",rtnValue);
                    component.set("v.showError",true);
                }
                else {
                    this.deleteCookie("startUrl");
                }
            });
            $A.enqueueAction(actionEmail);
        } else if (tab == 'phone') {
            var countryCode = component.get("v.codeInput");
            var phoneNumber = component.get("v.phoneInput");
            
            actionPhone.setParams({countryCode: countryCode, phoneNumber:phoneNumber, checkEmailUrl:checkEmailUrl});
            actionPhone.setCallback(this, function(a){
                var rtnValue = a.getReturnValue();
                if (rtnValue !== null) {
                    component.set("v.errorMessage",rtnValue);
                    component.set("v.showError",true);
                }
                else {
                    this.deleteCookie("startUrl");
                }
            });
            $A.enqueueAction(actionPhone);
        }
    }
})