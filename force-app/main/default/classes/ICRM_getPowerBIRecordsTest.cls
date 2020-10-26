/**
* @author     Karishma Gurjar
* @date       03/06/2020
* @description    Test class for ICRM_getPowerBIRecords 
*/
@isTest(SeeAllData=False)
public with sharing class ICRM_getPowerBIRecordsTest {
/*  Test method for testing  */
    @istest
    public static void getPowerBIRecordsTest(){
        Id PBRecordTypeId = Schema.SObjectType.BPG_PBI_Report__c.getRecordTypeInfosByName().get('IST PBI Report').getRecordTypeId();  
        BPG_PBI_Report__c pbreportrecord = new BPG_PBI_Report__c();
        String sTime= String.valueOf(System.currentTimeMillis());
        pbreportrecord.name='TestPBReport'+sTime;
        pbreportrecord.recordTypeId = PBRecordTypeId;
        insert pbreportrecord;
        Test.startTest();
        List<BPG_PBI_Report__c> PBList = new List<BPG_PBI_Report__c>();
        PBList = ICRM_getPowerBIRecords.getPowerBIRecords();
        System.assertNotEquals(PBList.size(), 0); 
        Test.stopTest();
    }
}