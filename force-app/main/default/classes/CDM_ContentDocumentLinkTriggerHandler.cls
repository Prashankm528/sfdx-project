/**
 * @Who     Sid
 * @when    17-06-2020
 * @what    The Generic Trigger Handler for the ContentDocumentLinkTrigger.
 **/
public with sharing class CDM_ContentDocumentLinkTriggerHandler extends BPG_Trigger_Handler_Utilities 
{
	 /**
    *————————————————————————————————————————————————————
    * @Description
    * After Insert trigger handler method
    *————————————————————————————————————————————————————
    * @param    
    * @return   
    *————————————————————————————————————————————————————
    **/
	public override void afterInsert(List<SObject> oldRecords_afterInsert, Map<Id, SObject> oldRecordsMap_afterInsert, List<SObject> newRecords_afterInsert, Map<Id, SObject> newRecordsMap_afterInsert, Schema.SObjectType sObjType, String params, Boolean debug) {
        //system.debug('Calling method');
        List<ContentDocumentLink> newrecords = (List<ContentDocumentLink>) newRecords_afterInsert;
        List<ContentDocumentLink> oldrecords = (List<ContentDocumentLink>) oldRecords_afterInsert;
        CDM_ContentDocumentHelper.updateCDMRecordFormDocument(newrecords,oldrecords);
    }
    
}