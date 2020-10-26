({
    doInit : function(component, event, helper) {
        var accId = component.get("v.recordId");
        var action = component.get("c.getAccountNames");
        action.setParams({accountId:accId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set('v.accountList',response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    navigate:function(component, event, helper){
        var currentTarget = event.currentTarget;
        var currentAccountId = currentTarget.dataset.value;
        var navService = component.find("navService");
        var pageReference = {    
       "type": "standard__recordPage", //example for opening a record page, see bottom for other supported types
       "attributes": {
       "recordId": currentAccountId, //place your record id here that you wish to open
       "actionName": "view"
        }
        }
        navService.generateUrl(pageReference)
       .then($A.getCallback(function(url) {
       console.log('success: ' + url); //you can also set the url to an aura attribute if you wish
       window.open(url,'_blank'); //this opens your page in a seperate tab here
       }));
        /*var currentTarget = event.currentTarget;
        var currentAccountId = currentTarget.dataset.value;
        console.log(currentAccountId);
        window.open('/' + event.getParam('currentAccountId'));
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": currentAccountId,
            "slideDevName": "detail"
        });
        navEvt.fire();  */ 

             }
})