/***********************************************************************************************
* @author           Xc
* @date             2020/08/12
* @group            CHCRM
* @description      handle HQ Monthly Assignment Objective related business logic

* history
* 2020/08/12  Xc   Created 
************************************************************************************************/
public with sharing class CHCRM_HQMonthlyAssignmentObjProcess {
    public void syncDataToSurounding(List<CHCRM_HQ_Monthly_Assgmnt_Obj__c> newHQMonthlyAssgmntObj) {
        List<Id> assignObjList = new List<Id>();
        for(CHCRM_HQ_Monthly_Assgmnt_Obj__c assignmentObj : newHQMonthlyAssgmntObj) {
            assignObjList.add(assignmentObj.Id);
            //CHCRM_IntegrationUtility.sendMonthlyObjectives(assignmentObj.Id,'admin');
        }
        System.enqueueJob(new CHCRM_QueueableCalloutService(assignObjList,'admin',''));
    }
}