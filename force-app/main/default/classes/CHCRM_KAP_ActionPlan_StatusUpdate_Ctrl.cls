/***********************************************************************************************
* @author           WuTong
* @date             2020/08/12
* @group            CHCRM
* @description      controller class used by lightning component CHCRM_KAP_ActionPlan_StatusUpdate_CMP
* @test class       CHCRM_KAP_ActionPlan_StatusUpdate_CtrlTest
* history
* 2020/08/12  WuTong  Created 
************************************************************************************************/
public with sharing class CHCRM_KAP_ActionPlan_StatusUpdate_Ctrl {
    
	@AuraEnabled
    public static String getExeStatus(String recordId) {
        Decimal count_completed = 0;
        Decimal percentage = 0;
        list<Event> evtList = [SELECT SOM_Status__c 
                                 FROM Event
                                WHERE whatId =: recordId
                                  AND SOM_Status__c <> 'Cancelled'];
        for(Event evt : evtList) {
            if(evt.SOM_Status__c == 'Completed') {
            	count_completed++;
            }
        }
        if(evtList.size() == 0) {
            percentage = 0;
        } else {
            percentage = 100 * (count_completed/evtList.size());
        }
        update new CHCRM_KAP_Action_Plan__c(Id=recordId, CHCRM_Plan_Status__c=percentage);
        return 'Success';
    }
    
}