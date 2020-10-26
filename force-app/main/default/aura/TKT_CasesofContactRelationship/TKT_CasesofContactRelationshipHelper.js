({
     setCaseColumns : function(component, event, helper) {
                          component.set('v.casesColumns', [
           { label: 'Case Number', fieldName: 'caseNumberUrl', type: 'url', typeAttributes: {label: { fieldName: 'caseNumber' }, target: '_top'} },
           { label: 'Status', fieldName: 'caseStatus', type: 'text'},
           { label: 'Case Age', fieldName: 'caseAge', type: 'text'},
           { label: 'Contact Email', fieldName: 'caseWebemail', type: 'text'},
           { label: 'Company', fieldName: 'caseCompany', type: 'text'}])	
    
     },
     
	 caseRecords : function(component, event, helper) {
		var caseAction = component.get("c.getCaseRecords");
        component.set("v.toggleSpinner", true);

		 caseAction.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.toggleSpinner", false);
                var caseRecs = response.getReturnValue();
                if(caseRecs.length > 0){
                    console.log('Case Length'+caseRecs.length);
                    this.setCaseColumns(component, event, helper);
                    component.set("v.caseList", caseRecs);
                }
            }
            else if(state == "ERROR"){
                component.set("v.toggleSpinner", false);
                var errors = caseAction.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMessage",errors[0].message);
                    }
                }
            }
        });
		$A.enqueueAction(caseAction);
	 }
})