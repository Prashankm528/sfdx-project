({
    doInit : function(component, event, helper) {
        console.log('p1');
        var targetURL = component.get("v.redirectToURL");
        console.log('targetURL --> ' + targetURL);
        //Check if site is in Preview Mode
        
        var urlToCheck = window.location.hostname.toLowerCase();
        var isPreviewMode = urlToCheck.indexOf('sitepreview') >= 0 || urlToCheck.indexOf('livepreview') >= 0;
		
        if (targetURL != '' && !isPreviewMode) {
            window.location = targetURL;
        }
    }
})