({
    handleForgotPassword: function (component, event, helper) {
        helper.handleForgotPassword(component, event, helper);
    },
    onKeyUp: function(component, event, helper){
        var username = component.find("username").get("v.value");
        var buttonDisabled = true;
        if(username != null && username.length >= 3) {
            buttonDisabled = false;
        }
        component.set("v.buttonDisabled", buttonDisabled);
        
        //checks for "enter" key
        if (!buttonDisabled && event.which === 13) {
            helper.handleForgotPassword(component, event, helpler);
        }
    }
})