({
    toast : function(component, message, variant) {
        $A.createComponent('c:REIDP_PAToast',
                           {
                               "variant" : variant,
                               "title" : message
                           }, 
                           function(toast) {
                               var body = component.get("v.body");
                               body.push(toast);
                               component.set("v.body", body);
                           });
    }, 
    
    toggleSpinner : function(component, event) {
        var spinner = component.find("consumerDetailsSpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
})