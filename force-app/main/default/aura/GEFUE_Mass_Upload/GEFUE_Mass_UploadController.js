({
    
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        if (uploadedFiles.length > 0) {
            
            var action = component.get("c.fetchFiles");
            action.setParams({  
                "recordId":uploadedFiles[0].documentId
            });     
            action.setCallback(this,function(response){  
                var state = response.getState();  
                if(state=='SUCCESS'){  
                    var result = response.getReturnValue();
                    component.set("v.fileUploaded", true);
                    component.set('v.stagingColumns', [    
                        			{label: 'Status', fieldName: 'GEFUE_Status__c', type: 'text', initialWidth: 100, "cellAttributes": {"class": {"fieldName": "statusClass"}}},
                                    {label: 'Message', fieldName: 'GEFUE_Message__c', type: 'text', initialWidth: 200},
                                    {label: 'Package', fieldName: 'GEFUE_Package__c', type: 'text', initialWidth: 175, editable:'true'},
                                    {label: 'Sold To', fieldName: 'GEFUE_Account_Number__c', type: 'text', initialWidth: 100, editable:'true', "cellAttributes": {"class": {"fieldName": "accNumberClass"}}},
                                    {label: 'Jobber Name', fieldName: 'GEFUE_Account_Name__c', type: 'text', initialWidth: 200, editable:'true', "cellAttributes": {"class": {"fieldName": "accNameClass"}}},
                                    {label: 'Site Street', fieldName: 'GEFUE_Site_Street__c', type: 'text', initialWidth: 200, editable:'true', "cellAttributes": {"class": {"fieldName": "streetClass"}}},
                                    {label: 'Site City', fieldName: 'GEFUE_Site_City__c', type: 'text', initialWidth: 150, editable:'true', "cellAttributes": {"class": {"fieldName": "cityClass"}}},
                                    {label: 'Site State', fieldName: 'GEFUE_Site_State__c', type: 'text', initialWidth: 75, editable:'true', "cellAttributes": {"class": {"fieldName": "stateClass"}}},
                                    {label: 'DCA/NTI', fieldName: 'GEFUE_DCA_NTI__c', type: 'text', initialWidth: 75, editable:'true', "cellAttributes": {"class": {"fieldName": "dcantiClass"}}},
                                    {label: 'Stage', fieldName: 'GEFUE_Stage__c', type: 'text', initialWidth: 150, editable:'true', "cellAttributes": {"class": {"fieldName": "stageClass"}}},
                        			{label: 'Close Date', fieldName: 'GEFUE_Close_Date__c', type: 'date-local', initialWidth: 150, editable:'true', "cellAttributes": {"class": {"fieldName": "closeDateClass"}}},            
                        			{label: 'Terminal', fieldName: 'GEFUE_Terminal__c', type: 'text', initialWidth: 150, editable:'true', "cellAttributes": {"class": {"fieldName": "terminalClass"}}},
                        			{label: 'Terminal Number', fieldName: 'GEFUE_Terminal_Number__c', type: 'text', initialWidth: 100, editable:'true', "cellAttributes": {"class": {"fieldName": "terminalNumberClass"}}},
                                    {label: 'Estimated Gas Volume', fieldName: 'GEFUE_Volume_Gas__c', type: 'text', initialWidth: 100, editable:'true', "cellAttributes": {"class": {"fieldName": "gasClass"}}},
                                    {label: 'Estimated Diesel Volume', fieldName: 'GEFUE_Volume_Diesel__c', type: 'text', initialWidth: 100, editable:'true', "cellAttributes": {"class": {"fieldName": "dieselClass"}}},
                                    {label: 'Image Amount', fieldName: 'GEFUE_Image_Amount__c', type: 'currency', initialWidth: 100, editable:'true'},
                                    {label: 'CPG', fieldName: 'GEFUE_CPG_Amount__c', type: 'currency', initialWidth: 85, editable:'true'},
                                    {label: 'IRR', fieldName: 'GEFUE_IRR__c', type: 'percent', initialWidth: 85, editable:'true'},
                        			{type: 'button-icon', initialWidth:20 ,typeAttributes: {name: 'delete', iconName: 'action:delete'}}
                    ]);
                    
                    component.set("v.oppStagingData",result);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissible',
                        title: "Success!",
                        message: "Records have been loaded to staging for preview.",
                        type: "success"
                    });
                    toastEvent.fire();
                }  
            });  
            $A.enqueueAction(action);  
        }
    },
    
    validateOppStageRows: function(component, event, helper) {
        var action = component.get("c.validateRows");
        action.setParams({  
            "oppStageRowstoValidate":component.get("v.oppStagingData")
        });
        
        action.setCallback(this, function(response){ 
            var state = response.getState();
            if (state === 'SUCCESS') {
                var records = response.getReturnValue();
                records.forEach(function(record){
                    if (typeof record.Id != 'undefined') {
                        
                        if (record.GEFUE_Account_Number__c == '' || record.GEFUE_Account_Number__c == null) {
                            record.accNumberClass = 'errorBorderCls';
                        }
                        if (record.GEFUE_Account_Name__c == '' || record.GEFUE_Account_Name__c == null) {
                            record.accNameClass = 'errorBorderCls';
                        }
                        if (record.GEFUE_Site_Street__c == '' || record.GEFUE_Site_Street__c == null) {
                            record.streetClass = 'errorBorderCls';
                        }
                        if (record.GEFUE_Site_City__c == '' || record.GEFUE_Site_City__c == null) {
                            record.cityClass = 'errorBorderCls';
                        }
                        if (record.GEFUE_Site_State__c == '' || record.GEFUE_Site_State__c == null) {
                            record.stateClass = 'errorBorderCls';
                        }
                        if (record.GEFUE_DCA_NTI__c == '' || record.GEFUE_DCA_NTI__c == null) {
                            record.dcantiClass = 'errorBorderCls';
                        }
                        if (record.GEFUE_Stage__c == '' || record.GEFUE_Stage__c == null) {
                            record.stageClass = 'errorBorderCls';
                        }
                        if (record.GEFUE_Close_Date__c == '' || record.GEFUE_Close_Date__c == null) {
                            record.closeDateClass = 'errorBorderCls';
                        }
                        if (record.GEFUE_Terminal__c == '' || record.GEFUE_Terminal__c == null) {
                            record.terminalClass = 'errorBorderCls';
                        }
                        if (record.GEFUE_Terminal_Number__c == '' || record.GEFUE_Terminal_Number__c == null) {
                            record.terminalNumberClass = 'errorBorderCls';
                        }
                        
                        if (record.GEFUE_Status__c == $A.get("$Label.c.GEFUE_Error")) {
                            record.statusClass = 'errorCls';
                        } else if (record.GEFUE_Status__c == $A.get("$Label.c.GEFUE_Validated")) {
                            record.statusClass = 'successCls';
                        }
                    }
                });
                component.set("v.oppStagingData", response.getReturnValue());
                
                var oppStagingValidate = component.get("v.oppStagingData");
                var lstValidateStatus = [];
                oppStagingValidate.forEach(function(record){
                    if (record.GEFUE_Status__c == $A.get("$Label.c.GEFUE_Validated")) {
                        lstValidateStatus.push(record.GEFUE_Status__c);
                    }
                });
                
                if (oppStagingValidate.length == lstValidateStatus.length) {
                    component.set("v.notAllValidated", false);
                } else {
                    component.set("v.notAllValidated", true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    onInlineEditSave : function(component, event, helper) {
        var updatedRecords = component.find("stagingTable").get("v.draftValues");
        var action = component.get("c.inlineEditSave");
        action.setParams({  
            "oppStageRowsEdited" : updatedRecords,
            "oppStageRows" : component.get("v.oppStagingData")
        });
        
        action.setCallback(this, function(response){
            component.set("v.notAllValidated", true);
            component.set("v.oppStagingData", response.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
    onCancel: function(component, event, helper) {
		component.set("v.fileUploaded", false);
    },
    
    finalSubmit : function(component, event, helper) {
        component.set("v.fileUploaded", false);
        var action = component.get("c.finalSubmitQueueable");
        action.setParams({
            "lstOppStageFinal" : component.get("v.oppStagingData")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.batchJobId", response.getReturnValue());
                helper.checkJobStatusHelper(component, event, helper);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    handleSelectedRowAction : function(component, event, helper) {
        component.set("v.notAllValidated", true);
        var action = event.getParam('action');
        var row = event.getParam('row');
        if(action.name == 'delete'){
            helper.removeSiteOpp(component, row);
        }
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    }
})