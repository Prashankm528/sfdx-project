/*****************************************************************************************
*   Date:     18/06/2020
*   Author:   Mansi Dhoke (TCS)  
*   Description:   Test Class for Class PCRM_CloneOpportunities
*   Changes: 0.1 
 
****************************************************************************************/

@isTest
public with sharing class PCRM_TestCloneOpportunities
{
   /* Public static List<Account> ListOfAccount {get;set;}
    Public static List<string> lstFrequncyType {get;set;}*/
    /* @testSetup  static void setup()
     {
         PCRM_Utility utilityClass = NEW PCRM_Utility();
         
         ListOfAccount = utilityClass.createAccount(1, 'Customer', 'ZMSH'); //ship to party
         for(Account ObjAccount : ListOfAccount)
         {
            ObjAccount.Sales_Division_Code__c ='69';
            ObjAccount.PCRM_Quote_Frequency__c = 'Monthly';
         }
        
         insert ListOfAccount;
         
         
        
     }*/
    //account = null
   static testMethod void validateExecuteWithoutAccounts() 
    {
      test.startTest();
      List<string> lstFrequncyType = NEW List<string>();
       PCRM_Utility utilityClass = NEW PCRM_Utility();
         
        lstFrequncyType = NEW   List<string>();
        lstFrequncyType.add('Monthly');
        lstFrequncyType.add('Quarterly');
        lstFrequncyType.add('Monthly and Quarterly');
        
        PCRM_CloneOpportunities objCloneOpportunity = new PCRM_CloneOpportunities(lstFrequncyType,null,null );
        objCloneOpportunity.cpuTimeLimit = 80;
      
           System.enqueueJob(objCloneOpportunity);
        test.stopTest();
        
    }
    
    //account! = null
    static testMethod void validateExecuteWithAccounts() 
    {
       test.startTest();
       List<string> lstFrequncyType = NEW List<string>();
       PCRM_Utility utilityClass = NEW PCRM_Utility();
         
       List<Account> ListOfAccount = new  List<Account>();
         ListOfAccount = utilityClass.createAccount(5, 'Customer', 'ZMSH'); //ship to party
         for(Account ObjAccount : ListOfAccount)
         {
            ObjAccount.Sales_Division_Code__c ='69';
            ObjAccount.PCRM_Quote_Frequency__c = 'Monthly';
         }
         insert ListOfAccount;
       system.debug('Inserted ACC TEST: '+ListOfAccount);
        
       List<opportunity> ListOfOpportunity = utilityClass.createOpportunity(ListOfAccount,10,'PCRM_PetChems_Acetyls');
       INSERT ListOfOpportunity; 
        
       ListOfAccount = [select id ,Name,recordtypeId,CurrencyIsoCode,(select id,Description,PCRM_Opportunity_Cloned_From__c,Territory2Id,PCRM_Payload__c,PCRM_Mode_of_Transport__c,Name,StageName,ForecastCategoryName,Type,PCRM_Related_Opportunity__c,CurrencyIsoCode,Pricebook2Id,recordtypeId,accountId,PCRM_Quarter__c,PCRM_Quote_Frequency__c from opportunities) from account where Id IN : ListOfAccount ]  ;
        
        
        lstFrequncyType = NEW   List<string>();
        lstFrequncyType.add('Monthly');
        lstFrequncyType.add('Quarterly');
        lstFrequncyType.add('Monthly and Quarterly');
        
        PCRM_CloneOpportunities objCloneOpportunity = new PCRM_CloneOpportunities(lstFrequncyType,ListOfAccount,null );
        
        //60
        objCloneOpportunity.cpuTimeLimit = 20;
        
            System.enqueueJob(objCloneOpportunity);
        
        system.debug('ooo: '+lstFrequncyType.contains('Quarterly'));
        system.assertEquals(true, lstFrequncyType.contains('Quarterly'));
        test.stopTest();
        
    }
    
  
     //account! = null cpu = 80
    static testMethod void validateExecuteWithoutRecurssion() 
    {
        test.startTest(); 
       List<string> lstFrequncyType = NEW List<string>();
       PCRM_Utility utilityClass = NEW PCRM_Utility();
         
       List<Account> ListOfAccount = new  List<Account>();
         ListOfAccount = utilityClass.createAccount(2, 'Customer', 'ZMSH'); //ship to party
         for(Account ObjAccount : ListOfAccount)
         {
            ObjAccount.Sales_Division_Code__c = '69'	;
            ObjAccount.PCRM_Quote_Frequency__c = 'Monthly';
         }
         insert ListOfAccount;
       system.debug('Inserted ACC TEST: '+ListOfAccount);
        
       List<opportunity> ListOfOpportunity = utilityClass.createOpportunity(ListOfAccount,2,'PCRM_PetChems_Acetyls');
       INSERT ListOfOpportunity; 
        
       ListOfAccount = [select id ,Name,recordtypeId,CurrencyIsoCode,(select id,Description,PCRM_Opportunity_Cloned_From__c,Territory2Id,PCRM_Payload__c,PCRM_Mode_of_Transport__c,Name,StageName,ForecastCategoryName,Type,PCRM_Related_Opportunity__c,CurrencyIsoCode,Pricebook2Id,recordtypeId,accountId,PCRM_Quarter__c,PCRM_Quote_Frequency__c from opportunities) from account where Id IN : ListOfAccount ]  ;
        
        lstFrequncyType = NEW   List<string>();
        lstFrequncyType.add('Monthly');
        lstFrequncyType.add('Quarterly');
        lstFrequncyType.add('Monthly and Quarterly');
        
        PCRM_CloneOpportunities objCloneOpportunity = new PCRM_CloneOpportunities(lstFrequncyType,ListOfAccount,null );
        objCloneOpportunity.cpuTimeLimit = 80;
       
        System.enqueueJob(objCloneOpportunity);
        
       
        test.stopTest();
        
    }
    
    
    
    
}