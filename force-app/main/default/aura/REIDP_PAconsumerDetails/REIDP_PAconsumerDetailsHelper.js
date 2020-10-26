({
	 toggleSpinner : function(component, event) {
        var spinner = component.find("consumerDetailsSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    togglePrompt : function(component, event) {
      var actions =  component.find("actionGroup");
      var prompt = component.find("promptGroup");
      $A.util.toggleClass(actions, "slds-hide");
      $A.util.toggleClass(prompt, "slds-hide");
    },
    
    doRefresh: function(component, event) {
        var accountId = component.get("v.recordId");
        if(accountId !=null && accountId!=undefined) {
            var ciAction = component.get("c.getConsumerDetails");
            ciAction.setParams({
                "accountId": accountId
            });
            ciAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    component.set("v.lookupInfo", a.getReturnValue());
                } else if (state == "ERROR") {
                    $A.createComponent('c:REIDP_PAToast',
                                       {
                                           "variant" : "error",
                                           "title" : a.getError()[0].message
                                       }, 
                                       function(toast) {
                                           var body = component.get("v.body");
                                           body.push(toast);
                                           component.set("v.body", body);
                                       });
                }
                this.toggleSpinner(component,event);
            });
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.lookupInfo", []);
            this.toggleSpinner(component,event);
        }        
    },
    
    disableWallet: function (component, event) {
        this.toggleSpinner(component, event);
        var accountId = component.get("v.recordId");
        if(accountId !=null && accountId!=undefined) {
            var dwAction = component.get("c.deactivateUserWallet");
            dwAction.setParams({
                "accountId": accountId
            });
            dwAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    $A.createComponent('c:REIDP_PAToast',
                                       {"title" : "Wallet successfully deactivated!"}, 
                                       function(toast) {
                                           var body = component.get("v.body");
                                           body.push(toast);
                                           component.set("v.body", body);
                                       });
                } else if (state == "ERROR") {
                    $A.createComponent('c:REIDP_PAToast',
                                       {
                                           "variant" : "error",
                                           "title" : a.getError()[0].message
                                       }, 
                                       function(toast) {
                                           var body = component.get("v.body");
                                           body.push(toast);
                                           component.set("v.body", body);
                                       });
                }
                this.doRefresh(component, event);
            });
            $A.enqueueAction(dwAction);
        }      
    },
    
    enableWallet: function (component, event) {
        this.toggleSpinner(component, event);
        var accountId = component.get("v.recordId");
        if(accountId !=null && accountId!=undefined) {
            var awAction = component.get("c.activateUserWallet");
            awAction.setParams({
                "accountId": accountId
            });
            awAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    $A.createComponent('c:REIDP_PAToast',
                                       {"title" : "Wallet successfully activated!"}, 
                                       function(toast) {
                                           var body = component.get("v.body");
                                           body.push(toast);
                                           component.set("v.body", body);
                                       });
                } else if (state == "ERROR") {
                    $A.createComponent('c:REIDP_PAToast',
                                       {
                                           "variant" : "error",
                                           "title" : a.getError()[0].message
                                       }, 
                                       function(toast) {
                                           var body = component.get("v.body");
                                           body.push(toast);
                                           component.set("v.body", body);
                                       });
                }
                this.doRefresh(component, event);
            });
            $A.enqueueAction(awAction);
        }      
    },
    
    deleteWallet: function (component, event) {
        this.toggleSpinner(component, event);
        var accountId = component.get("v.recordId");
        if(accountId !=null && accountId!=undefined) {
            var delWAction = component.get("c.deleteUserWallet");
            delWAction.setParams({
                "accountId": accountId
            });
            delWAction.setCallback(this, function(a) {
                var state = a.getState();
                 if(component.isValid() && state == "SUCCESS") {
                    $A.createComponent('c:REIDP_PAToast',
                                       {"title" : "Wallet successfully deleted!"}, 
                                       function(toast) {
                                           var body = component.get("v.body");
                                           body.push(toast);
                                           component.set("v.body", body);
                                       });
                } else if (state == "ERROR") {
                    $A.createComponent('c:REIDP_PAToast',
                                       {
                                           "variant" : "error",
                                           "title" : a.getError()[0].message
                                       }, 
                                       function(toast) {
                                           var body = component.get("v.body");
                                           body.push(toast);
                                           component.set("v.body", body);
                                       });
                }
                this.doRefresh(component, event);
            });
            $A.enqueueAction(delWAction);
        }      
    }
})