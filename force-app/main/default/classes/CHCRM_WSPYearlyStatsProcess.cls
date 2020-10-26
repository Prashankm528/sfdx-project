/***********************************************************************************************
* @author           DK
* @date             2020/08/20
* @group            CHCRM
* @description      handle WSP Yearly Stats business logic

* history
* 2020/08/20  DK  Created 
************************************************************************************************/
public with sharing class CHCRM_WSPYearlyStatsProcess{
    public void syncDataToSurounding(List<CHCRM_WSP_Yearly_Stats__c> newWSPYearlyStats) {
        List<Id> statsIdList = new List<Id>();
        for(CHCRM_WSP_Yearly_Stats__c wspYearlyStats : newWSPYearlyStats) {
            statsIdList.add(wspYearlyStats.Id);
            //CHCRM_IntegrationUtility.sendWorkshopYearlyStats(wspYearlyStats.Id,'admin');
        }
        System.enqueueJob(new CHCRM_QueueableCalloutService(statsIdList,'admin',''));
    }
}