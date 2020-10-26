({    
    loadOptions : function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
        
        var getLangAction = component.get("c.getCommunityLanguages");
        var getUrl = component.get("c.checkLanguageUrl");
        var currentUrl = window.location.origin + window.location.pathname;
        getUrl.setParams({ urlPath: currentUrl });
        getUrl.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var urlType = response.getReturnValue();
                component.set('v.communityTypeLangUrl', urlType);
            }
        });
    
        getLangAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var langList = response.getReturnValue();
                component.find("selectLang").set("v.value", $A.get("$Locale.langLocale"));
                component.set("v.options", langList);
                if (langList.length === 0 ) {
                    $A.util.toggleClass(component.find("selectLang"), "slds-hide");
                }
            }
        });

        $A.enqueueAction(getLangAction);
        $A.enqueueAction(getUrl);
    },
    
    handleLangOptionChange : function(component, event, helper) {
        helper.communityChangeLangUrl(component, event, helper);
    },
    
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
})