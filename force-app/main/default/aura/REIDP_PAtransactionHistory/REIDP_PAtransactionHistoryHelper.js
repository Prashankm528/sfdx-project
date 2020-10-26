({
	 toggleSpinner : function(component, event) {
        var spinner = component.find("transactionHistorySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    getTransactions : function(component, event) {
        var status = component.find("selectStatus").get("v.value");
        var startDate =  new Date(component.find("startDate").get("v.value")).getTime();
        var endDate = new Date(component.find("endDate").get("v.value")).getTime();
        
        if(!endDate) {
            endDate = Date.now();
        }
        if(!startDate) {
            startDate = "0000000000";
        }
        
        var accountId = component.get("v.recordId");
	    var pageNum = component.get("v.pageNum");
        
        var accountId = component.get("v.recordId");
        if(accountId != null && accountId != undefined) {
            var ciAction = component.get("c.getConsumerTransactions");       
            ciAction.setParams({
                "accountId": accountId,
                "num" : "" + pageNum,
                "startDate" : startDate,
                "endDate" : endDate,
                "status" : status
            });
            
            ciAction.setCallback(this, function(a) {
                var state = a.getState();
                component.set("v.modalTransaction", []);
                if(component.isValid() && state == "SUCCESS") {
  					component.set("v.modalTransaction", a.getReturnValue());
                    component.set("v.transactions", a.getReturnValue());
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
                this.toggleSpinner(component, event);
            });
            
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.transactions", []);
            h.toggleSpinner(component, event);
        }  
    }
})