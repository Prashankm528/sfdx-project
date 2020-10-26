/*****************************************************************************************
*   Date:     11/07/2020
*   Author:   Pooja Deokar(TCS)  
*   Description:   Class is used to sync quoteline item custom field with OLI fields
*   Changes: 0.1 
 
****************************************************************************************/
Public with sharing class PCRM_QuoteLineItemHandler extends BPG_Trigger_Handler_Utilities{   
    //beforeInsert
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
    	List<QuoteLineItem> listOfQli = (List<QuoteLineItem>) n;
        new PCRM_QuoteLineItemHelper().qliBeforeInsertCustomFieldSync(listOfQli);
    }
}