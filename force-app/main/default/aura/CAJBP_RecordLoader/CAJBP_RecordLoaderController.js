({
    /*
    * Construct array of fields from string, app build design attribute can only be primitives.
    */
    doInit: function(component, event, helper) {
        const fields = component.get('v.fields');

        if ($A.util.isEmpty(fields)) {
            return;
        }

        component.set('v.targetFields', fields.split(','));
    },

    /*
    * Captured loaded/updated record and send event with record payload, mainly used for CAJBP_JointBusinessPlanLayout.
    */
    handleRecordUpdated: function(component, event, helper) {
        const eventParams = event.getParams();

        switch(eventParams.changeType) {
            case 'LOADED':
            case 'CHANGED': {
                $A.get("e.c:CAJBP_RecordLoadedEvent")
                    .setParams({
                        id: component.get('v.id'),
                        record: component.get('v.record')
                    }).fire();
                break;
            }

            case 'ERROR': {
                break;
            }
        }
    }
});