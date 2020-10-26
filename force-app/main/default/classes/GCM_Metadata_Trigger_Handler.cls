/******************************************************************************************
 *  Date          : 19-MAR-2019
 *  Author        : Sunny Yap
 *  Description   : Triggers background metadata change processes.
 *                  When change header status is set to Submitted.
 * Modifications  : 19-MAR-2019 SYAP - Initial
 *                  19-APR-2019 SYAP - Moved all code into helper class.
 *                  27-JUL-2019 SYAP - Added error handling.
 ******************************************************************************************/

public with sharing class GCM_Metadata_Trigger_Handler extends BPG_Trigger_Handler_Utilities {

/******************************************************************************************
  Handles All After Update Event Handler
 ******************************************************************************************/
  public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    // GCM_Metadata_Change__c Event Handler
    if (sot.getDescribe().getName() == 'GCM_Metadata_Change__c') {
      GCM_Metadata.process((List<GCM_Metadata_Change__c>) n, (Map<Id, GCM_Metadata_Change__c>) oMap, (Map<Id, GCM_Metadata_Change__c>) nMap);
      GCM_Metadata.updateJobStatus((List<GCM_Metadata_Change__c>) n, (Map<Id, GCM_Metadata_Change__c>) oMap, (Map<Id, GCM_Metadata_Change__c>) nMap);
    }

    // GCM_Metadata_Object__c Event Handler
    if (sot.getDescribe().getName() == 'GCM_Metadata_Object__c') {
      GCM_Metadata.getMetadata((List<GCM_Metadata_Object__c>) n, (Map<Id, GCM_Metadata_Object__c>) oMap, (Map<Id, GCM_Metadata_Object__c>) nMap);  
    }
  }
}