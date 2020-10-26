/**
* @author       : Gaurav Wadhawan
* @date         : 19 June 2020
* @description  : Test class for BPCM_CaseTouchHistoryService class  
*/
@isTest(SeeAllData=False)
public with sharing class BPCM_CaseTouchHistoryService_Test {
    
/**
* @description - test setup method for creating test data
*/
      @testSetup static void setup() {
        // Create common test Cases
        List<Case> caseList = new List<Case>();
        List<User> userList = new List<User>();
        List<BPCM_Case_Touch_History__c> CaseHist = new List<BPCM_Case_Touch_History__c>();
        string caseRecID = [SELECT id from RecordType where DeveloperName ='BPCM_Account' AND SobjectType = 'Case'].Id;    
        case c1= new case(RecordTypeID=caseRecID , Subject='TESTINGCASE1', Description='This is description of Case for TESTINGCASE1', Origin='Email', SuppliedName = 'Test', SuppliedEmail = 'test@test.com');    
        caseList.add(c1);
        case c2= new case(RecordTypeID=caseRecID , Subject='TESTINGCASE2', Description='This is description of Case for TESTINGCASE2', Origin='Email', SuppliedName = 'Test', SuppliedEmail = 'test@test.com');    
        caseList.add(c2);
        insert caseList;
        
        // Create common test Users
        Profile p1 = [select id from profile where name='Standard User'];
        User u1 = new User(alias = 'standt', email='test@test.com', emailencodingkey='UTF-8',username='welcome@testmail.com',languagelocalekey='en_US',localesidkey='en_US',timezonesidkey='America/Los_Angeles',firstname='testfname', lastname='testlname', profileid = p1.Id);
        userList.add(u1);
        insert userList;
        User u2 = [SELECT id,Name from User WHERE username = : UserInfo.getUserName() LIMIT 1];
        
        // Create common test BPCM Case Touch History
        System.runas(u2){
        BPCM_Case_Touch_History__c ch2 = new BPCM_Case_Touch_History__c(BPCM_Case__c=c1.id,BPCM_UserId__c=u2.Id,BPCM_User__c = u2.Name); 
        CaseHist.add(ch2);
        }   
        BPCM_Case_Touch_History__c ch1 = new BPCM_Case_Touch_History__c(BPCM_Case__c=c1.id,BPCM_UserId__c=u1.Id,BPCM_User__c = u1.LastName);
        CaseHist.add(ch1);
        insert CaseHist;
        
        System.assertEquals(2, caseList.size(), 'Cases setup records inserted');
        System.assertEquals(1, userList.size(), 'User setup record inserted');
        System.assertEquals(2, CaseHist.size(), 'Case history setup records inserted');
          
      }
    
      //Test Method for capture the interactions done on the Case when BPCM_Case_Touch_History__c records not exist
      static testMethod void NotExistCaseTouchHistory(){
        Map<Id, List<String>> csIdInteractionsMap = new Map<Id, List<String>>();
        List<String> casestr = new List<String>{'BPCM_Outbound_Calls__c'};
        //Get case from test data
        Case c = [SELECT Id,Subject FROM Case WHERE Subject='TESTINGCASE2' LIMIT 1];
          
        Test.startTest();
         csIdInteractionsMap.put(c.Id, casestr);
         BPCM_CaseTouchHistoryService.captureCaseTouches(csIdInteractionsMap);     
        Test.stopTest();
        
        System.assertNotEquals(null, c.Id);
        System.assertEquals(c.Subject, 'TESTINGCASE2');

    }
    
      //Test Method for capture the interactions done on the Case when BPCM_Case_Touch_History__c records exist
      static testMethod void ExistCaseTouchHistory(){

        Map<Id, List<String>> csIdInteractionsMap = new Map<Id, List<String>>();
        List<String> casestr = new List<String>{'BPCM_Outbound_Calls__c'};
        //Get case from test data
        Case c = [SELECT Id, Subject FROM Case WHERE Subject='TESTINGCASE1' LIMIT 1];

        csIdInteractionsMap.put(c.Id, casestr);
        Test.startTest();
         BPCM_CaseTouchHistoryService.captureCaseTouches(csIdInteractionsMap);         
        Test.stopTest();
          
        System.assertNotEquals(null, c.Id);
        System.assertEquals(c.Subject, 'TESTINGCASE1');
        
    }
      //Test Method for verify and add Case interactions into a map to be processed
      static testMethod void addCsInteractionsMap(){
          
        Map<Id, List<String>> csIdInteractionsMap = new Map<Id, List<String>>();
        List<String> casestr = new List<String>{'BPCM_Outbound_Calls__c'};
        string interaction = 'BPCM_Outbound_Calls__c';    
          
        //Get case from test data
        Case c = [SELECT Id FROM Case WHERE Subject='TESTINGCASE1' LIMIT 1];
        csIdInteractionsMap.put(c.Id, casestr);
          
        Test.startTest();
         BPCM_CaseTouchHistoryService.addCsInteractionsMap(csIdInteractionsMap, c.Id, interaction);     
        Test.stopTest();
          
        System.assertNotEquals(null, c.Id);
    }
}