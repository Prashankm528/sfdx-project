({
    newCasePage : function(component, event, helper) {
        //Call Controller method to retrieve Task record details
        var getTaskRec = component.get('c.getTaskDetails');           
        getTaskRec.setParams({taskId:component.get('v.recordId')});
        getTaskRec.setCallback(this, function(response) {
            var retVal = response.getReturnValue();
            console.log('retval '+retVal);
            var state = response.getState();
            if (state == 'SUCCESS') {
                console.log('getTaskRec: SUCCESS');
                //Display message when task status is completed
                if(retVal == null){
                    $A.createComponents([
                        
                        ["ui:outputText",{
                            "value" :"A case cannot be created for one of the following reasons.\n\n1. The Task is marked as Completed.\n2. A Case is created for this task already.\n3. You are not allowed to create a case from Task."
                        }]
                    ],
                                        function(components, status, errorMessage){
                                            if (status === "SUCCESS") {
                                                var body = component.get("v.body");
                                                components.forEach(function(item){
                                                    body.push(item);
                                                });
                                                component.set("v.body", body);
                                            }
                                            else if (status === "INCOMPLETE") {
                                                console.log("No response from server or client is offline.")
                                            }
                                                else if (status === "ERROR") {
                                                    console.log("Error: " + errorMessage);
                                                }
                                        }
                                       );
                } else {
                    var orign;
                    var caseChannel;
                    var receivedDate;
                    var businessUnit;
                    if(retVal.GCM_Account__c != undefined){
                		console.log('retval Account BU'+retVal.GCM_Account__r.Business_Unit__c);
                        businessUnit = retVal.GCM_Account__r.Business_Unit__c;
            		}
                    console.log('retrnVal BU'+businessUnit);
                    if(retVal.softphone_it__IWS_Media_Name__c == 'voice'){
                        orign = 'Phone Call';
                        caseChannel = 'Phone';
                        // Get the RecordType Id
                        var getRecordType = component.get('c.getCaseRecordTypeId');           
                        getRecordType.setParams({
                            accBusinessUnit:businessUnit,
                            businessUnit:retVal.GCM_BU__c
                        });
                        getRecordType.setCallback(this, function(response) {
                            var retrnVal = response.getReturnValue();
                            console.log('retrnVal '+retrnVal);
                            console.log('received date '+receivedDate);
                            console.log('caseChannel '+caseChannel);
                            console.log('received date '+retVal.GCM_Call_Start_Date__c);
                            var state = response.getState();
                            if (state == 'SUCCESS') {
                                console.log('getRecordType: SUCCESS');
                                //Call CreateRecord event to open new case page
                                var createCaseEvent = $A.get("e.force:createRecord");
                                createCaseEvent.setParams({
                                    "entityApiName": "Case",
                                    "recordTypeId" : retrnVal,
                                    "defaultFieldValues": {
                                        'Subject' : retVal.Subject,
                                        'Description' : retVal.Description,
                                        'AccountId' : retVal.GCM_Account__c,
                                        'ContactId' : retVal.WhoId,
                                        'Origin' : orign,
                                        'GCM_Case_Channel__c' : caseChannel,
                                        'GCM_Parent_Interaction_Id__c' : retVal.softphone_it__IWS_Interaction_ID__c
                                    }
                                });
                                createCaseEvent.fire();
                            }
                            else if (state == 'INCOMPLETE') {
                                console.log('getRecordType: INCOMPLETE');
                            }else if (state == 'ERROR') {
                                console.log('getRecordType: ERROR');
                            }
                        });
                        $A.enqueueAction(getRecordType);
                    } else if(retVal.softphone_it__IWS_Media_Name__c == 'email'){
                        orign = 'Email';
                        caseChannel = 'Email';
                        receivedDate = retVal.GCM_Call_Start_Date__c;
                        // Get the RecordType Id
                        var getRecordType = component.get('c.getRecordTypeId');           
                        getRecordType.setParams({
                            devName:retVal.GCM_Sales_Organisation__c,
                            sobj:'Case'
                        });
                        getRecordType.setCallback(this, function(response) {
                            var retrnVal = response.getReturnValue();
                            console.log('retrnVal '+retrnVal);
                            console.log('received date '+receivedDate);
                            console.log('caseChannel '+caseChannel);
                            console.log('received date '+retVal.GCM_Call_Start_Date__c);
                            var state = response.getState();
                            if (state == 'SUCCESS') {
                                console.log('getRecordType: SUCCESS');
                                //Call CreateRecord event to open new case page
                                var createCaseEvent = $A.get("e.force:createRecord");
                                createCaseEvent.setParams({
                                    "entityApiName": "Case",
                                    "recordTypeId" : retrnVal,
                                    "defaultFieldValues": {
                                        'Subject' : retVal.Subject,
                                        'Description' : retVal.Description,
                                        'AccountId' : retVal.GCM_Account__c,
                                        'ContactId' : retVal.WhoId,
                                        'Origin' : orign,
                                        'GCM_Case_Channel__c' : caseChannel,
                                        'GCM_Received_Date__c' : receivedDate,
                                        'GCM_Parent_Interaction_Id__c' : retVal.softphone_it__IWS_Interaction_ID__c
                                    }
                                });
                                createCaseEvent.fire();
                            }
                            else if (state == 'INCOMPLETE') {
                                console.log('getRecordType: INCOMPLETE');
                            }else if (state == 'ERROR') {
                                console.log('getRecordType: ERROR');
                            }
                        });
                        $A.enqueueAction(getRecordType);
                    }
                    
                }
            }
            else if (state == 'INCOMPLETE') {
                console.log('getTaskRec: INCOMPLETE');
            }else if (state == 'ERROR') {
                console.log('getTaskRec: ERROR');
            }
        });
        $A.enqueueAction(getTaskRec);
        
    }
})