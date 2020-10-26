/***********************************************************************************************
* @author           DK
* @date             2020/08/20
* @group            CHCRM
* @description      handle WSP Yearly SalesRefProcess business logic

* history
* 2020/08/20  DK  Created 
************************************************************************************************/
public with sharing class CHCRM_WSPYearlySalesRefProcess{
    public void syncDataToSurounding(List<CHCRM_WSP_Yearly_SalesRef__c> newWSPYearlySalesRef) {
        List<Id> salesRefIdList = new List<Id>();
        for(CHCRM_WSP_Yearly_SalesRef__c wspYearlySalesRef : newWSPYearlySalesRef) {
            salesRefIdList.add(wspYearlySalesRef.Id);
            //CHCRM_IntegrationUtility.sendWorkshopSalesReferences(wspYearlySalesRef.Id,'admin');
        }
        System.enqueueJob(new CHCRM_QueueableCalloutService(salesRefIdList,'admin',''));
    }
}