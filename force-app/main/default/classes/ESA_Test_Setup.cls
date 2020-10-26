/*******Test Setup Class********/
/* It has 3 methods for 3 diffrent Accounts with different Business Unit and Sales Area*/

public with sharing class ESA_Test_Setup {
   
    /*******Test Setup Class********/
/* It has 3 methods for 3 diffrent Accounts with different Business Unit and Sales Area*/

       Public static final Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(); 
       List<Account> listOfAccounts = new List<Account>();
       public List<Account> createAccount1() {
       
            Account Account1 = new Account();
            Account1.Name = 'Test Account 1';
            Account1.ESA_Business_Unit__c='ESA_PTC';
            Account1.ESA_Sales_Organisation__c='ESA_DE01/01/01';
            Account1.ESA_Customer_Id__c='1002';
            Account1.ESA_Relationship_Type__c='ESA_Customer';
            Account1.BillingPostalCode ='411057';
            Account1.BillingCountry='INDIA';
            Account1.RecordTypeId = accountRecordTypeId;
            listOfAccounts.add(Account1);
           
            Account Account2 = new Account();
            Account2.Name = 'Test Account 2';
            Account2.ESA_Business_Unit__c='ESA_PTC';
            Account2.ESA_Sales_Organisation__c='ESA_DE01/01/05';
            Account2.ESA_Customer_Id__c='1002';
            Account2.ESA_Relationship_Type__c='ESA_Customer';
            Account2.BillingPostalCode ='411057';
            Account2.BillingCountry='INDIA';
            Account2.RecordTypeId = accountRecordTypeId;
            listOfAccounts.add(Account2);
           
            Account Account3 = new Account();
            Account3.Name='Test Account 2';
            Account3.ESA_Business_Unit__c='ESA_Coke';
            Account3.ESA_Sales_Organisation__c='ESA_DE01/09/03';
            Account3.ESA_Customer_Id__c='1002';
            Account3.ESA_Relationship_Type__c='ESA_Customer';
            Account3.BillingPostalCode ='411057';
            Account3.BillingCountry='INDIA';
            Account3.RecordTypeId = accountRecordTypeId;
            listOfAccounts.add(Account3);
            
            return listOfAccounts;
        }   
          
}