var Util = (function () {
    function Util() {
        this.mapDelegated = {};
        this.mapInteractions = {};
    }
    Util.prototype.addTabFocusListener = function () {
        sforce.console.onFocusedPrimaryTab(function (listened) {
            sforce.console.getFocusedPrimaryTabId(function (focused) {
                if (focused && listened && focused.id == listened.id) {
                    for (var key in iwscore.mapInteractions) {
                        var ixn = iwscore.mapInteractions[key];
                        var id = (ixn && ixn.attachdata) ? ixn.attachdata.ACTIVITY_ID || ixn.attachdata.WorkItemId || ixn.attachdata['context.WorkItemId'] : undefined;
                        if (id && id == listened.objectId) {
                            iwscommand.SetInteractionOnWde(ixn.InteractionID || ixn.ConnectionID);
                        }
                    }
                }
            });
        });
    };
    Util.prototype.listenToCustomEvents = function () {
        sforce.console.addEventListener('onBeforeUnload', function (res) {
            console.log("*** connector onBeforeUnload : ", res);
        });
    };
    Util.prototype.enableClickToDial = function () {
        var callback = function (res) {
            log.info("click to dial response=" + JSON.stringify(res));
        };
        log.info("enabling click to dial");
        if (isLightning) {
            sforce.opencti.onClickToDial({
                listener: function (payload) {
                    log.info('Clicked phone number: ' + +JSON.stringify(payload));
                    if (!payload || !payload.number) {
                        log.warn("The result from click to dial is not valid : " + JSON.stringify(payload));
                        return;
                    }
                    var mycollection = iwscore.createUserData();
                    mycollection.put("SF_RECID", payload.recordId);
                    mycollection.put("SF_CONTACTNUM", payload.number);
                    iwscommand.MakeCall(payload.number, mycollection);
                    //iwscommand.MakeCall(payload.number, undefined);
                }
            });
            sforce.opencti.enableClickToDial({ callback: callback });
        }
        else {
            log.info("setting onClickToDial");
            sforce.interaction.cti.onClickToDial(function (payload) {
                log.info('Clicked phone number: ' + JSON.stringify(payload));
                var result = JSON.parse(payload.result);
                if (!result || !result.number) {
                    log.warn("The result from click to dial is not valid : " + JSON.stringify(payload));
                    return;
                }
                log.info("Dialing phone number : " + result.number);
                iwscommand.MakeCall(result.number, undefined);
            });
            sforce.interaction.cti.enableClickToDial(undefined);
        }
    };
    Util.prototype.checkExists = function (event) {
        console.log("checkExists, event:", event);
        if (!event.attachdata) {
            console.log("the event has no attachdata, returning");
            return;
        }
        var id = event.attachdata.CONTACT_ID || event.attachdata.ACTIVITY_ID || event.attachdata.WorkItemId || event.attachdata['context.WorkItemId'];
        if (id) {
            log.infoFormat("There is already an item associated to this interaction : {0}, opening it", id);
            if (isLightning) {
                sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + id } });
            }
            else {
                sforce.interaction.screenPop('/' + id, true, undefined);
            }
            return true;
        }
        return false;
    };
    Util.prototype.createTask = function (event, field, id, subject) {
        if (this.checkExists(event)) {
            return;
        }
        var task = new sforce.SObject("task");
        task.Subject = subject;
        task.CallType = event.CallType;
        task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
        task.softphone_it__IWS_Media_Name__c = event.MediaType;
        ConnectorEntityController.createTask(task, field, id, function (result, req) {
            console.log("result : ", result);
            console.log("req : ", req);
            if (req.statusCode == 200) {
                var params = { "ACTIVITY_ID": result.Id };
                if (result.WhoId) {
                    params.CONTACT_ID = result.WhoId;
                }
                iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                var idToScreen = result.WhoId ? result.WhoId : result.Id;
                console.log("idToScreen :", idToScreen);
                if (isLightning) {
                    console.log("calling opencti");
                    sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen } });
                }
                else {
                    console.log("calling interaction");
                    sforce.interaction.screenPop('/' + idToScreen, true, function (res) {
                        console.log("screenpop result=", res);
                    });
                }
            }
        });
    };
    Util.prototype.createCase = function (event, field, id, subject) {
        if (this.checkExists(event)) {
            return;
        }
        var obj = new sforce.SObject("case");
        obj.Subject = subject;
        obj.IWS_Interaction_ID__c = event.ConnectionID;
        obj.IWS_Media_Name__c = event.MediaType;
        ConnectorEntityController.createCase(obj, field, id, function (result, req) {
            console.log("result : ", result);
            console.log("req : ", req);
            if (req.statusCode == 200) {
                var params = { "ACTIVITY_ID": result.Id };
                if (result.ContactId) {
                    params.CONTACT_ID = result.WhoId;
                }
                iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                var idToScreen = result.ContactId ? result.ContactId : result.Id;
                console.log("idToScreen :", idToScreen);
                if (isLightning) {
                    console.log("calling opencti");
                    sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen } });
                }
                else {
                    console.log("calling interaction");
                    sforce.interaction.screenPop('/' + idToScreen, true, function (res) {
                        console.log("screenpop result=", res);
                    });
                }
            }
        });
    };
    Util.prototype.createTaskAjax = function (event, field, id, subject) {
        var user = sforce.connection.getUserInfo(undefined);
        if (this.checkExists(event)) {
            return;
        }
        var task = new sforce.SObject("task");
        task.OwnerId = user.userId;
        task.Subject = subject;
        task.CallType = event.CallType;
        task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
        task.softphone_it__IWS_Media_Name__c = event.MediaType;
        console.log("task:", task);
        var q = "Select id,AccountId,Birthdate,Email,FirstName,LastName,Phone from Contact where {0} = \'{1}\'";
        var query = q.format(field, id);
        console.log("Executing query : ", query);
        var result = sforce.connection.query(query, undefined);
        var records = result.getArray("records");
        if (records && records.length == 1) {
            task.WhoId = records[0].Id;
        }
        sforce.connection.create([task], function (res) {
            console.log("task insert:");
            console.log(res);
            if (res && res.length > 0 && res[0].getBoolean("success")) {
                var params = iwscore.createUserData();
                params.put("ACTIVITY_ID", res[0].id);
                params.put("interactionId", event.ConnectionID);
                iwscommand.SetAttachdataByIdAndCustomerId(event.InteractionID, event.CustomerID, params);
                console.log("isLightning=" + isLightning);
                console.log(typeof isLightning);
                if (isLightning) {
                    console.log("calling opencti");
                    sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + res[0].id } });
                }
                else {
                    console.log("calling interaction");
                    sforce.interaction.screenPop('/' + res[0].id, true, function (res) {
                        console.log("screenpop result=", res);
                    });
                }
            }
        });
    };
    Util.prototype.updateTaskDuration = function (event) {
        console.log("updateTaskDuration Event:");
        console.log(event);
        if (!event.Duration) {
            log.warn("The event has no duration, no update performed!");
            return;
        }
        var taskId = event.attachdata.ACTIVITY_ID;
        var task = new sforce.SObject("task");
        task.id = taskId;
        task.CallDurationInSeconds = parseInt(event.Duration);
        var result = sforce.connection.update([task], undefined);
        if (result[0].getBoolean("success")) {
            log.info("account with id " + result[0].id + " updated");
        }
        else {
            log.error("failed to update account " + result[0]);
        }
    };
    Util.prototype.updateConnectionLed = function (clazz, msg) {
        $("#led").removeClass();
        $("#led").addClass(clazz);
        $(".led-msg p").text(msg);
    };
    Util.prototype.updateOpenCtiStatus = function (connected) {
        if (isLightning) {
            var icon = connected ? 'call' : 'end_call';
            sforce.opencti.setSoftphoneItemIcon({ key: icon, callback: function (res) { return console.log("result change icon : ", res); } });
        }
    };
    return Util;
}());
var sfutil = new Util();
