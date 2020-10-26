/****************************************************************************************************
 *  Date          : 15-FEB-2019
 *  Author        : Sunny Yap
 *  Description   : Validation to prevent a case from being closed when there are open
 *                  child tasks or activities.
 * Modifications  : 15-FEB-2019 SYAP - Initial
 *                  18-MAR-2019 SYAP - Moved in to BPG triggers framework.
 *                  27-MAY-2019 SYAP - Added error handling.
 *                  10-SEP-2019 SYAP - Commented the logic that sets mailbox reference.
 * 					03-MAR-2020 SYAP - Added PCI compliance filter.
 ****************************************************************************************************/

public with sharing class GCM_EmailMessage_Trigger_Handler extends BPG_Trigger_Handler_Utilities { 
/****************************************************************************************************
  Before Insert
 ****************************************************************************************************/
	public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
    {
    	if (sot.getDescribe().getName() == 'EmailMessage') GCM_EmailMessage_Trigger_Helper.filterContent((List<EmailMessage>) n, (Map<Id, EmailMessage>) nMap);
    	if (sot.getDescribe().getName() == 'EmailMessage') GCM_EmailMessage_Trigger_Helper.setSenderEmail((List<EmailMessage>) n, (Map<Id, EmailMessage>) nMap);
    }
    
/****************************************************************************************************
  After Insert
 ****************************************************************************************************/
	public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
	{
    	if (sot.getDescribe().getName() == 'EmailMessage') GCM_EmailMessage_Trigger_Helper.setLastMailTimestamp((List<EmailMessage>) n, (Map<Id, EmailMessage>) nMap);
	}

/****************************************************************************************************
  After Update
 ****************************************************************************************************/
	public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
	{
		// After Update
		if (sot.getDescribe().getName() == 'EmailMessage') GCM_EmailMessage_Trigger_Helper.setLastMailTimestamp((List<EmailMessage>) n, (Map<Id, EmailMessage>) nMap);
	}      
}