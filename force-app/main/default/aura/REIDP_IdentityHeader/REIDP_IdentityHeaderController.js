({
    doInit : function(component, event, helper) {
        
        // COMMUNITY URLS
        var communityUrls = component.get("c.fetchCommunityUrls");
        communityUrls.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.communityPageUrl", response.getReturnValue().baseURL ); // community url
                component.set("v.homePageUrl", response.getReturnValue().homeURL);		 // home page url
                component.set("v.profilePageUrl", response.getReturnValue().profileURL); // profile url
            }
        });
        $A.enqueueAction(communityUrls);
    },
    
    toggleMenu : function (component, event) {
        var menuButton = component.find("menu-toggle");
        var screenAfterToggle = component.find("after-toggle");
        
        $A.util.toggleClass(menuButton, "slds-hide");
        $A.util.toggleClass(screenAfterToggle, "slds-hide");
    }
})