/**
* @author           Amirhafeez
* @date             11/10/2019
* @group            CAJBP
* @description      Edit rebate.
*
* history
* 09/08/2018     Amirhafeez              Created
* 04/10/2019     Venkatesh Muniyasamy    Modified for new rebate wizard
* 20/02/2020     Venkatesh Muniyasamy    Modified for new rebate wizard
*/
({
    onCall: function(component, event, helper) {
        if (!helper.verified(component)) {
            return;
        }

        component.find('overlayLib').showCustomModal({
            /*header: "Edit Rebate: " + component.get('v.detail.recordTypeName'),*/
            body: component,
            footer: null,
            cssClass: 'slds-modal_small',
            showCloseButton: true
        });
    },

    onCancel: function(component, event, helper) {
        component.find('overlayLib').notifyClose();
    },

    rebateCreatedAction: function(component, event, helper) {
        component.find('overlayLib').notifyClose();
        $A.get('e.force:refreshView').fire();
    },

    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();

        if(eventParams.changeType === "LOADED") {
            const record = component.get('v.record');
            
            component.set('v.detail', {
                scoreCardId: record.CAJBP_Scorecard__c,
                recordTypeId: record.RecordTypeId,
                recordId: record.Id,
                recordTypeValues: record.RecordType.DeveloperName,
                recordTypeName: record.RecordType.Name,
                currencyId: record.CurrencyIsoCode
            });
        }
    }
});