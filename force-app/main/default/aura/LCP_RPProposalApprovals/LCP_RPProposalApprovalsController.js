({
    doInit : function(component, event, helper) {
        helper.fetchRPProposalRecord(component, event);
        helper.fetchloggedInDetails(component);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
    },
    //Reviewing the RP Proposal Record
    onReviewedRecordSubmit: function(component, event, helper) {
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields["LCP_Status__c"] = "Reviewed";
        eventFields["Approved_Reviewed_Date__c"] = component.get('v.today');
        component.find('rpproposalform').submit(eventFields);
    },
    //On sucessful of Reviewing the RP Proposal showing the below PopUp message 
    onReviewedRecordSuccess: function(component, event, helper){
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": "Proposal Reviewed",
            "message": "Proposal Reviewed and added to history sucessfully"
        });
        resultsToast.fire();
    },
    
    //Approving the RP Proposal Record and updating the RP record fields with respect to the RP Proposal Fields
    onApprovedRecordSubmit : function(component, event, helper) {
        event.preventDefault(); // stop form submission
        var eventFields = event.getParam("fields");
        eventFields["LCP_Status__c"] = "Approved";
        eventFields["LCP_Channel__c"] = true;
        eventFields["Approved_Reviewed_Date__c"] = component.get('v.today');
        component.find('rpproposalApprovedform').submit(eventFields);
        component.find('rpform').submit(eventFields);
    },
    
    //On sucessful of Approving the RP Proposal showing the below PopUp message 
    onApprovedRecordSuccess: function(component, event, helper){
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": "Proposal Approved",
            "message": "Proposal Approved and added to history sucessfully"
        });
        resultsToast.fire();
    },
    
    editRpRec : function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get('v.rpRecId')
        });
        editRecordEvent.fire();
    }
})