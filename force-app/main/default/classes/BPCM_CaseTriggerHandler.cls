/**
* @Author:       Sushant Sethi
* @Date  :       08 June 2020
* @Description : This class handles trigger activities related to BPCM Case object
**/
public with sharing class BPCM_CaseTriggerHandler extends BPG_Trigger_Handler_Utilities{
    
/*Override beforeInsert Method to include logic for BPCM*/
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
         List<Case> castCaseRecs = new List<Case>();
         castCaseRecs = n;
         
         /*Call BPCM_CaseService Class to invoke logic for BPCM Case Activities*/
         BPCM_CaseService.processCaseService(castCaseRecs);
         BPCM_CaseService.runBeforeInsert(castCaseRecs);
    }
    
    public override void afterInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
		new BPCM_CaseService().runAfterInsert( (List<Case>) n );
    }
    
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
         new BPCM_CaseService().runBeforeUpdate((List<Case>) n, (Map<Id, Case>) oMap);
    }
    
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
		new BPCM_CaseService().runAfterUpdate( (Map<Id, Case>) oMap, (List<Case>) n );
    }
}