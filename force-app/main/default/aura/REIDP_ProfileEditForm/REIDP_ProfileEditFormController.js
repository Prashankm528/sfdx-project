({
	handleSave : function(component, event, helper) {
        component.find("editProfile").submit();
        
        var toast = $A.get("e.force:showToast");
        // prepare toast
        toast.setParams({
            message: $A.get("$Label.c.IDPRecordSaved") ,
            duration: '3000',
            type: 'success'
        });
        toast.fire();
        component.set("v.saved", true);
        
        var username = component.find("fname").get("v.value") + ' ' + component.find("lname").get("v.value");
        var usernameEvent = $A.get("e.c:REIDP_UpdateUsername");
        usernameEvent.setParams({ "newUsername" : username});  
        usernameEvent.fire();
        
        $A.get("e.force:closeQuickAction").fire();
	},
    
     handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleLoad : function(component, event, helper) {
        component.set("v.showSpinner", false);
        component.set("v.modalStyle", ".topHeader {z-index:0;} .desktop .viewport{overflow:hidden}");
    },
})