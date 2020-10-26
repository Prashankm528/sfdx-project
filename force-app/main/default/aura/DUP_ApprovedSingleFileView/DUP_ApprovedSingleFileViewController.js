({
    doInit : function(component, event, helper) {
    	component.set("v.tempFileTitle",component.get("v.fileTitle"));
        helper.displayLogic(component, event, helper);
    },

    sendToSP : function(cmp, evt, hlp) {
        hlp.sendToSharepoint(cmp, evt, hlp);
    },

    previewFile : function(cmp, evt, hlp) {
        var rec_id = evt.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });
    },
       
    handleMenuSelect: function(component, event, helper) {
        var selectedMenu = event.detail.menuItem.get("v.value");
        switch(selectedMenu) {
            case "download": helper.downloadDocument(component, event);
                break;
            case "rename": 
                var fileId = component.get("v.fileId");
                component.set("v.isModalOpen", true);
                break;
            
        }
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false   
        component.set("v.isModalOpen", false);
    },
    saveFileName: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        var specialChars = $A.get("$Label.c.DUP_CharactersNotAllowed");
        var fileName = component.find('fileName').get("v.value");
        var isValidName = true;
       Array.from(specialChars).forEach((char, idx) => {
                if (fileName.indexOf(char) > -1) {
            	isValidName = false;
        		//component.set("v.tempFileTitle",fileName);
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please ensure that file name does not contain any special characters or symbols, and try to upload the file again.",
                    "type" : "error"
                });
                toastEvent.fire();
        
                }
    			
        
    });
        if(isValidName){
            component.set("v.fileTitle",fileName);
            helper.saveFileName(component, event);
        }else{
            component.set("v.tempFileTitle",component.get("v.fileTitle"));
        }
}

})