({
    proposeRPChanges : function(component) {
        var rpId = component.get('v.rprecordId');
        console.log('id for'+rpId);
        var action = component.get("c.fetchExistingRpProposalDetails");
        action.setParams({
            "rpId" : rpId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue().IsRpHavingToBeReviewedProposal){
                    this.showToastMsg('Selected Rp is already having propose changes');
                }else{
                    var createRecordEvent = $A.get("e.force:createRecord");
                    if(response.getReturnValue().CurrentRpTemplateName == 'Standard'){
                        var rpdata = response.getReturnValue().rprecData;
                        createRecordEvent.setParams({
                            'entityApiName': 'LCP_Reporting_Period_Proposal__c',
                            "recordTypeId": response.getReturnValue().selectedRPRecordTypeID,
                            'defaultFieldValues': {
                                'LCP_Reporting_Period__c' : rpdata.Id,
                                'Name' : rpdata.Name,
                                'LCP_Status__c':'To be reviewed',
                                'LCP_Report_Submitted__c':rpdata.LCP_Report_Submitted__c,
                                'LCP_Report_Net_Volume__c':rpdata.LCP_Report_Net_Volume__c,
                                'LCP_Type__c':rpdata.LCP_Type__c,
                                'LCP_Verifier__c':rpdata.LCP_Verifier__c,
                                'LCP_Start__c':rpdata.LCP_Start__c,
                                'LCP_End__c':rpdata.LCP_End__c,
                                'LCP_Net_Volume_Verified__c':rpdata.LCP_Net_Volume_Verified__c,
                                'LCP_Issuance_Date__c':rpdata.LCP_Issuance_Date__c,
                                'LCP_Issued_Volume__c':rpdata.LCP_Issued_Volume__c,
                                'LCP_Issued_Credit_Type__c' : rpdata.LCP_Issued_Credit_Type__c,
                                'LCP_Volume_to_BP__c':rpdata.LCP_Volume_to_BP__c,
                                'LCP_Credits_not_cash__c':rpdata.LCP_Credits_not_cash__c,
                                'LCP_Delivered_and_No_Conv__c':rpdata.LCP_Delivered_and_No_Conv__c,
                                'LCP_Delivered_Conv_Required__c':rpdata.LCP_Delivered_Conv_Required__c,
                                'LCP_Delivery_Date__c':rpdata.LCP_Delivery_Date__c,
                                'LCP_Conversion_Req_Before_Delivery__c':rpdata.LCP_Conversion_Req_Before_Delivery__c,
                                'LCP_Conversion_Application__c':rpdata.LCP_Conversion_Application__c,
                                'LCP_Conversion_Detail__c':rpdata.LCP_Conversion_Detail__c,
                                'LCP_Conversion_Approval__c':rpdata.LCP_Conversion_Approval__c,
                                'LCP_Converted_Net_Volume__c':rpdata.LCP_Converted_Net_Volume__c,
                                'LCP_Converted_Credit_Type__c':rpdata.LCP_Converted_Credit_Type__c,
                                'LCP_Volume_to_BP_2__c':rpdata.LCP_Volume_to_BP_2__c,
                                'LCP_Credits_not_cash2__c':rpdata.LCP_Credits_not_cash2__c,
                                'LCP_Delivery_Date2__c':rpdata.LCP_Delivery_Date2__c,
                                'LCP_Conv_Credits_Delivered__c':rpdata.LCP_Conv_Credits_Delivered__c,
                                'LCP_Project_Cycle_Updates__c':rpdata.LCP_Project_Cycle_Updates__c,
                                'LCP_Operational_Updates__c':rpdata.LCP_Operational_Updates__c,
                                'LCP_EHS_Violations_or_Issues__c':rpdata.LCP_EHS_Violations_or_Issues__c,
                                'LCP_social_community_bio__c':rpdata.LCP_social_community_bio__c,
                                'LCP_Non_C_Standard__c':rpdata.LCP_Non_C_Standard__c,
                                'LCP_Non_C_Std_Status__c':rpdata.LCP_Non_C_Std_Status__c,
                                'LCP_Reversal_Risk__c':rpdata.LCP_Reversal_Risk__c,
                                'LCP_Invalidation__c':rpdata.LCP_Invalidation__c,
                                'LCP_percent_to_recognise__c':rpdata.LCP_percent_to_recognise__c,
                                'LCP_Recognition_Comments__c':rpdata.LCP_Recognition_Comments__c,
                                'LCP_Report_Submitted_Color_code__c' 	: rpdata.LCP_Report_Submitted_Color_code__c,
                                'LCP_Report_net_volume_Color_code__c' 	: rpdata.LCP_Report_net_volume_Color_code__c,
                                'LCP_Type_Color_code__c'				: rpdata.LCP_Type_Color_code__c,
                                'LCP_Verifier_Color_code__c'			: rpdata.LCP_Verifier_Color_code__c,
                                'LCP_Start_Color_code__c'				: rpdata.LCP_Start_Color_code__c,
                                'LCP_End_Color_code__c'					: rpdata.LCP_End_Color_code__c,
                                'LCP_Net_Volume_verified_Color_code__c'	: rpdata.LCP_Net_Volume_verified_Color_code__c,
                                'LCP_Issuance_Date_Color_code__c'		: rpdata.LCP_Issuance_Date_Color_code__c,
                                'LCP_Issued_volume_Color_code__c'		: rpdata.LCP_Issued_volume_Color_code__c,
                                'LCP_Volume_to_bp_Color_code__c'		: rpdata.LCP_Volume_to_bp_Color_code__c,
                                'LCP_Delivery_Date_Color_code__c'		: rpdata.LCP_Delivery_Date_Color_code__c,
                                'LCP_Conversion_Application_Color_code__c'	: rpdata.LCP_Conversion_Application_Color_code__c,
                                'LCP_Conversion_Approval_Color_code__c'		: rpdata.LCP_Conversion_Approval_Color_code__c,
                                'LCP_Converted_net_volume_Color_code__c'	: rpdata.LCP_Converted_net_volume_Color_code__c,
                                'LCP_Volume_to_bp2_Color_code__c'			: rpdata.LCP_Volume_to_bp2_Color_code__c,
                                'LCP_Delivery_Date2_Color_code__c'			: rpdata.LCP_Delivery_Date2_Color_code__c,
                                'LCP_Reversal_Risk_Color_code__c'			: rpdata.LCP_Reversal_Risk_Color_code__c,
                            }
                        });}
                    if(response.getReturnValue().CurrentRpTemplateName == 'CALIFORNIA'){
                        var rpdata = response.getReturnValue().rprecData;
                        createRecordEvent.setParams({
                            'entityApiName': 'LCP_Reporting_Period_Proposal__c',
                            "recordTypeId": response.getReturnValue().selectedRPRecordTypeID,
                            'defaultFieldValues': {
                                'LCP_Reporting_Period__c' 	: rpId,
                                'Name' : rpdata.Name,
                                'LCP_Status__c'				:'To be reviewed',
                                'LCP_OPDR_Submitted__c'		:rpdata.LCP_OPDR_Submitted__c,
                                'LCP_OPDR_Net_Volume__c'	:rpdata.LCP_OPDR_Net_Volume__c,
                                'LCP_Type__c'				:rpdata.LCP_Type__c,
                                'LCP_Verifier__c'			:rpdata.LCP_Verifier__c,
                                'LCP_Start__c'				:rpdata.LCP_Start__c,
                                'LCP_End__c'				:rpdata.LCP_End__c,
                                'LCP_Net_Volume_Verified__c':rpdata.LCP_Net_Volume_Verified__c,
                                'LCP_ROC_Issuance_Date__c'	:rpdata.LCP_ROC_Issuance_Date__c,
                                'LCP_ROC_Net_Volume__c'		:rpdata.LCP_ROC_Net_Volume__c,
                                'LCP_ARBOC_Issuance__c'		:rpdata.LCP_ARBOC_Issuance__c,
                                'LCP_ARBOC_Issuance_Date__c':rpdata.LCP_ARBOC_Issuance_Date__c,
                                'LCP_Volume_to_BP__c'		:rpdata.LCP_Volume_to_BP__c,
                                'LCP_Credits_not_cash__c'	:rpdata.LCP_Credits_not_cash__c,
                                'LCP_Transfer_Date__c'		:rpdata.LCP_Transfer_Date__c,
                                'LCP_Project_Cycle__c'		:rpdata.LCP_Project_Cycle__c,
                                'LCP_Operations__c'			:rpdata.LCP_Operations__c,
                                'LCP_EHS_Compliance__c'		:rpdata.LCP_EHS_Compliance__c,
                                'LCP_social_community_bio__c':rpdata.LCP_social_community_bio__c,
                                'LCP_Conv_Credits_Delivered__c':rpdata.LCP_Conv_Credits_Delivered__c,
                                'LCP_Reversal_Risk__c'		:rpdata.LCP_Reversal_Risk__c,
                                'LCP_Invalidation__c'		:rpdata.LCP_Invalidation__c,
                                'LCP_recognition__c'		:rpdata.LCP_recognition__c,
                                'LCP_Recognition_Comments__c':rpdata.LCP_Recognition_Comments__c,
                                'LCP_OPDR_Submitted_Color_code__c' : rpdata.LCP_OPDR_Submitted_Color_code__c,
                                'LCP_OPDR_net_Volume_Color_code__c' : rpdata.LCP_OPDR_net_Volume_Color_code__c,
                                'LCP_Type_Color_code__c' : rpdata.LCP_Type_Color_code__c,
                                'LCP_Verifier_Color_code__c' : rpdata.LCP_Verifier_Color_code__c,
                                'LCP_Start_Color_code__c'				: rpdata.LCP_Start_Color_code__c,
                                'LCP_End_Color_code__c'					: rpdata.LCP_End_Color_code__c,
                                'LCP_Net_Volume_verified_Color_code__c' : rpdata.LCP_Net_Volume_verified_Color_code__c,
                                'LCP_ROC_Issuance_Date_Color_code__c' : rpdata.LCP_ROC_Issuance_Date_Color_code__c,
                                'LCP_ROC_net_Volume_Color_code__c' : rpdata.LCP_ROC_net_Volume_Color_code__c,
                                'LCP_ARBOC_Issuance_Color_code__c' : rpdata.LCP_ARBOC_Issuance_Number_Color_code__c,
                                'LCP_ARBOC_Issuance_Number_Color_code__c': rpdata.LCP_ARBOC_Issuance_Color_code__c,
                                'LCP_Volume_to_bp_Color_code__c' : rpdata.LCP_Volume_to_bp_Color_code__c,
                                'LCP_Transfer_Date_Color_code__c' : rpdata.LCP_Transfer_Date_Color_code__c,
                                'LCP_Reversal_Risk_Color_code__c' : rpdata.LCP_Reversal_Risk_Color_code__c,
                            }
                        });}
                    if(response.getReturnValue().CurrentRpTemplateName == 'Conversion Only'){
                        var rpdata = response.getReturnValue().rprecData;
                        createRecordEvent.setParams({
                            'entityApiName': 'LCP_Reporting_Period_Proposal__c',
                            "recordTypeId": response.getReturnValue().selectedRPRecordTypeID,
                            'defaultFieldValues': {
                                'LCP_Reporting_Period__c' : rpId,
                                'Name' : rpdata.Name,
                                'LCP_Status__c': 'To be reviewed',
                                'LCP_Conversion_Application__c' : rpdata.LCP_Conversion_Application__c,
                                'LCP_Conversion_Detail__c'		: rpdata.LCP_Conversion_Detail__c,
                                'LCP_Conversion_Approval__c'	: rpdata.LCP_Conversion_Approval__c,
                                'LCP_Converted_Net_Volume__c'	: rpdata.LCP_Converted_Net_Volume__c,
                                'LCP_Converted_Credit_Type__c'	: rpdata.LCP_Converted_Credit_Type__c,
                                'LCP_Volume_to_BP_2__c'			: rpdata.LCP_Volume_to_BP_2__c,
                                'LCP_Credits_not_cash2__c'		: rpdata.LCP_Credits_not_cash2__c,
                                'LCP_Delivery_Date2__c'			: rpdata.LCP_Delivery_Date2__c,
                                'LCP_Conv_Credits_Delivered__c'	: rpdata.LCP_Conv_Credits_Delivered__c,
                                'LCP_Project_Cycle__c'			: rpdata.LCP_Project_Cycle__c,
                                'LCP_Operations__c'				: rpdata.LCP_Operations__c,
                                'LCP_EHS_Compliance__c'			: rpdata.LCP_EHS_Compliance__c,
                                'LCP_social_community_bio__c'	: rpdata.LCP_social_community_bio__c,
                                'LCP_recognition__c'			: rpdata.LCP_recognition__c,
                                'LCP_Recognition_Comments__c'	: rpdata.LCP_Recognition_Comments__c,
                                'LCP_Conversion_Application_Color_code__c' : rpdata.LCP_Conversion_Application_Color_code__c,
                                'LCP_Conversion_Approval_Color_code__c' : rpdata.LCP_Conversion_Approval_Color_code__c,
                                'LCP_Converted_net_volume_Color_code__c' : rpdata.LCP_Converted_net_volume_Color_code__c,
                                'LCP_Volume_to_bp2_Color_code__c' : rpdata.LCP_Volume_to_bp2_Color_code__c,
                                'LCP_Delivery_Date2_Color_code__c' : rpdata.LCP_Delivery_Date2_Color_code__c,
                                
                            }
                        });
                    }
                    createRecordEvent.fire();
                }  
            }
        });           
        $A.enqueueAction(action); 
    },
    showToastMsg : function(errorMsg){
        var showToast = $A.get( "e.force:showToast" );   
        showToast.setParams({   
            message : errorMsg,  
            type : 'error',  
            mode : 'sticky'  
        });   
        showToast.fire(); 
    }
})