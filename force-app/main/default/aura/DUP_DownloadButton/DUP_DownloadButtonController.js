({
    doInit : function(component, event, helper) {
        helper.checkPermission(component, event, helper);
    },
    
	downloadDocument: function(cmp, evt, hlp){
        var downloadUrl= $A.get("e.force:navigateToURL");
        var fileId = cmp.get("v.fileId");
        var baseUrl = $A.get("$Label.c.BPISTDUPLightningBaseUrl");
        
        downloadUrl.setParams({
            "url": baseUrl + '/sfc/servlet.shepherd/document/download/' + fileId
        });
        downloadUrl.fire();
    }
})