/**
 * @author 			Venkatesh Muniyasamy
 * @date 			27/07/2020
 * @group			CAJBP
 * @description     trigger handler for on CAJBP_Customer_Contact__c object
 *
 * history
 * 27/07/2020	Venkatesh Muniyasamy			Created
 */
public with sharing class CAJBP_CustomerContactTriggerHandler extends BPG_Trigger_Handler_Utilities
{

    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
       this.handleAfterInsert(newList);
    }

    public void handleAfterInsert(List<SObject> newCustomerContact)
    {
        CAJBP_JbpSharing jbpShare = new CAJBP_JbpSharing();
		jbpShare.grantAccessToRelatedRecords(newCustomerContact);
        jbpShare.shareCustomerContactToJBPOwner(newCustomerContact);
    }
}