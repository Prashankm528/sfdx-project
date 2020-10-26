({
    NewCaseclearTimerClient : function(component) {
		console.log('NewCaseclearTimer: Begin');
    	var clearTimer = component.get('c.NewCaseclearTimer');
    	clearTimer.setCallback(this, function(response) {
      	var state = response.getState();
      	if (state == 'SUCCESS') {
        	console.log('clearTimer: SUCCESS');
      	}
      	else if (state == 'INCOMPLETE') {
        	console.log('clearTimer: INCOMPLETE');
      	}
      	else if (state == 'ERROR') {
        	console.log('clearTimer: ERROR');
      	}
    	});
    	$A.enqueueAction(clearTimer);
    	console.log('ClearTimer: End');        
    },
    clearTimerClient : function(component) {
		console.log('ClearTimer: Begin');
    	var clearTimer = component.get('c.clearTimer');
    	clearTimer.setCallback(this, function(response) {
      	var state = response.getState();
      	if (state == 'SUCCESS') {
        	console.log('clearTimer: SUCCESS');
      	}
      	else if (state == 'INCOMPLETE') {
        	console.log('clearTimer: INCOMPLETE');
      	}
      	else if (state == 'ERROR') {
        	console.log('clearTimer: ERROR');
      	}
    	});
    	$A.enqueueAction(clearTimer);
    	console.log('ClearTimer: End');        
    },
    
    startTimerClient : function(component) {
        console.log('StartTimer: Begin');
        var startTimer = component.get("c.startTimer");
        console.log('StartTimer: ' + window.recordId);
        startTimer.setParams({ caseId : window.recordId });
        startTimer.setCallback(this, function(response) {
          var state = response.getState();
          if (state == 'SUCCESS') {
            console.log('startTimer: SUCCESS');
          }
          else if (state == 'INCOMPLETE') {
            console.log('startTimer: INCOMPLETE');
          }
          else if (state == 'ERROR') {
            console.log('startTimer: ERROR');
          }
        });
        $A.enqueueAction(startTimer);
        console.log('StartTimer: End');		
	},

    stopTimerByCaseClient : function(component) {
        console.log('StopTimerByCase: Begin');
        console.log('this is the window record Id:' + window.recordId);
        var windowrecid =  window.recordId;
        console.log('This is the window id:' +windowrecid);
        if(windowrecid!='' && windowrecid!=null && windowrecid!=undefined){
        var stopTimer = component.get("c.stopTimerByCase");
        
        console.log('StopTimer: ' + window.recordId);
        stopTimer.setParams({ caseId : window.recordId });
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
    },
    
	startNewCaseTimerClient : function(component) {
        console.log('StartNewCaseTimer: Begin');
        console.log(window.recordId);
        var startNewCaseTimer = component.get("c.startNewCaseTimer");
        startNewCaseTimer.setCallback(this, function(response) {
          var state = response.getState();
          if (state == 'SUCCESS') {
            console.log('startNewCaseTimer: SUCCESS');
          }
          else if (state == 'INCOMPLETE') {
            console.log('startNewCaseTimer: INCOMPLETE');
          }
          else if (state == 'ERROR') {
            console.log('startNewCaseTimer: ERROR');
          }
        });
        $A.enqueueAction(startNewCaseTimer);
        console.log('startNewCaseTimer: End');		
	}
})