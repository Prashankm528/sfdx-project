log.setLogLevel(enumloglevel.error);
if (softphoneSettings.logLevel == 'Debug') {
    log.setLogLevel(enumloglevel.debug);
}
switch (softphoneSettings.integrationType) {
    case "PURECLOUD":
        loadPure();
        break;
    case "WDE":
        loadWDE();
        break;
    case "WWE":
        loadWWE();
        break;
}
var OMNI_READY_ID = softphoneSettings.omniReadyId;
var OMNI_NOT_READY_ID = softphoneSettings.omniNotReadyId;
var WDE_CHANNELS_TO_SYNCH = softphoneSettings.wdeChannelsToSynch;
function loadWDE() {
    iwscore.getLayoutParams().integrationType = "wde";
    iwscore.createConnection(softphoneSettings.wdeHost, softphoneSettings.wdePort, { 'protocol': softphoneSettings.wdeProtocol });
}
function loadPureRequestConfig() {
    var auth = {
        environment: softphoneSettings.pcEnv,
        notReadyPresenceId: softphoneSettings.pcNotReadyId,
        onQueuePresenceId: softphoneSettings.pcOnQueueId
    };
    var params = {
        settings: {
            sso: false,
            hideWebRTCPopUpOption: softphoneSettings.pcHideWebRTCPopUpOption == "true",
            enableCallLogs: softphoneSettings.pcEnableCallLogs == "true",
            hideCallLogSubject: softphoneSettings.pcHideCallLogSubject == "true",
            hideCallLogContact: softphoneSettings.pcHideCallLogContact == "true",
            hideCallLogRelation: softphoneSettings.pcHideCallLogRelation == "true",
            dedicatedLoginWindow: softphoneSettings.pcDedicatedLoginWindow == "true",
            embeddedInteractionWindow: false,
            enableConfigurableCallerId: false,
            enableServerSideLogging: false,
            enableCallHistory: false,
            theme: {
                primary: "#HHH",
                text: "#FFF"
            }
        },
        clientIds: {
            "mypurecloud.com": "5e7155c1-90dd-428d-a7b0-47e8d73c3c05"
        },
        helpLinks: {}
    };
    console.log("params : ", params);
    var url = "https://apps.mypurecloud.com/crm/softphoneGenericCRM/index.html?request_configuration=true&crm_domain=" + window.location.origin;
    console.log("url : ", url);
    var config = {
        context: window,
        layoutType: "frame",
        integrationType: "pure-embeddable",
        url: url,
        auth: auth,
        pefParams: params
    };
    iwscore.initCTI(config);
    iwscore.enableCTI();
}
function loadPure() {
    var auth = {
        environment: softphoneSettings.pcEnv,
        notReadyPresenceId: softphoneSettings.pcNotReadyId,
        onQueuePresenceId: softphoneSettings.pcOnQueueId
    };
    var params = "?crm_domain=" + window.location.origin;
    params += "&dedicatedLoginWindow=" + softphoneSettings.pcDedicatedLoginWindow;
    params += "&enableCallLogs=" + softphoneSettings.pcEnableCallLogs;
    params += "&hideCallLogContact=" + softphoneSettings.pcHideCallLogContact;
    params += "&hideCallLogRelation=" + softphoneSettings.pcHideCallLogRelation;
    params += "&hideCallLogSubject=" + softphoneSettings.pcHideCallLogSubject;
    params += "&hideWebRTCPopUpOption=" + softphoneSettings.pcHideWebRTCPopUpOption;
    params += "&embedWebRTCByDefault=" + softphoneSettings.pcEmbedWebRTCByDefault;
    console.log("params : ", params);
    iwscore.initCTI({
        context: window,
        layoutType: "frame",
        integrationType: "pure-embeddable",
        url: "https://apps.mypurecloud.com/crm/softphoneGenericCRM/index.html" + params,
        auth: auth
    });
    iwscore.enableCTI();
}
function loadWWE() {
    iwscore.initCTI({
        context: window,
        integrationType: "wwe",
        layoutType: "frame",
        url: softphoneSettings.wweUrl
    });
    iwscore.enableCTI();
}
