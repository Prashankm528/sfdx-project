/***********************************************************************************************
* @author           Chris
* @date             2020/03/27
* @group            CHCRM
* @description      controller class used by lightning component to view chcrm event

* history
* 2020/03/27  Chris  Created
* 2020/07/21  WuTong  Updated 
************************************************************************************************/
public with sharing class CHCRM_ViewEventController {
    @AuraEnabled
    public Static eventWrapper queryEventForView(String evtId){
        eventWrapper retWrapper = new eventWrapper();
        Event stdEvt = [SELECT Id, 
                        toLabel(Subject), 
                        StartDateTime, 
                        EndDateTime, 
                        toLabel(Type), 
                        CHCRM_Event__c, 
                        Location, 
                        Description, 
                        OwnerId, 
                        Owner.Name, 
                        whoId,
                        who.name,
                        whatId,
                        what.Name,
                        CreatedById,
                        CreatedBy.Name,
                        LastModifiedById,
                        LastModifiedBy.Name,
                        CreatedDate,
                        LastModifiedDate,
                        CHCRM_HQ_Mnthly_Assgmnt__c,
                        CHCRM_HQ_Mnthly_Assgmnt__r.Name,
                        RecordType.DeveloperName,
                        toLabel(SOM_Status__c) FROM Event WHERE Id = :evtId];
        CHCRM_Event__c ctmEvt = new CHCRM_Event__c();
        if(String.isNotBlank(stdEvt.CHCRM_Event__c)){
            ctmEvt = [SELECT Id, 
                      Name, 
                      //Added for Pipeline start
                      Visit_Summary__c,
                      CHCRM_Next_Step__c,
                      CHCRM_Type__c,
                      CHCRM_Actual_Visit_Time__c,
                      RecordType.DeveloperName,
                      //Added for Pipeline end
                      CHCRM_Complaint_Resolved__c, 
                      CHCRM_Complaint_Remarks__c, 
                      CHCRM_Cust_Exp_Day_Executed__c, 
                      CHCRM_Cust_Exp_Day_Remarks__c, 
                      CHCRM_Check_In_Address__c,
                      CHCRM_Check_In_Time__c,
                      CHCRM_HQ_Policy_or_Mkt_Act__c,
                      CHCRM_HQ_Policy_or_Mkt_Act_Remarks__c,
                      CHCRM_Training__c,
                      CHCRM_Training_Remarks__c,
                      CHCRM_LTT_Exec__c,
                      CHCRM_LTT_Remarks__c,
                      CHCRM_Lead_Collected__c,
                      CHCRM_Lead_Collected_Remarks__c,
                      CHCRM_KAP_Actual_Completion_Date__c,
                      CHCRM_KAP_Actual_Start_Date__c,
                      CHCRM_KAP_Remark__c 
                      FROM CHCRM_Event__c 
                      WHERE Id = :stdEvt.CHCRM_Event__c];
        }
        retWrapper.evt = stdEvt;
        retWrapper.detail = ctmEvt;
        return retWrapper;
    }
    
    @AuraEnabled
    public Static eventWrapper queryEventForEdit(String evtId){
        eventWrapper retWrapper = new eventWrapper();
        Event stdEvt = [SELECT Id, 
                        toLabel(Subject), 
                        StartDateTime, 
                        EndDateTime, 
                        Type, 
                        CHCRM_Event__c, 
                        Location, 
                        Description, 
                        OwnerId, 
                        Owner.Name, 
                        whoId,
                        who.name,
                        whatId,
                        what.Name,
                        CreatedById,
                        CreatedBy.Name,
                        LastModifiedById,
                        LastModifiedBy.Name,
                        CreatedDate,
                        LastModifiedDate,
                        CHCRM_HQ_Mnthly_Assgmnt__c,
                        CHCRM_HQ_Mnthly_Assgmnt__r.Name,
                        RecordType.DeveloperName,
                        SOM_Status__c FROM Event WHERE Id = :evtId];
        CHCRM_Event__c ctmEvt = new CHCRM_Event__c();
        if(String.isNotBlank(stdEvt.CHCRM_Event__c)){
            ctmEvt = [SELECT Id, 
                      Name, 
                      //Added for Pipeline start
                      Visit_Summary__c,
                      CHCRM_Next_Step__c,
                      CHCRM_Type__c,
                      CHCRM_Actual_Visit_Time__c,
                      RecordType.DeveloperName,
                      //Added for Pipeline end
                      CHCRM_Complaint_Resolved__c, 
                      CHCRM_Complaint_Remarks__c, 
                      CHCRM_Cust_Exp_Day_Executed__c, 
                      CHCRM_Cust_Exp_Day_Remarks__c, 
                      CHCRM_Check_In_Address__c,
                      CHCRM_Check_In_Time__c,
                      CHCRM_HQ_Policy_or_Mkt_Act__c,
                      CHCRM_HQ_Policy_or_Mkt_Act_Remarks__c,
                      CHCRM_Training__c,
                      CHCRM_Training_Remarks__c,
                      CHCRM_LTT_Exec__c,
                      CHCRM_LTT_Remarks__c,
                      CHCRM_Lead_Collected__c,
                      CHCRM_Lead_Collected_Remarks__c,
                      CHCRM_KAP_Actual_Completion_Date__c,
                      CHCRM_KAP_Actual_Start_Date__c,
                      CHCRM_KAP_Remark__c 
                      FROM CHCRM_Event__c 
                      WHERE Id = :stdEvt.CHCRM_Event__c];
        }
        retWrapper.evt = stdEvt;
        retWrapper.detail = ctmEvt;
        return retWrapper;
    }
    
    
    @AuraEnabled
    public Static saveWrapper saveEvent(Event evt, CHCRM_Event__c detail){
        Event updatedEvt = evt;
        CHCRM_Event__c updatedDetail = detail;
        updatedDetail.OwnerId = updatedEvt.OwnerId;
        saveWrapper wrapper = new saveWrapper();
        wrapper.status = 'Success';
        wrapper.errorMessage = '';
        Event oldEvent = [SELECT ID , SOM_Status__c From Event Where Id =:evt.Id];
        if(updatedEvt.RecordType.DeveloperName.contains('CHCRM') && String.isNotBlank(updatedEvt.CHCRM_HQ_Mnthly_Assgmnt__c) && 
           updatedEvt.SOM_Status__c == 'Completed' && oldEvent.SOM_Status__c != 'Completed'){
               CHCRM_HQ_Monthly_Assgmnt__c assgmnt = [SELECT ID ,CHCRM_Year__c ,CHCRM_Month__c FROM CHCRM_HQ_Monthly_Assgmnt__c WHERE Id =:updatedEvt.CHCRM_HQ_Mnthly_Assgmnt__c];
               Integer year = Integer.valueOf(assgmnt.CHCRM_Year__c);
               Integer month = Integer.valueOf(assgmnt.CHCRM_Month__c);
               System.debug('Year:'+year);
               System.debug('Month:'+month);
               Integer curYear = System.today().year();
               Integer curMonth = System.today().month();
               System.debug('year == curYear && month < curMonth :' + (year == curYear && month < curMonth));
               if(year< curYear || (year == curYear && month < curMonth)){               
                   wrapper.status = 'Error';
                   wrapper.errorMessage = '当前时间已经超出目标完成期，此任务不允许将状态设置为 已完成！';
                   return wrapper;
               }
           }
        try{
            Database.SaveResult sr = Database.update(updatedEvt);
            Database.update(updatedDetail);
            System.debug('It begin to sync data');
            new CHCRM_EventProcess().syncDataToSurounding(sr.getId());
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return wrapper;
    }
    
    /***********************************************************************************************
    * @author           Chris
    * @date             2020/03/27
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_ViewEvent Reture
    ************************************************************************************************/
    public with sharing class eventWrapper{
        @AuraEnabled
        public Event evt { get; set; }
        @AuraEnabled
        public CHCRM_Event__c detail { get; set; }        
    }
    
    /***********************************************************************************************
    * @author           Chris
    * @date             2020/03/27
    * @group            CHCRM
    * @description      controller class used by lightning component CHCRM_ViewEvent Reture
    ************************************************************************************************/
    public with sharing class saveWrapper{
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public String errorMessage { get; set; }        
    }
}