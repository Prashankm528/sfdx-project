/**
* @author Santosh Verma
* @date 04/08/2019
* @description - Handler class for triggers on Committee meeting object
* 
*/

public with sharing class ICRM_ComMeetTriggerHandler extends BPG_Trigger_Handler_Utilities
{
    
    // Operation on before insert 
    // Converts the Date to text and store it in Text Field
    public override void beforeInsert(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        List<ICRM_Committee_Meetings__c> CMMList = new List<ICRM_Committee_Meetings__c>();
        CmmList = n; 
        for(ICRM_Committee_Meetings__c cmm:CMMList)
        {
            String convertedName;
            cmm.ICRM_Text_Date__c  = string.valueOf(cmm.ICRM_Meeting_Date__c); 
            String meetingDateTotext = DateTime.newinstance(cmm.ICRM_Meeting_Date__c.year(), cmm.ICRM_Meeting_Date__c.month(), cmm.ICRM_Meeting_Date__c.day()).format('yyyy/MM/dd');
            if(cmm.ICRM_RB__c != null){
                convertedName = cmm.ICRM_RB__c+' ';
                convertedName = convertedName+cmm.ICRM_Type__c+' ';    
            }
            else{
                convertedName =cmm.ICRM_Type__c+' '; 
            }
            convertedName = convertedName+meetingDateTotext;
            if(cmm.ICRM_Offline__c == true){
                convertedName = convertedName+' Offline';
            }
            cmm.Name = convertedName;
        }
    }
    
    
    // Operation on before update   
    // Converts the Date to text and store it in Text Field
    public override void beforeUpdate(List<SObject> o, Map<Id, SObject> oMap, List<SObject> n, Map<Id, SObject> nMap, Schema.SObjectType sot, String params, Boolean debug)
    {
        List<ICRM_Committee_Meetings__c> CMMList = new List<ICRM_Committee_Meetings__c>();
        CmmList = n; 
        for(ICRM_Committee_Meetings__c cmm:CMMList)
        {
            cmm.ICRM_Text_Date__c  = string.valueOf(cmm.ICRM_Meeting_Date__c); 
            
        }
    }
}