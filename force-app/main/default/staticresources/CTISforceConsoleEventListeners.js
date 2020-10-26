//Define Event listener for the 'AssociateSRCall' event type
var listenerCall = function (result) {
    console.log('Message received from event: ' + result.message);
    var obj = JSON.parse(result.message);
    var params = iwscore.createUserData();
    params.put("CSD_SRNumber", obj.caseNumber);
    params.put("CSD_AccountName", obj.accName);
    params.put("CSD_ContactName", obj.conName);
    params.put("CSR_SRid", obj.caseId);
    params.put("interactionId", obj.interactionId);
    if(obj.interactionId != null && obj.interactionId != ' ' && obj.interactionId != ''){
        console.log('inside if');
        iwscommand.SetAttachdataById(obj.interactionId, params);
    }
};

//Add a Event listener for the 'AssociateSRCall' event type
sforce.console.addEventListener('AssociateSRCall', listenerCall);

//Define Event listener for the 'AssociateTask' event type
var listenerTask = function (result) {
    console.log('Message received from event: ' + result.message);
    var obj = JSON.parse(result.message);
    var params = iwscore.createUserData();
    params.put("CSD_AccountName", obj.accName);
    params.put("CSD_ContactName", obj.conName);
    params.put("CSR_SRid", obj.caseId);
    params.put("CSD_SRNumber", obj.caseNumber);
    params.put("interactionId", obj.interactionId);
    if(obj.interactionId != null && obj.interactionId != ' ' && obj.interactionId != ''){
        console.log('inside if');
        iwscommand.SetAttachdataById(obj.interactionId, params);
    }
};
//Add a Event listener for the 'AssociateTask' event type
sforce.console.addEventListener('AssociateTask', listenerTask);

//Define Event listener for the 'AssociateSREmail' event type
var listenerEmail = function (result) {
    console.log('Message received from event: ' + result.message);
    var obj = JSON.parse(result.message);
    var params = iwscore.createUserData();
    params.put("CSD_SRNumber", obj.caseNumber);
    params.put("CSD_AccountName", obj.accName);
    params.put("CSD_ContactName", obj.conName);
    params.put("CSR_SRid", obj.caseId);
    params.put("CSD_SRType", obj.type);
    params.put("CSD_SRArea", obj.area);
    params.put("CSD_SRSubArea", obj.subArea);
    params.put("CSD_SRStatus", obj.status);
    params.put("CSD_SRSubStatus", obj.subStatus);
    params.put("CSD_SRPriority", obj.priority);
    params.put("interactionId", obj.interactionId);
    if(obj.interactionId != null && obj.interactionId != ' ' && obj.interactionId != ''){
        console.log('inside if');
        iwscommand.SetAttachdataById(obj.interactionId, params);
    }
};
//Add a Event listener for the 'AssociateSREmail' event type
sforce.console.addEventListener('AssociateSREmail', listenerEmail);

//Define Event listener for the 'ReplyEmail' event type
var listenerReplyEmail = function (result) {
    console.log('Message received from event: ' + result.message);
    var obj = JSON.parse(result.message);
    if(obj.interactionId != null && obj.interactionId != ' ' && obj.interactionId != ''){
        console.log('inside if reply email');
        iwscommand.ReplyEmailById(obj.interactionId);
    }
};
//Add a Event listener for the 'ReplyEmail' event type
sforce.console.addEventListener('ReplyEmail', listenerReplyEmail);

//Define Event listener for the 'ReplyAllEmail' event type
var listenerReplyAllEmail = function (result) {
    console.log('Message received from event: ' + result.message);
    var obj = JSON.parse(result.message);
    if(obj.interactionId != null && obj.interactionId != ' ' && obj.interactionId != ''){
        console.log('inside if replyAll email');
        iwscommand.ReplyAllEmailById(obj.interactionId);
    }
};
//Add a Event listener for the 'ReplyAllEmail' event type
sforce.console.addEventListener('ReplyAllEmail', listenerReplyAllEmail);

//Define Event listener for the 'ForwardEmail' event type
var listenerForwardEmail = function (result) {
    console.log('Message received from event: ' + result.message);
    var obj = JSON.parse(result.message);
    if(obj.interactionId != null && obj.interactionId != ' ' && obj.interactionId != ''){
        console.log('inside if forward email');
        iwscommand.ForwardEmailById(obj.interactionId);
    }
};
//Add a Event listener for the 'ForwardEmail' event type
sforce.console.addEventListener('ForwardEmail', listenerForwardEmail);

//Define Event listener for the 'NewEmail' event type
var listenerNewEmail = function (result) {
    console.log('Message received from event: ' + result.message);
    var obj = JSON.parse(result.message);
    var params = iwscore.createUserData();
    params.put("CSD_SRNumber", obj.caseNumber);
    params.put("CSD_AccountName", obj.accName);
    params.put("CSD_ContactName", obj.conName);
    params.put("CSD_ContactId", obj.conId);
    params.put("CSD_AccountId", obj.accId);
    params.put("CSR_SRid", obj.caseId);
    params.put("CSD_SRType", obj.type);
    params.put("CSD_SRArea", obj.area);
    params.put("CSD_SRSubArea", obj.subArea);
    params.put("CSD_SRStatus", obj.status);
    params.put("CSD_SRSubStatus", obj.subStatus);
    params.put("CSD_SRPriority", obj.priority);
    params.put("SROwner", obj.caseOwner);
    params.put("CSD_CommMethod", "Email");
    console.log('inside new email');
    iwscommand.CreateNewOutboundEmail(obj.contactEmail,'','','','',params);
};
//Add a Event listener for the 'NewEmail' event type
sforce.console.addEventListener('NewEmail', listenerNewEmail);

window.onload=function(){
    deleteDuplicateEmails();
}