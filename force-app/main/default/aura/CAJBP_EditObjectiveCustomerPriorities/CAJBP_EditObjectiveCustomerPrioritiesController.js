({
    loaded: function(component, event, helper) {
        component.set('v.isLoading', false);
    },

    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    save: function(component, event, helper) {
        component.set('v.isLoading', true);
        component.find('objective-priorities').save().then();
    },

    success: function(component, event, helper) {
        component.find('notifLib').showToast({
            title: 'Success!',
            variant: 'success',
            message: 'Related Customer Priorities have been updated successfully.'
        });

        component.set('v.isLoading', false);
        $A.get("e.force:closeQuickAction").fire();
    },

    error: function(component, event, helper) {
        component.find('notifLib').showToast({
            title: 'Error!',
            variant: 'error',
            message: event.getParam('body').message,
            mode: 'sticky'
        });

        component.set('v.isLoading', false);
    },

    handleRecordUpdated: function(component, event, helper) {
        const eventParams = event.getParams();

        switch(eventParams.changeType) {
            case 'LOADED': {
                break;
            }

            case 'ERROR': {
                break;
            }
        }
    }
});