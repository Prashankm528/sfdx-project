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
    sfutil.updateConnectionLed("led-green", "Connection Established");
    sfutil.updateOpenCtiStatus(true);
    sfutil.enableClickToDial();
    sfutil.addTabFocusListener();
    softphone_connector_initialized = true;
}
function onPostActivateSession(message) {
}
function onDeactivateSession(message) {
}
function onChannelStatus(message) {
    console.log("onChannelStatus : ", message);
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
    sfctiutil.createVoiceTask(message, 'Phone', message.ANI.replace("tel:", ""), message.ConnectionID || message.callId);
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
    var email = message.Service == "PureCloud" ? message.attachdata["context.email"] : message.attachdata.EmailAddress;
    sfutil.createTask(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
}
function onChatEventEstablishedConsult(message) {
}
function onChatEventReleasedInbound(message) {
}
function onChatEventReleasedConsult(message) {
}
function onChatEventMarkDoneInbound(message) {
    console.log("onChatEventMarkDoneInbound , message : ", message);
}
function onChatEventTranscriptLink(message) {
}
function onChatEventPartyRemovedInbound(message) {
}
function onChatEventPartyAddedInbound(message) {
}
function onChatEventPartyChangedInbound(message) {
}
function onEmailEventRingingInbound(message) {
}
function onEmailEventEstablishedInbound(message) {
    console.log("onEmailEventEstablishedInbound , message : ", message);
    var email = message.Service == "PureCloud" ? message.EmailAddress : message.attachdata.EmailAddress;
    sfutil.createTask(message, 'Email', email, message.MediaType + " - " + message.ConnectionID);
}
function onEmailEventReleasedInbound(message) {
}
function onEmailEventReplyEstablishedOutbound(message) {
}
function onEmailEventReplyReleased(message) {
}
function onEmailEventReplyCancelled(message) {
}
function onEmailEventSessionInfo(message) {
}
function onDelegateCommand(message) {
}
function onRegisterCommand(message) {
}
function onInhibitCommand(message) {
}
function onWdeSwitchInteraction(message) {
    console.log("Called onWdeSwitchInteraction: ", message);
    var id = message.ConnectionID || message.InteractionID;
    if (!id) {
        console.log("interaction id null... returning");
        return;
    }
    var event = iwscore.mapInteractions[id.toLowerCase()];
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
}
function onWorkitemEventMarkDoneInbound(message) {
    console.log("Called onWorkitemEventMarkDoneInbound: ", message.attachdata);
}
function onWorkitemEventRingingInbound(message) {
    log.debug("Called onWorkitemEventRingingInbound: ");
}
