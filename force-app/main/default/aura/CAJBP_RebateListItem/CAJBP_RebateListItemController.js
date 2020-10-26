/* 
 * @author			Jan Majling
 * @date			09/08/2018
 * @group			CAJBP
 * @description		Controller for CAJBP_RebateListItem component
 *
 * history
 * 09/08/2018	Jan Majling			Created
 * 06/02/2019   Venkatesh Muniyasamy    Modified the component for JBP Currency Assigment and reformating
*/
({
    doInit: function(component, event, helper) {
		component.set('v.turnover',
		    component.get('v.rebate.RecordType.DeveloperName').toLowerCase().includes('turnover')
        );

        var navService = component.find("navService");

        var pageReference = {
            type : 'standard__recordPage',
            attributes: {
                recordId: component.get('v.rebate.Id'),
                objectApiName: 'CAJBP_Rebate__c',
                actionName: 'view'
            }
        };

        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                component.set('v.recordUrl', url);
            }), $A.getCallback(function(error) {
                console.error(error);
            }));
	},

	/**
	 * Calls rebateWizard form..
	 */
	editRecord: function(component, event, helper) {
		var targetRecord = component.get('v.rebate');
        var recordEvent = $A.get('e.c:BPG_EventAction');

        recordEvent.setParams({
            subject: 'CAJBP_EDIT_REBATE',
            detail: {
                recordId: targetRecord.Id,
                scoreCardId: targetRecord.CAJBP_Scorecard__c,
                recordTypeId: targetRecord.RecordTypeId,
                currencyId: targetRecord.CurrencyIsoCode,
                recordTypeName: targetRecord.RecordType.Name,
                recordTypeValues: targetRecord.RecordType.DeveloperName
            }
        });

        recordEvent.fire();
	},

    /**
     * Deletes single rebate record.
     */
	deleteRecord: function(component, event, helper) {
	    var targetRecord = component.get('v.rebate');
        var recordEvent = $A.get('e.c:BPG_EventAction');

        recordEvent.setParams({
            subject: 'BPG_DELETE',
            detail: {
                recordId: targetRecord.Id,
                refresh: true
            }
        });

        recordEvent.fire();
	}
})