/**
* @author     Karishma Gurjar
* @date       29/05/2020
* @description    controller class for ICRM_ShowPBReportRecord cmp 
*/
public with sharing class ICRM_getPowerBIRecords {
    
    @AuraEnabled
    public static List <BPG_PBI_Report__c> getPowerBIRecords() {
        /* to get the logged in user PBI report records as per user sharing*/
        Id PBRecordTypeId = Schema.SObjectType.BPG_PBI_Report__c.getRecordTypeInfosByName().get('IST PBI Report').getRecordTypeId();  
        return [SELECT id, name FROM BPG_PBI_Report__c WHERE recordTypeId =: PBRecordTypeId];
    }
}