/* 
 * @author			Jan Majling
 * @date			09/08/2018
 * @group			CAJBP
 * @description		Controller for CAJBP_RefreshIt component
 *
 * history
 * 09/08/2018	Jan Majling			Created
*/
({
	/**
	 * Fires an event defined in the component settings
	 */
	refreshView: function(component, event, helper) {
		var eventType = event.getParam('type'),
			message = event.getParam('message') || '',
			needle = component.get('v.needle'),
			targetEvent = component.get('v.eventType');

		if ($A.util.isEmpty(eventType)) {
            return ;
		}

		eventType = eventType.toLowerCase();
		message = message.toLowerCase();

		if ($A.util.isEmpty(needle) && $A.util.isEmpty(targetEvent)) {
            return ;
		}

		var foundEvent = false;
		var foundNeedle = false;

        //check targetEvent i.e. success,delete exists for incoming event type for toast message.
		if (!$A.util.isEmpty(targetEvent)) {
		    //match using lowercase event types and remove white spaces from comma separated values.
		    foundEvent = targetEvent.toLowerCase().trim().split(',')
		        .map(function(item) {
                    return item.trim();
                }).indexOf(eventType) != -1;

		    if (!foundEvent) {
                console.log('Could not found match for ' + targetEvent.split(',') + ' in: ' + eventType);
            } else {
                console.log('Found match for ' + targetEvent.split(',') + ' in: ' + eventType);
            }
        }

        if (!$A.util.isEmpty(needle)) {
            foundNeedle = needle.toLowerCase().trim().split(',')
                .some(function(item) {
                    return message.trim().indexOf(item.trim()) != -1;
                });

            if (!foundNeedle) {
                console.log('Could not found match for ' + needle.split(',') + ' in: ' + message);
            } else {
                console.log('Found match for ' + needle.split(',') + ' in: ' + message);
            }
		}

        //Check configuration i.e. if only targetEvent or only needle for search but both cannot be false.
        if ((!$A.util.isEmpty(targetEvent) && !foundEvent)
                || (!$A.util.isEmpty(needle) && !foundNeedle)) {

            console.log('Ignoring refresh ......');
            return;
        }

        console.log('Refreshing ......');

		var refreshEvent = $A.get(component.get('v.refreshEvent'));
		refreshEvent.fire();
	}
})