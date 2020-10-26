({
    doInit : function(component, event, helper) {
        helper.createNewDocStore(component, event, helper);
        helper.loadData(component, event, helper);
    },

    handleDocStore : function(component, event, helper) {
       helper.handleValidation(component, event, helper);
    },

    displayTemplate : function(component, event, helper) {
        helper.loadTemplateValues(component, event, helper);
    },
    
    handleCancel : function(component, event, helper) {
        helper.deleteDocStore(component, event, helper);
    },
    showUploadedDocument : function(component, event, helper) {
        //helper.updateStatusAndGetFileList(component, event, helper);
        helper.shareWithCounterParty(component, event, helper);
    },
    changeVal : function(component, event, helper) {
		var selected = event.getSource().get("v.value");
        if(selected!='' && selected!= null){
            component.find("fileUploadButton").set("v.disabled",true);
            var templates= component.get("v.docTemplateList");
            for(var key in templates){
                if(templates[key].Id == selected){
                    component.set("v.selectedTemplate",templates[key].Name);
                    break;
                }
            }
        }
        else{
            component.find("fileUploadButton").set("v.disabled",false);
        }
    },
    
    handledeletedFiles : function(component, event, helper) {
		var contentDocument = event.getParam("contentDocument");
        component.set("v.contentDocument",contentDocument)
    }
})