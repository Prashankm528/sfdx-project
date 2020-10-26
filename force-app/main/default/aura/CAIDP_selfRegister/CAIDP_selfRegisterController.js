({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        component.set('v.extraFields', helper.getExtraFields(component, event, helper));
        component.set('v.allCountries', helper.getCountries(component, event, helper));
        var fixedEmail = helper.getUrlParameter('email');
        var fullEmail = component.get("v.emailInput");
        if (fixedEmail) {
            helper.setCookie("fixedEmail", fixedEmail);
        }
        // ??
        //component.set(fullEmail, helper.getCookie("fixedEmail"));
    },
    
    handleSelfRegister: function (component, event, helper) {
        console.log('handleSelfRegister');
        helper.handleSelfRegisteration(component, event, helper);
        
    },
    
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },

    onKeyUp: function(component, event, helper) {
        //checks for "enter" key
        if (event.which === 13) {
            helper.handleSelfRegisteration(component, event, helper);
        }
        else if (event.target.id == 'countryId') {
            helper.filterCountries(component, event, helper);
        }
    },

    showList: function(component, event, helper) {
        
        if(component.get("v.countries").length == 0) {
            document.getElementById("countryCombobox").classList.remove('slds-is-open');
        }
        else if(!document.getElementById("countryCombobox").classList.contains('slds-is-open')) {
            document.getElementById("countryCombobox").classList.add('slds-is-open');
        }
    },

    selectItem : function(component, event, helper) {
        component.set("v.selectedCountry", event.target.closest(".slds-listbox__item").id);
        component.set("v.countries", []);
    },

    onCheck : function(component, event, helper) {
        var prevValue = component.get("v.acceptedPrivacies");
        console.log(prevValue);
        component.set("v.acceptedPrivacies", !prevValue);
    },
    
})