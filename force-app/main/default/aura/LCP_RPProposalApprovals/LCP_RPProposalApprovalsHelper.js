({
    fetchloggedInDetails : function(component) {
        var action = component.get("c.fetchLoggedInInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {  
                component.set('v.isBpManager',"true");
            }
        });           
        $A.enqueueAction(action);
    },
    fetchRPProposalRecord : function(component, event) {
        var rpproposalId = component.get('v.rpProposalId');
        var action = component.get("c.fetchRPProposalRecord");
        action.setParams({
            rpproposalId : rpproposalId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State returned>>>>'+state);
            if (state === "SUCCESS") {  
                var responseValue = response.getReturnValue();
                component.set('v.rpRec',responseValue.wrapperRpRecords);
                component.set('v.rpRecId',responseValue.wrapperRpRecords.Id);
                component.set('v.tobeRevProposalRec',responseValue.wrapperTobeRevProposalRec);
                component.set('v.approvedRpProposals',responseValue.wrapperApprovedRpProposalsRecords);
                component.set('v.rpfieldNames',responseValue.wrapperrpfieldsList);
                component.set('v.rpPropfieldNames',responseValue.wrapperRpProposalFieldList);
                component.set('v.labelMap',responseValue.wrapperlistOflabelsMap);
                component.set('v.noToBeReviewedRecordsFound',responseValue.noToBeReviewedRecordsErrorMsg);
                component.set('v.noApprovedProposalRecordsFound',responseValue.noApprovedProposalRecordsErrorMsg);
                var allValues = responseValue.wrapperRpApprovedFieldList; // apiNames
                var labelMap=responseValue.wrapperlistOflabelsMap;
                var actions = [{ label: 'Show details', name: 'show_details' },
                               { label: 'Edit details', name: 'edit_details' }];
                var columnsJson = [];
                columnsJson.push({ type: 'action', typeAttributes: { rowActions: actions } });
                for(var i=0; i<responseValue.wrapperRpApprovedFieldList.length; i++){
                    var fieldName=allValues[i];
                    columnsJson.push({
                        fieldName: fieldName,
                        label:labelMap[fieldName],
                        sortable:true,
                        initialWidth: 200,
                    });
                }
                console.log('!!!!JSON' + JSON.stringify(columnsJson));
                component.set('v.columns',columnsJson);
            }
        });           
        $A.enqueueAction(action);
    }
})