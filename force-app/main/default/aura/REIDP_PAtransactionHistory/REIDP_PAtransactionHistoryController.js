({
    doInit: function(component, event, helper) {
        helper.toggleSpinner(component, event);
        var accountId = component.get("v.recordId");
        var pageNum = component.get("v.pageNum");
        var params = {startDate: "", endDate: "", statuses: [""]};
        if(accountId != null && accountId != undefined) {
            var ciAction = component.get("c.getConsumerTransactions");       
            ciAction.setParams({
                "accountId": accountId,
                "num" : pageNum,
                "startDate" : "",
                "endDate" : "",
                "status" : ""
            }); 
            ciAction.setCallback(this, function(a) {
                var state = a.getState();
                component.set("v.modalTransaction", []);
                if(component.isValid() && state == "SUCCESS") {
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
                helper.toggleSpinner(component,event);
            });
            $A.enqueueAction(ciAction);
        } else {
            component.set("v.transactions", []);
            helper.toggleSpinner(component,event);
        }        
    },
    findTransactions : function(component, event, h) {

        h.toggleSpinner(component, event);
        component.set("v.pageNum", "1");
        var dummy_array = ["1"];
        component.set("v.totalPageCount", dummy_array);
        h.getTransactions(component, event); 
        
    },  

    nextPage : function(component, event, h) {
        h.toggleSpinner(component, event);
        var lastIndex = parseInt(component.get("v.pageNum"));
		var pages = component.get("v.totalPageCount");
        
        lastIndex += 1;
        var i = pages.length;
        while (i--) {
            if (pages[i] === "" + lastIndex){
               break;
            } else {
                pages.push("" + lastIndex);
                break;
            }
        }
        
         
        
        component.set("v.totalPageCount", pages);
        component.set("v.pageNum", "" + lastIndex);
        h.getTransactions(component, event);
    },
    
    goToPage : function (component, event, h) {
        h.toggleSpinner(component, event);
        var goToPage =   event.getSource().get("v.label");
        var pages = component.get("v.totalPageCount");
        component.set("v.totalPageCount", pages);
       	component.set("v.pageNum", "" + goToPage);
        h.getTransactions(component, event);
    }, 
    
    prevPage : function(component, event, h) {
        h.toggleSpinner(component, event);
        var lastIndex = parseInt(component.get("v.pageNum"));
        lastIndex -= 1;
        var pages = component.get("v.totalPageCount");
        component.set("v.totalPageCount", pages);
        component.set("v.pageNum", "" + lastIndex);
        h.getTransactions(component, event);
    },
    
    toggleModal : function(component, event) {
        var i = event.getSource().get("v.value")
        var transactions = component.get("v.transactions");
        var transaction = transactions[i];
        component.set("v.modalTransaction", transaction);
        var modal = component.find("transactionDetailsModal");
        $A.util.toggleClass(modal, "slds-hide");
        
    }
})