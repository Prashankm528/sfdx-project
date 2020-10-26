({
	 toggleSpinner : function(component, event) {
        var spinner = component.find("cardDetailsSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    doRefresh: function(component, event) {
      this.toggleSpinner(component, event);
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
                this.toggleSpinner(component,event);
            });
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.cardsInfo", []);
            this.toggleSpinner(component,event);
        }       
    }
})