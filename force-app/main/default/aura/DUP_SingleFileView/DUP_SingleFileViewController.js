({
    doInit : function(component, event, helper) {
        helper.displayLogic(component, event, helper);
    },

    deleteDocument : function(component, event, helper) {
        helper.deleteDocumentAndRefresh(component, event, helper);
    },

    rejectDocumentNoRequest : function(cmp, evt, hlp) {
        hlp.rejectDocumentNoReq(cmp, evt, hlp);
    },

    rejectDocumentWithRequest : function(cmp, evt, hlp) {
        hlp.rejectDocumentWithReq(cmp, evt, hlp);
    },

    approveDocument : function(cmp, evt, hlp) {
        hlp.approveDocument(cmp, evt, hlp);
    },    

    previewFile : function(cmp, evt, hlp) {
        var rec_id = evt.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ 
            recordIds: [rec_id]
        });
    },
    
    openRejectModal : function(cmp, evt, hlp) {
        cmp.set('v.isActive', true);
    },
    
    handleCancel : function(cmp, evt, hlp) {
        cmp.set('v.isActive', false);
    },

    handleOnload : function(cmp, evt, hlp) {
        var rejectComment = cmp.get("v.document.DUP_Reject_Comments__c");
        cmp.find("rejectComment").set("v.value", rejectComment);
    },   
})