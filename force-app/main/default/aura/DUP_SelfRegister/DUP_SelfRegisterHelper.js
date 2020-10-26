({
    qsToEventMap: {
        'startURL'  : 'e.c:REIDP_setStartUrl'
    },
    
    handleSelfRegister: function (component, event, helper) {
        var policyAccepted = component.get("v.acceptedPolicies");
        if(!policyAccepted) {
            component.set("v.hasError", true);
            return
        }
        
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        var language = $A.get("$Locale.langLocale");

        startUrl = decodeURIComponent(startUrl);
        action.setParams({firstname:firstname,lastname:lastname,email:email,language:language,
                          password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, 
                          extraFields:extraFields, startUrl:startUrl, includePassword:includePassword});
          action.setCallback(this, function(a){
          var rtnValue = a.getReturnValue();
          if (rtnValue !== null) {
             component.set("v.errorMessage",rtnValue);
             component.set("v.showError",true);
          }
       });
    $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helper) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    }    
})