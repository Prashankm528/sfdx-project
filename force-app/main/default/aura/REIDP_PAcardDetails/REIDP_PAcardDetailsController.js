({
    doInit: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var accountId = component.get("v.recordId");
        if(accountId != null && accountId != undefined) {
            var ciAction = component.get("c.getConsumerCards");
            ciAction.setParams({
                "accountId": accountId
            });
            ciAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    component.set("v.cardsInfo", a.getReturnValue());
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
                helper.toggleSpinner(component, event);
            });
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.cardsInfo", []);
            helper.toggleSpinner(component,event);
        }        
    },
    
    deleteCard: function (component, event, helper) {
        var accountId = component.get("v.recordId");
        var cardUri = event.getParam("value");
        if(accountId !=null && accountId!=undefined
           && cardUri != null && cardUri != undefined) {
            var dwAction = component.get("c.deleteConsumerCard");
            dwAction.setParams({
                "accountId": accountId,
                "cardUri": cardUri
            });
            dwAction.setCallback(this, function(a) {
                var state = a.getState();
                if(component.isValid() && state == "SUCCESS") {
                    $A.createComponent('c:REIDP_PAToast',
                                       {"title" : "Card successfully deleted!"}, 
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
                helper.doRefresh(component, event, helper);
            });
            $A.enqueueAction(dwAction);
        }      
    }
})