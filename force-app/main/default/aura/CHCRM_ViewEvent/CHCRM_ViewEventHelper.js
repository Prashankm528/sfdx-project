({
    queryEvent : function(component) {
        this.callServer(
            component,
            "c.queryEventForView",
            function(response) {
                component.set("v.evt", response.evt);
                component.set("v.detail", response.detail);
            },
            {evtId:component.get('v.recordId')}
        );		
    }
})