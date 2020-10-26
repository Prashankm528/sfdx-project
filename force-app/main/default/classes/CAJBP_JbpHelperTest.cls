/**
 * @author 			Jan Majling
 * @date 			25/07/2018
 * @group			CAJBP
 * @description     testing class for CAJBP_JbpHelper
 * 
 * history
 * 25/07/2018	Jan Majling			Created
 * 04/09/2018	Jana Cechova		Added tests for scorecard creating
 */
@isTest
public class CAJBP_JbpHelperTest {
    static list<CAJBP_Joint_Business_Plan__c> lstJBPsToInsert = new list<CAJBP_Joint_Business_Plan__c>();
    static integer bulkSize=200;

    static void createTestData() {
         Account account = new Account(
            Name = 'Power Plant',
            Type = 'ZMHI'
         );
        insert account;
        
        Contact contact = new Contact(FirstName='Test', LastName='Last', accountid=account.id);
        insert contact;
        
        for(Integer j=0; j<bulkSize; j++){   
           lstJBPsToInsert.add(new CAJBP_Joint_Business_Plan__c(
                CAJBP_Year__c = string.valueOf(date.today().year()),
                CAJBP_Account__c = account.id,
                CAJBP_State__c = 'Closed',
                CAJBP_JBP_Start_Date__c = Date.today(),
                CAJBP_JBP_End_Date__c = Date.today().addDays(10),
                CAJBP_JBP_Agreed_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Agreed_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Agreed_Sign_Off__c=True,
                CAJBP_JBP_Rev_Closing_Customer_Contact__c=Contact.Id,
                CAJBP_Date_of_JBP_Rev_Closing_Sign_Off__c=Date.Today(),
                CAJBP_JBP_Reviewed_Closed_Sign_Off__c=True
                
            ));
        }
            
    }


    @isTest static void testNameCreating() {
        CAJBP_Joint_Business_Plan__c jbp = new CAJBP_Joint_Business_Plan__c(
            CAJBP_Year__c = string.valueOf(date.today().year())
        );
        Account account = new Account(
            Name = 'Power Plant',
            Type = 'ZMHI'
        );
        String createdName = CAJBP_JbpHelper.createName(jbp, account);
        System.assertEquals('Power Plant Customer Group JBP '+ string.valueOf(date.today().year()), createdName);
    }
    
   static testmethod void checkCreateOneScorecardRecord() {
       list<CAJBP_Scorecard__c> lstScorecardToCheck = new list<CAJBP_Scorecard__c>();
       bulkSize = 1;
       createTestData();
       
        system.Test.startTest();
            
            insert lstJBPsToInsert;
            
        system.Test.stopTest();
        
        
       
        lstScorecardToCheck = [SELECT Id, Name FROM CAJBP_Scorecard__c];
        system.assertEquals(1, lstScorecardToCheck.size(), 'Record Scorecard was created unexpectedly.');
        System.assertEquals('Power Plant Scorecard ' + string.valueOf(date.today().year()), lstScorecardToCheck[0].Name, 'Scorecard name was created incorrectly.');
       
       
   }
   
   static testmethod void checkCreateBulkScorecardRecords() {
       list<CAJBP_Scorecard__c> lstScorecardToCheck = new list<CAJBP_Scorecard__c>();
       
       createTestData();
       
        system.Test.startTest();
            
            insert lstJBPsToInsert;
            
        system.Test.stopTest();
       
        lstScorecardToCheck = [SELECT Id, Name FROM CAJBP_Scorecard__c];
        system.assertEquals(200, lstScorecardToCheck.size(), 'Records Scorecard were created unexpectedly.');
        
        for(CAJBP_Scorecard__c objScoreCard : lstScorecardToCheck ){
            System.assertEquals('Power Plant Scorecard ' + string.valueOf(date.today().year()), objScoreCard.Name, 'Scorecard name was created incorrectly.');
        }
       
       
   }
    
}