/**
 * Created by Alessandro Miele 2019-10-18
 */
({   
    showSpinner: function(cmp) {
        var spinner = cmp.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
    },

    loadFile : function(cmp, evt, hlp) {
        var action = cmp.get("c.getFile");
        action.setParams({ 
            "docStoreId": cmp.get("v.documentId")
        }); 
        
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == null){
                    return;
                }                
                cmp.set("v.contentDocument" , result.contentDocumentLinkList);
                cmp.set("v.fileInfoList" , result.fileInfoList);                 
            } else {
                console.log('Problem updating document status, response state: ' + state);
            }
        });
        $A.enqueueAction(action);        
    },
    
    hideSpinner: function(cmp, evt, hlp) {
        var spinner = cmp.find('spinner');  
        $A.util.addClass(spinner, 'slds-hide');
    }
})