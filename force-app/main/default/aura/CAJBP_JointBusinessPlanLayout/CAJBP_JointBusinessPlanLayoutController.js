({
    /*
    * Capture external or internal request to change the current JBP tab view.
    */
    handleTabView: function(component, event, helper) {
        helper.setTabSession(component, event.getParam('tabId'));

        if(event.getParam('navigate'))
        {
            setTimeout($A.getCallback(function(){
                var scrollOptions = {
                    left: 0,
                    top: 2000,
                    behavior: 'auto'
                }
                window.scrollTo(scrollOptions);
            }),1500 );
        }
    },

    /*
    * Listens to the record loaded event to capture the context JBP record, to use in the custom layout.
    */
    handleRecordLoaded: function(component, event, helper) {
        component.set('v.record', event.getParam('record'));

        const sessionId = helper.getSessionId(component);
        var tabId = (helper.isInDesigner() ? 'Summary' : sessionStorage.getItem(sessionId)) || 'Summary';

        if (!tabId) {
            tabId = component.get('v.tabId');
        }

        window.setTimeout($A.getCallback(function() {
            if (!component.find(tabId)) {
                tabId = 'Summary';
            }

            helper.setTabSession(component, tabId);

            var tabs = component.find(tabId);
            tabs = (Array.isArray(tabs) ? tabs : [tabs]);

            tabs.forEach(function(tab) {
                tab.focus();
            });
        }), 100);
    },

    /*
    * On layout initialise look at previous tab session the current user was on and show, otherwise load defaults.
    * If in app builder we do not store the user tab session.
    */
    doInit: function(component, event, helper) {
        //Apply window size check.
        helper.checkWindowSize(component);

        //Are we in the app builder?
        helper.setInDesigner(component);

        if (!helper.isInDesigner()) {
            const sessionId = helper.getSessionId(component);
            const tabId = sessionStorage.getItem(sessionId) || 'Summary';

            if (tabId) {
                component.set('v.tabId', tabId);
            }
        } else {
            component.set('v.tabId', 'Summary');
        }
    },

    /*
    * Store the tab session whenever the user changes the tab.
    */
    onTabSelect: function(component, event, helper) {
        helper.setTabSession(component, event.getParam('id'));
    },

    toggleSidebar: function(component, event, helper) {
        const expanded = !component.get('v.isSidebarCollapsed');
        component.set('v.isSidebarCollapsed', expanded);

        $A.get('e.c:CAJBP_LayoutToggleEvent')
        .setParams({
            expanded: expanded
        }).fire();
    },

    handleLayoutRefresh: function(component, event, helper) {
        console.log('Not implemented handleLayoutRefresh ....');
    }
});