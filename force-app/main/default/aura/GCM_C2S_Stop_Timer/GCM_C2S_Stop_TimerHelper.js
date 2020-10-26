({
    stopTimerByCaseClient : function(component) {
        console.log('StopTimerByCase: Begin');
        console.log(window.recordId);
        var stopTimer = component.get('c.stopTimerByCase');
        var recordId = component.get('v.recordId');
        console.log('Record Id: ' + recordId);
        stopTimer.setParams({ caseId : recordId });
        stopTimer.setCallback(this, function(response) {
          var state = response.getState();
          if (state == 'SUCCESS') {
            console.log('stopTimer: SUCCESS');
          }
          else if (state == 'INCOMPLETE') {
            console.log('stopTimer: INCOMPLETE');
          }
          else if (state == 'ERROR') {
            console.log('stopTimer: ERROR');
          }
        });
        $A.enqueueAction(stopTimer);
        console.log('StopTimerByCase: End');		
	}
})