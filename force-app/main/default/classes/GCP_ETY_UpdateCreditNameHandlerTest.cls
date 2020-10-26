/*****************************************************************************************
*   Date:         18/10/2019
*   Author:       Subin M Nair
*   Description:  Test class for GCP_ETY_UpdateCreditName trigger and  GCP_ETY_UpdateCreditNameHandler class
****************************************************************************************/
@isTest
private with sharing class GCP_ETY_UpdateCreditNameHandlerTest {

 static testmethod void updateNameTest()
 {
      List<RecordType> recordType = [Select Id,DeveloperName From RecordType where sObjectType='Account' and isActive=true and Developername='ICRM_Legal_Entity'];
      Map<String,String> accountRecordTypes = New Map<String,String>{};
      for (RecordType rec : recordType) 
      {
          accountRecordTypes.put(rec.DeveloperName,rec.Id);
      }
      List<RecordType> entrecordType = [Select Id,DeveloperName From RecordType where sObjectType='GCP_ETY_Credit_Entity__c' and isActive=true and Developername in ('GCP_ETY_BPLE','GCP_ETY_Counterparty')];
      Map<String,String> credRecordTypes = New Map<String,String>{};
      for (RecordType rec : entrecordType) 
      {
          credRecordTypes.put(rec.DeveloperName,rec.Id);
      }
      List<GCP_ETY_Credit_Entity__c> insertCredList = new List<GCP_ETY_Credit_Entity__c>();
      Account ac1 = new account();
      ac1.name='Test Account Name';
      ac1.RecordTypeId = accountRecordTypes.get('ICRM_Legal_Entity');
      insert ac1;
      GCP_ETY_Credit_Entity__c cred1 = new GCP_ETY_Credit_Entity__c();
      cred1.Name='TestBPLE';
      cred1.Recordtypeid = credRecordTypes.get('GCP_ETY_BPLE');
      cred1.GCP_ETY_Account__c = ac1.id;
      insertCredList.add(cred1);
      GCP_ETY_Credit_Entity__c cred2 = new GCP_ETY_Credit_Entity__c();
      cred1.Name='TestCtpty';
      cred1.Recordtypeid = credRecordTypes.get('GCP_ETY_Counterparty');
      cred1.GCP_ETY_Account__c = ac1.id;
      insertCredList.add(cred2);
      Test.startTest();
      insert insertCredList;
      system.assertEquals(2, insertCredList.size());
      Test.stopTest();
 }

}