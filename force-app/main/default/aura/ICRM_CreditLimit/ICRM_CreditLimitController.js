({
    handleApplicationEvent : function(component, event, helper) {
        var message = event.getParam("CPID");
        var recId = event.getParam("recId");
        component.set("v.CPID", message);
        component.set("v.recordId", recId);
    }
})