/****************************************************************************************************
 *  Date          : 03-JAN-2020https://bpcustomer--gcmdev.cs86.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#
 *  Author        : Sunny Yap
 *  Description   : Service Request Trigger Handler.
 *  Modifications :
 *  03-JAN-2020   : SYAP - Initial
 *  24-FEB-2020   : SYAP - Before Update Event Handler
 ****************************************************************************************************/

public with sharing class GCM_Service_Request_Trigger_Handler extends BPG_Trigger_Handler_Utilities {

/****************************************************************************************************
  Before Insert Event Handler
 ****************************************************************************************************/
  public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    GCM_Service_Request_Trigger_Helper.postCreate((List<GCM_Service_Request__c>) n, (Map<Id, GCM_Service_Request__c>) oMap, (Map<Id, GCM_Service_Request__c>) nMap);
  }

/****************************************************************************************************
  Before Update Event Handler
 ****************************************************************************************************/
  public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    GCM_Service_Request_Trigger_Helper.convertIntoCases((List<GCM_Service_Request__c>) n, (Map<Id, GCM_Service_Request__c>) oMap, (Map<Id, GCM_Service_Request__c>) nMap);
  }
}