/************************************************************************************************************
* Description : Basic test for CASFO_QBRMeetingRequestController
*
* Date          Version #           Author              Description
* -----------------------------------------------------------------------------------------------------------
*       
* 2019-06-24    1.0					Adam Janicko	    Test logic with BU as MSP
*
*************************************************************************************************************/
@isTest
public class CASFO_QBRMeetingRequestControllerTest {
    private static User user;
    
    static void setup(String userBU) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Castrol_SalesUser'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name = 'Castrol - Alpine FWS Sales'];
        Territory2 territory2 = [SELECT Id FROM Territory2 WHERE DeveloperName = 'Lubricants_AT01' LIMIT 1];
        
        user = new User(Alias = 'TestUser', Email='TestUser@example.castrol.com', 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = p.Id, 
                        TimeZoneSidKey='America/Los_Angeles', UserName='TestUser@example.castrol.com',
                        Business_Unit__c = userBU,   
                        Sales_Organisation__c = 'AT01',
                        UserRole = r);
        insert user;
        
        List<Account> accounts = new List<Account>();
        String customerId = [SELECT Id, SobjectType, Name 
                             FROM RecordType WHERE Name = 'Customer'
                             AND SobjectType = 'Account'  LIMIT 1].Id;
        
        Account acc = new Account(RecordTypeId = customerId, Name='Test acc', Sales_Organisation__c = 'AT01', Business_Unit__c = 'Lubricants - Automotive', 
                                  CASFO_QBR_Favorite__c = true, CASFO_QBR_Completed_Date__c = null);
        acc.AccountNumber = '123456';
        accounts.add(acc);
        
        acc = new Account(RecordTypeId = customerId, Name='Test acc2', Sales_Organisation__c = 'AT01', Business_Unit__c = 'Lubricants - Industrial', 
                          CASFO_QBR_Favorite__c = true, CASFO_QBR_Completed_Date__c = null);
        acc.AccountNumber = '654321';
        accounts.add(acc);
        insert accounts;
        
        User adminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(adminUser) {        
            insert new UserTerritory2Association(Territory2Id = territory2.Id, UserId = user.Id);
            insert new ObjectTerritory2Association(AssociationCause='Territory2Manual', Territory2Id = territory2.Id, ObjectId = accounts[0].Id);
            insert new ObjectTerritory2Association(AssociationCause='Territory2Manual', Territory2Id = territory2.Id, ObjectId = accounts[1].Id);
        }
    }
    
    @isTest
    static void getAccountsWithCorrectBu() {
        setup('Lubricants - Automotive;Lubricants - Industrial');
        
        Test.startTest();
        List<Account> returnedAccs;
        System.runAs(user) {
            returnedAccs = CASFO_QBRMeetingRequestController.getAccounts(true, true);
        }
        Test.stopTest();
        
        System.assertEquals(2, returnedAccs.size(),'Returned Accounts size should be equal to test accounts size');
    }
    
    @isTest
    static void getAccountsWithCorrectBuAndUnFav() {
        setup('Lubricants - Automotive;Lubricants - Industrial');
        String customerId = [SELECT Id, SobjectType, Name 
                             FROM RecordType WHERE Name = 'Customer'
                             AND SobjectType = 'Account'  LIMIT 1].Id;
        
        List<Account> accounts = [Select Id From Account Where recordTypeId =: customerId Limit 2];
        for(Account testAccout : accounts)
        {
            testAccout.CASFO_QBR_Favorite__c = False;
            testAccout.CASFO_QBR_Planned__c = False;
            testAccout.Classification__c = 'PL Platinum';
            testAccout.Type = 'ZMSP';
        }
        update accounts;
        Test.startTest();
        List<Account> returnedAccs;
        System.runAs(user) {
            returnedAccs = CASFO_QBRMeetingRequestController.getAccounts(false, true);
        }
        Test.stopTest();
        
        System.assertEquals(accounts.size(), returnedAccs.size(),'returned accounts size should be eaual to test account list size');
    }
    
    @isTest
    static void getAccountsWithInCorrectBu() {
        setup('Lubricants - Marine');
        
        Test.startTest();
        List<Account> returnedAccs;
        System.runAs(user) {
            returnedAccs = CASFO_QBRMeetingRequestController.getAccounts(true, true);
        }
        Test.stopTest();
        
        System.assertEquals(0, returnedAccs.size(),'Returned Accounts size should be equal to 0');
    }
    
    
    @isTest
    static void searchAccountsTest() {
        setup('Lubricants - Marine');
        List<Account> accounts = [Select Id From Account limit 2];
        
        Id [] fixedSearchResults= new Id[2];
        fixedSearchResults[0] = accounts[0].Id;
        fixedSearchResults[1] = accounts[1].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
        List<Account> returnedAccs;
        
        System.runAs(user) {
            system.debug([Select Id,Sales_Organisation__c From Account]);
            
            returnedAccs = CASFO_QBRMeetingRequestController.searchAccounts('AT01');
        }
        Test.stopTest();
        
        System.assertEquals(fixedSearchResults.size(), returnedAccs.size(), 'returnedAccs size should be equal to fixedSearchResults size');
    }
    
    @isTest(SeeAllData=true)
    /**
     * SeeAllData=true is required here as we are using connectApi Class
     */
    static void requestAccountsTest() 
    {
        String customerId = [SELECT Id, SobjectType, Name 
                             FROM RecordType WHERE Name = 'Customer'
                             AND SobjectType = 'Account'  LIMIT 1].Id;
        
        List<Account> accounts = [Select Id From Account Where recordTypeId =: customerId Limit 2];
        
        Test.startTest();
        CASFO_QBRMeetingRequestController.requestAccounts(accounts);
        Test.stopTest();
        accounts = [Select Id,CASFO_QBR_Requested__c,CASFO_QBR_Requester__c From Account Where Id IN : accounts];
        
        for(Account testAccount : accounts)
        {
            System.assertEquals(TRUE, testAccount.CASFO_QBR_Requested__c, 'CASFO_QBR_Requested__c value should be equal TRUE');
            System.assertEquals(UserInfo.getUserId(), testAccount.CASFO_QBR_Requester__c, 'CASFO_QBR_Requester__c value should be equal to '+ UserInfo.getUserId());            
        }
    }
}