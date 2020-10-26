({
    defaults: function() {
        return {
            SMALL_LAYOUT_WIDTH: 1023
        };
    },

    isInDesigner: function() {
        return window.location.href.indexOf('flexipageEditor') != -1;
    },

    setInDesigner: function(component) {
        if (this.isInDesigner()) {
            component.set('v.isConfig', true);
        }
    },

    getSessionId: function(component) {
        const userId = $A.get('$SObjectType.CurrentUser.Id');
        const recordId = component.get('v.record.Id');

        return userId + '#' + recordId + '#tabId';
    },

    setTabSession: function(component, tabId) {
        const sessionId = this.getSessionId(component);

        if (!this.isInDesigner()) {
            sessionStorage.setItem(sessionId, tabId);
        }

        component.set('v.tabId', tabId);
    },

    checkWindowSize: function(component) {
        const that = this;
        that.assignLayoutType(component);

        window.addEventListener('resize', $A.getCallback(function() {
            that.assignLayoutType(component);
        }));
    },

    assignLayoutType: function(component) {
        if (document.documentElement.clientWidth <= this.defaults().SMALL_LAYOUT_WIDTH) {
            component.set('v.layoutType', 'small');
        } else {
            component.set('v.layoutType', 'large');
        }
    }
});