/***********************************************************************************************
* @author           Xc
* @date             2020/08/12
* @group            CHCRM
* @description      handle HQ Monthly Assignment related business logic

* history
* 2020/08/12  Xc   Created 
************************************************************************************************/
public with sharing class CHCRM_HQMonthlyAssignmentProcess {
    public void syncDataToSurounding(List<CHCRM_HQ_Monthly_Assgmnt__c> newHQMonthlyAssgmnt) {
        List<Id> assignmentIdList = new List<Id>();
        for(CHCRM_HQ_Monthly_Assgmnt__c assignment : newHQMonthlyAssgmnt) {
            assignmentIdList.add(assignment.Id);
            //CHCRM_IntegrationUtility.sendMonthlyAssignments(assignment.Id,'admin');
        }
        System.enqueueJob(new CHCRM_QueueableCalloutService(assignmentIdList,'admin',''));
    }
}