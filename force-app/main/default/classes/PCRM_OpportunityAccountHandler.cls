/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Hrushikesh Pangarkar(TCS)  
*   Description:   
*   Changes: 0.1 
 
****************************************************************************************/
Public with sharing class PCRM_OpportunityAccountHandler extends BPG_Trigger_Handler_Utilities{   
    //afterdelete
    public override void afterdelete(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        List<PCRM_Opportunity_Account__c> lstOpportunityAccounts = (List<PCRM_Opportunity_Account__c>) o;
        new PCRM_OpportunityLineItemHelper().onDeleteOfOpportunityAccount(lstOpportunityAccounts);
    }
}