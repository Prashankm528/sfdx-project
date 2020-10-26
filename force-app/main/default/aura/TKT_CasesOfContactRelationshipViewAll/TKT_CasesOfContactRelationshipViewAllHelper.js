({
	setCaseColumns : function(component, event, helper) {
                          component.set('v.caseColumns', [
           { label: 'Case Number', fieldName: 'caseNumberUrl', type: 'url', typeAttributes: {label: { fieldName: 'caseNumber' }, target: '_top'} },
           { label: 'Status', fieldName: 'caseStatus', type: 'text'},
           { label: 'Subject', fieldName: 'caseSubject', type: 'text'},
           { label: 'Priority', fieldName: 'casePriority', type: 'text'},
           { label: 'Case Age', fieldName: 'caseAge', type: 'text'},
           { label: 'Contact Email', fieldName: 'caseWebemail', type: 'text'},
           { label: 'Company', fieldName: 'caseCompany', type: 'text'},
           { label: 'Case Origin', fieldName: 'caseOrigin', type: 'text'},
           { label: 'Created Date', fieldName: 'caseCreatedate', type: 'text'}])
    
     },
     
    CaseRecords : function(component, event, helper) {    
        var CaseAllAction = component.get("c.getAllCaseRecords");
        component.set("v.toggleSpinner", true);
		CaseAllAction.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                component.set("v.toggleSpinner", false);
                var caseRecords = response.getReturnValue();
                if(caseRecords.length > 0){
                    console.log('Placement Length-cand'+caseRecords.length);
                    this.setCaseColumns(component, event, helper);
                    component.set("v.caseList", caseRecords);
                }
            }
            else if(state == "ERROR"){
                component.set("v.toggleSpinner", false);
                var errors = CaseAllAction.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMessage",errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(CaseAllAction);
	},
})