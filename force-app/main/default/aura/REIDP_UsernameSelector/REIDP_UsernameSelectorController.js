({
    init: function(component, event, helper) {
        var loginOptAction = component.get("c.getLoginOption");
        loginOptAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                // if user uses expId link
                if (response.getReturnValue() != null) {
                    component.set("v.emailBool", response.getReturnValue().email);
                    component.set("v.phoneBool", response.getReturnValue().phone);
                    
                    // sets default active tab
                    if (response.getReturnValue().emailDefault == true) {
                        component.set('v.selTabId', 'email');
                    } else if (response.getReturnValue().emailDefault == false) {
                        component.set('v.selTabId', 'phone');
                    } 
                }
                
                // if user uses simple link, expId=null
                else if (response.getReturnValue() == null) {
                    component.set("v.emailBool", true);
                    component.set("v.phoneBool", true);
                    component.set('v.selTabId', 'email');
                }

            }
        });
        $A.enqueueAction(loginOptAction);
    },
    
    // sets Code, Phone, Email values for current evt attributes
    handleEmailInput: function(component, event, helper) {
        var email = component.find("userFieldEmail").get("v.value");
        var code = component.find("codeInputEvent").get("v.value");
        var phone = component.find("phoneInputEvent").get("v.value");
        
        component.set('v.Email', email);
    }
    
})