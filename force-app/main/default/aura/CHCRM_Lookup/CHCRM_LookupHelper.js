({
    searchAccount : function(component, searchStr) {
        
        var action = component.get("c.query");
        action.setParams({queryStr:searchStr, objName : component.get("v.objName")});
        
        action.setCallback(this, function(actionResult) {
            console.log( actionResult.getReturnValue());
            component.set("v.queryItems", actionResult.getReturnValue());
            this.openDropDownList(component);
        });
        $A.enqueueAction(action);        
        
    },     
    openDropDownList : function(component) {
        $A.util.addClass(component.find("lookupDropList"), "slds-is-open");
    },
    
    closeDropDownList : function(component) {
        $A.util.removeClass(component.find("lookupDropList"), "slds-is-open");
    },
    openObjectList : function(component) {

        $A.util.addClass(component.find("objectSelectList"), "slds-is-open");

    },
    closeObjectList : function(component) {

        $A.util.removeClass(component.find("objectSelectList"), "slds-is-open");

    },    
    initSelectedItem : function(component) {
        component.set("v.selectedName", '');
        component.set("v.selectedId", '');
    }      
})