/**
* @author: Gabriela Matos
* @date: 18/06/2020
* @group: BPG
* @description: BPCM service class for Task object
* @name BPCM_TaskService.cls
*/

public inherited sharing class BPCM_TaskService {
    
    /** 
     * @description: method to run after insert and centralise all logics
     * 1. Identify all inbound/outbound Calls logged for BPCM Case, then sum an interaction to the case (case touch)
     * 2. Identify all Tasks created for BPCM Case, then sum an interaction to the case (case touch)
     * @author Gabriela Matos | 18/06/2020
     * @param: Map of new Task records
     * @return void
     * */
    public void runAfterInsert(Map<Id, Task> newMap){

        //querying to capture whatId record type dev name
        List<Task> tkCompleteInfoList = [SELECT WhatId, Type, RecordTypeId,
                                                What.RecordType.DeveloperName
                                                 FROM Task WHERE Id IN: newMap.KeySet()];

        Map<Id, List<String>> tkListMap = new Map<Id, List<String>>();

        for(Task tk : tkCompleteInfoList){
            Id tkCallRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(BPCM_GlobalConstants.TK_CALL_REC_TYPE).getRecordTypeId();
            Id tkTaskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(BPCM_GlobalConstants.TK_TASK_REC_TYPE).getRecordTypeId();

            if(tk.WhatId != null){
                String sObjName = tk.WhatId.getSObjectType().getDescribe().getName();
                if(sObjName != null && sObjName == BPCM_GlobalConstants.CASE_SOBJECT_TYPE
                   && tk.What.RecordType.DeveloperName.startsWith(BPCM_GlobalConstants.BPCM_PREFIX)){

                    if(tk.RecordTypeId == tkCallRTId && tk.Type == BPCM_GlobalConstants.TK_INB_CALL_TYPE){
                        //count number of inbound calls made on the Case (interaction)   
                        tkListMap = BPCM_CaseTouchHistoryService.addCsInteractionsMap(tkListMap, tk.WhatId, BPCM_GlobalConstants.CHT_INB_CALLS_FIELD_APINAME);
                    }

                    if(tk.RecordTypeId == tkCallRTId && tk.Type == BPCM_GlobalConstants.TK_OUT_CALL_TYPE){
                        //count number of outbound calls made on the Case (interaction)  
                        tkListMap = BPCM_CaseTouchHistoryService.addCsInteractionsMap(tkListMap, tk.WhatId, BPCM_GlobalConstants.CHT_OUT_CALLS_FIELD_APINAME);
                    }

                    if(tk.RecordTypeId == tkTaskRTId){
                        //count number of tasks created for the Case (interaction)   
                        tkListMap = BPCM_CaseTouchHistoryService.addCsInteractionsMap(tkListMap, tk.WhatId, BPCM_GlobalConstants.CHT_TASKS_FIELD_APINAME);
                    }
                } 
            }
        }

        if(!tkListMap.isEmpty()){
            BPCM_CaseTouchHistoryService.captureCaseTouches(tkListMap);
        }
    }

    /** 
     * @description: log inbound call when a new case origin 'Phone Call' is created
     * @author Gabriela Matos | 14/07/2020
     * @param: List of new Cases
     * @return Void
     * */
    public static void logInboundCall(List<Case> newRecords){

        List<Task> newInbCallList = new List<Task>();
        for(Case cs : newRecords){
            newInbCallList.add(
                new Task(
                    RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(BPCM_GlobalConstants.TK_CALL_REC_TYPE).getRecordTypeId(),
                    Subject = cs.Subject,
                    Description = cs.Description,
                    Status = BPCM_GlobalConstants.TK_STATUS_COMPLETED,
                    Type = BPCM_GlobalConstants.TK_INB_CALL_TYPE,
                    CallType = BPCM_GlobalConstants.TK_LOG_CALL_TYPE_INB,
                    CallObject = String.valueOf(System.now().getTime()) + cs.OwnerId + cs.Id,
                    TaskSubtype = BPCM_GlobalConstants.TK_SUBTYPE_CALL,
                    ActivityDate = System.Today(),
                    WhatId = cs.Id,
                    WhoId = (cs.ContactId != null ? cs.ContactId : null)
                )
            );
        }

        if(!newInbCallList.isEmpty()){
            insert newInbCallList;
        }
    }
}