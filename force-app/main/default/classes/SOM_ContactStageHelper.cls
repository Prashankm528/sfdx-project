/*************************************************************************************************
* Date:          14JUL17
* Author:        Jon Marson (Forcify Ltd)
* Comments:      Whenever the stage gets updated on the Opportunity, we need to denormalise the
*                stage name onto the 'Opporutnity Stage' field for all related Contacts.  This
*                is because the Contact record gets sync'd to DotMailer, and Dotmailer needs this
*                information to trigger various marketing programmes. 
* Modification:  7OCT2019 ABHISHEK- UK Fuel Card Migration.
* ***********************************************************************************************/

public without sharing class SOM_ContactStageHelper {
    
    public static Id recordtypeNew = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
    public static Id recordtypeRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Relationship Maintenance').getRecordTypeId();
    public static Id recordtypeContract = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Contract').getRecordTypeId();    
    public static Id recordtypeRisk = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Risk').getRecordTypeId();    
    public static Id recordtypeCross = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Cross/Upselling').getRecordTypeId();    
    
    /***********************************************************************************
* Date:          08FEB17
* Author:        Jon Marson - Forcify Ltd
* Desc:          Method to update Contact opportunity stage.
* Modifications: 7OCT2019 ABHISHEK- UK Fuel Card Migration.
* *********************************************************************************/
    
    public static void updateContactOpptyStage(List<SObject> lstOldOpportunity,List<SObject> lstnewOpportunity) 
    {
        List<Contact> lstContact ;
        map<id,string> mapOpptyIdStage ;
        map<id,string> mapOldOpptyIdStage;
        try
        {
            if(lstOldOpportunity.size() > 0)
            {
                mapOldOpptyIdStage = new map<Id,String>();
                for (SObject objOldOpportunityRecord : lstOldOpportunity) {
                    Opportunity recordOldOpportunity = (Opportunity) objOldOpportunityRecord;
                    if(recordOldOpportunity.RecordTypeId == recordtypeNew ||recordOldOpportunity.RecordTypeId == recordtypeRenewal  || recordOldOpportunity.RecordTypeId == recordtypeContract || recordOldOpportunity.RecordTypeId == recordtypeRisk || recordOldOpportunity.RecordTypeId == recordtypeCross )
                        mapOldOpptyIdStage.put(recordOldOpportunity.id,recordOldOpportunity.StageName);
                }
            }
            system.debug('mapOldOpptyIdStage'+mapOldOpptyIdStage);
            if(lstnewOpportunity.size() > 0)
            {
                mapOpptyIdStage = new map<Id,String>();
                for (SObject objOpportunityRecord : lstnewOpportunity) {
                    Opportunity recordOpportunity = (Opportunity) objOpportunityRecord;
                    if(recordOpportunity.RecordTypeId == recordtypeNew ||recordOpportunity.RecordTypeId == recordtypeRenewal  || recordOpportunity.RecordTypeId == recordtypeContract || recordOpportunity.RecordTypeId == recordtypeRisk || recordOpportunity.RecordTypeId == recordtypeCross )
                        if(mapOldOpptyIdStage.get(recordOpportunity.id) != recordOpportunity.StageName)
                        mapOpptyIdStage.put(recordOpportunity.id,recordOpportunity.StageName);
                }
            }
             
            if(mapOpptyIdStage.size() > 0)    
            {
            system.debug('mapOpptyIdStage'+mapOldOpptyIdStage);
                lstContact = new List<Contact>();
                for (OpportunityContactRole objOpptyContactRole: [SELECT ContactId, OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN :mapOpptyIdStage.keyset()])
                    lstContact.add(new Contact(Id=objOpptyContactRole.ContactId, SOM_Opportunity_Stage__c=mapOpptyIdStage.get(objOpptyContactRole.OpportunityId)));
                
                if (!lstContact.isEmpty())
                    update lstContact;   
            }
        }
        catch (Exception e)
        {
            system.debug('Exception'+e.getMessage());
        }
    }
}