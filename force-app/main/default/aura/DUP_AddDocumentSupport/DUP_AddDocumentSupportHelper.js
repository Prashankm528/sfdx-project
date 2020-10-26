/**
 * Created by Mayuri Basutkar on 2019-09-03
 * Updated by Alessandro Miele
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
                cmp.set("v.contentDocument", result);
                var notApprovedFiles = result.length;
                for (var i = 0; i < result.length; i++) {
                    if(result[i].ContentDocument.LatestPublishedVersion.DUP_Status__c == 'Approved' ||
                       result[i].ContentDocument.LatestPublishedVersion.DUP_Status__c == 'Template'){
                        notApprovedFiles -= 1;
                    }
                }
                cmp.set("v.counterFiles", notApprovedFiles);  
                
            } else {
                console.log('Problem loading document stores, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    hideSpinner: function(cmp, evt, hlp) {
        var spinner = cmp.find('spinner');  
        $A.util.addClass(spinner, 'slds-hide');
    },
    
    toshowornot: function(cmp, evt, hlp){
        var docstatus = cmp.get('v.document.DUP_Document_Status__c');
        var rej_comments = cmp.get('v.document.DUP_RejectComments_Available__c');
        
        if((docstatus=='Uploaded' ||docstatus=='Reviewed') || (docstatus=='Requested' && rej_comments))
        {
            cmp.set('v.toshow', true);
        }
        else 
        {
            cmp.set('v.toshow', false);
        }
    }
})