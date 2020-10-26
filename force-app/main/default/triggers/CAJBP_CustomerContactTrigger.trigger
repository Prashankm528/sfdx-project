/**
 * @author 			Venkatesh Muniyasamy
 * @date 			27/07/2020
 * @group			CAJBP
 * @description     trigger on CAJBP_Customer_Contact__c object
 *
 * history
 * 27/07/2020	Venkatesh Muniyasamy			Created
 */
trigger CAJBP_CustomerContactTrigger on CAJBP_Customer_Contact__c (after insert)
{
    if(!FeatureManagement.checkPermission('BPG_DisableAll'))
    {
        BPG_Trigger_Handler_Utilities.handleEvent('CAJBP_Customer_Contact__c', Trigger.operationType, Trigger.size, Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
    }
}