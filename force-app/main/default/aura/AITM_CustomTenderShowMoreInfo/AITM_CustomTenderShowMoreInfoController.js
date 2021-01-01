({
	init : function(component, event, helper) {
		helper.getDefaultValuesForCheckboxes(component);
	},

    handleCurrentStage : function(component, event, helper) {
        helper.handleCurrentStage(component, event);
    },

    produceCustomerEmailChangeState : function(component, event, helper) {
    	helper.produceCustomerEmailChangeState(component, event);
    },

    setCheckBoxFeedbackToDeBrief : function(component, event, helper) {
    	helper.setCheckBoxFeedbackToDeBrief(component, event);
    },

    closePopup : function(component, event, helper) {
    	helper.closePopup(component);
    },

    addCustomer : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_AddCustomer');
    },
	
    addGroup : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_AddGroup');
    },
    
    addLocation : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_AddLocations');
    },

    uploadLocation : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_LoadLocations');
    },

    chasePrices : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_TenderInvitationEmailGenerator');
    },
    
    chasePolishPrices : function(component, event, helper) {
        helper.createComponent(component, 'c:AITM_TenderInvitationEmailGeneratorPolish');
    },

    generateOffer : function(component, event, helper) {
        component.set('v.isReportButton', false);
    	helper.createComponent(component, 'c:AITM_TenderOfferContainer');
    },
    
    generateCongaOffer : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_TenderCongaOfferContainer');
    },

    sendOffer : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_GenerateOfferButton');
    },

    sendFeedback : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_GenerateRoundsEmail');
    },

    sendFeedbackPolish : function(component, event, helper) {
        helper.createComponent(component, 'c:AITM_GenerateRoundsEmailPolish');
    },

    sendDeBriefEmail : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_DeBriefEmailGenerator');
    },

    sendDeBriefEmailPolish : function(component, event, helper) {
        helper.createComponent(component, 'c:AITM_DeBriefEmailGeneratorPolish');
    },

    generateContract : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_TenderContractContainer');
    },
	
    generateCongaContract : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_TenderCongaContractContainer');
    },
    
    sendContract : function(component, event, helper) {
    	helper.createComponent(component, 'c:AITM_GenerateContractEmailButton');
    },
    downloadExcelFile: function(component, event, helper) {
       //helper.downloadExcelFile(component);		        
       var isOldTender = component.get('v.isTenderOld');
       if(isOldTender){
           helper.downloadExcelFile(component);
       }else{
           component.set('v.isReportButton', true);
           helper.createComponent(component, 'c:AITM_TenderOfferContainer');
       }
    },
    
     // Added by Prashank to open a subtab for pakage in console 
    openPackageCloneTab:function(component, event){
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openSubtab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__AITM_customAddPackage"
                },
                "state": {
                  c__crecordId: component.get("v.recordId")
         		}
            },
            focus: true
        }).then(function(subtabId){
            workspaceAPI.setTabLabel({
                tabId: subtabId,
                label: "Package"
            });
            workspaceAPI.setTabIcon({
                tabId: subtabId,
                icon: "action:new_case",
                iconAlt: "Package"
            });
        }).catch(function(error) {
            console.log(error);
        });
    },
})