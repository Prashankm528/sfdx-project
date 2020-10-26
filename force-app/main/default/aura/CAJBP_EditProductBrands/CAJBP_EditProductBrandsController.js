/**
 * @author			Venkatesh Muniyasamy
 * @date			13/08/2020
 * @group			CAJBP
 * @description		Edit Product Brands for Product Mix Target Item.
 *
 * history
 * 13/08/2020	Venkatesh Muniyasamy	    Edit Product Brands
 */
({
    loaded: function(component, event, helper) {
        component.set('v.isLoading', false);
    },

    cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    save: function(component, event, helper) {
        component.set('v.isLoading', true);
        component.find('product-brands').saveProductBrands();
    },

    success: function(component, event, helper) {
        component.find('notifLib').showToast({
            title: 'Success!',
            variant: 'success',
            message: 'The Product Brands have been updated successfully.'
        });

        component.set('v.isLoading', false);
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    },

    error: function(component, event, helper) {
        component.find('notifLib').showToast({
            title: 'Error!',
            variant: 'error',
            message: event.getParam('errorMessage'),
            mode: 'sticky'
        });

        component.set('v.isLoading', false);
        $A.get('e.force:closeQuickAction').fire();
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