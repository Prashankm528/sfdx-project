/***********************************************************************************************
* @author           WuTong
* @date             2020/08/19
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAP_ActionEvent_CMP
* @test class       CHCRM_KAP_ActionEventControllerTest
* history
* 2020/08/19  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAP_ActionEventController {
    
    @AuraEnabled
    public static Wrapper initDataList(String recordId){
        Wrapper wrapper = new Wrapper();
        List<Event> eventList = [SELECT Id, Subject, StartDateTime, EndDateTime, CHCRM_Event__c ,OwnerId, Owner.Name,
                                 SOM_Status__c ,RecordType.DeveloperName , Description
                                 From Event Where whatId =:recordId];
        if(!eventList.isEmpty()){
            Set<Id> deatilSet = new Set<Id>();
            for(Event e : eventList){
                deatilSet.add(e.CHCRM_Event__c);
            }
            Map<Id,CHCRM_Event__c> eventDeatilMap = new Map<Id,CHCRM_Event__c>([SELECT Id, 
                            CHCRM_KAP_Actual_Completion_Date__c,
                            CHCRM_KAP_Actual_Start_Date__c,
                            CHCRM_KAP_Remark__c
                    FROM CHCRM_Event__c 
                    WHERE Id in :deatilSet]);
            List<EventItem> eventDatatable = new List<EventItem>();
            for(Event e:eventList){
                EventItem eventItem = new EventItem();
                eventItem.id = e.Id;
                eventItem.eventUrl = '/'+e.Id;
                eventItem.Subject = e.Subject;
                eventItem.Description = e.Description;
                eventItem.planStartDate = e.StartDateTime;
                eventItem.planEndDate = e.EndDateTime;
                eventItem.status = e.SOM_Status__c;
                eventItem.owner = e.OwnerId == null ? '' : e.Owner.Name;
                eventItem.progress = getProcessByStatus(e.SOM_Status__c);
                CHCRM_Event__c detail = eventDeatilMap.get(e.CHCRM_Event__c);
                if(detail != null){
                    eventItem.acStartDate = detail.CHCRM_KAP_Actual_Start_Date__c;
                    eventItem.acEndDate = detail.CHCRM_KAP_Actual_Completion_Date__c;
                    eventItem.remark = detail.CHCRM_KAP_Remark__c;
                }
                eventDatatable.add(eventItem);
            }
            wrapper.eventDatatable = eventDatatable;
        }
        return wrapper;
    }
    
    
    private static String getProcessByStatus(String status){
        if(status == 'Cancelled' || status == ''){
            return 'red';
        }
        return 'green';
    }
    
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/19
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_ActionEvent_CMP Reture
    ************************************************************************************************/
    public with sharing class Wrapper{
        @AuraEnabled
        public List<EventItem> eventDatatable{set;get;}
    }
    
    /***********************************************************************************************
    * @author           WuTong
    * @date             2020/08/19
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_KAP_ActionEvent_CMP Reture
    ************************************************************************************************/
    public with sharing class EventItem{
        @AuraEnabled
        public String id{set;get;}
        @AuraEnabled
        public String progress{set;get;}
        @AuraEnabled
        public String eventUrl{set;get;}//'/'+event.Id;
        @AuraEnabled
        public String Subject{set;get;}
        @AuraEnabled
        public String Description{set;get;}
        @AuraEnabled
        public Datetime planStartDate{set;get;}
        @AuraEnabled
        public Datetime planEndDate{set;get;}
        @AuraEnabled
        public Datetime acStartDate{set;get;}
        @AuraEnabled
        public Datetime acEndDate{set;get;}
        @AuraEnabled
        public String owner{set;get;}
        @AuraEnabled
        public String status{set;get;}
        @AuraEnabled
        public String remark{set;get;}
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}