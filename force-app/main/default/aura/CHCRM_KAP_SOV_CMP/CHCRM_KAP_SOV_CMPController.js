({
    init : function(component, event, helper) {
        component.set('v.isloading',true);
        helper.initSOV(component);
    },
    createSOVData : function(component, event, helper) {
        component.set('v.isloading',true);
        helper.createSOVData(component);
    }
    
    
})