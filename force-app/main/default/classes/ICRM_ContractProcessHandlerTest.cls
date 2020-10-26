/** 
* @author     Irfan Ahmed
* @date       26/03/2020
* @description    Test class for Contract Process Builder   
**/
@isTest(SeeAllData=False)
public with sharing class ICRM_ContractProcessHandlerTest {
    @testSetup 
    static void testdataSetup(){  
        //Create Test Data for Test Methods
        Profile p = [SELECT Id FROM Profile WHERE Name='ICRM Base'];
        
        User u1 = new User(Alias = 'standr', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing1', FirstName='Test1',LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='OppNewUser@test.com.test');
        insert u1;
        ICRM_Staff__c s1 = new ICRM_Staff__c(NAME='Test Staff1', ICRM_NTID__C='er32',ICRM_TRADER_ISACTIVE__C=True,ICRM_IST_USER__C=True);
        Insert s1;
        ICRM_Staff__c s2 = new ICRM_Staff__c(NAME='Test Staff2', ICRM_NTID__C='yu32',ICRM_TRADER_ISACTIVE__C=True,ICRM_IST_USER__C=True);
        Insert s2;
        Account acc = new Account();
        string recTypeid = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('IST Prospect').getRecordTypeId();
        acc.RecordTypeId = recTypeid;
        acc.Name = 'Test Account for Contact';
        acc.ICRM_OriginationTag__c=u1.id;
        acc.ICRM_Head_Of_Origination__c=u1.id;
        acc.ICRM_Trader_Tag1__c=s1.id;
        acc.ICRM_Head_of_Trading1__c=s2.id;
        acc.ICRM_Operations_Tag1__c=s1.id;
        Insert acc;
    }
    @isTest
    public static void testContractObjectTags(){
        // To cover process builder  ICRM Update Contract Object Tags    
        Account acc1 = [SELECT Id, name,ICRM_OriginationTag__c,ICRM_Head_Of_Origination__c,ICRM_Trader_Tag1__c,ICRM_Head_of_Trading1__c,ICRM_Operations_Tag1__c FROM Account WHERE Name = 'Test Account for Contact'];
        string recTypeid = Schema.getGlobalDescribe().get('ICRM_Contract__c').getDescribe().getRecordTypeInfosByName().get('IST Contract').getRecordTypeId();
        
        ICRM_Contract__c Cont = new ICRM_Contract__c();
        Cont.RecordTypeId = recTypeid;
        Cont.Name='Test Contract';
        Cont.ICRM_Counterparty__c=acc1.id;
        Test.startTest(); 
        Insert Cont;
        ICRM_Contract__c contNew = [Select id,ICRM_Head_of_Origination_Tag__c,ICRM_Head_of_Trading_HoT_Tag__c,ICRM_Operations_Tag__c,ICRM_Origination_Tag__c,ICRM_Trading_Tag__c from ICRM_Contract__c where Id = :Cont.Id];        
        System.assertEquals(contNew.ICRM_Head_of_Origination_Tag__c, acc1.ICRM_Head_Of_Origination__c);
        System.assertEquals(contNew.ICRM_Head_of_Trading_HoT_Tag__c, acc1.ICRM_Head_of_Trading1__c);
        System.assertEquals(contNew.ICRM_Operations_Tag__c, acc1.ICRM_Operations_Tag1__c);
        System.assertEquals(contNew.ICRM_Origination_Tag__c,acc1.ICRM_OriginationTag__c); 
        System.assertEquals(contNew.ICRM_Trading_Tag__c,acc1.ICRM_Trader_Tag1__c);
        Test.stopTest();
    }
}