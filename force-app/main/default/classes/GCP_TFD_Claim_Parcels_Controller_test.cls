/**
  * @author                         : Sid
  * @date                           : 10/04/2019
  * @description                    : Test Class for GCP_TFD_Claim_Parcels_Controller covering both positive and negative scenarios...
  * Covered Scenarios (Positive)    : Calling different methods of controller class and verifying the output.
  * Covered Scenarios (Negative)    : Trying to cover catch block and handling error.
  * 
  */   
@isTest
public with sharing class GCP_TFD_Claim_Parcels_Controller_test 
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
    //Positive Scenario with Single record Update and check number of parcels...
    static testmethod void method1()
    {
        User ActContextuser = [select Name from User where lastname = 'Test User'];
        system.runas(ActContextuser)
        {
            GCP_TFD_Letter_of_Credit__c lc = GCP_TFD_TestDataFactory.createLC('12','123','1','UTest');
            GCP_TFD_LC_Parcel__c parcel1 = GCP_TFD_TestDataFactory.createParcel('12',100,Null,lc.Id,'New');
            GCP_TFD_LC_Parcel__c parcel2 = GCP_TFD_TestDataFactory.createParcel('123',100,Null,lc.Id,'New');
            GCP_TFD_LC_Parcel__c parcel3 = GCP_TFD_TestDataFactory.createParcel('1234',100,Null,lc.Id,'New');
            //Verifying number of parcels...
            List<GCP_TFD_LC_Parcel__c> parcels = GCP_TFD_Claim_Parcels_Controller.fetchParcels(lc.id);
            system.assertEquals(3,parcels.size());
        }
    }
    //Positive Scenario with Single record Update and checking if picklist values are updating correctly...
    static testmethod void method2()
    {
        User ActContextuser = [select Name from User where lastname = 'Test User'];
        system.runas(ActContextuser)
        {
            GCP_TFD_Letter_of_Credit__c lc = GCP_TFD_TestDataFactory.createLC('12','123','1','UTest');
            GCP_TFD_LC_Parcel__c parcel1 = GCP_TFD_TestDataFactory.createParcel('12',100,Null,lc.Id,'New');
            GCP_TFD_LC_Parcel__c parcel2 = GCP_TFD_TestDataFactory.createParcel('123',100,Null,lc.Id,'New');
            GCP_TFD_LC_Parcel__c parcel3 = GCP_TFD_TestDataFactory.createParcel('1234',100,Null,lc.Id,'New');
            //Verifying number of parcels...
            List<GCP_TFD_LC_Parcel__c> parcels = GCP_TFD_Claim_Parcels_Controller.fetchParcels(lc.id);
            system.assertEquals(3,parcels.size());
            //Calling the picklist related method...
            case cs = new case();
            List<string> picklistvalues = GCP_TFD_Claim_Parcels_Controller.getselectOptions(cs,'GCP_TFD_Cover_Letter__c');
            system.assert(picklistvalues.size() > 0);
        }
    }
    //Positive Scenario with Single record Update and checking if case is getting created correctly...
    static testmethod void method3()
    {
        User ActContextuser = [select Name from User where lastname = 'Test User'];
        system.runas(ActContextuser)
        {
            GCP_TFD_Letter_of_Credit__c lc = GCP_TFD_TestDataFactory.createLC('12','123','1','UTest');
            GCP_TFD_LC_Parcel__c parcel1 = GCP_TFD_TestDataFactory.createParcel('12',100,Null,lc.Id,'New');
            GCP_TFD_LC_Parcel__c parcel2 = GCP_TFD_TestDataFactory.createParcel('123',100,Null,lc.Id,'New');
            GCP_TFD_LC_Parcel__c parcel3 = GCP_TFD_TestDataFactory.createParcel('1234',100,Null,lc.Id,'New');
            //Verifying number of parcels...
            List<GCP_TFD_LC_Parcel__c> parcels = GCP_TFD_Claim_Parcels_Controller.fetchParcels(lc.id);
            system.assertEquals(3,parcels.size());
            //Calling the picklist related method...
            case cs = new case();
            List<string> picklistvalues = GCP_TFD_Claim_Parcels_Controller.getselectOptions(cs,'GCP_TFD_Cover_Letter__c');
            system.assert(picklistvalues.size() > 0);
            //Calling the Case creation method...
            List<id> pardelids = new list<Id>();
            pardelids.add(parcel1.Id);
            pardelids.add(parcel2.Id);
            pardelids.add(parcel3.Id);
            Date discountDate = system.today()+1;
            string caseid = GCP_TFD_Claim_Parcels_Controller.createCase(pardelids,'Discounting','LOI',discountDate,lc.id);
            system.assertNotEquals(NULL,caseId);
        }
    }
    //Negative scenario to cover the catch block...
    static testmethod void method4()
    {
        User ActContextuser = [select Name from User where lastname = 'Test User'];
        system.runas(ActContextuser)
        {
            GCP_TFD_Letter_of_Credit__c lc = GCP_TFD_TestDataFactory.createLC('12','123','1','UTest');
            GCP_TFD_LC_Parcel__c parcel1 = GCP_TFD_TestDataFactory.createParcel('12',100,Null,lc.Id,'New');
            GCP_TFD_LC_Parcel__c parcel2 = GCP_TFD_TestDataFactory.createParcel('123',100,Null,lc.Id,'New');
            GCP_TFD_LC_Parcel__c parcel3 = GCP_TFD_TestDataFactory.createParcel('1234',100,Null,lc.Id,'New');
            //Verifying number of parcels...
            List<GCP_TFD_LC_Parcel__c> parcels = GCP_TFD_Claim_Parcels_Controller.fetchParcels(lc.id);
            system.assertEquals(3,parcels.size());
            //Calling the picklist related method...
            case cs = new case();
            List<string> picklistvalues = GCP_TFD_Claim_Parcels_Controller.getselectOptions(cs,'GCP_TFD_Cover_Letter__c');
            system.assert(picklistvalues.size() > 0);
            //Calling the Case creation method...
            List<id> pardelids = new list<Id>();
            pardelids.add(parcel1.Id);
            pardelids.add(parcel2.Id);
            pardelids.add(parcel3.Id);
            Date discountDate = system.today()+1;
            string caseid = GCP_TFD_Claim_Parcels_Controller.createCase(pardelids,'Discounting1','LOI',discountDate,lc.id);
            //system.assertNotEquals(NULL,caseId);
        }
    }
}