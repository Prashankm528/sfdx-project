/*****************************************************************************************
*   Date:     22/06/2020
*   Author:   Hrushikesh Pangarkar(TCS)  
*   Description:   
*   Changes: 0.1 
 
****************************************************************************************/
Public with sharing class PCRM_OpportunityLineItemHandler extends BPG_Trigger_Handler_Utilities{
    //beforeInsert
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        List<OpportunityLineItem> lstOpportunityLineItems = (List<OpportunityLineItem>) n;
        new PCRM_OpportunityLineItemHelper().updateIsClonedForTheFirstTime(lstOpportunityLineItems);
    }
    //afterInsert
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        List<OpportunityLineItem> lstOpportunityLineItems = (List<OpportunityLineItem>) n;
        new PCRM_OpportunityLineItemHelper().autoCreateOpportunityLineItemOnProductInsertion(lstOpportunityLineItems);  
        new PCRM_OpportunityLineItemHelper().populateOLIValues(lstOpportunityLineItems);
    }
    //afterUpdate
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
        List<OpportunityLineItem> lstOpportunityLineItems = (List<OpportunityLineItem>) n;       
        new PCRM_OpportunityLineItemHelper().populateOLIValues(lstOpportunityLineItems);
    }

}