({
    onLoad : function(component, event, helper)
    {
        if(window.location.href.indexOf('flexipageEditor')==-1)
        {
            helper.checkYTDMonth(component);
        }
    },

    handleConfirmYes : function(component, event, helper)
    {
        helper.updateYTDMonth(component);
        component.set('v.showYTDConfirm', false);
    },

    handleConfirmNo : function(component, event, helper)
    {
        component.set('v.showYTDConfirm', false);
        $A.get('e.c:CAJBP_TabViewEvent')
                .setParams({
                    tabId: 'Scorecard',
                    navigate: 'true'
                }).fire();
    }
})