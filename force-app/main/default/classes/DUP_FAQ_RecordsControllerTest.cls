@isTest
public class DUP_FAQ_RecordsControllerTest {
	@testSetup
    public static void FAQ_records(){
        list<DUP_FAQ__c> records = new list<DUP_FAQ__c>();
        for(integer i=0;i<10;i++){
            DUP_FAQ__c faq = new DUP_FAQ__c();
            faq.DUP_Title__c = 'Test'+i;
            faq.DUP_Record_views__c = i;
            records.add(faq);
        }
        insert records;
    }
    @isTest
    public static void getRelatedRecordsTest(){
        list<DUP_FAQ__c> receivedRecords = new list<DUP_FAQ__c>();
        receivedRecords = DUP_FAQ_RecordsController.getRelatedRecords();
        //checking List size
        system.assertEquals(5, receivedRecords.size());
        integer i=9;
        //checking the order 
        for(DUP_FAQ__c faq:receivedRecords){
            system.assertEquals('Test'+i, faq.DUP_Title__c);
            //system.debug(faq.Name);
            i--;
        }
    }
    @isTest
    public static void getSearchedRecordsTest(){
        list<DUP_FAQ__c> receivedRecords = new list<DUP_FAQ__c>();
        string searchTerm = 'test';
        //checking by passing string
        receivedRecords = DUP_FAQ_RecordsController.getSearchedRecords(searchTerm);
        system.assertEquals(5, receivedRecords.size());
        
        //passing random string not present in test data
        receivedRecords = DUP_FAQ_RecordsController.getSearchedRecords('searchTerm');
        system.assertEquals(0, receivedRecords.size());
        
        //passing empty string
        receivedRecords = DUP_FAQ_RecordsController.getSearchedRecords('');
        system.assertEquals(5, receivedRecords.size());
        integer i=0;
        //checking the order 
        for(DUP_FAQ__c faq:receivedRecords){
            system.assertEquals('Test'+i, faq.DUP_Title__c);
            //system.debug(faq.Name);
            i++;
        }
    }
    @isTest
    public static void updateRecordViewsTest(){
        list<DUP_FAQ__c> records = new list<DUP_FAQ__c>();
        records = [SELECT id,DUP_Record_views__c from DUP_FAQ__c];
        for(DUP_FAQ__c faq:records){
            DUP_FAQ__c receivedRecord = new DUP_FAQ__c();
            receivedRecord = DUP_FAQ_RecordsController.updateRecordViews(faq.Id);
            system.assertEquals(faq.DUP_Record_views__c+1, receivedRecord.DUP_Record_views__c);
        }
    }
}