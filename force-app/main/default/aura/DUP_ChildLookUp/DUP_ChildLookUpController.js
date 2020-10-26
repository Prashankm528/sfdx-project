({ 
    doinit : function(component, event, helper) {
        var icon = component.get("v.iconName");
        var Object = component.get("v.sObject");
    },
    
    onOptionClick : function(component, event, helper) {
        var selVal  = component.get("v.myData");
        var cmpName  = component.get("v.cmpName");
        if(cmpName!="ChangeCP"){
            var itemid = component.get("v.itemId");
            var objName = component.get("v.objectName");
            var groupTitle = component.get("v.groupTitle");
            var evt = component.getEvent("LookupEventToParent");
            evt.setParams({
                selectedItem : selVal,
                itemId : itemid,
                objectName : objName,
                groupTitle : groupTitle
            });
            evt.fire();
        }
        else{
            var evt = component.getEvent("LookupEventToParent");
            evt.setParams({
                selectedItem : selVal
            });
            evt.fire();
        }
        
    }
})