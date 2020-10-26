({
    qsToEventMap: {
        'startURL'  : 'e.c:REIDP_setStartUrl'
    },
    
    communityChangeLangUrl : function (component, event, helper) {
        var selectedLang = component.find("selectLang").get("v.value");
		var selectedType = component.get("v.communityTypeLangUrl");
        var startUrl = component.get("v.startUrl");
        var currentUrl = document.location.href;

        startUrl = decodeURIComponent(startUrl);
        
        var action;
        if (selectedType == 'ForgotPassword') {
            action = component.get("c.changeLanguageUrlForgotPassword");
        } else if (selectedType == 'SelfRegister') {
            action = component.get("c.changeLanguageUrlSelfRegister");
        } else if (selectedType == 'Login') {
            action = component.get("c.changeLanguageUrlLogin");
        }

        action.setParams({ language:selectedLang, startUrl:startUrl, urlPath:currentUrl });
        
        $A.enqueueAction(action);
    },
    
})