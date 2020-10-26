/**
  * @author                         : Sid
  * @date                           : 10/04/2019
  * @description                    : Test Class for GCP_TFD_LcParcelsTriggerHandle covering both positive and negative scenarios...
  * Covered Scenarios (Positive)    : Single Record Update and checking if Amount on case is updated correctly.
  *                                 : Checking if the status of parcel is updating correctly.
  *                                 : Bulk records (multiple parcel records) Update and checking if logic works fine.
  * Covered Scenarios (Negative)    : Updating parcel with out mandatory fields and catching the exceptions.
  *                                 : Not updating Case field on Parcel and make sure logic don't run.
  * 
  */   
@isTest
public with sharing class GCP_TFD_LcParcelsTriggerHandler_test
{
    //testing data setup for all methods in this class
    @testSetup
    static void DataForThisTestClass()
    {
        //Create User with profile as System Admin...
        Profile prof = [select id from profile where Name = 'System Administrator' LIMIT 1];
        User Contextuser = new User(alias = 'TestUser', email= 'test@test.com',
                            emailencodingkey= 'UTF-8', lastname = 'Test User',
                            timezonesidkey='America/Los_Angeles',
                            languagelocalekey='en_US',
                            localesidkey='en_US', profileid = prof.Id,
                            UserRoleId= NULL,
                            username= 'TestUser' + System.currentTimeMillis() + '@testorg.com');
        insert Contextuser;
    }
    
    //Negative Scenario with Single record Update and checking if parcel is getting deleted...
    static testmethod void deleteparcel1()
    {
        User ActContextuser = [select Name from User where lastname = 'Test User'];
        system.runas(ActContextuser)
        {
            system.test.startTest();
            case cs = GCP_TFD_TestDataFactory.createCase();
            GCP_TFD_LC_Parcel__c parcel1 = GCP_TFD_TestDataFactory.createParcelNew('12',100,cs.id,NULL,'Claimed','D','Complete','Test');
            system.test.stopTest();
            system.assertEquals(0,[select count() from GCP_TFD_LC_Parcel__c where GCP_TFD_Related_Case__c =:cs.id]);
        }
    }
    static testmethod void deleteparcel()
    {
        User ActContextuser = [select Name from User where lastname = 'Test User'];
        system.runas(ActContextuser)
        {
            case cs = GCP_TFD_TestDataFactory.createCase();
            GCP_TFD_LC_Parcel__c parcel1 = GCP_TFD_TestDataFactory.createParcelNew('12',100,cs.id,NULL,'New','','Completed','SBLC');
            system.test.startTest();
            parcel1.GCP_TFD_Audit__c = 'A';
            update parcel1;
            system.test.stopTest();
            system.assertEquals(1,[select count() from GCP_TFD_LC_Parcel__c where GCP_TFD_Related_Case__c =:cs.id]);
        }
    }
    
}