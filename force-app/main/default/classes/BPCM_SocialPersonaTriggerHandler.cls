/**
* @Author:       Sushant Sethi
* @Date  :       18 June 2020
* @Description : This class handles trigger activities related to BPCM SocialPersona object
**/
public with sharing class BPCM_SocialPersonaTriggerHandler extends BPG_Trigger_Handler_Utilities{
    
/*Override afterUpdate Method to include logic for BPCM*/
    public override void afterUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug){
         List<SocialPersona> socialPersonaNewRec = new List<SocialPersona>();
         Map<id,SocialPersona> socialPersonaOldMap = new Map<id,SocialPersona>();
         socialPersonaNewRec = n;
         for(SObject objectRec: oMap.values()){
             socialPersonaOldMap.put(objectRec.id,(SocialPersona)objectRec);
         }
         /*Call BPCM_SocialPersonaService Class to invoke logic for BPCM SocialPersona Activities*/
         BPCM_SocialPersonaService.runAfterUpdate(socialPersonaNewRec,socialPersonaOldMap);
    }
}