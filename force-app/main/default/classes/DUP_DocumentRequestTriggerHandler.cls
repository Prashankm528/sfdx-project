/*****************************************************************************************
*       Date:           05SEP19
*       Author:         Payal Ahuja - IBM
*       Description:    Trigger Handler for creating Document Store records
*       Updated by:     Alessandro Miele - IBM (adding method and refactoring)
*****************************************************************************************/
public with sharing class DUP_DocumentRequestTriggerHandler extends BPG_Trigger_Handler_Utilities {
    @TestVisible private static boolean executeTrigger = true;

    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {     
        new DUP_DocumentRequestTriggerHelper().afterUpdateOperations((Map<Id, DUP_Document_Request__c>) oMap, (List<DUP_Document_Request__c>) n);   
    }
    
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {    
        new DUP_DocumentRequestTriggerHelper().checkOnStatusChanges((Map<Id, DUP_Document_Request__c>) oMap, (List<DUP_Document_Request__c>) n);
    	new DUP_DocumentRequestTriggerHelper().validateRequestorEmail((List<DUP_Document_Request__c>) n, (Map<Id, DUP_Document_Request__c>) oMap);
    }
    
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {    
	new DUP_DocumentRequestTriggerHelper().validateRequestorEmail((List<DUP_Document_Request__c>) n, null);        
    }
    
}