({
    initSOV : function(component) {
        var action = component.get("c.initStatus");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                component.set('v.isDraft',response.getReturnValue().isDraftFlag);
            }
        });
        $A.enqueueAction(action);
        var action = component.get("c.initData");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                               
              component.set('v.mainData',response.getReturnValue().wrapperItemList);
              component.set('v.isloading',false);
            }
        });
        $A.enqueueAction(action);        
    },
    createSOVData :  function(component) {
        var action = component.get("c.createSOV");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                               
               this.initSOV(component);         
            }
        });
        $A.enqueueAction(action);
    }
})