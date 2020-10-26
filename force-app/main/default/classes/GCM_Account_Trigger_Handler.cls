/****************************************************************************************************
 *  Date          : 25-JUN-2019
 *  Author        : Sunny Yap
 *  Description   : Account trigger handler for GCM.
 *  Modifications : 25-JUN-2019 SYAP - Initial
 *                  10-AUG-2019 SYAP - Added default SEL logic.
 ****************************************************************************************************/

public with sharing class GCM_Account_Trigger_Handler extends BPG_Trigger_Handler_Utilities {

/****************************************************************************************************
  Before Insert Event Handler
 ****************************************************************************************************/
  public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'Account') GCM_Account_Trigger_Helper.setDefaultSEL((List<Account>) n, (Map<Id, Account>) oMap, (Map<Id, Account>) nMap);
  } 

/****************************************************************************************************
  Before Update Event Handler
 ****************************************************************************************************/
  public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'Account') GCM_Account_Trigger_Helper.setDefaultSEL((List<Account>) n, (Map<Id, Account>) oMap, (Map<Id, Account>) nMap);
    if (sot.getDescribe().getName() == 'Account') GCM_Account_Trigger_Helper.updateAccountServExpLevel((List<Account>) n, (Map<Id, Account>) oMap, (Map<Id, Account>) nMap);
  } 

/****************************************************************************************************
  After Update Event Handler
 ****************************************************************************************************/
  public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'Account') BPG_Account_Sharing.assignPublicGroup((List<Account>) n, (Map<Id, Account>) oMap, (Map<Id, Account>) nMap, false, 'GCM_Application_Administrator');
    if (sot.getDescribe().getName() == 'Account') GCM_Account_Trigger_Helper.createEntitlement((List<Account>) n, (Map<Id, Account>) oMap, (Map<Id, Account>) nMap, false);
  } 

/****************************************************************************************************
  After Insert Event Handler
 ****************************************************************************************************/
  public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    if (sot.getDescribe().getName() == 'Account') BPG_Account_Sharing.assignPublicGroup((List<Account>) n, (Map<Id, Account>) oMap, (Map<Id, Account>) nMap, true, 'GCM_Application_Administrator');
    if (sot.getDescribe().getName() == 'Account') GCM_Account_Trigger_Helper.createEntitlement((List<Account>) n, (Map<Id, Account>) oMap, (Map<Id, Account>) nMap, true);
  }   
}