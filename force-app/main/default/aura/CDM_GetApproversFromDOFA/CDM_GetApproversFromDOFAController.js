({
	/** dosave method **/
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        } else {
             var toastEvent = $A.get("e.force:showToast");
                    if(toastEvent) {
                        toastEvent.setParams({
                            "title": "Select a Valid File!",
                            "message":  "Please Select a Valid File"
                        });
                        toastEvent.fire();
                    }
           
        }
    },
 /** input file event change  **/
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
})