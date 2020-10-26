var softphone_connector_initialized = false;
function networkError(message) {
    log.error(message);
}
function onIdentity(message) {
}
function onConnectedSession(message) {
    if (softphone_connector_initialized == true) {
        return;
    }
    sfutil.updateOpenCtiStatus(false);
    sfutil.updateConnectionLed("led-yellow", "Connection in Standby ...");
}
function onDisconnectedSession(message) {
    sforce.console.presence.logout(function (res) { console.log(res); });
    $("#led").removeClass();
    $("#led").addClass("led-red");
    $(".led-msg p").text("Session disconnected");
    sfutil.updateOpenCtiStatus(false);
    softphone_connector_initialized = false;
}
function onActivateSession(message) {
    console.log("onActivateSession ", message);
    if (softphone_connector_initialized == true) {
        return;
    }
    omniUtils.addTabsListener();
    omniUtils.addPresenceListener();
    if (iwscore.getLayoutParams().integrationType == "wde" || !iwscore.getLayoutParams().integrationType) {
        sfutil.updateConnectionLed("led-green", "Connection Established");
        sfutil.enableClickToDial();
        sfutil.addTabFocusListener();
    }
    sfutil.updateOpenCtiStatus(true);
    iwscommand.NotReadyAll(undefined);
    omniUtils.manageChangeStatus(message);
    softphone_connector_initialized = true;
}
function onPostActivateSession(message) {
}
function onDeactivateSession(message) {
}
function onChannelStatus(message) {
    console.log("onChannelStatus : ", message);
    omniUtils.manageChangeStatus(message);
}
function onEventAgentNotReady(message) {
    console.log("onEventAgentNotReady : ", message);
}
function onEventAgentNotReadyAfterCallWork(message) {
}
function onEventAgentReady(message) {
    console.log("onEventAgentReady : ", message);
}
function onEventAgentLogout(message) {
}
function onEventAgentLogin(message) {
}
function onEventRingingInbound(message) {
    var callback = function (response) {
        if (response.success) {
            console.log('API method call executed successfully! returnValue:', response.returnValue);
        }
        else {
            console.error('Something went wrong! Errors:', response.errors);
        }
    };
    if (iwscore.getLayoutParams().integrationType === 'wwe' || iwscore.getLayoutParams().integrationType === 'pure-embeddable') {
        sforce.opencti.setSoftphonePanelVisibility({ visible: true, callback: callback });
    }
}
function onEventRingingInternal(message) {
}
function onEventRingingConsult(message) {
}
function onEventRingingOutbound(message) {
}
function onEventEstablishedInbound(message) {
    console.log("onEventEstablishedInbound , message : ", message);
    if (message.Service == "PureCloud") {
        sfutil.createTask(message, 'Phone', message.attachdata['context.phoneNumber'], message.ConnectionID);
    }
    else {
        sfctiutil.createVoiceTask(message, 'Phone', message.ANI, message.ConnectionID || message.callId);
    }
}
function onEventPartyChangedInbound(message) {
    console.log("onEventPartyChangedInbound , message : ", message);
    sfctiutil.createVoiceTask(message, 'Phone', message.ANI, message.ConnectionID || message.callId);
}
function onEventPartyChangedOutbound(message) {
    console.log("onEventPartyChangedOutbound , message : ", message);
    var dialedNum = message.DNIS;
    if(dialedNum.startsWith("00",0)){
        var pattern = /00/i;
        dialedNum = dialedNum.replace( pattern, "+" );
    }
    console.log('dialed number '+dialedNum);
    sfctiutil.createVoiceTask(message, 'Phone', dialedNum, message.MediaType + " - " + message.ConnectionID || message.callId);
}
function onEventPartyAddedInbound(message) {
    console.log("onEventPartyAddedInbound , message : ", message);
    sfctiutil.updateConferenceFlag(message, 'Added');
}
function onEventPartyAddedOutbound(message) {
    console.log("onEventPartyAddedOutbound , message : ", message);
    sfctiutil.updateConferenceFlag(message, 'Added');
}
function onEventPartyDeletedInbound(message) {
    console.log("onEventPartyDeletedInbound , message : ", message);
    sfctiutil.updateConferenceFlag(message, 'Deleted');
}
function onEventPartyDeletedOutbound(message) {
    console.log("onEventPartyAddedOutbound , message : ", message);
    sfctiutil.updateConferenceFlag(message, 'Deleted');
}
function onEventEstablishedInternal(message) {
}
function onEventEstablishedConsult(message) {
    console.log("onEventEstablishedConsult , message : ", message);
    sfctiutil.updateConsultedUser(message);
}
function onEventEstablishedOutbound(message) {
    console.log("onEventEstablishedOutbound , message : ", message);
    var dialedNum = message.DNIS;
    if(dialedNum.startsWith("00",0)){
        var pattern = /00/i;
        dialedNum = dialedNum.replace( pattern, "+" );
    }
    console.log('dialed number '+dialedNum);
    sfctiutil.createVoiceTask(message, 'Phone', dialedNum, message.MediaType + " - " + message.ConnectionID || message.callId);
}
function onEventMarkDoneInbound(message) {
    log.debug("Called onEventMarkDoneInbound: ");
    sfctiutil.updateTaskDetail(message, 'MarkDone');
}
function onEventMarkDoneOutbound(message) {
    log.debug("Called onEventMarkDoneOutbound: ");
    sfctiutil.updateTaskDetail(message, 'MarkDone');
}
function onEventHeldInbound(message) {
}
function onEventHeldInternal(message) {
}
function onEventHeldConsult(message) {
}
function onEventHeldOutbound(message) {
}
function onEventRetrievedInbound(message) {
}
function onEventRetrievedInternal(message) {
}
function onEventRetrievedConsult(message) {
}
function onEventRetrievedOutbound(message) {
}
function onEventAttachedDataChangedInbound(message) {
}
function onEventAttachedDataChangedInternal(message) {
}
function onEventAttachedDataChangedConsult(message) {
}
function onEventAttachedDataChangedOutbound(message) {
}
function onEventReleasedInbound(message) {
    console.log('onEventReleasedInbound '+message);
    sfctiutil.updateTaskDetail(message, 'EndDate');
}
function onEventReleasedInternal(message) {
}
function onEventReleasedConsult(message) {
}
function onEventReleasedOutbound(message) {
    console.log('onEventReleasedOutbound '+message);
    sfctiutil.updateTaskDetail(message, 'EndDate');
}
function onEventDialingInternal(message) {
}
function onEventDialingConsult(message) {
}
function onEventDialingOutbound(message) {
}
function onChatEventRingingInbound(message) {
    var callback = function (response) {
        if (response.success) {
            console.log('API method call executed successfully! returnValue:', response.returnValue);
        }
        else {
            console.error('Something went wrong! Errors:', response.errors);
        }
    };
    if (iwscore.getLayoutParams().integrationType === 'wwe' || iwscore.getLayoutParams().integrationType === 'pure-embeddable') {
        sforce.opencti.setSoftphonePanelVisibility({ visible: true, callback: callback });
    }
}
function onChatEventRingingConsult(message) {
}
function onChatEventEstablishedInbound(message) {
    console.log("onChatEventEstablishedInbound , message : ", message);
    if (message.Service == "PureCloud" || message.Service == "Wwe") {
        if (message.attachdata['context.WorkItemId']) {
            message.attachdata.WorkItemId = message.attachdata['context.WorkItemId'];
            message.attachdata.ServiceChannelId = message.attachdata['context.ServiceChannelId'];
            message.attachdata.QueueId = message.attachdata['context.QueueId'];
            message.attachdata.Id = message.attachdata['context.Id'];
            omniUtils.createAgentWork(message);
        }
        else {
            sfutil.createTask(message, 'Phone', message.attachdata['context.phoneNumber'], message.ConnectionID);
        }
    }
    else {
        sfutil.createTask(message, 'Email', message.attachdata.EmailAddress, message.ConnectionID);
    }
}
function onChatEventEstablishedConsult(message) {
}
function onChatEventReleasedInbound(message) {
}
function onChatEventReleasedConsult(message) {
}
function onChatEventMarkDoneInbound(message) {
    console.log("onChatEventMarkDoneInbound , message : ", message);
    if (message.attachdata['context.WorkItemId']) {
        omniUtils.closeTab(message.attachdata['context.WorkItemId'], undefined);
    }
}
function onEmailEventRingingInbound(message) {
}
function onEmailEventEstablishedInbound(message) {
    console.log("onEmailEventEstablishedInbound , message : ", message);
    var email = message.Service == "PureCloud" ? message.EmailAddress : message.attachdata.EmailAddress;
    sfctiutil.createNewEmailTask(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
}
function onEmailEventReleasedInbound(message) {
    console.log('onEmailEventReleasedInbound '+message);	
    sfctiutil.updateTaskDetail(message, 'EmailReleased');
}
function onEmailEventReplyEstablishedOutbound(message) {
}
function onEmailEventReleasedOutbound(message) {
    console.log('onEmailEventReleasedOutbound ',message);
}
function onEmailEventReplyReleased(message) {
    console.log('onEmailEventReplyReleased ',message);
}
function onEmailEventReplySessionInfo(message) {
}
function onCustomEventEmailOutbound(message) {
    console.log("Called onCustomEventEmailOutbound: ", message);
    var email = message.Service == "PureCloud" ? message.EmailAddress : message.attachdata.EmailAddress;
    console.log("outboundInteractionMap",outboundInteractionMap);
    if(outboundInteractionMap.get(message.ConnectionID) == undefined){
    	outboundInteractionMap.set(message.ConnectionID, message.ConnectionID);
    	sfctiutil.createOutboundEmailTask(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
    }
}
function onEmailEventReplyCancelled(message) {
}
function onEmailEventPartyRemovedInbound(message) {
    console.log('onEmailEventPartyRemovedInbound ',message);
    sfctiutil.transferredEmail(message);
}
function onEmailEventSessionInfo(message) {
    console.log('onEmailEventSessionInfo ',message);
}
function onDelegateCommand(message) {
    console.log("onDelegateCommand : ", message);
    if (iwscore.getLayoutParams().integrationType == "wde" || !iwscore.getLayoutParams().integrationType) {
        var interaction = iwscore.mapInteractions[message.ConnectionID.toLowerCase()];
        console.log("interaction :", interaction);
        var workItemId = interaction ? interaction.attachdata ? interaction.attachdata.WorkItemId : null : null;
        if (workItemId) {
            omniUtils.closeTab(workItemId, message.ID);
        }
        else {
            iwscommand.ExecuteDelegatedCommand(message.ID);
        }
    }
    else if (iwscore.getLayoutParams().integrationType == "wwe") {
        if (!message || !message.ChainName || !message.ID) {
            console.log("invalid message, returning ...");
            return;
        }
        switch (message.ChainName) {
            case 'InteractionBundleClose':
                var workItemId = message ? message.Parameters ? message.Parameters.mainInteraction ? message.Parameters.mainInteraction.userData ? message.Parameters.mainInteraction.userData.WorkItemId : null : null : null : null;
                if (workItemId) {
                    omniUtils.closeTab(workItemId, message.ID);
                }
                else {
                    iwscommand.ExecuteDelegatedCommand(message.ID);
                }
                break;
        }
    }
}
function onRegisterCommand(message) {
    console.log("onRegisterCommand : ", message);
    if (!message || !message.ChainName) {
        console.log("invalid message, returning ...");
        return;
    }
    switch (message.ChainName) {
        case 'AgentLogout':
            sforce.console.presence.logout(function (res) { console.log(res); });
            break;
    }
}
function onInhibitCommand(message) {
    log.debug("======= onInhibitCommand ==========");
    if (message.Parameters.Device) {
        log.debugFormat("Device Name: {0}", message.Parameters.Device.Name);
    }
}
function onWdeSwitchInteraction(message) {
    log.debug("Called onWdeSwitchInteraction: " + message);
    var id = message.ConnectionID || message.InteractionID;
    var event = iwscore.getInteraction(id);
    if (event) {
        sfutil.checkExists(event);
    }
}
function onSwitchInteractionInbound(message) {
    log.debug("Called onSwitchInteractionInbound ");
    onSwitchInteraction(message);
}
function onSwitchInteraction(message) {
    log.debug("Called onWdeSwitchInteraction: " + message);
    sfutil.checkExists(message);
}
function onWorkitemEventEstablishedInbound(message) {
    log.debug("Called onWorkitemEventEstablishedInbound: ");
    console.log(message);
    omniUtils.createAgentWork(message);
}
function onWorkitemEventMarkDoneInbound(message) {
    console.log("Called onWorkitemEventMarkDoneInbound: ", message.attachdata);
}
function onWorkitemEventReleasedInbound(message) {
    console.log("Called onWorkitemEventMarkDoneInbound: ", message.attachdata);
}
function onWorkitemEventRingingInbound(message) {
    log.debug("Called onWorkitemEventRingingInbound: ");
    if (iwscore.getLayoutParams().integrationType == "wwe" || iwscore.getLayoutParams().integrationType == "pure-embeddable") {
        var callback = function (response) {
            if (response.success) {
                console.log('API method call executed successfully! returnValue:', response.returnValue);
            }
            else {
                console.error('Something went wrong! Errors:', response.errors);
            }
        };
        sforce.opencti.setSoftphonePanelVisibility({ visible: true, callback: callback });
    }
}
function onWorkbinTakenOut(message) {
    console.log("Called onWorkbinTakenOut: ", message);
    //sfctiutil.popTask(message);
}
function onWorkbinPlacedIn(message) {
    console.log("Called onWorkbinPlacedIn: ", message);
   // myInteractionMap.set(message.ConnectionID, message.ConnectionID);
    console.log("myInteractionMap",myInteractionMap);
}
function onEmailEventOpenedInbound(message) {
    console.log("Called onEmailEventOpenedInbound: ", message);
    console.log("OperationType ",message.OperationType);
    if(message.OperationType == 'queue'){
        var email = message.Service == "PureCloud" ? message.EmailAddress : message.attachdata.EmailAddress;
    	//sfctiutil.createNewEmailTask(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
    }
    if(message.OperationType == 'workbin'){
       // sfctiutil.popTask(message);
    }
}