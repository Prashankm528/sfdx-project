/***********************************************************************************************
* @author           Chris
* @date             2020/03/27
* @group            CHCRM
* @description      handle event related business logic

* history
* 2020/03/27  Chris  Created 
************************************************************************************************/
public with sharing class CHCRM_EventProcess {

    public final String CHCRM_EVENT_STATUS_COMPLETED = 'Completed';
    public final String CHCRM_EVENT_STATUS_CANCELLED = 'Cancelled';

    public void validation(List<Event> newEvents){
        Set<Id> assignmentIds = new Set<Id>();

        for(Event e : newEvents){
            if (String.isNotBlank(e.WhatId) && e.WhatId.getSobjectType() == Schema.CHCRM_HQ_Monthly_Assgmnt__c.SObjectType) {
                assignmentIds.add(e.WhatId);
            }
        }

        Map<Id,CHCRM_HQ_Monthly_Assgmnt__c> assignmentsMap = new Map<Id,CHCRM_HQ_Monthly_Assgmnt__c>([Select Id,
                                                                                                             CHCRM_Acceptance_Status__c,
                                                                                                             CHCRM_Month__c,
                                                                                                             CHCRM_Year__c 
                                                                                                             FROM CHCRM_HQ_Monthly_Assgmnt__c 
                                                                                                             WHERE Id IN:assignmentIds]);

        for (Event e : newEvents) {
            if (assignmentsMap.get(e.WhatId) != null) {

                String acceptanceStatus = assignmentsMap.get(e.WhatId).CHCRM_Acceptance_Status__c;
                Integer year = Integer.valueOf(assignmentsMap.get(e.WhatId).CHCRM_Year__c);
                Integer month = Integer.valueOf(assignmentsMap.get(e.WhatId).CHCRM_Month__c);

                if (acceptanceStatus == 'Rejected' || acceptanceStatus == 'No reply') {
                    e.WhatId.addError('请将关联总部任务状态标记为"已接受"后再继续操作！');
                    return;
                }

                if (e.StartDateTime.year() != year || e.StartDateTime.month() != month) {
                    e.StartDateTime.addError('拜访开始时间与所关联总部任务年份或月份不符！');
                    return;
                }
                
                Integer curYear = System.today().year();
                Integer curMonth = System.today().month();
                if(year< curYear || (year == curYear && month < curMonth)){
                    e.StartDateTime.addError('当前日期大于所关联总部限制日期，不能够创建此任务！');
                    return;
                }
            }
        }
    }

    public void createRelatedDetails(List<Event> newEvents) {
        /*List<Event> events = [Select Id,OwnerId,CHCRM_Event__c FROM Event WHERE Id IN:newEvents];
        Map<Id, CHCRM_Event__c> newDetailMap = new Map<Id, CHCRM_Event__c> ();

        for(Event e : events){
            CHCRM_Event__c detail = new CHCRM_Event__c();
            detail.OwnerId = e.OwnerId;
            newDetailMap.put(e.Id, detail);
        }
        insert newDetailMap.values();

        for(Event e : events){
            te.CHCRM_Event__c = newDetailMap.get(e.Id).Id;
        }
        update events;*/
        List<CHCRM_Event__c> detailList = new List<CHCRM_Event__c>();
        for(Event tempEvent : newEvents){
            CHCRM_Event__c detail = new CHCRM_Event__c();
            String evtRtDevName = Schema.getGlobalDescribe().get('Event').getDescribe().getRecordTypeInfosById().get(tempEvent.RecordTypeId).getDeveloperName();
            String detailRtId = Schema.SObjectType.CHCRM_Event__c.getRecordTypeInfosByDeveloperName().get(evtRtDevName).getRecordTypeId();
            detail.OwnerId = tempEvent.OwnerId;
            detail.RecordTypeId = detailRtId;
            detailList.add(detail);
        }
        if(!detailList.isEmpty()){
            insert detailList;
        }
        
        for(Integer i = 0; i < newEvents.size(); i++){
            if(i < detailList.size()){
                CHCRM_Event__c tempDetail = detailList.get(i);
                Event newEvent = newEvents.get(i);
                if(tempDetail != null && tempDetail != null){
                    newEvent.CHCRM_Event__c = tempDetail.Id;
                }
            }
        }

    }    

    public void deleteRelatedDetails(List<Event> oldEvents) {
        Id CHCRM_EVENT_RECORDTYPE = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('CHCRM_Event').getRecordTypeId();
        List<CHCRM_Event__c> deleteDetails = new List<CHCRM_Event__c>();
        for(Event e : oldEvents){
            if(e.RecordTypeId == CHCRM_EVENT_RECORDTYPE && String.isNotBlank(e.CHCRM_Event__c)){
                CHCRM_Event__c detail = new CHCRM_Event__c();
                detail.Id = e.CHCRM_Event__c ;
                deleteDetails.add(detail);            
            }
        }
        if(deleteDetails.size() > 0){
            delete deleteDetails ;
        }
    }

    public void populateEventFields(List<Event> newEvents, Map<Id,Event> oldMap) {
        Set<Id> HQIdSet = new Set<Id>();
        for(Event e : newEvents){
            if(String.isNotBlank(e.WhatId) && e.WhatId.getSobjectType() == Schema.CHCRM_HQ_Monthly_Assgmnt__c.SObjectType){
                HQIdSet.add(e.WhatId);
            }
        }

        Map<Id, CHCRM_HQ_Monthly_Assgmnt__c> HQMap = new Map<Id, CHCRM_HQ_Monthly_Assgmnt__c>(
            [SELECT Id, 
             CHCRM_Workshop__c,
             CHCRM_Workshop__r.Name,
             tolabel(CHCRM_HQ_Mnthly_Assgmnt_Obj__r.CHCRM_Visit_Objective__c) 
             FROM CHCRM_HQ_Monthly_Assgmnt__c
             WHERE Id IN :HQIdSet]);

        List<CHCRM_HQ_Monthly_Assgmnt__c> assignmentTasks = new List<CHCRM_HQ_Monthly_Assgmnt__c>();

        for(Event e : newEvents){
            String hqKey = e.WhatId;
            //Initialize Event Name , update CHCRM_HQ_Mnthly_Assgmnt__c and WhatId field value
            if(HQMap.containsKey(hqKey)){
                String name = '【总部任务】---' + HQMap.get(hqKey).CHCRM_Workshop__r.Name + '+' + HQMap.get(hqKey).CHCRM_HQ_Mnthly_Assgmnt_Obj__r.CHCRM_Visit_Objective__c;
                e.Subject = name.left(255);
                e.CHCRM_HQ_Mnthly_Assgmnt__c = hqKey;
                e.WhatId = HQMap.get(hqKey).CHCRM_Workshop__c;
            }
            //When the status of event changed to 'Completed', update the CHCRM_Covered_Status__c of relevent assignment task to 'Covered'
            if (e.CHCRM_HQ_Mnthly_Assgmnt__c != null && oldMap != null && e.SOM_Status__c == 'Completed' && oldMap.get(e.Id).SOM_Status__c != 'Completed') {
                CHCRM_HQ_Monthly_Assgmnt__c assignmentTask = new CHCRM_HQ_Monthly_Assgmnt__c();
                assignmentTask.Id = e.CHCRM_HQ_Mnthly_Assgmnt__c;
                assignmentTask.CHCRM_Covered_Status__c = 'Covered';
                assignmentTasks.add(assignmentTask);
            }
        }

        update assignmentTasks;
    }

    public void pupulateVisitDetailFields(List<Event> newEvents) {
        
        Set<String> clearActualVistTimeIdSet = new Set<String>();
        Set<String> setActualVistTimeIdSet = new Set<String>();
        Set<String> allVisitDetailIdSet = new Set<String>();
        List<CHCRM_Event__c> visitDetailUpdList = new List<CHCRM_Event__c>();
        Map<String,Event> detailIdEventMap = new Map<String,Event>();
        
        for(Event e : newEvents) {
            allVisitDetailIdSet.add(e.CHCRM_Event__c);
            detailIdEventMap.put(e.CHCRM_Event__c,e);
            if(e.SOM_Status__c == CHCRM_EVENT_STATUS_COMPLETED) {
                setActualVistTimeIdSet.add(e.CHCRM_Event__c);
            } else if(e.SOM_Status__c == CHCRM_EVENT_STATUS_CANCELLED) {
                clearActualVistTimeIdSet.add(e.CHCRM_Event__c);
            }
        }

        for(CHCRM_Event__c vd : [SELECT Id,
                                        CHCRM_Start_Date__c,
                                        CHCRM_End_Date__c,
                                        CHCRM_Actual_Visit_Time__c ,
                                        CHCRM_Description__c
                                    FROM CHCRM_Event__c
                                    WHERE Id IN :allVisitDetailIdSet]) {
            Boolean needUpdate = false;
            //populate acutal visit time
            if(vd.CHCRM_Actual_Visit_Time__c != null) {
                if(clearActualVistTimeIdSet.contains(vd.Id)) {
                    vd.CHCRM_Actual_Visit_Time__c = null;
                    needUpdate = true;
                    //visitDetailUpdList.add(vd);
                }
            } else {
                if(setActualVistTimeIdSet.contains(vd.Id)) {
                    vd.CHCRM_Actual_Visit_Time__c = System.now();
                    needUpdate = true;
                    //visitDetailUpdList.add(vd);
                }
            }
            //pupulate start date and end date
            if(detailIdEventMap.containsKey(vd.Id)) {
                Event relatedEvent = detailIdEventMap.get(vd.Id);

                if(relatedEvent.StartDateTime != vd.CHCRM_Start_Date__c) {
                    vd.CHCRM_Start_Date__c = relatedEvent.StartDateTime;
                    needUpdate = true;
                }
                if(relatedEvent.EndDateTime != vd.CHCRM_End_Date__c) {
                    vd.CHCRM_End_Date__c = relatedEvent.EndDateTime;
                    needUpdate = true;
                }
                
                if(String.isNotEmpty(relatedEvent.Type)){
                    vd.CHCRM_Type__c = relatedEvent.Type;
                    needUpdate = true;
                }
                
                if(String.isNotEmpty(relatedEvent.Description)){
                    vd.CHCRM_Description__c = relatedEvent.Description;
                    needUpdate = true;
                }
            }
            if(needUpdate) {
                visitDetailUpdList.add(vd);
            }
        }

        if(!visitDetailUpdList.isEmpty()) {
            update visitDetailUpdList;
        }

    }

    public void syncDataToSurounding(Id eventId) {
        List<Id> eventIdList = new List<Id>();
        eventIdList.add(eventId);
        System.enqueueJob(new CHCRM_QueueableCalloutService(eventIdList,'admin',''));
        //CHCRM_IntegrationUtility.sendEvent(eventId,'admin');
    }

    public void syncDelDataToSurounding(Id eventId) {
        List<Id> eventIdList = new List<Id>();
        eventIdList.add(eventId);
        System.enqueueJob(new CHCRM_QueueableCalloutService(eventIdList,'admin','delete'));
        //CHCRM_IntegrationUtility.sendDelEvent(eventId,'admin');
    }
}