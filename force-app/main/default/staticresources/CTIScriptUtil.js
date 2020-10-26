var CTIUtil = (function () {
    function CTIUtil() {
        this.mapDelegated = {};
        this.mapInteractions = {};
    }
    CTIUtil.prototype.updateConsultedUser = function (event) {
        var id = event.attachdata.ACTIVITY_ID;
        if (id) {
            log.infoFormat("Activity Id", id);
            log.infoFormat("Consulted user update", runningUserId);
            if (isLightning) {
                var params = { "SF_ConsultedUser_ID": runningUserId };
				iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
			}
        }
    };
    CTIUtil.prototype.updateConferenceFlag = function (event, field) {
        var id = event.attachdata.ACTIVITY_ID;
        if (id) {
            log.infoFormat("Activity Id", id);
            log.infoFormat("Conference flag update");
            if (isLightning) {
                if(field == 'Added'){
                    var params = { "SF_ConferenceInitiated": "True" };
					iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                }else if(field == 'Deleted'){
                    var params = { "SF_ConferenceInitiated": "False" };
					iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                }
			}
        }
    };
    CTIUtil.prototype.extractEmails = function (text)
    {
        var emails = text.match(/([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9._-]+)/gi);
        var set2 = new Set(emails); 
        var val = ''
    
        for (item of set2.values())
            val+=item + ';'; 
        return val;
    };
    CTIUtil.prototype.createExistingEmailTask = function (event) {
        console.log('createExistingEmailTask : message'+ event);
        console.log('Existing thread with case');
        var task = new sforce.SObject("task");
        task.Subject = event.EntrepriseInteractionCurrent.Subject;
        task.GCM_Call_From__c = event.attachdata.EmailAddress? event.attachdata.EmailAddress : event.attachdata.CtmFrom;
        task.GCM_Call_To__c = event.attachdata.CtmTo.substring(0,254);
        task.GCM_Match_Type__c = event.attachdata.CSD_MatchType;
        task.CallType = event.CallType;
        task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
        task.softphone_it__IWS_Media_Name__c = event.MediaType;
        task.Description = event.EntrepriseInteractionCurrent.StructuredText;
        task.GCM_BU__c = 'BU-'+event.attachdata.CSD_BU+';SO-'+event.attachdata.CSD_SalesOrganisation;
        task.GCM_Sales_Organisation__c = event.attachdata.CSD_SFCaseRecordType;
        //task.GCM_Cc_Addresses__c = this.extractEmails(event.attachdata.Cc);
        var c = null;
        console.log('cc'+event.attachdata.Cc);
        var ccAddr = event.attachdata.Cc? this.extractEmails(event.attachdata.Cc) : null;
        var srId = event.attachdata.CSR_SRid? event.attachdata.CSR_SRid : null;
        var srNumber = event.attachdata.CSD_SRNumber? event.attachdata.CSD_SRNumber : null;
        var accId = event.attachdata.CSD_AccountId? event.attachdata.CSD_AccountId : null;
        var conId = event.attachdata.CSD_ContactId? event.attachdata.CSD_ContactId : null;
        var matchType = event.attachdata.CSD_MatchType? event.attachdata.CSD_MatchType : null;
        var defAccId = event.attachdata.CSD_DefaultAccountId? event.attachdata.CSD_DefaultAccountId : null;
        var defConId = event.attachdata.CSD_DefaultContactId? event.attachdata.CSD_DefaultContactId : null;
        var createSR = event.attachdata.CSD_CreateSR? event.attachdata.CSD_CreateSR : null;
        var commMethod = event.attachdata.CSD_CommMethod? event.attachdata.CSD_CommMethod : null;
        var hasAttachment = event.attachdata._ContainsAttachment? event.attachdata._ContainsAttachment : null;
        var caseRecordType = event.attachdata.CSD_SFCaseRecordType? event.attachdata.CSD_SFCaseRecordType : null;
        
        if(event.MediaType == "email" && event.CallType == "Inbound") {
            GCM_CTIController.createTaskforInboundEmail(task, accId, conId, matchType, defAccId, defConId, event.EntrepriseInteractionCurrent.StartDate, event.EntrepriseInteractionCurrent.Subject, event.EntrepriseInteractionCurrent.MessageText, createSR, c, commMethod, srNumber , hasAttachment, ccAddr, caseRecordType, function (result, req) {
                console.log("result : ", result);
                console.log("req : ", req);
                if (req.statusCode == 200) {
                    var params = { "ACTIVITY_ID": result.Id };
                    if (result.WhoId) {
                        params.CONTACT_ID = result.WhoId;
                    }
                    var casId = result.WhatId;
                    iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                 
                    //var idToScreen = result.WhoId ? result.WhoId : result.Id;
                    var idToScreen;
                    if(event.attachdata.CSD_CreateSR == 'Y' && event.attachdata.CSR_SRid != null && event.attachdata.CSR_SRid != undefined){
                        console.log('inside createsr Y pop');
                        idToScreen = casId;
                    } else if(event.attachdata.CSD_CreateSR = 'N' && event.attachdata.CSR_SRid != null && event.attachdata.CSR_SRid != undefined ){
                        console.log('inside createsr N pop');
                        GCM_CTIController.getCaseDetails(result.WhatId, function (resultCase, req) {
                            console.log("result : CreateExistingTaskemail", resultCase);		
                            console.log("req : ", req);		
                            if (req.statusCode == 200) {
                                if(resultCase.Status == 'Open' || resultCase.Status == 'In Progress'){
                                    console.log('inside open or in progress');
                                    idToScreen = casId;
                                }else {
                                    idToScreen = result.Id;
                                }
                                console.log("idToScreen :", idToScreen);
                                if (isLightning) {
                         			var callback = function(response) {
                                    if (response.success) {
                                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                                        var listeneropen = function (resultOpenTab) {
                                            console.log('Message received from event: ' + resultOpenTab.message);
                                            var showTabId = function showTabId(result) {
                                                console.log('focussed console Tab ID: ' + result.id);
                                                console.log('Tab ID: ' + result.id);
                                                console.log('Tab ID: ' + resultOpenTab.objectId);
                                                var objId = resultOpenTab.objectId;
                                                var sfTabId = result.id;
                                                console.log('sfTabId: ' + sfTabId);
                                                if(sfTabId != null && sfTabId != undefined && (objId.startsWith("00T",0) || objId.startsWith("500",0)) && objId == idToScreen){
                                                    params.SF_TAB_ID = sfTabId;
                                                    iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                                                    console.log('after set attach data command');
                                                }
                                            };
                                    		sforce.console.getFocusedPrimaryTabId(showTabId);
                                			};
                                			sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB,
                                                                			listeneropen
                                                               				);
                            		} else { 
                                		console.error('Something went wrong! Errors:', response.errors);
                            			}
                        			};
                                    console.log("calling opencti");
                                    sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen },callback: callback });
                                    if(result.GCM_Email_Message_Id__c){
                                        attachmentUtil.uploadAttachment(event.ConnectionID,result.GCM_Email_Message_Id__c);
                                    }
                                }
                            }
                        });
                        return;
                    } else {
                        idToScreen = result.Id;
                    }
                    //var idToScreen = casId.startsWith("500",0)? casId : result.Id;
                    console.log("idToScreen :", idToScreen);
                    if (isLightning) {
                        var callback = function(response) {
                                    if (response.success) {
                                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                                        var listeneropen = function (resultOpenTab) {
                                            console.log('Message received from event: ' + resultOpenTab.message);
                                            var showTabId = function showTabId(result) {
                                                console.log('focussed console Tab ID: ' + result.id);
                                                console.log('Tab ID: ' + result.id);
                                                console.log('Tab ID: ' + resultOpenTab.objectId);
                                                var objId = resultOpenTab.objectId;
                                                var sfTabId = result.id;
                                                console.log('sfTabId: ' + sfTabId);
                                                if(sfTabId != null && sfTabId != undefined && (objId.startsWith("00T",0) || objId.startsWith("500",0)) && objId == idToScreen){
                                                    params.SF_TAB_ID = sfTabId;
                                                    iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                                                    console.log('after set attach data command');
                                                }
                                            };
                                    		sforce.console.getFocusedPrimaryTabId(showTabId);
                                			};
                                			sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB,
                                                                			listeneropen
                                                               				);
                            		} else { 
                                		console.error('Something went wrong! Errors:', response.errors);
                            			}
                        			};
                        console.log("calling opencti");
                        sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen },callback: callback });
                    	if(result.GCM_Email_Message_Id__c){
                            attachmentUtil.uploadAttachment(event.ConnectionID,result.GCM_Email_Message_Id__c);
                        }
                    }
                    else {
                        console.log("calling interaction");
                        sforce.interaction.screenPop('/' + idToScreen, true, function (res) {
                            console.log("screenpop result=", res);
                        });
                    }
                }
            });
        }
        
    };
    CTIUtil.prototype.transferredEmail = function (event) {
        console.log("transferredEmail, event:", event);
        var id = event.attachdata.ACTIVITY_ID;
        console.log('Id'+id);
        console.log('srnumber'+event.attachdata.CSD_SRNumber);
        console.log('srid'+event.attachdata.CSR_SRid);
        console.log('srcommmethod'+event.attachdata.CSD_CommMethod);
        console.log('createsr '+event.attachdata.CSD_CreateSR);
        console.log('InteractionSubType'+event.EntrepriseInteractionCurrent.InteractionSubtype);
        
        if (id) {
            log.infoFormat("There is already an item associated to this email transfer interaction : {0}, opening it", id);
            if (isLightning) {
				console.log('Inside email transfer');
                    GCM_CTIController.updateTaskOwner(id, function (result, req) {		
                        console.log("result : ", result);		
                        console.log("req : ", req);		
                        if (req.statusCode == 200) {		
                            console.log('update owner successful');
                            var casId = result.WhatId;
                            if(event.attachdata.CSD_CreateSR == 'N' && casId.startsWith("500",0)){
                                GCM_CTIController.getCaseDetails(result.WhatId, function (resultCase, req) {
                                    console.log("result : transferredEmail CreateSR = N pop", resultCase);		
                                    console.log("req : ", req);		
                                    if (req.statusCode == 200) {
                                        if(resultCase.Status == 'Open' || resultCase.Status == 'In Progress'){
                                            console.log('inside open or in progress');
                                            idToScreen = casId;
                                        }else {
                                            idToScreen = result.Id;
                                        }
                                        console.log("idToScreen :", idToScreen);
                                        if (isLightning) {
                                            var callback = function(response) {
                                            if (response.success) {
                                                console.log('API method call executed successfully! returnValue:', response.returnValue);
                                                var listeneropen = function (resultOpenTab) {
                                                    console.log('Message received from event: ' + resultOpenTab.message);
                                                    var showTabId = function showTabId(result) {
                                                        console.log('focussed console Tab ID: ' + result.id);
                                                        console.log('Tab ID: ' + result.id);
                                                        console.log('Tab ID: ' + resultOpenTab.objectId);
                                                        var objId = resultOpenTab.objectId;
                                                        var sfTabId = result.id;
                                                        console.log('sfTabId: ' + sfTabId);
                                                        if(sfTabId != null && sfTabId != undefined && (objId.startsWith("00T",0) || objId.startsWith("500",0)) && objId == idToScreen){
                                                            params.SF_TAB_ID = sfTabId;
                                                            iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                                                            console.log('after set attach data command');
                                                        }
                                                    };
                                                    sforce.console.getFocusedPrimaryTabId(showTabId);
                                                    };
                                                    sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB,
                                                                                    listeneropen
                                                                                    );
                                            } else { 
                                                console.error('Something went wrong! Errors:', response.errors);
                                                }
                                            };
                                            console.log("calling opencti");
                                            sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen },callback: callback });
                                        }
                                    }
                                });
                            } else {
                                var idToScreen = casId.startsWith("500",0)? casId : id;
                                var callback = function(response) {
                                    if (response.success) {
                                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                                        var listeneropen = function (resultOpenTab) {
                                            console.log('Message received from event: ' + resultOpenTab.message);
                                            var showTabId = function showTabId(result) {
                                                console.log('focussed console Tab ID: ' + result.id);
                                                console.log('Tab ID: ' + result.id);
                                                console.log('Tab ID: ' + resultOpenTab.objectId);
                                                var objId = resultOpenTab.objectId;
                                                var sfTabId = result.id;
                                                console.log('sfTabId: ' + sfTabId);
                                                if(sfTabId != null && sfTabId != undefined && (objId.startsWith("00T",0) || objId.startsWith("500",0)) && objId == idToScreen){
                                                    var params = { "SF_TAB_ID": sfTabId };
                                                    //params.SF_TAB_ID = sfTabId;
                                                    iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                                                    console.log('after set attach data command');
                                                }
                                            };
                                            sforce.console.getFocusedPrimaryTabId(showTabId);
                                        };
                                        sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB,
                                                                        listeneropen
                                                                       );
                                    } else { 
                                        console.error('Something went wrong! Errors:', response.errors);
                                    }
                                };
                                sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen }, callback: callback});
                            }
                        }
                	});
            }
            else {
                sforce.interaction.screenPop('/' + id, true, undefined);
            }
            return true;
        }
        return false;
    };
    CTIUtil.prototype.popTask = function (event) {
        console.log("popTask, event:", event);
        if (!event.attachdata) {
            console.log("the event has no attachdata, returning");
            return;
        }
        var id = event.attachdata.ACTIVITY_ID;
        if (id) {
            log.infoFormat("There is already an item associated to this interaction : {0}, opening it", id);
            if (isLightning) {
                console.log("myInteractionMap",myInteractionMap);
                if(myInteractionMap.get(event.ConnectionID) == undefined){
                    sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + id } });
                } else {
                    myInteractionMap.delete(event.ConnectionID);
                    console.log("myInteractionMap",myInteractionMap);
                }
            }
        }
    }
    CTIUtil.prototype.checkTaskCTI = function (event) {
        console.log("checkTaskCTI, event:", event);
        if (!event.attachdata) {
            console.log("the event has no attachdata, returning");
            return;
        }
        //var id = event.attachdata.CONTACT_ID || event.attachdata.ACTIVITY_ID || event.attachdata.WorkItemId || event.attachdata['context.WorkItemId'];
        var id = event.attachdata.ACTIVITY_ID;
        console.log('Id'+id);
        console.log('srnumber'+event.attachdata.CSD_SRNumber);
        console.log('srid'+event.attachdata.CSR_SRid);
        console.log('srstatus'+event.attachdata.CSD_SRStatus);
        console.log('srsubstatus'+event.attachdata.CSD_SRSubStatus);
        console.log('srpriority'+event.attachdata.CSD_SRPriority);
        console.log('srcommmethod'+event.attachdata.CSD_CommMethod);
        console.log('createsr '+event.attachdata.CSD_CreateSR);
        console.log('InteractionSubType'+event.EntrepriseInteractionCurrent.InteractionSubtype);
        
        if (id) {
            log.infoFormat("There is already an item associated to this interaction : {0}, opening it", id);
            if (isLightning) {
                if(event.attachdata.SF_ConferenceInitiated != undefined && event.attachdata.SF_ConferenceInitiated != null && event.attachdata.SF_ConferenceInitiated == 'True'){
                    
                }else if(event.attachdata.GCS_TransferringAgentName != null && event.attachdata.GCS_TransferringAgentName != undefined){
                    GCM_CTIController.updateTaskOwner(id, function (result, req) {		
                        console.log("result : ", result);		
                        console.log("req : ", req);		
                        if (req.statusCode == 200) {		
                            console.log('update owner successful');
                            var callback = function(response) {
                                if (response.success) {
                                    console.log('API method call executed successfully! returnValue:', response.returnValue);
                                    var listeneropen = function (resultOpenTab) {
                                        console.log('Message received from event: ' + resultOpenTab.message);
                                        var showTabId = function showTabId(result) {
                                            console.log('focussed console Tab ID: ' + result.id);
                                            console.log('Tab ID: ' + result.id);
                                            console.log('Tab ID: ' + resultOpenTab.objectId);
                                            var objId = resultOpenTab.objectId;
                                            var sfTabId = result.id;
                                            console.log('sfTabId: ' + sfTabId);
                                            if(sfTabId != null && sfTabId != undefined && objId.startsWith("00T",0) && objId == id){
                                                var params = { "SF_TAB_ID": sfTabId };
                                               // params.SF_TAB_ID = sfTabId;
                                                iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                                                console.log('after set attach data command');
                                            }
                                        };
                                        sforce.console.getFocusedPrimaryTabId(showTabId);
                                    };
                                    sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB,
                                                                    listeneropen
                                                                   );
                                } else { 
                                    console.error('Something went wrong! Errors:', response.errors);
                                }
                            };
                            sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + id },callback: callback });
                         }		
                	});
                }else if(event.attachdata.CSD_CommMethod == 'Email' && event.OperationType != undefined && event.OperationType == 'workbin'){
                    //Create task and email message for the SR
                    console.log('Inside workbin- Event Established');
                    return true;
                }else if(event.attachdata.CSD_CommMethod == 'Email' && event.EntrepriseInteractionCurrent.InteractionSubtype == 'InboundCustomerReply'){
                    //Create task and email message for the SR
                    console.log('Inside inbound reply');
                    this.createExistingEmailTask(event);
                }else if(event.attachdata.CSD_CommMethod == 'Email' && event.EntrepriseInteractionCurrent.InteractionSubtype == 'OutboundReply' && event.attachdata.CSR_SRid != undefined && event.attachdata.CSR_SRid != null){
                    //OutboundReply
                    return false;
                }else if(event.attachdata.CSD_CommMethod == 'Email' && event.EntrepriseInteractionCurrent.InteractionSubtype == 'InboundNew'){
                    //New Inbound email transferred
                    console.log('Inside inbound new with Task ID i.e., transferred task');
                    return true;
                }else {
                    sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + id } });
                }
            }
            else {
                sforce.interaction.screenPop('/' + id, true, undefined);
            }
            return true;
        }
        if(event.attachdata.CSD_CommMethod == 'Email' && event.EntrepriseInteractionCurrent.InteractionSubtype == 'InboundNew' && event.attachdata.CSD_SRNumber != undefined && event.attachdata.CSD_SRNumber != null){
            //Create task and email message for the SR
            this.createNewEmailTaskwithCaseNumber(event);
            console.log('SRNumber '+event.attachdata.CSD_SRNumber);
            return true;
        }
        return false;
    };
    CTIUtil.prototype.createVoiceTask = function (event, field, id, subject) {
        if (this.checkTaskCTI(event)) {
            return;
        }
        var task = new sforce.SObject("task");
        task.Subject = 'Call-'+event.CallType;
        task.CallType = event.CallType;
        task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
        task.softphone_it__IWS_Media_Name__c = event.MediaType;
        task.GCM_Match_Type__c = event.attachdata.CSD_MATCHTYPE;
        task.GCM_Call_From__c = event.ANI;
        task.GCM_Call_To__c = event.DNIS;
        task.GCM_BU__c = 'BU-'+event.attachdata.CSD_BU+';SO-'+event.attachdata.CSD_SalesOrganisation;
        task.GCM_Sales_Organisation__c = event.attachdata.CSD_SFCaseRecordType;
        var sfConRecId = null;
        if(event.attachdata.SF_RECID){
            var sfConRecId = event.attachdata.SF_RECID;
        }
        if(event.MediaType == "voice" && event.CallType == "Outbound"){
            console.log('Inside outbound'+sfConRecId);
            GCM_CTIController.createTaskforOutboundCall(task, id, sfConRecId, function (result, req) {
                console.log("result : ", result);
                console.log("req : ", req);
                if (req.statusCode == 200) {
                    var params = { "ACTIVITY_ID": result.Id };
                    if (result.WhoId) {
                        params.CONTACT_ID = result.WhoId;
                    }
                    if(result.WhatId && result.WhatId.startsWith("500",0)){
                        GCM_CTIController.getCaseDetails(result.WhatId, function (result, req) {
                            console.log("result : ", result);		
                			console.log("req : ", req);		
                			if (req.statusCode == 200) {
                       			params.CSD_SRNumber = result.CaseNumber;
                            }
                        });
                    }
                    iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                    // var idToScreen = result.WhoId ? result.WhoId : result.Id;
                    var idToScreen = result.Id;
                    console.log("idToScreen :", idToScreen);
                    if (isLightning) {
                        console.log("calling opencti");
                        var callback = function(response) {
                            if (response.success) {
                                console.log('API method call executed successfully! returnValue:', response.returnValue);
                                //alert('Focus this window pls');
                                var listeneropen = function (resultOpenTab) {
                                    console.log('Message received from event: ' + resultOpenTab.message);
                                    var showTabId = function showTabId(result) {
                                        console.log('focussed console Tab ID: ' + result.id);
                                        console.log('Tab ID: ' + result.id);
                                        console.log('Tab ID: ' + resultOpenTab.objectId);
                                        var objId = resultOpenTab.objectId;
                                        var sfTabId = result.id;
                                        console.log('sfTabId: ' + sfTabId);
                                        if(sfTabId != null && sfTabId != undefined && objId.startsWith("00T",0) && objId == idToScreen){
                                            params.SF_TAB_ID = sfTabId;
                                            iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                                            console.log('after set attach data command');
                                        }
                                    };
                                    sforce.console.getFocusedPrimaryTabId(showTabId);
                                };
                                sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB,
                                                                listeneropen
                                                               );
                            } else { 
                                console.error('Something went wrong! Errors:', response.errors);
                            }
                        };
                        sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen },callback: callback });
                    	window.focus();
                    }
                    else {
                        console.log("calling interaction");
                        sforce.interaction.screenPop('/' + idToScreen, true, function (res) {
                            console.log("screenpop result=", res);
                        });
                    }  
                }
            });
        } else if(event.MediaType == "voice"){
            console.log('contact id'+event.attachdata.CSD_CONTACTID);
            console.log('account id'+event.attachdata.CSD_ACCOUNTID);
            var accId = event.attachdata.CSD_ACCOUNTID? event.attachdata.CSD_ACCOUNTID : null;
            var conId = event.attachdata.CSD_CONTACTID? event.attachdata.CSD_CONTACTID : null;
            var matchType = event.attachdata.CSD_MATCHTYPE? event.attachdata.CSD_MATCHTYPE : null;
            var defAccId = event.attachdata.CSD_DEF_ACCOUNTID? event.attachdata.CSD_DEF_ACCOUNTID : null;
            var defConId = event.attachdata.CSD_DEF_CONTACTID? event.attachdata.CSD_DEF_CONTACTID : null;
            GCM_CTIController.createTaskforInboundCall(task, id, accId, conId, matchType, defAccId, defConId, function (result, req) {
                console.log("result : ", result);
                console.log("req : ", req);
                if (req.statusCode == 200) {
                    var params = { "ACTIVITY_ID": result.Id };
                    if (result.WhoId) {
                        params.CONTACT_ID = result.WhoId;
                    }
                    iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                    //var idToScreen = result.WhoId ? result.WhoId : result.Id;
                    var idToScreen = result.Id;
                    console.log("idToScreen :", idToScreen);
                    if (isLightning) {
                        console.log("calling opencti");
                        var callback = function(response) {
                            if (response.success) {
                                console.log('API method call executed successfully! returnValue:', response.returnValue);
                                var listeneropen = function (resultOpenTab) {
                                    console.log('Message received from event: ' + resultOpenTab.message);
                                    var showTabId = function showTabId(result) {
                                        console.log('focussed console Tab ID: ' + result.id);
                                        console.log('Tab ID: ' + result.id);
                                        console.log('Tab ID: ' + resultOpenTab.objectId);
                                        var objId = resultOpenTab.objectId;
                                        var sfTabId = result.id;
                                        console.log('sfTabId: ' + sfTabId);
                                        if(sfTabId != null && sfTabId != undefined && objId.startsWith("00T",0) && objId == idToScreen){
                                            params.SF_TAB_ID = sfTabId;
                                            iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                                            console.log('after set attach data command');
                                        }
                                    };
                                    sforce.console.getFocusedPrimaryTabId(showTabId);
                                };
                                sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB,
                                                                listeneropen
                                                               );
                            } else { 
                                console.error('Something went wrong! Errors:', response.errors);
                            }
                        };
                        sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen },callback: callback });
                    }
                    else {
                        console.log("calling interaction");
                        sforce.interaction.screenPop('/' + idToScreen, true, function (res) {
                            console.log("screenpop result=", res);
                        });
                    }
                }
            });
        } else {
            GCM_CTIController.createTask(task, field, id, function (result, req) {
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
        }
    };
    
    CTIUtil.prototype.createNewEmailTask = function (event, field, id, subject) {
        if (this.checkTaskCTI(event)) {
            return;
        }
        console.log('New email or existing thread without case');
		var task = new sforce.SObject("task");
		task.Subject = event.EntrepriseInteractionCurrent.Subject;
		task.GCM_Call_From__c = event.attachdata.EmailAddress? event.attachdata.EmailAddress : event.attachdata.CtmFrom;
		task.GCM_Call_To__c = event.attachdata.CtmTo.substring(0,254);
		task.GCM_Match_Type__c = event.attachdata.CSD_MatchType;
		task.CallType = event.CallType;
        task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
        task.softphone_it__IWS_Media_Name__c = event.MediaType;
        task.Description = event.EntrepriseInteractionCurrent.StructuredText;
        task.GCM_BU__c = 'BU-'+event.attachdata.CSD_BU+';SO-'+event.attachdata.CSD_SalesOrganisation;
        task.GCM_Sales_Organisation__c = event.attachdata.CSD_SFCaseRecordType;
       // task.GCM_Cc_Addresses__c = this.extractEmails(event.attachdata.Cc);
        var c = null;
        if(event.attachdata.CSD_CreateSR == 'Y'){
            cas = new sforce.SObject("Case");
            cas.Type = event.attachdata.CSD_SRType;
            cas.Area__c = event.attachdata.CSD_SRArea;
            cas.Sub_Area__c = event.attachdata.CSD_SRSubArea;
            c = cas;
            console.log('CAse '+cas);
            console.log('CAse '+c);
        }
        var srId;
        console.log('cc'+event.attachdata.Cc);
        var ccAddr = event.attachdata.Cc? this.extractEmails(event.attachdata.Cc) : null;
        var accId = event.attachdata.CSD_AccountId? event.attachdata.CSD_AccountId : null;
        var conId = event.attachdata.CSD_ContactId? event.attachdata.CSD_ContactId : null;
        var matchType = event.attachdata.CSD_MatchType? event.attachdata.CSD_MatchType : null;
        var defAccId = event.attachdata.CSD_DefaultAccountId? event.attachdata.CSD_DefaultAccountId : null;
        var defConId = event.attachdata.CSD_DefaultContactId? event.attachdata.CSD_DefaultContactId : null;
        var createSR = event.attachdata.CSD_CreateSR? event.attachdata.CSD_CreateSR : null;
        var commMethod = event.attachdata.CSD_CommMethod? event.attachdata.CSD_CommMethod : null;
        var hasAttachment = event.attachdata._ContainsAttachment? event.attachdata._ContainsAttachment : null;
        var caseRecordType = event.attachdata.CSD_SFCaseRecordType? event.attachdata.CSD_SFCaseRecordType : null;
		if(event.MediaType == "email" && event.CallType == "Inbound") {
            GCM_CTIController.createTaskforInboundEmail(task, accId, conId, matchType, defAccId, defConId, event.EntrepriseInteractionCurrent.StartDate, event.EntrepriseInteractionCurrent.Subject, event.EntrepriseInteractionCurrent.MessageText, createSR, c, commMethod, null, hasAttachment, ccAddr, caseRecordType, function (result, req) {
                console.log("result : ", result);
                console.log("req : ", req);
                if (req.statusCode == 200) {
                    
                    var params = { "ACTIVITY_ID": result.Id };
                    if (result.WhoId) {
                        params.CONTACT_ID = result.WhoId;
                    }
                    var casId = result.WhatId;
                    if(casId && casId.startsWith("500",0)){
                        GCM_CTIController.getCaseDetails(result.WhatId, function (resultCase, req) {
                            console.log("result : association", resultCase);		
                            console.log("req : ", req);		
                            if (req.statusCode == 200) {
                                params.CSD_SRNumber = resultCase.CaseNumber;
                                params.CSR_SRid = resultCase.Id;
                                params.CSD_SRStatus = resultCase.Status;
                        		params.CSD_SRSubStatus = resultCase.Sub_Status__c;
                                params.CSD_SRPriority = resultCase.Priority;
                                iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                            }
                        });
                    }else {
                        iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                    }
                    //var idToScreen = result.WhoId ? result.WhoId : result.Id;
                    
                    var idToScreen = (casId && casId.startsWith("500",0))? casId : result.Id;
                    console.log("idToScreen :", idToScreen);
                    if (isLightning) {
                        var callback = function(response) {
                            if (response.success) {
                                console.log('API method call executed successfully! returnValue:', response.returnValue);
                                var listeneropen = function (resultOpenTab) {
                                    console.log('Message received from event: ' + resultOpenTab.message);
                                    var showTabId = function showTabId(result) {
                                        console.log('focussed console Tab ID: ' + result.id);
                                        console.log('Tab ID: ' + result.id);
                                        console.log('Tab ID: ' + resultOpenTab.objectId);
                                        var objId = resultOpenTab.objectId;
                                        var sfTabId = result.id;
                                        console.log('sfTabId: ' + sfTabId);
                                        if(sfTabId != null && sfTabId != undefined && (objId.startsWith("00T",0) || objId.startsWith("500",0)) && objId == idToScreen){
                                            params.SF_TAB_ID = sfTabId;
                                            iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                                            console.log('after set attach data command');
                                        }
                                    };
                                    sforce.console.getFocusedPrimaryTabId(showTabId);
                                };
                                sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB,
                                                                listeneropen
                                                               );
                            } else { 
                                console.error('Something went wrong! Errors:', response.errors);
                            }
                        };
                        console.log("calling opencti");
                        sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen }, callback: callback });
                    	if(result.GCM_Email_Message_Id__c){
                            attachmentUtil.uploadAttachment(event.ConnectionID,result.GCM_Email_Message_Id__c);
                        }
                    }
                    else {
                        console.log("calling interaction");
                        sforce.interaction.screenPop('/' + idToScreen, true, function (res) {
                            console.log("screenpop result=", res);
                        });
                    }
                }
            });
        }
    };
    
    CTIUtil.prototype.updateTaskDetail = function (event, field) {		
        console.log("update task:"+event.attachdata.ACTIVITY_ID);		
        console.log(event);		
        var taskId = event.attachdata.ACTIVITY_ID;
        var mediaTyp;
        if(event.MediaType == "voice") {
            mediaTyp = 'Call';
        } else {
            mediaTyp = event.attachdata.CSD_CommMethod;
        }
        var taskTyp = mediaTyp+'-'+event.CallType; //Inbound/Outbound
        console.log('Task type'+taskTyp);
        console.log('tab ID' + event.attachdata.SF_TAB_ID);
        console.log('GCS_TransferringAgentName' + event.attachdata.GCS_TransferringAgentName);
        console.log('GCS_TransferringEmployeeId' + event.attachdata.GCS_TransferringEmployeeId);
        console.log('GCS_TransferringDate' + event.attachdata.GCS_TransferringDate);
        var empId = event.attachdata.GCS_TransferringEmployeeId;
        if(field == 'MarkDone' && event.attachdata.SF_ConsultedUser_ID != undefined && event.attachdata.SF_ConsultedUser_ID != null && event.attachdata.SF_ConsultedUser_ID == runningUserId){
            var params = { "SF_ConsultedUser_ID": "" };
			iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
        }else if(event.attachdata.GCS_TransferringAgentName != null && event.attachdata.GCS_TransferringAgentName != undefined){
            console.log('inside transfer');
            GCM_CTIController.checkCurrentUser(empId, function (result, req) {		
                console.log("result : ", result);		
                console.log("req : ", req);		
                if (req.statusCode == 200) {		
                    console.log('current user');
                    if(result == true){
                        if(field != 'MarkDone'){
                            sforce.console.closeTab(event.attachdata.SF_TAB_ID);
                            console.log('Event released with transfer attach data - current user true - close tab');
                        } else{
                            console.log('Mark with transfer attach data - current user true - Do nothing');
                        } 
                    }else if(taskId){
                        GCM_CTIController.updateTaskDetail(taskId, field, taskTyp, function (result, req) {		
                            console.log("result : ", result);		
                            console.log("req : ", req);		
                            if (req.statusCode == 200) {		
                                console.log('update successful');	
                                
                            }		
                        });	
                    } 
                }		
            });
            //sforce.console.closeTab(event.attachdata.SF_TAB_ID);
        } else if(event.OperationType == 'transferred' && event.MediaType == 'email'){
            console.log('Inside operation type transferred'+event.attachdata.SF_TAB_ID);
            sforce.console.closeTab(event.attachdata.SF_TAB_ID);
        }else if(taskId){
            GCM_CTIController.updateTaskDetail(taskId, field, taskTyp, function (result, req) {		
                console.log("result : ", result);		
                console.log("req : ", req);		
                if (req.statusCode == 200) {		
                    console.log('update successful');	
                    
                }		
            });		
        }
    };
    
    CTIUtil.prototype.createOutboundEmailTask = function (event, field, id, subject) {
        console.log('Outbound Email');
		var task = new sforce.SObject("task");
		task.Subject = event.EntrepriseInteractionCurrent.Subject;
		task.GCM_Call_From__c = event.attachdata.FromAddress;
		task.GCM_Call_To__c = event.attachdata.To.substring(0,254);
		task.GCM_Match_Type__c = event.attachdata.CSD_MatchType;
		task.CallType = event.CallType;
        task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
        task.softphone_it__IWS_Media_Name__c = event.MediaType;
        task.Description = event.EntrepriseInteractionCurrent.StructuredText;
        task.GCM_BU__c = 'BU-'+event.attachdata.CSD_BU+';SO-'+event.attachdata.CSD_SalesOrganisation;
        task.GCM_Sales_Organisation__c = event.attachdata.CSD_SFCaseRecordType;
       // task.GCM_Cc_Addresses__c = event.attachdata.CcAddresses;
        console.log('task outbound' + task);
        console.log('media type' +event.MediaType);
		console.log('Common method' +event.attachdata.CSD_CommMethod);
        console.log('Call type' +event.CallType);
        console.log('cc address' +event.attachdata.CcAddresses);
        console.log('bcc address' +event.attachdata.BccAddresses);
        console.log('interaction id '+event.ConnectionID);
        var srId = event.attachdata.CSR_SRid? event.attachdata.CSR_SRid : null;
        var srNumber = event.attachdata.CSD_SRNumber? event.attachdata.CSD_SRNumber : null;
        var accId = event.attachdata.CSD_AccountId? event.attachdata.CSD_AccountId : null;
        var conId = event.attachdata.CSD_ContactId? event.attachdata.CSD_ContactId : null;
        var matchType = event.attachdata.CSD_MatchType? event.attachdata.CSD_MatchType : null;
        var defAccId = event.attachdata.CSD_DefaultAccountId? event.attachdata.CSD_DefaultAccountId : null;
        var defConId = event.attachdata.CSD_DefaultContactId? event.attachdata.CSD_DefaultContactId : null;
        var createSR = event.attachdata.CSD_CreateSR? event.attachdata.CSD_CreateSR : null;
        var commMethod = event.attachdata.CSD_CommMethod? event.attachdata.CSD_CommMethod : null;
        var srStatus = event.attachdata.CSD_SRStatus? event.attachdata.CSD_SRStatus : null;
        var bccAddr = event.attachdata.BccAddresses? event.attachdata.BccAddresses : '';
        var ccAddr = '';
        if(event.attachdata.CcAddresses){
            ccAddr = this.extractEmails(event.attachdata.CcAddresses);
        }
        //var hasAttachment = event.attachdata._ContainsAttachment? event.attachdata._ContainsAttachment : null;
        var hasAttachment = event.attachdata._ContainsOutboundAttach? event.attachdata._ContainsOutboundAttach : null;
        console.log('srId' + srId);
        console.log('has attachment '+event.attachdata._ContainsOutboundAttach);
        console.log('has attachment '+hasAttachment);
        if(event.MediaType == "email"){
                GCM_CTIController.createTaskforOutboundEmail(task, accId, conId, matchType, defAccId, defConId, event.EntrepriseInteractionCurrent.StartDate, event.EntrepriseInteractionCurrent.Subject, event.EntrepriseInteractionCurrent.MessageText, createSR, null, commMethod, srNumber, event.EntrepriseInteractionCurrent.InteractionSubtype, bccAddr, hasAttachment, ccAddr, function (result, req) {
                    console.log("result : ", result);
                    console.log("req : ", req);
                    if (req.statusCode == 200 && result != null) {
                        var params = { "ACTIVITY_ID": result.Id };
                        if (result.WhoId) {
                            params.CONTACT_ID = result.WhoId;
                        }
                        iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                        iwscommand.SendEmailById(event.ConnectionID);
                        if(result.GCM_Email_Message_Id__c){
                            attachmentUtil.uploadAttachment(event.ConnectionID,result.GCM_Email_Message_Id__c);
                        }
                    }else {
                        iwscommand.SendEmailById(event.ConnectionID);
                    }
                });
        }
    };
    
    CTIUtil.prototype.createNewEmailTaskwithCaseNumber = function (event) {
        console.log('createNewEmailTaskwithCaseNumber : message'+ event);
        console.log('New thread with case number');
        var task = new sforce.SObject("task");
        task.Subject = event.EntrepriseInteractionCurrent.Subject;
        task.GCM_Call_From__c = event.attachdata.EmailAddress? event.attachdata.EmailAddress : event.attachdata.CtmFrom;
        task.GCM_Call_To__c = event.attachdata.CtmTo.substring(0,254);
        task.GCM_Match_Type__c = event.attachdata.CSD_MatchType;
        task.CallType = event.CallType;
        task.softphone_it__IWS_Interaction_ID__c = event.ConnectionID;
        task.softphone_it__IWS_Media_Name__c = event.MediaType;
        task.Description = event.EntrepriseInteractionCurrent.StructuredText;
        task.GCM_BU__c = 'BU-'+event.attachdata.CSD_BU+';SO-'+event.attachdata.CSD_SalesOrganisation;
        task.GCM_Sales_Organisation__c = event.attachdata.CSD_SFCaseRecordType;
       // task.GCM_Cc_Addresses__c = this.extractEmails(event.attachdata.Cc);
        var c = null;
        console.log('cc'+event.attachdata.Cc);
        var ccAddr = event.attachdata.Cc? this.extractEmails(event.attachdata.Cc) : null;
        var srId = event.attachdata.CSR_SRid? event.attachdata.CSR_SRid : null;
        var srNum = event.attachdata.CSD_SRNumber? event.attachdata.CSD_SRNumber : null;
        var accId = event.attachdata.CSD_AccountId? event.attachdata.CSD_AccountId : null;
        var conId = event.attachdata.CSD_ContactId? event.attachdata.CSD_ContactId : null;
        var matchType = event.attachdata.CSD_MatchType? event.attachdata.CSD_MatchType : null;
        var defAccId = event.attachdata.CSD_DefaultAccountId? event.attachdata.CSD_DefaultAccountId : null;
        var defConId = event.attachdata.CSD_DefaultContactId? event.attachdata.CSD_DefaultContactId : null;
        var createSR = event.attachdata.CSD_CreateSR? event.attachdata.CSD_CreateSR : null;
        var commMethod = event.attachdata.CSD_CommMethod? event.attachdata.CSD_CommMethod : null;
        var hasAttachment = event.attachdata._ContainsAttachment? event.attachdata._ContainsAttachment : null;
        var caseRecordType = event.attachdata.CSD_SFCaseRecordType? event.attachdata.CSD_SFCaseRecordType : null;
        
		if(event.attachdata.CSD_CreateSR == 'Y'){
            cas = new sforce.SObject("Case");
            cas.Type = event.attachdata.CSD_SRType;
            cas.Area__c = event.attachdata.CSD_SRArea;
            cas.Sub_Area__c = event.attachdata.CSD_SRSubArea;
            c = cas;
            console.log('Case '+cas);
            console.log('CAse '+c);
        }
        if(event.MediaType == "email" && event.CallType == "Inbound") {
            GCM_CTIController.createTaskforNewInboundEmailwithCaseNo(task, accId, conId, matchType, defAccId, defConId, event.EntrepriseInteractionCurrent.StartDate, event.EntrepriseInteractionCurrent.Subject, event.EntrepriseInteractionCurrent.MessageText, createSR, c, commMethod, srNum , hasAttachment, ccAddr, caseRecordType, function (result, req) {
                console.log("result : ", result);
                console.log("req : ", req);
                if (req.statusCode == 200) {
                    var params = { "ACTIVITY_ID": result.Id };
                    if (result.WhoId) {
                        params.CONTACT_ID = result.WhoId;
                    }
                    var casId = result.WhatId;
					var idToScreen = (casId && casId.startsWith("500",0))? casId : result.Id;
                    if(casId && casId.startsWith("500",0)){
                    GCM_CTIController.getCaseDetails(result.WhatId, function (resultCase, req) {
                            console.log("result : association", resultCase);		
                            console.log("req : ", req);		
                            if (req.statusCode == 200) {
                                params.CSD_SRNumber = resultCase.CaseNumber;
                                params.CSR_SRid = resultCase.Id;
                                iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                            }
                        });
                    }else {
                        params.CSD_SRNumber = '';
                        iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                    }
                    console.log("idToScreen :", idToScreen);
                    if (isLightning) {
                        var callback = function(response) {
                                    if (response.success) {
                                        console.log('API method call executed successfully! returnValue:', response.returnValue);
                                        var listeneropen = function (resultOpenTab) {
                                            console.log('Message received from event: ' + resultOpenTab.message);
                                            var showTabId = function showTabId(result) {
                                                console.log('focussed console Tab ID: ' + result.id);
                                                console.log('Tab ID: ' + result.id);
                                                console.log('Tab ID: ' + resultOpenTab.objectId);
                                                var objId = resultOpenTab.objectId;
                                                var sfTabId = result.id;
                                                console.log('sfTabId: ' + sfTabId);
                                                if(sfTabId != null && sfTabId != undefined && (objId.startsWith("00T",0) || objId.startsWith("500",0)) && objId == idToScreen){
                                                    params.SF_TAB_ID = sfTabId;
                                                    iwscommand.SetAttachdataByIdAndCustomerId(event.ConnectionID, event.CustomerID, params);
                                                    console.log('after set attach data command');
                                                }
                                            };
                                    		sforce.console.getFocusedPrimaryTabId(showTabId);
                                			};
                                			sforce.console.addEventListener(sforce.console.ConsoleEvent.OPEN_TAB,
                                                                			listeneropen
                                                               				);
                            		} else { 
                                		console.error('Something went wrong! Errors:', response.errors);
                            			}
                        			};
                        console.log("calling opencti");
                        sforce.opencti.screenPop({ type: sforce.opencti.SCREENPOP_TYPE.URL, params: { url: '/' + idToScreen },callback: callback });
                    	if(result.GCM_Email_Message_Id__c){
                            attachmentUtil.uploadAttachment(event.ConnectionID,result.GCM_Email_Message_Id__c);
                        }
                    }
                    else {
                        console.log("calling interaction");
                        sforce.interaction.screenPop('/' + idToScreen, true, function (res) {
                            console.log("screenpop result=", res);
                        });
                    }
                }
            });
        } 
    };
    return CTIUtil;
}());
var sfctiutil = new CTIUtil();