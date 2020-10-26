/***********************************************************************************************
* @author           Xc
* @date             2020/06/19
* @group            CHCRM
* @description      handle sales channel related business logic

* history
* 2020/06/19  Xc  Created 
************************************************************************************************/
public with sharing class CHCRM_SalesChannelProcess {

    public void populateDirectCustomer(List<CHCRM_Sales_Channel__c> newSalesChannels){
        
        for(CHCRM_Sales_Channel__c sc : newSalesChannels) {
            if(String.isNotBlank(sc.CHCRM_TOB_Direct_Customer__c)) {
                sc.CHCRM_Direct_Customer__c = sc.CHCRM_TOB_Direct_Customer__c;
            } else if(String.isNotBlank(sc.CHCRM_Distributor__c)) {
                sc.CHCRM_Direct_Customer__c = sc.CHCRM_Distributor__c;
            } else if(String.isNotBlank(sc.CHCRM_Service_Direct_Customer__c)) {
                sc.CHCRM_Direct_Customer__c = sc.CHCRM_Service_Direct_Customer__c;
            } else if(String.isNotBlank(sc.CHCRM_DSP__c)) {
                sc.CHCRM_Direct_Customer__c = sc.CHCRM_DSP__c;
            } else {
                sc.CHCRM_Direct_Customer__c = '';
            }
        }
    }
}