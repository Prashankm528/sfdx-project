/****************************************************************************************************
 *  Date          : 15-FEB-2019
 *  Author        : Sunny Yap
 *  Description   : Validation to prevent a case from being closed when there are open
 *                  child tasks or activities.
 * Modifications  : 15-FEB-2019 SYAP - Initial
 *                  18-MAR-2019 SYAP - Moved in to BPG triggers framework.
 *                  19-SEP-2019 SYAP - Added logic to set the team name based on owner of the case.
 *                  18-FEB-2020 Roselin - Added logic to set case number in custom field.
 ****************************************************************************************************/

public with sharing class GCM_Case_Trigger_Handler extends BPG_Trigger_Handler_Utilities { 

/****************************************************************************************************
 * beforeUpdate Event
 ****************************************************************************************************/
  public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    // Before Update Event
    // Execution Sequence Below Important
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.setTeamName((Map<Id, Case>) oMap, (Map<Id, Case>) nMap, (List<Case>) n); 
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.validateChildRecords((Map<Id, Case>) oMap, (Map<Id, Case>) nMap, (List<Case>) n);
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.applyRoutingRules((Map<Id, Case>) oMap, (Map<Id, Case>) nMap, (List<Case>) n);
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.setCaseEntitlement((Map<Id, Case>) oMap, (Map<Id, Case>) nMap, (List<Case>) n);
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.setServiceCatalog((Map<Id, Case>) oMap, (Map<Id, Case>) nMap, (List<Case>) n);
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.setMilestoneCompletedDate((List<Case>) n, (Map<Id, Case>) oMap, (Map<Id, Case>) nMap); 
  }

/****************************************************************************************************
 * beforeInsert Event
 ****************************************************************************************************/   
  public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
  {
    // Before Insert Event
    // Execution Sequence Below Important
    if (sot.getDescribe().getName() == 'Case') GCM_Routing_Engine.applyRoutingRules((Map<Id, Case>) oMap, (Map<Id, Case>) nMap, (List<Case>) n);
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.setTeamName((Map<Id, Case>) oMap, (Map<Id, Case>) nMap, (List<Case>) n);
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.setCaseEntitlement((Map<Id, Case>) oMap, (Map<Id, Case>) nMap, (List<Case>) n);
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.setServiceCatalog((Map<Id, Case>) oMap, (Map<Id, Case>) nMap, (List<Case>) n);
    if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.setMilestoneCompletedDate((List<Case>) n, (Map<Id, Case>) oMap, (Map<Id, Case>) nMap);
  }
  
/****************************************************************************************************
 * afterUpdate Event
 ****************************************************************************************************/  
  public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) 
  {
    // After Update Event
    if (sot.getDescribe().getName() == 'Case'){
        GCM_C2S_Controller.stopTimerBulk(((List<case>)n),((map<id,case>)oMap));
    }   
  } 

/****************************************************************************************************
 * afterInsert Event
 ****************************************************************************************************/       
  public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug) {
    // After Insert Event
    if (sot.getDescribe().getName() == 'Case') GCM_C2S_Controller.stopNewCaseTimer((List<Case>) n);
    //if (sot.getDescribe().getName() == 'Case') GCM_Case_Trigger_Helper.setCaseNumber((Map<Id, Case>) nMap);
  }   
}