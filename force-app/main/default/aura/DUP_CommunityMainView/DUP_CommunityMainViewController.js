/*****************************************************************************************
*       Date:        19Set2019
*       Author:      Alessandro Miele - IBM
*       Description: Js Controller for DUP_CommunityMainView 
*****************************************************************************************/
({
    doInit : function(cmp, evt, hlp){
        var action = cmp.get("c.getLoggedInUser");
        action.setCallback(this, function(response) {
            var showVideo = response.getReturnValue();
            cmp.set("v.closeVideo",showVideo);
        });
        $A.enqueueAction(action);
    },
    
    searchDocuments: function(cmp, evt, hlp) {
        var docReqName = evt.getParam("selectedId");
        cmp.set("v.isCertifiedPresent",false) ;
        hlp.searchDocuments(cmp,evt,hlp,docReqName);
    },

    submitDocuments: function(cmp, evt, hlp) {
        hlp.submitDocuments(cmp, evt, hlp);
        window.setTimeout(
            $A.getCallback(function () {
				cmp.find("docRequests").handleRefresh();                
            }), 2000
        );
    },

    logout : function(component, event, helper) {
        window.location.replace("https://dupdev-bpcustomer.cs87.force.com/BPISTDUP/secur/logout.jsp");
    },
    closeVideo : function(component, event, helper) {
        component.set("v.closeVideo",false);
    },
 
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
	handleExpand :function(cmp,event,helper){
        if(cmp.get("v.expand")){
            cmp.set("v.expand",false);
            $A.util.toggleClass(cmp.find("collapseDocs"), 'slds-hide');
            $A.util.toggleClass(cmp.find("expandDocs"), 'slds-hide');
        }
        else{
            cmp.set("v.expand", true);
            $A.util.toggleClass(cmp.find("expandDocs"), 'slds-hide');
            $A.util.toggleClass(cmp.find("collapseDocs"), 'slds-hide');
        }
        
        console.log(cmp.get("v.expand"))
    }
    
})