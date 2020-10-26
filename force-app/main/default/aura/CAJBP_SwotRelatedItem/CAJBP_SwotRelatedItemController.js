/**
 * Created by amirhafeez on 18/03/2020.
 */
({
    doInit: function(component, event, helper) {
        helper.load(component);
    },

    viewSwot: function(component, event, helper) {
        event.preventDefault();

        const swotId = event.target.getAttribute('data-id');
        var navService = component.find("navService");

        var pageReference = {
            type : 'standard__recordPage',
            attributes: {
                recordId : swotId,
                objectApiName: 'CAJBP_SWOT__c',
                actionName: 'view'
            }
        };

        navService.navigate(pageReference);
    },

    editSwot: function(component, event, helper) {
        event.preventDefault();

        const swotId = event.target.getAttribute('data-id');
        var navService = component.find("navService");

        var pageReference = {
            type : 'standard__recordPage',
            attributes: {
                recordId : swotId,
                objectApiName: 'CAJBP_SWOT__c',
                actionName: 'edit'
            }
        };

        navService.navigate(pageReference);
    }
});