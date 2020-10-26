/*****************************************************************************************
* Date:        27MAY17
* Author:      Jon Marson (Forcify)
* Comments:    Simple wrapper class to allow us to trigger an Apex class from a custom
*              button (Allocate) on the Lead page.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* ***************************************************************************************/
global without sharing class SOM_BP_Lead_Allocation_Wrapper 
{    
    /***********************************************************************************
* Date:          08FEB17
* Author:        Jon Marson - Forcify Ltd
* Desc:          Lightning button use to trigger an apex class.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration
* *********************************************************************************/
    webservice static String allocate(Id leadId)
    {
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Lead').getRecordTypeId();  
        SOM_BP_Lead_Allocation.allocateHelper([SELECT Id, SOM_Allocation_Group__c FROM Lead WHERE Id = :leadId and RecordTypeId =:devRecordTypeId], true);
        return 'OK';
        
    }
}