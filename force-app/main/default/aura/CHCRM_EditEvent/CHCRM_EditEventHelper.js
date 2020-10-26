({
    queryEvent : function(component) {
        component.set('v.loading', true);
        this.callServer(
            component,
            "c.queryEventForEdit",
            function(response) {
                component.set('v.loading', false);
                component.set("v.evt", response.evt);
                component.set("v.detail", response.detail);
            },
            {evtId:component.get('v.recordId')}
        );		
    },
    saveEvent : function(component) {
        component.set('v.loading', true);
        JSON.stringify

        var evt = component.get('v.evt');
        delete evt.Owner;
        delete evt.Who;
        delete evt.What;
        var detail = component.get('v.detail');
        
        this.callServer(
            component,
            "c.saveEvent",
            function(response) {
                console.log('response.status:'+response.status);
                if(response.status == 'Error'){
                    component.set('v.loading', false);
                    component.set('v.errorMessage',response.errorMessage);
                    component.set('v.showError',true);
                }else{
                    this.prepareSuccessNotify(component);
                    $A.get('e.force:refreshView').fire();  
                }
            },
            {evt:evt, detail:detail}
        );
    },
    prepareSuccessNotify : function(component) {
        var config ={
            title: '成功',
            message: '保存成功！',
            variant: 'success'
        }
        this.showNotification(component, config);

    },
    showNotification : function(component, config) {
        component.set('v.loading', false);
        component.find('notifLib').showToast(config);
        if (config.variant != 'error') {
          $A.get('e.force:refreshView').fire();
          $A.get("e.force:closeQuickAction").fire();
        }        
    }

})