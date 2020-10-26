/**
 * @author 			Venkatesh Muniyasamy
 * @date 			19/07/2019
 * @group			CAJBP
 * @description     Trigger Handler on CAJBP_JBP_Team_Member__c object
 *
 * history
  * 19/07/2019	Venkatesh Muniyasamy		Created for code refactoring
  * 26/08/2020  Abhinit Kohar               Updated to add Before delete
 */

public with sharing class CAJBP_JbpTeamMemberHandler extends BPG_Trigger_Handler_Utilities
{
    public override void beforeInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {   
       CAJBP_JbpTeamMemberTriggerHandler handler = new CAJBP_JbpTeamMemberTriggerHandler((List<CAJBP_JBP_Team_Member__c>)newList, (List<CAJBP_JBP_Team_Member__c>) oldList, (Map<Id,CAJBP_JBP_Team_Member__c>) newMap, (Map<Id,CAJBP_JBP_Team_Member__c>) oldMap); 
       handler.handleBeforeInsert();
    }
	public override void beforeUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {   
        CAJBP_JbpTeamMemberTriggerHandler handler = new CAJBP_JbpTeamMemberTriggerHandler((List<CAJBP_JBP_Team_Member__c>)newList, (List<CAJBP_JBP_Team_Member__c>) oldList, (Map<Id,CAJBP_JBP_Team_Member__c>) newMap, (Map<Id,CAJBP_JBP_Team_Member__c>) oldMap); 
        handler.handleBeforeUpdate();
    }
    public override void afterUpdate(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {   
        CAJBP_JbpTeamMemberTriggerHandler handler = new CAJBP_JbpTeamMemberTriggerHandler((List<CAJBP_JBP_Team_Member__c>)newList, (List<CAJBP_JBP_Team_Member__c>) oldList, (Map<Id,CAJBP_JBP_Team_Member__c>) newMap, (Map<Id,CAJBP_JBP_Team_Member__c>) oldMap); 
        handler.handleAfterUpdate();
    }

    public override void afterInsert(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)    
    {
        CAJBP_JbpTeamMemberTriggerHandler handler = new CAJBP_JbpTeamMemberTriggerHandler((List<CAJBP_JBP_Team_Member__c>)newList, (List<CAJBP_JBP_Team_Member__c>) oldList, (Map<Id,CAJBP_JBP_Team_Member__c>) newMap, (Map<Id,CAJBP_JBP_Team_Member__c>) oldMap); 
        handler.handleAfterInsert();
    }
    public override void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {   
        CAJBP_JbpTeamMemberTriggerHandler handler = new CAJBP_JbpTeamMemberTriggerHandler((List<CAJBP_JBP_Team_Member__c>)newList, (List<CAJBP_JBP_Team_Member__c>) oldList, (Map<Id,CAJBP_JBP_Team_Member__c>) newMap, (Map<Id,CAJBP_JBP_Team_Member__c>) oldMap); 
        handler.handleAfterDelete();
    }

    public override void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap, List<SObject> newList, Map<Id, SObject> newMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        CAJBP_JbpTeamMemberTriggerHandler handler = new CAJBP_JbpTeamMemberTriggerHandler((List<CAJBP_JBP_Team_Member__c>)newList, (List<CAJBP_JBP_Team_Member__c>) oldList, (Map<Id,CAJBP_JBP_Team_Member__c>) newMap, (Map<Id,CAJBP_JBP_Team_Member__c>) oldMap);
        handler.handleBeforeDelete();
    }
}